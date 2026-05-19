#!/usr/bin/env bash
# =============================================================================
# triple-debt.sh --- Track cognitive + intent + technical debt (Storey, 2026)
#
# The Triple Debt Model says AI makes cognitive debt (erosion of shared
# understanding) and intent debt (missing externalized rationale) grow faster
# than technical debt. This script measures and trends all three.
#
# Technical debt:   measurable from code quality gates (delegates to quality-gate)
# Cognitive debt:   can the agent explain what changed and why without re-reading?
# Intent debt:      are decisions documented with rationale?
#
# Usage:
#   assess            Evaluate current debt levels for this task
#   history           Show debt trend over time
#   log <type> <level> [--detail "..."]   Manually record a debt entry
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DEBT_LOG="$RUNTIME_DIR/debt-history.jsonl"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  assess            Evaluate current debt levels.
                    Checks: comprehension gap, decision documentation,
                    code quality, plan-vs-execution drift.

  history           Show debt trend over time (last 10 entries).

  log <type> <level> [--detail "..."]
                    Manually record a debt entry.
                    Type: technical|cognitive|intent
                    Level: 0-10 (0=none, 10=critical)
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
gen_id() {
  local ts hash
  ts=$(date +%s)
  hash=$(echo "$ts$RANDOM" | md5sum 2>/dev/null | head -c 6 || echo "$RANDOM")
  echo "debt-$(date +%H%M)-$hash"
}

record_entry() {
  local entry="$1"
  mkdir -p "$RUNTIME_DIR"
  echo "$entry" >> "$DEBT_LOG"
}

# ---------------------------------------------------------------------------
# Assess current debt levels
# ---------------------------------------------------------------------------
assess_debt() {
  echo "=========================================="
  echo "  Triple Debt Assessment"
  echo "=========================================="
  echo ""

  local tid
  tid=$(gen_id)
  local timestamp
  timestamp=$(date +%s)
  local task_name=""
  if [[ -f "$REPO_ROOT/session-state.json" ]]; then
    task_name=$(python3 -c "
import json
with open('$REPO_ROOT/session-state.json') as f:
    s = json.load(f)
print(s.get('currentTask', {}).get('name', 'unknown'))
" 2>/dev/null || echo "unknown")
  fi
  echo "Task: $task_name"
  echo ""

  # --- Technical Debt ---
  echo "--- Technical Debt ---"
  local tech_score=0
  local tech_detail=""

  # Check for TODO/FIXME in staged files
  local todo_count=0
  todo_count=$(git diff --cached -U0 2>/dev/null | grep '^+.*TODO\|^+.*FIXME\|^+.*HACK\|^+.*XXX' | wc -l || echo 0)
  if [[ "$todo_count" -gt 0 ]]; then
    tech_score=$((tech_score + todo_count))
    tech_detail="$todo_count TODO/FIXME/HACK markers introduced"
  fi

  # Check for large changes (>200 lines)
  local added_lines=0
  added_lines=$(git diff --cached --stat 2>/dev/null | tail -1 | grep -oP '\d+(?= insertion)' 2>/dev/null || echo 0)
  if [[ -n "$added_lines" ]] && [[ "$added_lines" -gt 200 ]] 2>/dev/null; then
    tech_score=$((tech_score + 1))
    tech_detail="$tech_detail; $added_lines lines added in single commit"
  fi

  # Cap at 10
  [[ "$tech_score" -gt 10 ]] && tech_score=10
  echo "  Score: $tech_score/10"
  echo "  Detail: ${tech_detail:-clean}"
  echo ""

  # --- Cognitive Debt ---
  echo "--- Cognitive Debt ---"
  local cog_score=0
  local cog_detail=""

  # Check comprehension evidence freshness
  if [[ -f "$RUNTIME_DIR/comprehension-evidence.md" ]]; then
    local evidence_age=$((($(date +%s) - $(stat -c%Y "$RUNTIME_DIR/comprehension-evidence.md" 2>/dev/null || echo 0)) / 3600 ))
    if [[ "$evidence_age" -gt 2 ]]; then
      cog_score=$((cog_score + 2))
      cog_detail="comprehension evidence $evidence_age hours old"
    fi
  else
    cog_score=$((cog_score + 3))
    cog_detail="no comprehension evidence found"
  fi

  # Check decision-log for pending entries
  if [[ -f "$RUNTIME_DIR/decision-log.jsonl" ]]; then
    local pending_decisions
    pending_decisions=$(grep -c 'PENDING_\|status.*pending' "$RUNTIME_DIR/decision-log.jsonl" 2>/dev/null || echo 0)
    if [[ "$pending_decisions" -gt 0 ]]; then
      cog_score=$((cog_score + pending_decisions))
      cog_detail="$cog_detail; $pending_decisions unresolved decisions"
    fi
  fi

  # Check skills loaded without evidence
  local skill_audit="$RUNTIME_DIR/skill-audit.jsonl"
  if [[ -f "$skill_audit" ]] && [[ -f "$RUNTIME_DIR/comprehension-evidence.md" ]]; then
    local skills_loaded
    local evidence_skills
    skills_loaded=$(wc -l < "$skill_audit" 2>/dev/null || echo 0)
    if [[ "$skills_loaded" -gt 3 ]]; then
      cog_score=$((cog_score + 1))
      cog_detail="$cog_detail; $skills_loaded skills loaded this session"
    fi
  fi

  # Cap at 10
  [[ "$cog_score" -gt 10 ]] && cog_score=10
  echo "  Score: $cog_score/10"
  echo "  Detail: ${cog_detail:-clean}"
  echo ""

  # --- Intent Debt ---
  echo "--- Intent Debt ---"
  local intent_score=0
  local intent_detail=""

  # Check commit message quality
  local last_msg
  last_msg=$(git log -1 --format='%s' 2>/dev/null || echo "")
  if [[ ${#last_msg} -lt 10 ]]; then
    intent_score=$((intent_score + 2))
    intent_detail="last commit message is very short"
  fi
  if echo "$last_msg" | grep -qi 'fix\|wip\|temp\|update\|misc\|stuff\|changes'; then
    intent_score=$((intent_score + 1))
    intent_detail="$intent_detail; commit message uses vague verb"
  fi

  # Check for decisions with no rationale
  if [[ -f "$RUNTIME_DIR/decision-log.jsonl" ]]; then
    local undocumented
    undocumented=$(grep -c '"evidence":""\|"evidence":" "' "$RUNTIME_DIR/decision-log.jsonl" 2>/dev/null || echo 0)
    if [[ "$undocumented" -gt 0 ]]; then
      intent_score=$((intent_score + undocumented))
      intent_detail="$intent_detail; $undocumented decisions with no evidence"
    fi
  fi

  # Check session-state.json has whatChanged
  local wc_count=0
  wc_count=$(python3 -c "
import json
with open('$REPO_ROOT/session-state.json') as f:
    s = json.load(f)
print(len(s.get('whatChanged', [])))
" 2>/dev/null || echo 0)
  if [[ "$wc_count" -eq 0 ]]; then
    intent_score=$((intent_score + 2))
    intent_detail="$intent_detail; no whatChanged entries in session-state"
  fi

  # Cap at 10
  [[ "$intent_score" -gt 10 ]] && intent_score=10
  echo "  Score: $intent_score/10"
  echo "  Detail: ${intent_detail:-clean}"
  echo ""

  # --- Summary ---
  local total_score=$((tech_score + cog_score + intent_score))
  echo "--- Summary ---"
  echo "  Technical: $tech_score/10"
  echo "  Cognitive: $cog_score/10"
  echo "  Intent:    $intent_score/10"
  echo "  Total:     $total_score/30"
  echo ""

  local assessment
  if [[ "$total_score" -le 3 ]]; then assessment="low"
  elif [[ "$total_score" -le 8 ]]; then assessment="moderate"
  elif [[ "$total_score" -le 15 ]]; then assessment="elevated"
  else assessment="critical"
  fi
  echo "  Assessment: $assessment"

  # Record
  local entry
  entry=$(cat <<EOF
{"id":"$tid","task":"$task_name","timestamp":$timestamp,"technical":$tech_score,"cognitive":$cog_score,"intent":$intent_score,"total":$total_score,"assessment":"$assessment","tech_detail":"${tech_detail:-}","cog_detail":"${cog_detail:-}","intent_detail":"${intent_detail:-}"}
EOF
)
  record_entry "$entry"
  echo ""
  echo "Recorded: $tid"
}

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
show_history() {
  if [[ ! -f "$DEBT_LOG" ]]; then
    echo "No debt history found."
    exit 0
  fi

  local total
  total=$(wc -l < "$DEBT_LOG" 2>/dev/null || echo 0)
  echo "=== Triple Debt History ($total entries) ==="
  echo ""

  tail -10 "$DEBT_LOG" | python3 -c '
import json, sys, time
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        d = json.loads(line)
        ts = time.strftime("%H:%M", time.localtime(d.get("timestamp", 0)))
        # Support both assess-format and log-format entries
        if "technical" in d:
            t = d.get("technical", "?")
            c = d.get("cognitive", "?")
            i = d.get("intent", "?")
            tot = d.get("total", "?")
            a = d.get("assessment", "?")
            task = d.get("task", "?")[:40]
            print(f"  {ts} | T:{t} C:{c} I:{i} = {tot}/30 {str(a):8s} | {task}")
        else:
            lt = d.get("type", "?")
            lv = d.get("level", "?")
            det = d.get("detail", "")[:30]
            print(f"  {ts} | {lt:9s} {lv:2s}/10         | {det}")
    except Exception:
        pass
'
}

# ---------------------------------------------------------------------------
# Manual log
# ---------------------------------------------------------------------------
log_entry() {
  local dtype="${1:-}"
  local level="${2:-}"
  local detail=""

  shift 2 2>/dev/null || true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --detail) detail="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  if [[ -z "$dtype" || -z "$level" ]]; then
    echo "ERROR: usage: debt.sh log <type> <level>" >&2
    exit 2
  fi

  if ! echo "technical cognitive intent" | grep -q "$dtype"; then
    echo "ERROR: type must be: technical, cognitive, or intent" >&2
    exit 2
  fi

  local did
  did=$(gen_id)
  local timestamp
  timestamp=$(date +%s)

  local entry
  entry=$(cat <<EOF
{"id":"$did","type":"$dtype","level":$level,"detail":"${detail:-}","timestamp":$timestamp}
EOF
)
  record_entry "$entry"
  echo "Logged: $did - $dtype debt at $level/10"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "$CMD" in
  assess)
    assess_debt
    ;;
  history)
    show_history
    ;;
  log)
    log_entry "$@"
    ;;
  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
