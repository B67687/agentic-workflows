#!/bin/bash
# safety-escalate.sh --- Retry logic, human escalation, and rollback.
# Part of the autonomous runtime fork.
#
# Handles the escalation chain: retry (2x with context) -> human -> abort.
# Each step is checked by safety-guard.sh before execution.
#
# Usage:
#   bash ./scripts/safety-escalate.sh retry <pipeline-id> <task-id> [--max-attempts <N>]
#   bash ./scripts/safety-escalate.sh escalate <pipeline-id> <task-id> <reason>
#   bash ./scripts/safety-escalate.sh rollback <pipeline-id> [--message <msg>]
#   bash ./scripts/safety-escalate.sh budget-check <pipeline-id>
#   bash ./scripts/safety-escalate.sh status <pipeline-id>

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
PIPELINE_DIR="$REPO_ROOT/.runtime/pipeline"

CMD="${1:-help}"

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
show_help() {
  echo "Safety Escalation Chain --- Retry, escalate, rollback"
  echo ""
  echo "Usage:"
  echo "  retry    <id> <task> [--max-attempts N]        Retry failed task with progressive context"
  echo "  escalate <id> <task> <reason>                  Escalate to human after retries exhausted"
  echo "  rollback <id> [--message <msg>]                Git rollback on catastrophic failure"
  echo "  budget-check <id>                              Check budget (tasks, loops, drift)"
  echo "  status   <id>                                   Show escalation state for pipeline"
  echo ""
  echo "Examples:"
  echo "  bash scripts/safety-escalate.sh retry pipe-001 3 --max-attempts 3"
  echo "  bash scripts/safety-escalate.sh escalate pipe-001 5 'API key not found'"
  echo "  bash scripts/safety-escalate.sh rollback pipe-001 --message 'Auth refactor broke tests'"
  echo "  bash scripts/safety-escalate.sh budget-check pipe-001"
}

# ---------------------------------------------------------------------------
# Load pipeline JSON helper
# ---------------------------------------------------------------------------
load_pipeline() {
  if [ ! -f "$PIPELINE_DIR/$PIPELINE_ID.json" ]; then
    echo "Pipeline not found: $PIPELINE_ID"
    exit 1
  fi
  cat "$PIPELINE_DIR/$PIPELINE_ID.json"
}

save_pipeline() {
  local data="$1"
  echo "$data" > "$PIPELINE_DIR/$PIPELINE_ID.json"
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------
case "$CMD" in

  retry)
    PIPELINE_ID="${2:-}"
    TASK_ID="${3:-}"
    shift 3 || true

    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    [ -z "$TASK_ID" ] && show_help && exit 1

    MAX_ATTEMPTS=3
    while [ $# -gt 0 ]; do
      case "$1" in
        --max-attempts) MAX_ATTEMPTS="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    PJ=$(load_pipeline)
    TASK=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
for t in p.get('tasks', []):
    if t.get('id') == $TASK_ID:
        print(json.dumps(t))
        break
" 2>/dev/null)

    if [ -z "$TASK" ] || [ "$TASK" = "null" ]; then
      echo "Task $TASK_ID not found."
      exit 1
    fi

    ATTEMPTS=$(echo "$TASK" | python3 -c "import json,sys; print(json.load(sys.stdin).get('attempts', 0))" 2>/dev/null || echo "0")
    ATTEMPTS=$((ATTEMPTS + 1))

    if [ "$ATTEMPTS" -gt "$MAX_ATTEMPTS" ]; then
      echo "RETRIES EXHAUSTED: Task $TASK_ID failed after $MAX_ATTEMPTS attempts."
      echo "  Escalate via: bash scripts/safety-escalate.sh escalate $PIPELINE_ID $TASK_ID 'Retries exhausted'"
      exit 2
    fi

    # Mark task as pending for retry with modified context
    # Append retry info to the task description for context
    RETRY_NOTES=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
for t in p.get('tasks', []):
    if t.get('id') == $TASK_ID:
        notes = t.get('retry_notes', [])
        break
print(json.dumps(notes))
" 2>/dev/null || echo "[]")

    # Update task: increment attempts, reset status, add retry context
    UPDATED=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
for t in p.get('tasks', []):
    if t.get('id') == $TASK_ID:
        t['status'] = 'pending'
        t['attempts'] = $ATTEMPTS
        if 'retry_notes' not in t:
            t['retry_notes'] = []
        t['retry_notes'].append({
            'attempt': $ATTEMPTS,
            'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
            'context': 'Retry $ATTEMPTS/$MAX_ATTEMPTS'
        })
        break
print(json.dumps(p, indent=2))
")
    save_pipeline "$UPDATED"

    echo "RETRY $ATTEMPTS/$MAX_ATTEMPTS: Task $TASK_ID reset to pending"
    echo "  Next: bash scripts/pipeline-run.sh next $PIPELINE_ID"
    ;;

  escalate)
    PIPELINE_ID="${2:-}"
    TASK_ID="${3:-}"
    REASON="${4:-}"
    shift 4 || true

    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    [ -z "$TASK_ID" ] && echo "Reason required: escalate <id> <task> <reason>" && exit 1
    [ -z "$REASON" ] && echo "Reason required: escalate <id> <task> <reason>" && exit 1

    PJ=$(load_pipeline)

    UPDATED=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
p['status'] = 'escalated'
for t in p.get('tasks', []):
    if t.get('id') == $TASK_ID:
        t['status'] = 'escalated'
        if 'escalations' not in t:
            t['escalations'] = []
        t['escalations'].append({
            'reason': '$REASON',
            'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
        })
        break
print(json.dumps(p, indent=2))
")
    save_pipeline "$UPDATED"

    echo "ESCALATED: Pipeline $PIPELINE_ID, Task $TASK_ID"
    echo "  Reason: $REASON"
    echo "  Action required:"
    echo "    1. Review: bash scripts/pipeline-run.sh status $PIPELINE_ID"
    echo "    2. Approve or modify: bash scripts/pipeline-run.sh update $PIPELINE_ID $TASK_ID done|failed"
    echo "    3. Resume: bash scripts/pipeline-run.sh next $PIPELINE_ID"
    echo "    4. Rollback: bash scripts/safety-escalate.sh rollback $PIPELINE_ID --message '$REASON'"
    ;;

  rollback)
    PIPELINE_ID="${2:-}"
    shift 2 || true
    [ -z "$PIPELINE_ID" ] && show_help && exit 1

    ROLLBACK_MSG="Autonomous rollback"
    while [ $# -gt 0 ]; do
      case "$1" in
        --message) ROLLBACK_MSG="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    PJ=$(load_pipeline)

    # Check if git is clean enough to rollback
    if ! rtk diff --quiet 2>/dev/null; then
      # Stash any uncommitted changes
      rtk stash 2>/dev/null || true
    fi

    # Git rollback: checkout main branch files that were changed
    MAIN_BRANCH="main"
    if rtk branch --list main 2>/dev/null | grep -q main; then
      MAIN_BRANCH="main"
    elif rtk branch --list master 2>/dev/null | grep -q master; then
      MAIN_BRANCH="master"
    fi

    echo "ROLLBACK: Restoring from $MAIN_BRANCH"
    echo "  Reason: $ROLLBACK_MSG"
    echo ""

    # Get list of files changed by this pipeline
    CHANGED_FILES=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
files = set()
for t in p.get('tasks', []):
    f = t.get('files_touched', [])
    if isinstance(f, list):
        for fn in f:
            files.add(fn)
print('\n'.join(sorted(files)) if files else '')
" 2>/dev/null)

    if [ -n "$CHANGED_FILES" ]; then
      echo "  Files to restore:"
      echo "$CHANGED_FILES" | while IFS= read -r f; do
        echo "    $f"
        rtk checkout "$MAIN_BRANCH" -- "$f" 2>/dev/null || echo "    (not found in $MAIN_BRANCH)"
      done
    else
      echo "  No tracked files to restore."
    fi

    # Mark pipeline as rolled back
    UPDATED=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
p['status'] = 'rolled_back'
if 'rollbacks' not in p:
    p['rollbacks'] = []
p['rollbacks'].append({
    'message': '$ROLLBACK_MSG',
    'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
})
print(json.dumps(p, indent=2))
")
    save_pipeline "$UPDATED"

    echo ""
    echo "Rollback complete. Pipeline $PIPELINE_ID marked as rolled_back."
    ;;

  budget-check)
    PIPELINE_ID="${2:-}"
    [ -z "$PIPELINE_ID" ] && show_help && exit 1

    PJ=$(load_pipeline)
    SAFETY=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
s = p.get('safety', {})
print(json.dumps(s))
" 2>/dev/null || echo "{}")

    MAX_TASKS=$(echo "$SAFETY" | python3 -c "import json,sys; v=json.load(sys.stdin).get('max_tasks'); print(v if v is not None else 'unlimited')" 2>/dev/null || echo "unlimited")
    MAX_LOOPS=$(echo "$SAFETY" | python3 -c "import json,sys; v=json.load(sys.stdin).get('max_loops'); print(v if v is not None else 'unlimited')" 2>/dev/null || echo "unlimited")

    TASK_COUNT=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
tasks = p.get('tasks', [])
done = len([t for t in tasks if t.get('status') in ('done', 'failed')])
print(f'{done}/{len(tasks)}')
" 2>/dev/null)

    TOTAL_ATTEMPTS=$(echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
total = sum(t.get('attempts', 1) for t in p.get('tasks', []))
print(total)
" 2>/dev/null || echo "0")

    echo "Budget check: $PIPELINE_ID"
    echo "  Tasks completed: $TASK_COUNT"
    echo "  Max tasks:       $MAX_TASKS"
    echo "  Total attempts:  $TOTAL_ATTEMPTS"
    echo "  Max loops:       $MAX_LOOPS"

    # Check task budget
    if [ "$MAX_TASKS" != "unlimited" ]; then
      DONE=$(echo "$TASK_COUNT" | cut -d/ -f1)
      if [ "$DONE" -ge "$MAX_TASKS" ]; then
        echo "  BUDGET EXCEEDED: Tasks ($DONE) >= max ($MAX_TASKS)"
        echo "  Suggestion:"
        echo "    bash scripts/safety-escalate.sh rollback $PIPELINE_ID --message 'Budget exceeded'"
        exit 1
      fi
    fi

    # Check loop budget
    if [ "$MAX_LOOPS" != "unlimited" ]; then
      if [ "$TOTAL_ATTEMPTS" -ge "$MAX_LOOPS" ]; then
        echo "  BUDGET EXCEEDED: Total agent calls ($TOTAL_ATTEMPTS) >= max loops ($MAX_LOOPS)"
        exit 2
      fi
    fi

    echo "  Budget OK"
    ;;

  status)
    PIPELINE_ID="${2:-}"
    [ -z "$PIPELINE_ID" ] && show_help && exit 1

    PJ=$(load_pipeline)
    echo "$PJ" | python3 -c "
import json, sys
p = json.load(sys.stdin)
print(f'Escalation status: {p.get(\"pipeline_id\", \"?\")}')
print(f'  Pipeline status:   {p.get(\"status\", \"?\")}')
s = p.get('safety', {})
print(f'  Allowed paths:     {s.get(\"allowed_paths\", [])}')
print(f'  Blocked paths:     {s.get(\"blocked_paths\", [])}')
print(f'  Human gates:       {s.get(\"human_gates\", [])}')
print()
for t in p.get('tasks', []):
    att = t.get('attempts', 1)
    notes = t.get('retry_notes', [])
    esc = t.get('escalations', [])
    if att > 1 or esc:
        print(f'  Task {t[\"id\"]}: {t.get(\"status\", \"?\")} (attempts={att}, retries={len(notes)}, escalations={len(esc)})')
rollbacks = p.get('rollbacks', [])
if rollbacks:
    print(f'  Rollbacks: {len(rollbacks)}')
    for r in rollbacks:
        print(f'    - {r.get(\"message\", \"?\")} ({r.get(\"timestamp\", \"\")})')
" 2>/dev/null
    ;;

  help|--help|-h|*)
    show_help
    ;;
esac
