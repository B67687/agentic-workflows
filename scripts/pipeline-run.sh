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

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
PIPELINE_DIR="$REPO_ROOT/.pipeline"
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
      TASK_JSON=$(echo "$TASK_JSON" | jq ". + [{\"id\": $ID, \"description\": $(echo "$task" | jq -Rs .), \"status\": \"pending\", \"worker_result\": null, \"notes\": null}]" 2>/dev/null)
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
    ALL_DONE=$(jq '[.tasks[] | select(.status=="done" or .status=="failed")] | length == (.tasks | length)' "$FILE" 2>/dev/null)
    if [ "$ALL_DONE" = "true" ]; then
      jq '.status = "complete"' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      echo "Pipeline complete: $PIPELINE_ID"
    else
      echo "Task $TASK_ID → $STATUS"
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
    ;;
    
  *)
    echo "Subagent Pipeline State Manager"
    echo ""
    echo "Usage:"
    echo "  init    <title> [tasks...]   Create a new pipeline"
    echo "  list                         List all pipelines"
    echo "  status  [pipeline-id]        Show pipeline status"
    echo "  update  <id> <task> <s> [n]  Update task status (done/failed/pending)"
    echo "  next    <pipeline-id>        Show next uncompleted task"
    echo ""
    echo "Example:"
    echo "  pipeline-run.sh init \"Auth module\" \"Implement JWT middleware\" \"Add login endpoint\" \"Write tests\""
    ;;
esac
