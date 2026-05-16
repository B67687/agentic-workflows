#!/usr/bin/env bash
# =============================================================================
# feedback-loop.sh --- Post-verification methodology feedback loop
#
# After verification produces results, checks whether failures indicate a
# methodology gap (the process missed something) or an execution gap (agent
# made a mistake). If methodology gap, logs a meta-learning for future
# methodology updates.
#
# Usage:
#   bash ./scripts/feedback-loop.sh                    # check and log
#   bash ./scripts/feedback-loop.sh --check-only       # only report, don't log
#   bash ./scripts/feedback-loop.sh --status           # show feedback history
# =============================================================================

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$REPO_ROOT/session-state.json"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DECISION_LOG="$RUNTIME_DIR/decision-log.jsonl"
LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"
FEEDBACK_LOG="$RUNTIME_DIR/feedback-loop.jsonl"

MODE="${1:-full}"

# ── Helpers ──

ensure_runtime_dir() {
  mkdir -p "$RUNTIME_DIR"
}

read_verification() {
  python3 -c "
import json
with open('$STATE_FILE') as f:
    d = json.load(f)
ver = d.get('verification', [])
for v in ver:
    print(v)
" 2>/dev/null || echo "no verification data"
}

read_task() {
  python3 -c "
import json
with open('$STATE_FILE') as f:
    d = json.load(f)
t = d.get('currentTask', {})
print(t.get('name', '(none)'))
" 2>/dev/null || echo "(unknown)"
}

# ── Check ──

check_verification() {
  local task
  task=$(read_task)
  local has_failures=false
  local failure_details=""

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if echo "$line" | grep -qi "fail\|error\|blocked\|warn"; then
      has_failures=true
      failure_details="$failure_details  - $line"$'\n'
    fi
  done < <(read_verification)

  if [[ "$has_failures" == "false" ]]; then
    return 0
  fi

  return 1
}

# ── Log feedback ──

log_feedback() {
  local task="$1" gap_type="$2" gap_detail="$3"
  ensure_runtime_dir

  local entry
  entry=$(python3 -c "
import json
entry = {
    'type': 'feedback_loop',
    'task': '''$task''',
    'gap_type': '$gap_type',
    'detail': '''$gap_detail''',
    'timestamp': $(date +%s),
    'id': 'fb-$(date +%H%M)-$RANDOM'
}
print(json.dumps(entry))
" 2>/dev/null || echo "{}")

  if [[ "$entry" != "{}" ]]; then
    echo "$entry" >>"$FEEDBACK_LOG"
    # Also append to .learnings.jsonl
    local content
    content=$(python3 -c "
import json
d = json.loads('''$entry''')
print(f'Feedback loop [{d[\"gap_type\"]}]: {d[\"detail\"][:200]}')
" 2>/dev/null || echo "Feedback recorded")
    echo "$entry" >>"$LEARNINGS_FILE" 2>/dev/null || true
    echo "  Feedback logged: gap_type=$gap_type"
  fi
}

# ── Show status ──

show_status() {
  if [[ ! -f "$FEEDBACK_LOG" ]]; then
    echo "  No feedback history yet."
    return
  fi
  echo "  Feedback History:"
  python3 -c "
import json
with open('$FEEDBACK_LOG') as f:
    for line in f:
        line = line.strip()
        if line:
            try:
                d = json.loads(line)
                print(f\"  [{d.get('gap_type','?')}] {d.get('detail','')[:100]}\")
            except: pass
" 2>/dev/null || echo "  Error reading feedback log"
}

# ── Main ──

main() {
  case "$MODE" in
  --status | -s)
    show_status
    exit 0
    ;;
  --check-only | -c)
    if check_verification; then
      echo "  Feedback: no verification issues found."
      exit 0
    else
      echo "  Feedback: verification FAILURES detected — methodology gap possible."
      exit 1
    fi
    ;;
  esac

  ensure_runtime_dir

  local task
  task=$(read_task)

  if check_verification; then
    echo "  ✓ Feedback: verification passed — no methodology gap detected."
    # Log a clean pass for the record
    log_feedback "$task" "pass" "All verifications passed for task: $task"
    exit 0
  fi

  # Failures detected — log as methodology gap investigation needed
  local failure_summary
  failure_summary=$(read_verification | grep -i "fail\|error\|blocked" | head -3 | tr '\n' '; ')

  echo ""
  echo "  ⚠ FAILURES IN VERIFICATION — methodology gap possible"
  echo ""
  echo "  Task: $task"
  echo "  Failures:"
  read_verification | grep -i "fail\|error\|blocked" | head -5
  echo ""
  echo "  This may be:"
  echo "    1) Execution gap (agent made a mistake the methodology would catch)"
  echo "    2) Methodology gap (the process/gate didn't prevent the failure)"
  echo "    3) Novel situation (current methodology doesn't cover this case)"
  echo ""
  echo "  Logging as methodology gap investigation needed..."

  log_feedback "$task" "methodology_gap_investigation" \
    "Verification failures detected for task '$task'. Failure summary: $failure_summary"

  echo ""
  echo "  To resolve:"
  echo "    1. Review the failing verification in session-state.json"
  echo "    2. Classify as execution gap or methodology gap"
  echo "    3. If methodology gap: update the relevant gate plugin or AGENTS.md section"
  echo "    4. If execution gap: log as learning, continue"
}

main "$@"
