#!/usr/bin/env bash
# =============================================================================
# plan-challenge.sh --- Dynamic dissent engine (CATFISH protocol)
#
# Injects structured adversarial challenge into the planning process.
# Instead of a static devil's advocate (which breeds adversarial fatigue),
# this script detects premature convergence ("collapse") and, only when
# triggered, generates a counterfactual challenge task for subagent dispatch.
#
# Uses outcome-based checks and information isolation --- the challenge
# sees only the plan's conclusions, not the reasoning chain.
#
# Usage:
#   bash scripts/plan-challenge.sh detect   --plan <plan.json>
#   bash scripts/plan-challenge.sh prompt  --plan <plan.json> [--out <file>]
#   bash scripts/plan-challenge.sh reconcile --plan <plan.json> --response <response.json>
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"
CHALLENGE_HISTORY="$RUNTIME_DIR/challenge-history.json"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  detect   --plan <plan.json>              Check plan for collapse signals.
           [--trivial]                     Skip detection (overridden if plan is non-trivial).
                                           Returns challenge_deferred or challenge_required.

  prompt  --plan <plan.json>               Generate structured challenge prompt.
          [--out <file>]                   Write challenge task to file (default: stdout).
                                           Designed for subagent dispatch (fresh context).

  reconcile --plan <plan.json>             Check plan addresses all challenge findings.
            --response <response.json>
            [--out <file>]                 Write reconcile report to file (default: stdout).
                                           Returns PASS or FAIL.

  history --show                           Show challenge history for current session.
         --clear                           Clear challenge history.
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

require_plan() {
  local plan_file="$1"
  if [[ ! -f "$plan_file" ]]; then
    echo "ERROR: plan file not found: $plan_file" >&2
    exit 1
  fi
}

require_response() {
  local resp_file="$1"
  if [[ ! -f "$resp_file" ]]; then
    echo "ERROR: challenge response file not found: $resp_file" >&2
    exit 1
  fi
}

load_json_field() {
  local file="$1" field="$2"
  python3 -c "
import json, sys
with open('$file') as f:
    d = json.load(f)
val = d
for k in '$field'.split('.'):
    val = val.get(k, '')
print(json.dumps(val) if isinstance(val, (dict, list)) else str(val))
"
}

# ---------------------------------------------------------------------------
# Signal: top-level directory spread
# ---------------------------------------------------------------------------
compute_spread() {
  local plan_file="$1"
  python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
files = p.get('files', [])
dirs = set()
for f in files:
    parts = f.strip('/').split('/')
    if len(parts) > 1:
        dirs.add(parts[0])
print(len(dirs))
"
}

# ---------------------------------------------------------------------------
# Signal: verification target quality
# ---------------------------------------------------------------------------
check_vague_verification() {
  local plan_file="$1"
  python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
ver = p.get('verification', '')
vague = ['make it work', 'should pass', 'looks right', 'seems correct',
         'works as expected', 'verify manually', 'check visually',
         'should be fine', 'no testing needed', 'test manually']
for v in vague:
    if v in ver.lower():
        print('true')
        sys.exit(0)
print('false')
"
}

# ---------------------------------------------------------------------------
# Challenge history (prevents iteration fatigue)
# ---------------------------------------------------------------------------
init_history() {
  if [[ ! -f "$CHALLENGE_HISTORY" ]]; then
    echo '{"challenges": []}' > "$CHALLENGE_HISTORY"
  fi
}

task_hash() {
  local plan_file="$1"
  python3 -c "
import json, hashlib, sys
with open('$plan_file') as f:
    p = json.load(f)
# Hash task description + files (not reasoning chain)
key = str(p.get('task', '')) + str(p.get('files', []))
h = hashlib.sha256(key.encode()).hexdigest()[:16]
print(h)
"
}

check_history() {
  local plan_file="$1"
  init_history
  local hash
  hash=$(task_hash "$plan_file")
  python3 -c "
import json, sys
with open('$CHALLENGE_HISTORY') as f:
    h = json.load(f)
for c in h.get('challenges', []):
    if c.get('task_hash') == '$hash':
        print('found')
        sys.exit(0)
print('not_found')
"
}

record_challenge() {
  local plan_file="$1"
  init_history
  local hash
  hash=$(task_hash "$plan_file")
  python3 -c "
import json, sys, time
with open('$CHALLENGE_HISTORY') as f:
    h = json.load(f)
h['challenges'].append({
    'task_hash': '$hash',
    'timestamp': time.time(),
    'session': '$(basename "${SESSION_ID:-default}" 2>/dev/null || echo "default")'
})
with open('$CHALLENGE_HISTORY', 'w') as f:
    json.dump(h, f, indent=2)
"
}

# ---------------------------------------------------------------------------
# Collapse detection
# ---------------------------------------------------------------------------
collapse_signals() {
  local plan_file="$1"
  local trivial="${2:-false}"

  require_plan "$plan_file"

  local steps files spread verif_quality has_risk has_alternatives signals=()

  # S0: --trivial override check
  if [[ "$trivial" == "true" ]]; then
    # Override --trivial if plan is non-trivial
    files=$(python3 -c "import json; print(len(json.load(open('$plan_file')).get('files', [])))" 2>/dev/null || echo 0)
    steps=$(python3 -c "import json; print(len(json.load(open('$plan_file')).get('steps', [])))" 2>/dev/null || echo 0)
    if [[ "$files" -gt 3 || "$steps" -gt 3 ]]; then
      trivial="false"
    fi
    # Check for infrastructure paths
    if python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
infra = ['scripts/hooks/', '.runtime/', 'session-state.json', 'AGENTS.md', 'docs/workflow.md']
files = p.get('files', [])
for i in infra:
    for f in files:
        if f.startswith(i):
            sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
      trivial="false"
    fi
  fi

  # Get plan size for threshold scaling
  steps=$(python3 -c "import json; print(len(json.load(open('$plan_file')).get('steps', [])))" 2>/dev/null || echo 0)
  files=$(python3 -c "import json; print(len(json.load(open('$plan_file')).get('files', [])))" 2>/dev/null || echo 0)

  if [[ "$trivial" == "true" ]]; then
    echo '{"challenge_required": false, "signals": [], "deferred_reason": "trivial_override"}'
    return
  fi

  # S1: Step count > 5 AND spread > 1 top-level directory
  spread=$(compute_spread "$plan_file")
  if [[ "$steps" -gt 5 && "$spread" -gt 1 ]]; then
    signals+=("high_complexity")
  fi

  # S2: Vague verification target
  if [[ "$(check_vague_verification "$plan_file")" == "true" ]]; then
    signals+=("vague_verification")
  fi

  # S3: Missing risk section
  has_risk=$(python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
risks = p.get('risks', p.get('risk', []))
if isinstance(risks, list) and len(risks) == 0:
    print('false')
elif not risks:
    print('false')
else:
    print('true')
" 2>/dev/null || echo "false")
  if [[ "$has_risk" != "true" ]]; then
    signals+=("no_risk_analysis")
  fi

  # S4: Single option presented (no alternatives)
  has_alternatives=$(python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
alts = p.get('alternatives', [])
if isinstance(alts, list) and len(alts) == 0:
    print('false')
elif not alts:
    print('false')
else:
    print('true')
" 2>/dev/null || echo "false")
  if [[ "$has_alternatives" != "true" ]]; then
    signals+=("no_alternatives_considered")
  fi

  # S5: Planning rounds >= 2
  rounds=$(python3 -c "import json; print(json.load(open('$plan_file')).get('planning_rounds', 1))" 2>/dev/null || echo 1)
  if [[ "$rounds" -ge 2 ]]; then
    signals+=("repeated_planning_round")
  fi

  # Check challenge history (prevents iteration fatigue)
  local history_check
  history_check=$(check_history "$plan_file" 2>/dev/null || echo "not_found")
  if [[ "$history_check" == "found" ]]; then
    echo '{"challenge_required": false, "signals": [], "deferred_reason": "already_challenged_this_session"}'
    return
  fi

  # Scale threshold by plan size
  # Small plans (<=3 steps AND <=3 files): need 4+ signals (almost impossible to trigger incorrectly)
  # Medium plans (<=5 steps OR <=5 files): need 3+ signals
  # Large plans (>5 steps OR >5 files): need 2+ signals (current threshold)
  local threshold=2
  if [[ "$steps" -le 3 && "$files" -le 3 ]]; then
    threshold=4
  elif [[ "$steps" -le 5 || "$files" -le 5 ]]; then
    threshold=3
  fi

  if [[ ${#signals[@]} -ge "$threshold" ]]; then
    # Record in history
    record_challenge "$plan_file" 2>/dev/null || true
    # Build signals JSON
    local signals_json="["
    local first=true
    for s in "${signals[@]}"; do
      if [[ "$first" == true ]]; then first=false; else signals_json+=", "; fi
      signals_json+="\"$s\""
    done
    signals_json+="]"
    echo "{\"challenge_required\": true, \"signals\": $signals_json, \"signal_count\": ${#signals[@]}, \"threshold\": $threshold}"
  else
    echo "{\"challenge_required\": false, \"signals\": [], \"deferred_reason\": \"below_threshold\", \"signal_count\": ${#signals[@]}, \"threshold\": $threshold}"
  fi
}

# ---------------------------------------------------------------------------
# Prompt generation
# ---------------------------------------------------------------------------
generate_prompt() {
  local plan_file="$1"
  require_plan "$plan_file"

  local task_context
  task_context=$(python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
ctx = p.get('context', p.get('task', 'no context provided'))
print(ctx[:500])
" 2>/dev/null || echo "no context")

  local plan_steps
  plan_steps=$(python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
steps = p.get('steps', [])
for i, s in enumerate(steps, 1):
    f = s.get('file', s.get('files', []))
    if isinstance(f, list):
        f = ', '.join(f)
    print(f'{i}. {s.get(\"action\", s.get(\"description\", \"\"))}  [{f}]')
" 2>/dev/null || echo "(no steps)")

  local plan_files
  plan_files=$(python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
fl = p.get('files', [])
for f in fl:
    print(f'  - {f}')
" 2>/dev/null || echo "  (none)")

  local plan_verification
  plan_verification=$(python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
print(p.get('verification', 'not specified'))
" 2>/dev/null || echo "not specified")

  cat <<PROMPT
You are a post-mortem investigator. You are reviewing a plan that was executed
and FAILED catastrophically in production.

The plan:

Task: $(python3 -c "import json,sys; print(json.load(open('$plan_file')).get('task','unknown'))" 2>/dev/null)
Context: $task_context

Files to change:
$plan_files

Steps to execute:
$plan_steps

Verification target: $plan_verification

---

Your job: Determine the 3 most likely root causes of failure.

IMPORTANT: The plan has already been executed and has failed. This is a
post-mortem, not a pre-review. "Find flaws" is NOT your job --- you are
explaining why a real failure happened.

For each root cause (up to 3):

## Root Cause N: [title]

- **Scenario**: Describe precisely what went wrong --- the specific conditions,
  timing, or interactions that produced the failure.
- **Evidence**: What evidence would you expect to find in logs, output, test
  failures, or behavior that confirms this root cause?
- **What should have been different**: What change to the plan would have
  prevented this specific failure?
- **Severity**: blocking (this makes the plan's goal unachievable without
  restructuring) OR significant (this creates real risk but is survivable)

Format your response as a JSON object with this schema:
{"findings": [{"title": "...", "scenario": "...", "evidence": "...", "suggestion": "...", "severity": "blocking|significant"}]}
Return ONLY the JSON object, no other text.
PROMPT
}

# ---------------------------------------------------------------------------
# Reconcile checker
# ---------------------------------------------------------------------------
check_reconcile() {
  local plan_file="$1"
  local response_file="$2"

  require_plan "$plan_file"
  require_response "$response_file"

  python3 -c "
import json, sys

with open('$response_file') as f:
    resp = json.load(f)

findings = resp.get('findings', [])
if not findings:
    print('PASS: No findings to address')
    sys.exit(0)

blocking_unaddressed = []
significant_unaddressed = []

for f in findings:
    sev = f.get('severity', 'significant')
    status = f.get('_status', f.get('status', 'unaddressed'))
    title = f.get('title', 'unknown')
    if status == 'addressed':
        continue
    if sev == 'blocking':
        blocking_unaddressed.append(title)
    else:
        significant_unaddressed.append(title)

if blocking_unaddressed:
    for b in blocking_unaddressed:
        print(f'BLOCKING: {b}')
    print('FAIL: Blocking findings must be addressed before commit')
    sys.exit(1)

if significant_unaddressed:
    for s in significant_unaddressed:
        print(f'WARN: {s}')
    print('WARN: Significant findings remain (advisory, not blocking)')
    sys.exit(0)

print('PASS: All findings addressed')
" 2>/dev/null
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------
case "$CMD" in
  detect)
    PLAN_FILE=""
    TRIVIAL=false

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --plan) PLAN_FILE="$2"; shift 2 ;;
        --trivial) TRIVIAL=true; shift ;;
        *) echo "Unknown: $1" >&2; usage; exit 2 ;;
      esac
    done

    if [[ -z "$PLAN_FILE" ]]; then
      echo "ERROR: --plan is required" >&2
      usage
      exit 2
    fi

    collapse_signals "$PLAN_FILE" "$TRIVIAL"
    ;;

  prompt)
    PLAN_FILE=""
    OUTFILE=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --plan) PLAN_FILE="$2"; shift 2 ;;
        --out) OUTFILE="$2"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage; exit 2 ;;
      esac
    done

    if [[ -z "$PLAN_FILE" ]]; then
      echo "ERROR: --plan is required" >&2
      usage
      exit 2
    fi

    if [[ -n "$OUTFILE" ]]; then
      generate_prompt "$PLAN_FILE" > "$OUTFILE"
      echo "Challenge prompt written to: $OUTFILE"
    else
      generate_prompt "$PLAN_FILE"
    fi
    ;;

  reconcile)
    PLAN_FILE=""
    RESPONSE_FILE=""
    OUTFILE=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --plan) PLAN_FILE="$2"; shift 2 ;;
        --response) RESPONSE_FILE="$2"; shift 2 ;;
        --out) OUTFILE="$2"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage; exit 2 ;;
      esac
    done

    if [[ -z "$PLAN_FILE" ]]; then
      echo "ERROR: --plan is required" >&2
      usage
      exit 2
    fi
    if [[ -z "$RESPONSE_FILE" ]]; then
      echo "ERROR: --response is required" >&2
      usage
      exit 2
    fi

    if [[ -n "$OUTFILE" ]]; then
      check_reconcile "$PLAN_FILE" "$RESPONSE_FILE" > "$OUTFILE" 2>&1
      echo "Reconcile report written to: $OUTFILE"
    else
      check_reconcile "$PLAN_FILE" "$RESPONSE_FILE"
    fi
    ;;

  history)
    # Strip leading --
    hist_cmd="${1:-show}"
    hist_cmd="${hist_cmd#--}"
    case "$hist_cmd" in
      show|"")
        init_history
        python3 -c "
import json, sys
with open('$CHALLENGE_HISTORY') as f:
    h = json.load(f)
chs = h.get('challenges', [])
print(f'Challenge history: {len(chs)} entries')
for c in chs[-10:]:
    import time
    ts = time.strftime('%Y-%m-%d %H:%M', time.localtime(c.get('timestamp', 0)))
    print(f'  {ts} | hash={c.get(\"task_hash\",\"?\")}')
"
        ;;
      clear)
        echo '{"challenges": []}' > "$CHALLENGE_HISTORY"
        echo "Challenge history cleared."
        ;;
      *)
        echo "Unknown: ${1:-}" >&2; usage; exit 2 ;;
    esac
    ;;

  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
