#!/bin/bash
# autopilot.sh --- Autonomous goal execution loop.
# Part of the autonomous runtime fork.
#
# Orchestrates the full autonomous loop:
#   goal -> decompose -> safety init -> task loop -> self-improve
#
# Usage:
#   bash ./scripts/autopilot.sh --goal "<goal>" [options]
#   bash ./scripts/autopilot.sh --resume <pipeline-id>
#   bash ./scripts/autopilot.sh --status
#
# Options:
#   --agent <name>      Agent for decomposition (default: pi)
#   --allow <paths>     Blast radius allowed paths (default: scripts/)
#   --max-tasks <N>     Budget limit (default: 10)
#   --max-attempts <N>  Retries per task (default: 3)
#   --resume <id>       Resume a paused pipeline
#   --status            Show autopilot status
#   --no-learn          Skip self-improvement at end

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
AUTOPILOT_DIR="$REPO_ROOT/.runtime/autopilot"
mkdir -p "$AUTOPILOT_DIR"

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
AGENT="pi"
MAX_TASKS=10
MAX_ATTEMPTS=3
ALLOWED_PATHS=("scripts/")
RESUME_ID=""
NO_LEARN=false

while [ $# -gt 0 ]; do
  case "$1" in
    --goal) GOAL="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --allow)
      shift
      ALLOWED_PATHS=()
      while [ $# -gt 0 ] && ! [[ "$1" =~ ^-- ]]; do
        ALLOWED_PATHS+=("$1")
        shift
      done
      ;;
    --max-tasks) MAX_TASKS="$2"; shift 2 ;;
    --max-attempts) MAX_ATTEMPTS="$2"; shift 2 ;;
    --resume) RESUME_ID="$2"; shift 2 ;;
    --no-learn) NO_LEARN=true; shift ;;
    --status)
      echo "=== Autopilot Status ==="
      echo ""
      for f in "$AUTOPILOT_DIR"/*.json; do
        [ -f "$f" ] || continue
        python3 -c "
import json
with open('$f') as fh:
    a = json.load(fh)
print(f'  Pipeline: {a.get(\"pipeline_id\", \"?\")}')
print(f'  Goal:     {a.get(\"goal\", \"?\")[:80]}...')
print(f'  Status:   {a.get(\"status\", \"?\")}')
print()
" 2>/dev/null
      done
      if [ "$(ls -A "$AUTOPILOT_DIR" 2>/dev/null | wc -l)" -eq 0 ]; then
        echo "  No autopilot sessions."
      fi
      exit 0
      ;;
    *) echo "Unknown: $1"
       echo "Usage: bash ./scripts/autopilot.sh --goal \"<goal>\" [options]"
       echo "       bash ./scripts/autopilot.sh --resume <pipeline-id>"
       echo "       bash ./scripts/autopilot.sh --status"
       exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Phase 0: Determine goal
# ---------------------------------------------------------------------------
if [ -n "$RESUME_ID" ]; then
  echo "=== AutoPilot: Resume Mode ==="
  PIPELINE_ID="$RESUME_ID"

  PIPELINE_FILE="$REPO_ROOT/.runtime/pipeline/$PIPELINE_ID.json"
  if [ ! -f "$PIPELINE_FILE" ]; then
    echo "Pipeline $PIPELINE_ID not found."
    exit 1
  fi

  GOAL=$(python3 -c "
import json
with open('$PIPELINE_FILE') as f:
    p = json.load(f)
print(p.get('title', ''))
" 2>/dev/null)

  echo "Resuming: $GOAL"
  echo ""

elif [ -z "${GOAL:-}" ]; then
  echo "Provide --goal \"<goal>\" or --resume <pipeline-id>"
  echo "Usage: bash ./scripts/autopilot.sh --goal \"<goal>\""
  exit 1
fi

# ---------------------------------------------------------------------------
# Phase 1: Decompose goal into pipeline
# ---------------------------------------------------------------------------
if [ -z "$RESUME_ID" ]; then
  echo "=== Phase 1: Goal Decomposition ==="
  echo "Goal: ${GOAL:0:120}..."
  echo "Agent: $AGENT"
  echo ""

  PIPELINE_OUTPUT=$(bash "$REPO_ROOT/scripts/goal-decompose.sh" "$GOAL" \
    --agent "$AGENT" \
    --max-tasks "$MAX_TASKS" \
    --allow "${ALLOWED_PATHS[@]}"  2>&1) || true

  PIPELINE_ID=$(echo "$PIPELINE_OUTPUT" | grep -oP 'pipeline-\S+' | head -1)

  if [ -z "$PIPELINE_ID" ]; then
    echo "Goal decomposition failed. Output:"
    echo "$PIPELINE_OUTPUT"
    exit 1
  fi

  echo "Pipeline: $PIPELINE_ID"

  # Save autopilot session state
  cat > "$AUTOPILOT_DIR/$PIPELINE_ID.json" << APEOF
{
  "pipeline_id": "$PIPELINE_ID",
  "goal": $(echo "$GOAL" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))"),
  "status": "running",
  "started": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "completed": null,
  "task_results": []
}
APEOF
fi

# ---------------------------------------------------------------------------
# Phase 2: Task execution loop
# ---------------------------------------------------------------------------
echo ""
echo "=== Phase 2: Autonomous Execution ==="
echo ""

MAX_ATTEMPTS_INT=$MAX_ATTEMPTS
TASK_COUNTER=0

while true; do
  # Check if pipeline is already complete (from previous iteration)
  PIPELINE_STATUS=$(python3 -c "
import json
with open('$REPO_ROOT/.runtime/pipeline/$PIPELINE_ID.json') as f:
    p = json.load(f)
print(p.get('status', ''))
" 2>/dev/null || echo "")
  if [ "$PIPELINE_STATUS" = "complete" ]; then
    echo "Pipeline already complete."
    break
  fi

  # Check budget before each task
  echo "--- Budget Check ---"
  BUDGET_RESULT=0
  bash "$REPO_ROOT/scripts/safety-escalate.sh" budget-check "$PIPELINE_ID" 2>&1 || BUDGET_RESULT=$?

  if [ "$BUDGET_RESULT" -ne 0 ]; then
    echo "Budget exceeded. Halting."
    bash "$REPO_ROOT/scripts/safety-escalate.sh" escalate "$PIPELINE_ID" 0 "Budget exceeded (exit $BUDGET_RESULT)"
    break
  fi
  echo ""

  # Get next task
  NEXT_OUTPUT=$(bash "$REPO_ROOT/scripts/pipeline-run.sh" next "$PIPELINE_ID" 2>&1) || true

  if echo "$NEXT_OUTPUT" | grep -q "No pending tasks\|Pipeline complete\|complete"; then
    echo "Pipeline complete!"
    break
  fi

  # Extract task ID from the output
  TASK_ID=$(echo "$NEXT_OUTPUT" | grep -oP 'Task \K\d+' | head -1 || echo "")

  if [ -z "$TASK_ID" ]; then
    echo "No more tasks. Pipeline may be complete."
    break
  fi

  TASK_DESC=$(echo "$NEXT_OUTPUT" | grep -oP "(?<=Task $TASK_ID )\(?routed\)?:\s*\K.*" | head -1 || echo "Task $TASK_ID")
  TASK_COUNTER=$((TASK_COUNTER + 1))

  echo "--- Task $TASK_ID: $TASK_DESC ---"

  # Safety check: validate task against blast radius and budget
  bash "$REPO_ROOT/scripts/safety-guard.sh" check "$PIPELINE_ID" "$TASK_ID" 2>&1 || true
  echo ""

  # Dispatch the task to a subagent
  DISPATCH_PROMPT="Implement task $TASK_ID from pipeline $PIPELINE_ID. Task description: ${TASK_DESC}. Work in the $REPO_ROOT directory. Return JSON with: implemented (bool), files_changed (list), summary (str)."
  JOB_ID=$(bash "$REPO_ROOT/scripts/agent-dispatch.sh" run "$AGENT" "$DISPATCH_PROMPT" --format json 2>&1 | grep -oP 'job-\S+' | head -1 || echo "")

  if [ -z "$JOB_ID" ]; then
    echo "Dispatch failed for task $TASK_ID"
    bash "$REPO_ROOT/scripts/safety-escalate.sh" retry "$PIPELINE_ID" "$TASK_ID" --max-attempts "$MAX_ATTEMPTS_INT" 2>&1 || true
    continue
  fi

  echo "Dispatched: $JOB_ID"

  # Poll for completion
  for i in $(seq 1 60); do
    STATUS=$(bash "$REPO_ROOT/scripts/agent-dispatch.sh" status "$JOB_ID" 2>&1 | grep -oP '"status":\s*"\K[^"]+' | head -1 || echo "running")
    if [ "$STATUS" = "done" ] || [ "$STATUS" = "failed" ]; then
      break
    fi
    sleep 5
  done

  # Check result
  if [ "$STATUS" = "done" ]; then
    # Get structured result
    RESULT=$(bash "$REPO_ROOT/scripts/agent-dispatch.sh" result "$JOB_ID" 2>&1 | head -5) || true

    # Update pipeline
    bash "$REPO_ROOT/scripts/pipeline-run.sh" update "$PIPELINE_ID" "$TASK_ID" done "$RESULT" 2>&1 || true

    # Save to autopilot session
    AUTOPILOT_FILE="$AUTOPILOT_DIR/$PIPELINE_ID.json"
    python3 -c "
import json
with open('$AUTOPILOT_FILE') as f:
    a = json.load(f)
a.setdefault('task_results', []).append({
    'task_id': $TASK_ID,
    'status': 'done',
})" 2>/dev/null || true

    # Log to learnings
    echo "autopilot: task $TASK_ID done for pipeline $PIPELINE_ID" >> "$REPO_ROOT/.learnings.jsonl" 2>/dev/null || true

    echo "Task $TASK_ID done."

  else
    echo "Task $TASK_ID failed (status=$STATUS)"
    bash "$REPO_ROOT/scripts/pipeline-run.sh" update "$PIPELINE_ID" "$TASK_ID" failed 2>&1 || true
    bash "$REPO_ROOT/scripts/safety-escalate.sh" retry "$PIPELINE_ID" "$TASK_ID" --max-attempts "$MAX_ATTEMPTS_INT" 2>&1 || true

    # Save failure to autopilot state
    AUTOPILOT_FILE="$AUTOPILOT_DIR/$PIPELINE_ID.json"
    python3 -c "
import json
with open('$AUTOPILOT_FILE') as f:
    a = json.load(f)
a.setdefault('task_results', []).append({
    'task_id': $TASK_ID,
    'status': 'failed',
})
with open('$AUTOPILOT_FILE', 'w') as f:
    json.dump(a, f, indent=2)" 2>/dev/null || true
  fi

  echo ""
done

# ---------------------------------------------------------------------------
# Phase 3: Self-improvement (optional)
# ---------------------------------------------------------------------------
if [ "$NO_LEARN" = false ]; then
  echo ""
  echo "=== Phase 3: Self-Improvement ==="
  echo ""

  # Run self-improvement
  if [ -f "$REPO_ROOT/scripts/self-improve.sh" ]; then
    bash "$REPO_ROOT/scripts/self-improve.sh" --pipeline "$PIPELINE_ID" 2>&1 || true
  else
    echo "self-improve.sh not found (optional, skip)"
  fi

  # Mark autopilot session complete
  AUTOPILOT_FILE="$AUTOPILOT_DIR/$PIPELINE_ID.json"
  python3 -c "
import json, datetime
with open('$AUTOPILOT_FILE') as f:
    a = json.load(f)
a['status'] = 'complete'
a['completed'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
with open('$AUTOPILOT_FILE', 'w') as f:
    json.dump(a, f, indent=2)" 2>/dev/null || true
fi

echo ""
echo "=== AutoPilot Complete ==="
echo "Pipeline: $PIPELINE_ID"
echo "Tasks completed: $TASK_COUNTER"
echo ""
echo "Review: bash scripts/pipeline-run.sh status $PIPELINE_ID"
echo "Safety: bash scripts/safety-guard.sh show $PIPELINE_ID"
echo "Log:     cat $AUTOPILOT_DIR/$PIPELINE_ID.json"
