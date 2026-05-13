#!/bin/bash
# Subagent pipeline state manager.
# Tracks progress across a sequence of implementation tasks,
# each dispatched to an isolated @worker subagent.
#
# Usage:
#   bash ./scripts/pipeline-run.sh init <plan-title> [task1, task2, ...]
#   bash ./scripts/pipeline-run.sh list
#   bash ./scripts/pipeline-run.sh status [pipeline-id]
#   bash ./scripts/pipeline-run.sh update <pipeline-id> <task-id> <status> [note]
#   bash ./scripts/pipeline-run.sh next <pipeline-id>

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
PIPELINE_DIR="$REPO_ROOT/.runtime/pipeline"
mkdir -p "$PIPELINE_DIR"

CMD="${1:-help}"

case "$CMD" in
  init)
    # Create a new pipeline from a plan
    PLAN_TITLE="${2:-untitled}"
    shift 2
    TASKS=("$@")
    
    PIPELINE_ID="pipeline-$(date -u +%Y%m%d%H%M%S)"
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Build tasks array
    TASK_JSON="[]"
    ID=0
    for task in "${TASKS[@]}"; do
      ID=$((ID + 1))
      TASK_JSON=$(echo "$TASK_JSON" | jq ". + [{\"id\": $ID, \"description\": $(echo "$task" | jq -Rs .), \"status\": \"pending\", \"agent_job_id\": null, \"worker_result\": null, \"notes\": null}]" 2>/dev/null)
    done
    
    cat > "$PIPELINE_DIR/$PIPELINE_ID.json" << EOF
{
  "id": "$PIPELINE_ID",
  "title": $(echo "$PLAN_TITLE" | jq -Rs . 2>/dev/null),
  "created": "$TIMESTAMP",
  "current_task": null,
  "tasks": $TASK_JSON,
  "status": "active"
}
EOF
    
    echo "$PIPELINE_ID"
    echo "Pipeline created: $PLAN_TITLE"
    echo "Tasks: ${#TASKS[@]}"
    echo ""
    echo "Next: bash ./scripts/pipeline-run.sh next $PIPELINE_ID"
    ;;
    
  list)
    # List all pipelines
    echo "Pipelines:"
    echo ""
    for f in "$PIPELINE_DIR"/*.json; do
      [ -f "$f" ] || continue
      ID=$(jq -r '.id' "$f" 2>/dev/null)
      TITLE=$(jq -r '.title' "$f" 2>/dev/null)
      STATUS=$(jq -r '.status' "$f" 2>/dev/null)
      DONE=$(jq '[.tasks[] | select(.status=="done")] | length' "$f" 2>/dev/null)
      TOTAL=$(jq '.tasks | length' "$f" 2>/dev/null)
      echo "  $ID"
      echo "    title:  $TITLE"
      echo "    status: $STATUS ($DONE/$TOTAL tasks done)"
      echo ""
    done
    ;;
    
  status)
    # Show pipeline status
    PIPELINE_ID="${2:-}"
    if [ -z "$PIPELINE_ID" ]; then
      # Show latest
      PIPELINE_ID=$(ls -t "$PIPELINE_DIR"/*.json 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/\.json//' || echo "")
      [ -z "$PIPELINE_ID" ] && echo "No pipelines found." && exit 0
    fi
    
    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1
    
    echo "=== $PIPELINE_ID ==="
    jq -r '
      "Title:    " + .title,
      "Status:   " + .status,
      "Tasks:    " + (.tasks | length | tostring),
      "Done:     " + ([.tasks[] | select(.status=="done")] | length | tostring),
      "Failed:   " + ([.tasks[] | select(.status=="failed")] | length | tostring),
      "Pending:  " + ([.tasks[] | select(.status=="pending")] | length | tostring),
      ""
    ' "$FILE" 2>/dev/null
    
    echo "Task breakdown:"
    jq -r '.tasks[] | "  [" + .status + "] Task " + (.id | tostring) + ": " + .description' "$FILE" 2>/dev/null
    echo ""
    echo "Commands:"
    echo "  Next task:   bash ./scripts/pipeline-run.sh next $PIPELINE_ID"
    echo "  Update:      bash ./scripts/pipeline-run.sh update $PIPELINE_ID <task-id> <status> [note]"
    ;;
    
  update)
    # Update a task's status
    PIPELINE_ID="${2:-}"
    TASK_ID="${3:-}"
    STATUS="${4:-}"
    NOTE="${5:-}"
    
    [ -z "$PIPELINE_ID" ] && echo "Usage: pipeline-run.sh update <pipeline-id> <task-id> <status> [note]" && exit 1
    [ -z "$TASK_ID" ] && echo "Usage: pipeline-run.sh update <pipeline-id> <task-id> <status> [note]" && exit 1
    [ -z "$STATUS" ] && echo "Usage: pipeline-run.sh update <pipeline-id> <task-id> <status> [note]" && exit 1
    
    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1
    
    # Build jq filter
    if [ -n "$NOTE" ]; then
      jq --arg id "$TASK_ID" --arg status "$STATUS" --arg note "$NOTE" '
        (.tasks[] | select(.id == ($id | tonumber))) |= (.status = $status | .notes = $note)
      ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    else
      jq --arg id "$TASK_ID" --arg status "$STATUS" '
        (.tasks[] | select(.id == ($id | tonumber))) |= (.status = $status)
      ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    fi
    
    # If any task failed, mark pipeline as blocked
    FAILED=$(jq '[.tasks[] | select(.status=="failed")] | length' "$FILE" 2>/dev/null)
    if [ "$FAILED" -gt 0 ]; then
      jq '.status = "blocked"' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    fi
    
    # If all tasks done, mark pipeline as complete
    ALL_DONE=$(jq '(.tasks | length) as $n | ([.tasks[] | select(.status=="done" or .status=="failed")] | length) == $n' "$FILE" 2>/dev/null)
    if [ "$ALL_DONE" = "true" ]; then
      jq '.status = "complete"' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      echo "Pipeline complete: $PIPELINE_ID"
    else
      echo "Task $TASK_ID -> $STATUS"
    fi
    ;;
    
  next)
    # Show the next uncompleted task
    PIPELINE_ID="${2:-}"
    [ -z "$PIPELINE_ID" ] && echo "Usage: pipeline-run.sh next <pipeline-id>" && exit 1
    
    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1
    
    # Check if pipeline is complete
    STATUS=$(jq -r '.status' "$FILE" 2>/dev/null)
    if [ "$STATUS" = "complete" ]; then
      echo "Pipeline complete."
      exit 0
    fi
    
    # Find first pending task
    NEXT=$(jq -r '[.tasks[] | select(.status=="pending")] | first | {id, description}' "$FILE" 2>/dev/null)
    if [ -z "$NEXT" ] || [ "$NEXT" = "null" ]; then
      # Check for failed tasks
      FAILED=$(jq '[.tasks[] | select(.status=="failed")] | length' "$FILE" 2>/dev/null)
      if [ "$FAILED" -gt 0 ]; then
        echo "Pipeline has $FAILED failed task(s). Resolve before continuing."
        jq -r '.tasks[] | select(.status=="failed") | "  Task " + (.id | tostring) + ": " + .description + " - " + (.notes // "no notes")' "$FILE" 2>/dev/null
        exit 1
      fi
      echo "No pending tasks (pipeline may be blocked)."
      exit 0
    fi
    
    TASK_ID=$(echo "$NEXT" | jq -r '.id' 2>/dev/null)
    TASK_DESC=$(echo "$NEXT" | jq -r '.description' 2>/dev/null)
    
    # Mark as in-progress
    jq --arg id "$TASK_ID" --arg pid "$PIPELINE_ID" '
      (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "in-progress")
      | .current_task = ($id | tonumber)
    ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    
    echo "Task $TASK_ID: $TASK_DESC"
    echo ""
    echo "Dispatch to @worker:"
    echo "  Use the task tool to spawn subagent_type=worker"
    echo "  Prompt includes: task description, files to modify, verification target"
    echo ""
    echo "After worker returns:"
    echo "  bash ./scripts/pipeline-run.sh update $PIPELINE_ID $TASK_ID done|failed \"notes\""
    echo "  bash ./scripts/pipeline-run.sh next $PIPELINE_ID"
    echo ""
    echo "For high-stakes tasks:"
    echo "  bash ./scripts/pipeline-run.sh human-checkpoint $PIPELINE_ID $TASK_ID"
    ;;
    
  human-checkpoint|checkpoint)
    # Pause pipeline for human approval (12-factor F7)
    PIPELINE_ID="${2:-}"
    TASK_ID="${3:-}"
    
    [ -z "$PIPELINE_ID" ] && echo "Usage: pipeline-run.sh human-checkpoint <pipeline-id> [task-id]" && exit 1
    
    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1
    
    if [ -z "$TASK_ID" ]; then
      # No task specified --- show current task
      TASK_ID=$(jq -r '.current_task // empty' "$FILE" 2>/dev/null)
      [ -z "$TASK_ID" ] && echo "No current task. Specify a task ID." && exit 1
    fi
    
    # Get task description
    TASK_DESC=$(jq -r --arg id "$TASK_ID" '.tasks[] | select(.id == ($id | tonumber)) | .description // "?"' "$FILE" 2>/dev/null)
    [ -z "$TASK_DESC" ] || [ "$TASK_DESC" = "?" ] && echo "Task $TASK_ID not found." && exit 1
    
    echo "=== Human Checkpoint: Task $TASK_ID ==="
    echo "Task: $TASK_DESC"
    echo ""
    
    # Request human approval via A2H protocol
    APPROVAL_ID=$(bash "$REPO_ROOT/scripts/a2h-contact.sh" approve \
      "pipeline: $TASK_DESC" \
      "{\"pipeline\": \"$PIPELINE_ID\", \"task\": $TASK_ID}" \
      --urgency high --channel cli 2>&1 | tail -1 || echo "")
    
    # Mark task as waiting-human
    jq --arg id "$TASK_ID" \
      '(.tasks[] | select(.id == ($id | tonumber))) |= (.status = "waiting-human")' \
      "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    
    echo ""
    echo "Pipeline paused at task $TASK_ID."
    echo "Run: bash ./scripts/a2h-contact.sh list --pending"
    echo "After human response: bash ./scripts/pipeline-run.sh next $PIPELINE_ID"
    ;;
    
  dispatch)
    # Dispatch all pending tasks to an external agent asynchronously
    PIPELINE_ID="${2:-}"
    AGENT="${3:-pi}"
    [ -z "$PIPELINE_ID" ] && echo "Usage: pipeline-run.sh dispatch <pipeline-id> [agent]" && exit 1

    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1

    echo "Dispatching pending tasks to '$AGENT'..."
    echo ""

    # Check agent-dispatch exists
    DISPATCH_SCRIPT="$REPO_ROOT/scripts/agent-dispatch.sh"
    if [ ! -f "$DISPATCH_SCRIPT" ]; then
      echo "agent-dispatch.sh not found at $DISPATCH_SCRIPT"
      echo "Pipeline dispatch requires agent-dispatch.sh (created in session 72)"
      exit 1
    fi

    # Find pending tasks
    PENDING=$(jq '[.tasks[] | select(.status=="pending")]' "$FILE" 2>/dev/null)
    PENDING_COUNT=$(echo "$PENDING" | jq 'length' 2>/dev/null || echo 0)

    if [ "$PENDING_COUNT" -eq 0 ]; then
      echo "No pending tasks to dispatch."
      exit 0
    fi

    echo "Found $PENDING_COUNT pending task(s)."
    echo ""

    DISPATCHED=0
    for i in $(seq 0 $((PENDING_COUNT - 1))); do
      TASK_ID=$(echo "$PENDING" | jq -r ".[$i].id" 2>/dev/null)
      TASK_DESC=$(echo "$PENDING" | jq -r ".[$i].description" 2>/dev/null)

      echo "[$((i+1))/$PENDING_COUNT] Task $TASK_ID: ${TASK_DESC:0:60}..."

      # Dispatch to agent
      JOB_RESULT=$(bash "$DISPATCH_SCRIPT" run "$AGENT" "$TASK_DESC" 2>&1)
      JOB_ID=$(echo "$JOB_RESULT" | head -1 | grep -E "^job-" || echo "")

      if [ -n "$JOB_ID" ]; then
        # Mark as dispatched with the job ID
        jq --arg id "$TASK_ID" --arg jid "$JOB_ID" '
          (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "dispatched" | .agent_job_id = $jid)
        ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
        echo "  -> $JOB_ID"
        DISPATCHED=$((DISPATCHED + 1))
      else
        echo "  -> FAILED to dispatch"
        echo "  -> $JOB_RESULT" | head -3
      fi
    done

    echo ""
    echo "Dispatched $DISPATCHED/$PENDING_COUNT task(s) to '$AGENT'."
    echo ""
    echo "Collect results: bash ./scripts/pipeline-run.sh collect $PIPELINE_ID"
    ;;

  collect)
    # Collect results from dispatched agent tasks
    PIPELINE_ID="${2:-}"
    [ -z "$PIPELINE_ID" ] && echo "Usage: pipeline-run.sh collect <pipeline-id>" && exit 1

    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1

    DISPATCHED=$(jq '[.tasks[] | select(.status=="dispatched")]' "$FILE" 2>/dev/null)
    DISPATCHED_COUNT=$(echo "$DISPATCHED" | jq 'length' 2>/dev/null || echo 0)

    if [ "$DISPATCHED_COUNT" -eq 0 ]; then
      echo "No dispatched tasks awaiting collection."
      echo "Run: bash ./scripts/pipeline-run.sh dispatch $PIPELINE_ID"
      exit 0
    fi

    echo "Collecting $DISPATCHED_COUNT dispatched task(s)..."
    echo ""

    COMPLETED=0
    for i in $(seq 0 $((DISPATCHED_COUNT - 1))); do
      TASK_ID=$(echo "$DISPATCHED" | jq -r ".[$i].id" 2>/dev/null)
      TASK_DESC=$(echo "$DISPATCHED" | jq -r ".[$i].description" 2>/dev/null)
      JOB_ID=$(echo "$DISPATCHED" | jq -r ".[$i].agent_job_id" 2>/dev/null)

      if [ -z "$JOB_ID" ] || [ "$JOB_ID" = "null" ]; then
        echo "[$((i+1))/$DISPATCHED_COUNT] Task $TASK_ID: no job ID (re-dispatch needed)"
        continue
      fi

      # Check agent job status
      JOB_STATUS="unknown"
      if [ -f "$REPO_ROOT/.runtime/agent-jobs/$JOB_ID.json" ]; then
        JOB_STATUS=$(jq -r '.status' "$REPO_ROOT/.runtime/agent-jobs/$JOB_ID.json" 2>/dev/null || echo "unknown")
        EXIT_CODE=$(jq -r '.exit_code // "null"' "$REPO_ROOT/.runtime/agent-jobs/$JOB_ID.json" 2>/dev/null || echo "null")
      fi

      echo "[$((i+1))/$DISPATCHED_COUNT] Task $TASK_ID: ${TASK_DESC:0:50}..."

      case "$JOB_STATUS" in
        done)
          jq --arg id "$TASK_ID" '
            (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "done")
          ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
          echo "  -> DONE (exit: $EXIT_CODE)"
          COMPLETED=$((COMPLETED + 1))
          ;;
        failed)
          jq --arg id "$TASK_ID" '
            (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "failed")
          ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
          echo "  -> FAILED (exit: $EXIT_CODE)"
          COMPLETED=$((COMPLETED + 1))
          ;;
        running)
          echo "  -> still running"
          ;;
        cancelled)
          jq --arg id "$TASK_ID" '
            (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "pending" | .agent_job_id = null)
          ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
          echo "  -> was CANCELLED, reset to pending"
          ;;
        *)
          echo "  -> unknown status: $JOB_STATUS"
          ;;
      esac
    done

    echo ""
    # Auto-update pipeline status based on completed tasks
    ALL_DONE=$(jq '(.tasks | length) as $n | ([.tasks[] | select(.status=="done" or .status=="failed")] | length) == $n' "$FILE" 2>/dev/null)
    if [ "$ALL_DONE" = "true" ]; then
      jq '.status = "complete"' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      echo "Pipeline complete: $PIPELINE_ID"
    elif [ "$COMPLETED" -gt 0 ]; then
      echo "Collected $COMPLETED result(s). Some tasks still pending/dispatched."
      echo "Re-run: bash ./scripts/pipeline-run.sh collect $PIPELINE_ID"
    fi
    ;;

  *)
    echo "Subagent Pipeline State Manager"
    echo ""
    echo "Usage:"
    echo "  init    <title> [tasks...]     Create a new pipeline"
    echo "  list                           List all pipelines"
    echo "  status  [pipeline-id]          Show pipeline status"
    echo "  update  <id> <task> <s> [n]    Update task status (done/failed/pending)"
    echo "  next    <pipeline-id>          Show next uncompleted task"
    echo "  human-checkpoint <id> [task]   Pause for human approval (12-factor F7)"
    echo "  dispatch <id> [agent]          Dispatch pending tasks to agent asynchronously"
    echo "  collect <id>                   Collect results from dispatched tasks"
    echo ""
    echo "Agents for dispatch: pi (default), codex, claude"
    echo ""
    echo "Example:"
    echo "  pipeline-run.sh init \"Auth module\" \"Implement JWT middleware\" \"Add login endpoint\" \"Write tests\""
    echo "  pipeline-run.sh dispatch <id> pi"
    echo "  pipeline-run.sh collect <id>"
    ;;
esac
