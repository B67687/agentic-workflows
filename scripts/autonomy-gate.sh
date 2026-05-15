#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# autonomy-gate.sh --- Risk-adjusted agent autonomy levels with dynamic cascade
#
# Maps task risk + blast radius + context score to an autonomy level.
# Supports static assessment AND dynamic mid-phase adjustment.
#
# Dynamic cascade: error-counter, comprehension-audit, and file-decision
# signals can adjust the autonomy level mid-phase (9Router-inspired pattern).
#
# Autonomy levels:
#   FULL       --- agent implements, tests, commits without human check
#   SUPERVISED --- agent implements, runs verification, presents diff for review
#   RESTRICTED --- agent proposes plan, waits for approval before implementing
#
# Usage:
#   assess [--risk low|medium|high] [--files N] [--cross-module true|false]
#          [--context-score high|low]
#   quick     --- quick assessment from current git + safety state
#   start     --- initial assessment + persist state to .runtime/autonomy-state.json
#   adjust    --- re-evaluate based on accumulated signals (error counter, etc.)
#   status    --- show current autonomy level, signal counters, transition history
# =============================================================================


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$RUNTIME_DIR/autonomy-state.json"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  assess [--risk low|medium|high] [--files N] [--cross-module true|false]
         [--context-score high|low]
         Assess autonomy level from explicit args (static, no state file).

  quick  Quick assessment from current git state + evidence files.
         (static, no state file)

  start [--initial FULL|SUPERVISED|RESTRICTED]
        Initial assessment + persist state. Creates autonomy-state.json.
        --initial overrides auto-detection (use when you know the right level).

  adjust
        Dynamic mid-phase adjustment. Reads current state and accumulated
        signals (error counter, comprehension audit, file decision log).
        Adjusts autonomy level if signals cross thresholds.
        Logs all transitions.

  status
        Show current autonomy level, signal counters, and transition history.
        Exits 0 if state exists, 3 (SKIP) if no state file.

Autonomy levels:
  FULL        --- implement, test, commit without human check
  SUPERVISED  --- verify then show diff for review before commit
  RESTRICTED  --- propose plan, wait for approval before implementing

Dynamic cascade thresholds:
  Error streak >= 2       -> drop one level
  Comprehension fail      -> drop one level
  File decision warn      -> suggest drop (non-blocking)
  Success streak >= 5     -> restore one level
  All gates pass >= 3     -> restore one level
EOF
}

LEVEL_ORDER=("FULL" "SUPERVISED" "RESTRICTED")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

level_index() {
  local level="$1"
  case "$level" in
    FULL) echo 0 ;;
    SUPERVISED) echo 1 ;;
    RESTRICTED) echo 2 ;;
    *) echo -1 ;;
  esac
}

level_drop() {
  local current="$1"
  local idx
  idx=$(level_index "$current")
  if [[ "$idx" -ge 2 ]]; then
    echo "RESTRICTED"
  elif [[ "$idx" -ge 0 ]]; then
    echo "${LEVEL_ORDER[$((idx + 1))]}"
  else
    echo "RESTRICTED"
  fi
}

level_raise() {
  local current="$1"
  local idx
  idx=$(level_index "$current")
  if [[ "$idx" -le 0 ]]; then
    echo "FULL"
  elif [[ "$idx" -le 2 ]]; then
    echo "${LEVEL_ORDER[$((idx - 1))]}"
  else
    echo "FULL"
  fi
}

load_state() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "{}"
    return
  fi
  python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    try:
        print(json.dumps(json.load(f)))
    except:
        print('{}')
" 2>/dev/null || echo "{}"
}

save_state() {
  local state="$1"
  mkdir -p "$RUNTIME_DIR"
  echo "$state" > "$STATE_FILE"
}

# ---------------------------------------------------------------------------
# Decision matrix (shared between assess and start)
# ---------------------------------------------------------------------------
decide_autonomy() {
  local risk="$1" blast_radius="$2" context_score="$3"
  local files="$4" cross_module="$5"

  if [[ "$risk" == "high" ]]; then
    echo "RESTRICTED|high risk --- human approval required before any edit|true|false"
  elif [[ "$risk" == "medium" && "$blast_radius" == "large" ]]; then
    echo "RESTRICTED|medium risk with large blast radius --- human approval required|true|false"
  elif [[ "$risk" == "medium" ]]; then
    echo "SUPERVISED|medium risk --- implement then present diff for review|false|true"
  elif [[ "$blast_radius" == "large" ]]; then
    echo "SUPERVISED|small risk but large blast radius --- verify before commit|false|true"
  elif [[ "$context_score" == "low" ]]; then
    echo "SUPERVISED|low context confidence --- verify before commit|false|true"
  else
    echo "FULL|low risk, small blast radius, good context --- full autonomy|false|false"
  fi
}

# ---------------------------------------------------------------------------
# Read signals for dynamic adjustment
# ---------------------------------------------------------------------------
read_signals() {
  local error_streak=0
  local comprehension_fails=0
  local file_decision_warns=0
  local success_streak=0
  local all_gates_pass_streak=0

  # Signal 1: error-counter --- count recent increments (last hour)
  local error_dir="$RUNTIME_DIR/error-counter/decisions"
  if [[ -d "$error_dir" ]]; then
    local recent_errors=0
    local now
    now=$(date +%s)
    shopt -s nullglob 2>/dev/null || true
    local error_files
    error_files=("$error_dir"/*.json)
    shopt -u nullglob 2>/dev/null || true
    for f in "${error_files[@]}"; do
      [[ -f "$f" ]] || continue
      local mtime
      mtime=$(stat -c%Y "$f" 2>/dev/null || echo 0)
      if [[ $((now - mtime)) -lt 3600 ]]; then
        recent_errors=$((recent_errors + 1))
      fi
    done
    error_streak=$recent_errors
  fi

  # Signal 2: comprehension-audit --- count recent fails/warns
  if [[ -f "$RUNTIME_DIR/comprehension-audit.jsonl" ]]; then
    local recent_fails
    recent_fails=$(grep -c '"result":"fail"\|"result":"warn"' "$RUNTIME_DIR/comprehension-audit.jsonl" 2>/dev/null || echo 0)
    comprehension_fails=$recent_fails
  fi

  # Signal 3: file-decision log --- recent warns
  if [[ -f "$RUNTIME_DIR/file-decisions.jsonl" ]]; then
    local recent_warns
    recent_warns=$(grep -c '"decision":"split"\|"decision":"restructure"' "$RUNTIME_DIR/file-decisions.jsonl" 2>/dev/null || echo 0)
    file_decision_warns=$recent_warns
  fi

  echo "{\"error_streak\":$error_streak,\"comprehension_fails\":$comprehension_fails,\"file_decision_warns\":$file_decision_warns,\"success_streak\":$success_streak,\"all_gates_pass_streak\":$all_gates_pass_streak}"
}

# ---------------------------------------------------------------------------
# Print autonomy level output (shared by assess, start, adjust)
# ---------------------------------------------------------------------------
print_autonomy() {
  local autonomy="$1" reason="$2" risk="$3" blast_radius="$4" context_score="$5"
  local files="$6" cross_module="$7" source="$8"
  local human_gate=false
  local verify_before_commit=false

  if echo "$reason" | grep -q "human approval"; then
    human_gate=true
  fi
  if echo "$reason" | grep -q "verify before commit\|present diff"; then
    verify_before_commit=true
  fi

  echo "=========================================="
  echo "  Autonomy Gate"
  echo "=========================================="
  echo ""
  echo "  Risk:         $risk"
  echo "  Blast radius: $blast_radius ($files files, cross-module: $cross_module)"
  echo "  Context:      $context_score"
  echo ""
  echo "  Autonomy:     $autonomy"
  echo "  Reason:       $reason"
  echo "  Source:       $source"
  echo ""
  echo "  --- Agent May ---"
  case "$autonomy" in
    FULL)
      echo "  ✓ Implement changes"
      echo "  ✓ Run tests"
      echo "  ✓ Commit and push"
      echo "  No human gates required"
      ;;
    SUPERVISED)
      echo "  ✓ Implement changes"
      echo "  ✓ Run tests"
      echo "  ✗ Commit --- must present diff for review first"
      echo "  After review: commit with checkpoint-commit.sh"
      if [[ "$human_gate" == true ]]; then
        echo ""
        echo "  Human approval may be required for specific operations"
      fi
      ;;
    RESTRICTED)
      echo "  ✓ Propose implementation plan"
      echo "  ✗ Edit any file --- human approval required"
      echo "  After approval: autonomy upgrades to SUPERVISED for execution"
      echo ""
      echo "  To request approval:"
      echo "    bash $SCRIPT_DIR/a2h-contact.sh approve \"implement: <task>\""
      ;;
  esac
  echo ""
}

# ---------------------------------------------------------------------------
# Assess (static, no state)
# ---------------------------------------------------------------------------
compute_autonomy() {
  local risk="$1" files="$2" cross_module="$3" context_score="$4"

  local blast_radius="small"
  if [[ "$files" -gt 5 ]] || [[ "$cross_module" == "true" ]]; then
    blast_radius="large"
  elif [[ "$files" -gt 2 ]]; then
    blast_radius="medium"
  fi

  local result
  result=$(decide_autonomy "$risk" "$blast_radius" "$context_score" "$files" "$cross_module")
  local autonomy reason
  IFS='|' read -r autonomy reason _ _ <<< "$result"

  # Return pipe-separated: level|reason|blast_radius (for $(...) callers)
  # Callers print via print_autonomy separately
  echo "$autonomy|$reason|$blast_radius"
}

# Print autonomy output and exit with appropriate code
print_and_exit() {
  local autonomy="$1" risk="$2" files="$3" cross_module="$4" context_score="$5" source="$6"
  local blast_radius="$7"
  local reason="$8"

  print_autonomy "$autonomy" "$reason" "$risk" "$blast_radius" "$context_score" \
    "$files" "$cross_module" "$source"

  case "$autonomy" in
    FULL) exit 0 ;;
    SUPERVISED) exit 1 ;;
    RESTRICTED) exit 2 ;;
  esac
}

assess() {
  local risk="medium"
  local files=0
  local cross_module="false"
  local context_score="medium"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --risk) risk="$2"; shift 2 ;;
      --files) files="$2"; shift 2 ;;
      --cross-module) cross_module="$2"; shift 2 ;;
      --context-score) context_score="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  local result
  result=$(compute_autonomy "$risk" "$files" "$cross_module" "$context_score")
  local autonomy reason blast_radius
  IFS='|' read -r autonomy reason blast_radius <<< "$result"

  print_and_exit "$autonomy" "$risk" "$files" "$cross_module" "$context_score" "static" "$blast_radius" "$reason"
}

# ---------------------------------------------------------------------------
# Quick assessment (static, no state)
# ---------------------------------------------------------------------------
quick_assess() {
  local risk="low"
  local files=0
  local cross_module="false"
  local context_score="medium"

  # Detect risk from staged/in-progress file paths
  local changed_files
  changed_files=$(git diff --name-only 2>/dev/null || true)
  if [[ -z "$changed_files" ]]; then
    changed_files=$(git diff --cached --name-only 2>/dev/null || true)
  fi

  if echo "$changed_files" | grep -qE 'scripts/hooks/|auth|security|production|secret|credential'; then
    risk="high"
  elif echo "$changed_files" | grep -qE 'scripts/|core/|config|api|database|migration'; then
    risk="medium"
  elif [[ -z "$changed_files" ]]; then
    risk="low"
  fi

  # Count files and detect cross-module
  files=$(echo "$changed_files" | grep -c . 2>/dev/null || echo 0)
  if [[ "$files" -gt 0 ]]; then
    local top_dirs
    top_dirs=$(echo "$changed_files" | grep -oP '^[^/]+' | sort -u | wc -l || echo 1)
    if [[ "$top_dirs" -gt 1 ]]; then
      cross_module="true"
    fi
  fi

  # Context score from comprehension evidence freshness
  if [[ -f "$RUNTIME_DIR/comprehension-evidence.md" ]]; then
    local evidence_age
    evidence_age=$((($(date +%s) - $(stat -c%Y "$RUNTIME_DIR/comprehension-evidence.md" 2>/dev/null || echo 0)) / 3600 ))
    if [[ "$evidence_age" -gt 4 ]]; then
      context_score="low"
    fi
  else
    context_score="low"
  fi

  # If there's a CATFISH challenge that failed reconcile, context is definitely low
  if [[ -f "$RUNTIME_DIR/challenge-response.json" ]]; then
    local reconcile_status
    reconcile_status=$(grep -c '"status":"addressed"' "$RUNTIME_DIR/challenge-response.json" 2>/dev/null || echo 0)
    if [[ "$reconcile_status" -eq 0 ]]; then
      context_score="low"
    fi
  fi

  local result
  result=$(compute_autonomy "$risk" "$files" "$cross_module" "$context_score")
  local autonomy reason blast_radius
  IFS='|' read -r autonomy reason blast_radius <<< "$result"

  print_and_exit "$autonomy" "$risk" "$files" "$cross_module" "$context_score" "quick" "$blast_radius" "$reason"
}

# ---------------------------------------------------------------------------
# Start (initial assessment + persist state)
# ---------------------------------------------------------------------------
cmd_start() {
  local initial_override=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --initial) initial_override="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  # Detect state
  local risk="low" files=0 cross_module="false" context_score="medium"
  local changed_files
  changed_files=$(git diff --name-only 2>/dev/null || true)
  if [[ -z "$changed_files" ]]; then
    changed_files=$(git diff --cached --name-only 2>/dev/null || true)
  fi
  if echo "$changed_files" | grep -qE 'scripts/hooks/|auth|security|production|secret|credential'; then
    risk="high"
  elif echo "$changed_files" | grep -qE 'scripts/|core/|config|api|database|migration'; then
    risk="medium"
  fi
  files=$(echo "$changed_files" | grep -c . 2>/dev/null || echo 0)
  if [[ "$files" -gt 0 ]]; then
    local top_dirs
    top_dirs=$(echo "$changed_files" | grep -oP '^[^/]+' | sort -u | wc -l || echo 1)
    [[ "$top_dirs" -gt 1 ]] && cross_module="true"
  fi
  if [[ -f "$RUNTIME_DIR/comprehension-evidence.md" ]]; then
    local evidence_age
    evidence_age=$((($(date +%s) - $(stat -c%Y "$RUNTIME_DIR/comprehension-evidence.md" 2>/dev/null || echo 0)) / 3600 ))
    [[ "$evidence_age" -gt 4 ]] && context_score="low"
  else
    context_score="low"
  fi

  # Compute or override autonomy level
  local autonomy reason blast_radius_fmt
  if [[ -n "$initial_override" ]]; then
    case "$initial_override" in
      FULL|SUPERVISED|RESTRICTED) autonomy="$initial_override" ;;
      *) echo "ERROR: invalid level: $initial_override" >&2; exit 2 ;;
    esac
    reason="explicit override: $initial_override"
    blast_radius_fmt="small"
    [[ "$files" -gt 5 || "$cross_module" == "true" ]] && blast_radius_fmt="large"
    [[ "$files" -gt 2 && "$blast_radius_fmt" != "large" ]] && blast_radius_fmt="medium"
  else
    local computed_blast_radius="small"
    [[ "$files" -gt 5 || "$cross_module" == "true" ]] && computed_blast_radius="large"
    [[ "$files" -gt 2 && "$computed_blast_radius" != "large" ]] && computed_blast_radius="medium"
    local result
    result=$(decide_autonomy "$risk" "$computed_blast_radius" "$context_score" "$files" "$cross_module")
    IFS='|' read -r autonomy reason _ _ <<< "$result"
    blast_radius_fmt="$computed_blast_radius"
  fi

  print_autonomy "$autonomy" "$reason" "$risk" "$blast_radius_fmt" "$context_score" \
    "$files" "$cross_module" "start"

  # Build state
  local signals
  signals=$(read_signals)
  local now_epoch
  now_epoch=$(date +%s)
  local state
  state=$(python3 -c "
import json
s = {
    'level': '$autonomy',
    'initial_level': '$autonomy',
    'history': [{
        'previous': None,
        'new': '$autonomy',
        'reason': '$reason',
        'source': 'start',
        'timestamp': $now_epoch
    }],
    'signals': $signals,
    'context': {
        'risk': '$risk',
        'blast_radius': '$blast_radius_fmt',
        'files': $files,
        'cross_module': '$cross_module',
        'context_score': '$context_score'
    }
}
print(json.dumps(s, indent=2))
" 2>/dev/null)

  save_state "$state"
  echo "  State saved to: .runtime/autonomy-state.json"
  echo ""

  case "$autonomy" in
    FULL) exit 0 ;;
    SUPERVISED) exit 1 ;;
    RESTRICTED) exit 2 ;;
  esac
}

# ---------------------------------------------------------------------------
# Adjust (dynamic mid-phase adjustment)
# ---------------------------------------------------------------------------
cmd_adjust() {
  local state
  state=$(load_state)
  local level
  level=$(echo "$state" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('level','SUPERVISED'))" 2>/dev/null || echo "SUPERVISED")

  if [[ "$level" == "{}" ]] || [[ "$level" == "" ]]; then
    echo "  SKIP   No autonomy state to adjust (run 'start' first)"
    echo "         bash scripts/autonomy-gate.sh start"
    exit 3
  fi

  local signals
  signals=$(read_signals)
  local error_streak
  error_streak=$(echo "$signals" | python3 -c "import json,sys; print(json.load(sys.stdin)['error_streak'])" 2>/dev/null || echo 0)
  local comprehension_fails
  comprehension_fails=$(echo "$signals" | python3 -c "import json,sys; print(json.load(sys.stdin)['comprehension_fails'])" 2>/dev/null || echo 0)
  local file_decision_warns
  file_decision_warns=$(echo "$signals" | python3 -c "import json,sys; print(json.load(sys.stdin)['file_decision_warns'])" 2>/dev/null || echo 0)

  local new_level="$level"
  local adjustments=""

  # Cascade down: check for downgrade signals
  if [[ "$error_streak" -ge 2 ]]; then
    local dropped
    dropped=$(level_drop "$new_level")
    if [[ "$dropped" != "$new_level" ]]; then
      adjustments="$adjustments|error_streak=$error_streak (>=2): drop to $dropped"
      new_level="$dropped"
    fi
  fi

  if [[ "$comprehension_fails" -ge 1 ]]; then
    local dropped
    dropped=$(level_drop "$new_level")
    if [[ "$dropped" != "$new_level" ]]; then
      adjustments="$adjustments|comprehension_fails=$comprehension_fails (>=1): drop to $dropped"
      new_level="$dropped"
    fi
  fi

  # Cascade up: check for restore signals
  # Success streak from clean gates since last transition
  local latest_source
  latest_source=$(echo "$state" | python3 -c "import json,sys; d=json.load(sys.stdin); h=d.get('history',[]); print(h[-1].get('source','') if h else '')" 2>/dev/null || echo "")

  if [[ "$error_streak" -eq 0 && "$comprehension_fails" -eq 0 && "$file_decision_warns" -eq 0 ]]; then
    if [[ "$latest_source" == "adjust" ]]; then
      # No new signals since last adjustment --- strengthen success streak
      local old_success
      old_success=$(echo "$state" | python3 -c "import json,sys; d=json.load(sys.stdin); return d.get('signals',{}).get('success_streak',0)" 2>/dev/null || echo 0)
      local new_success=$((old_success + 1))
      if [[ "$new_success" -ge 5 ]]; then
        local raised
        raised=$(level_raise "$new_level")
        if [[ "$raised" != "$new_level" ]]; then
          adjustments="$adjustments|success_streak=$new_success (>=5): raise to $raised"
          new_level="$raised"
        fi
      fi
    fi
  fi

  # Build updated state
  local now_epoch
  now_epoch=$(date +%s)
  local updated_state

  if [[ -n "$adjustments" ]]; then
    # Strip leading |
    adjustments="${adjustments#|}"
    echo "=========================================="
    echo "  Autonomy Adjustment"
    echo "=========================================="
    echo ""
    echo "  Previous: $level"
    echo "  New:      $new_level"
    echo "  Reasons:  $adjustments"
    echo ""

    updated_state=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
signals = $signals
# Merge signal counters (don't reset, let them accumulate)
old_signals = s.get('signals', {})
# Update error streak, comprehension fails from fresh read
old_signals['error_streak'] = signals['error_streak']
old_signals['comprehension_fails'] = signals['comprehension_fails']
old_signals['file_decision_warns'] = signals['file_decision_warns']
# Update success streak: reset on down-adjust, increment on no-signal
if '$new_level' != '$level' and 'drop' in '$adjustments':
    old_signals['success_streak'] = 0
elif '$new_level' == '$level' and signals['error_streak'] == 0 and signals['comprehension_fails'] == 0:
    old_signals['success_streak'] = old_signals.get('success_streak', 0) + 1
if '$new_level' != '$level' and 'raise' in '$adjustments':
    old_signals['success_streak'] = 0
s['signals'] = old_signals
s['level'] = '$new_level'
if 'history' not in s:
    s['history'] = []
s['history'].append({
    'previous': '$level',
    'new': '$new_level',
    'reason': '$adjustments',
    'source': 'adjust',
    'timestamp': $now_epoch
})
print(json.dumps(s, indent=2))
" 2>/dev/null)

    echo "  --- Agent May ---"
    case "$new_level" in
      FULL)
        echo "  ✓ Implement changes"
        echo "  ✓ Run tests"
        echo "  ✓ Commit and push" ;;
      SUPERVISED)
        echo "  ✓ Implement changes"
        echo "  ✓ Run tests"
        echo "  ✗ Commit --- must present diff for review first" ;;
      RESTRICTED)
        echo "  ✓ Propose implementation plan"
        echo "  ✗ Edit any file --- human approval required" ;;
    esac
    echo ""
  else
    # No adjustment needed
    echo "  Autonomy stable: $level (no signal crosses threshold)"
    echo "    error_streak=$error_streak (threshold: 2)"
    echo "    comprehension_fails=$comprehension_fails (threshold: 1)"
    echo "    file_decision_warns=$file_decision_warns (threshold: 1, non-blocking)"
    updated_state=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
signals = $signals
old_signals = s.get('signals', {})
old_signals['error_streak'] = signals['error_streak']
old_signals['comprehension_fails'] = signals['comprehension_fails']
old_signals['file_decision_warns'] = signals['file_decision_warns']
if signals['error_streak'] == 0 and signals['comprehension_fails'] == 0:
    old_signals['success_streak'] = old_signals.get('success_streak', 0) + 1
s['signals'] = old_signals
print(json.dumps(s, indent=2))
" 2>/dev/null)
  fi

  save_state "$updated_state"

  case "$new_level" in
    FULL) exit 0 ;;
    SUPERVISED) exit 1 ;;
    RESTRICTED) exit 2 ;;
  esac
}

# ---------------------------------------------------------------------------
# Status (show current state)
# ---------------------------------------------------------------------------
cmd_status() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "  SKIP   No autonomy state found"
    echo "         Run: bash scripts/autonomy-gate.sh start"
    exit 3
  fi

  python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    s = json.load(f)

level = s.get('level', 'unknown')
initial = s.get('initial_level', level)
history = s.get('history', [])
signals = s.get('signals', {})
ctx = s.get('context', {})

print('==========================================')
print('  Autonomy Status')
print('==========================================')
print('')
print(f'  Level:        {level}')
print(f'  Initial:      {initial}')
print(f'  Transitions:  {len(history)}')
print('')
print('  --- Context ---')
print(f'  Risk:         {ctx.get(\"risk\", \"?\")}')
print(f'  Blast radius: {ctx.get(\"blast_radius\", \"?\")}')
print(f'  Files:        {ctx.get(\"files\", \"?\")}')
print(f'  Cross-module: {ctx.get(\"cross_module\", \"?\")}')
print(f'  Context score:{ctx.get(\"context_score\", \"?\")}')
print('')
print('  --- Signals ---')
for k, v in signals.items():
    print(f'  {k}: {v}')
print(f'')
print('  --- Recent Transitions ---')
for entry in history[-5:]:
    prev = entry.get('previous', '?') or '---'
    new = entry.get('new', '?')
    reason = entry.get('reason', '?')
    source = entry.get('source', '?')
    print(f'  {prev} -> {new}  [{source}] {reason}')
print('')
" 2>/dev/null || echo "  Could not parse state file"

  exit 0
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "$CMD" in
  assess)
    assess "$@"
    ;;
  quick)
    quick_assess
    ;;
  start)
    cmd_start "$@"
    ;;
  adjust)
    cmd_adjust
    ;;
  status)
    cmd_status
    ;;
  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
