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
      # Check for on_error annotation: "task :: abort|continue|retry:N"
      ON_ERROR="abort"
      TASK_DESC="$task"
      if echo "$task" | grep -qE ':: (abort|continue|retry:[0-9]+)$'; then
        ON_ERROR=$(echo "$task" | sed 's/.*:: //')
        TASK_DESC=$(echo "$task" | sed 's/ :: .*$//')
      fi
      TASK_JSON=$(echo "$TASK_JSON" | jq ". + [{\"id\": $ID, \"description\": $(echo "$TASK_DESC" | jq -Rs .), \"status\": \"pending\", \"on_error\": \"$ON_ERROR\", \"retry_count\": 0, \"agent_job_id\": null, \"worker_result\": null, \"notes\": null}]" 2>/dev/null)
    done
    
    cat > "$PIPELINE_DIR/$PIPELINE_ID.json" << EOF
{
  "id": "$PIPELINE_ID",
  "title": $(echo "$PLAN_TITLE" | jq -Rs . 2>/dev/null),
  "created": "$TIMESTAMP",
  "current_task": null,
  "tasks": $TASK_JSON,
  "status": "active",
  "routes": []
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
    
    # N8N-style per-node error handling: respect on_error field
    # abort   (default) -> block pipeline on failure
    # continue          -> mark failed, keep pipeline moving
    # retry:N           -> retry up to N times before aborting
    if [ "$STATUS" = "failed" ]; then
      ON_ERROR=$(jq -r --arg id "$TASK_ID" '.tasks[] | select(.id == ($id | tonumber)) | .on_error // "abort"' "$FILE" 2>/dev/null)
      RETRY_COUNT=$(jq -r --arg id "$TASK_ID" '.tasks[] | select(.id == ($id | tonumber)) | .retry_count // 0' "$FILE" 2>/dev/null)
      
      case "$ON_ERROR" in
        continue)
          # Mark failed but don't block pipeline
          jq --arg id "$TASK_ID" '
            (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "failed" | .retry_count = 0)
          ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
          echo "  n8n: on_error=continue, task failed, pipeline continues"
          ;;
        retry:*)
          MAX_RETRY=$(echo "$ON_ERROR" | cut -d: -f2)
          if [ "$RETRY_COUNT" -lt "$MAX_RETRY" ]; then
            NEW_COUNT=$((RETRY_COUNT + 1))
            jq --arg id "$TASK_ID" --argjson count "$NEW_COUNT" '
              (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "pending" | .retry_count = $count | .notes = "retry \($count)")
            ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
            echo "  n8n: on_error=$ON_ERROR, retry $NEW_COUNT/$MAX_RETRY"
          else
            # Out of retries --- fall back to abort
            jq --arg id "$TASK_ID" '
              (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "failed" | .retry_count = 0)
            ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
            jq '.status = "blocked"' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
            echo "  n8n: on_error=$ON_ERROR, out of retries, pipeline blocked"
          fi
          ;;
        *)
          # abort (default): block pipeline on any failure
          jq '.status = "blocked"' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
          echo "  n8n: on_error=abort (default), pipeline blocked"
          ;;
      esac
    fi
    
    # CrewAI Flow @router: resolve routing rules
    if [ "$STATUS" = "done" ] || [ "$STATUS" = "failed" ]; then
      ROUTE_NEXT=$(jq -r --arg tid "$TASK_ID" --arg status "$STATUS" '
        def resolve: if $status == "done" then .on_success // empty else .on_failure // empty end;
        [.routes[] | select(.from == ($tid | tonumber))] | first | resolve // empty
      ' "$FILE" 2>/dev/null)
      if [ -n "$ROUTE_NEXT" ] && [ "$ROUTE_NEXT" != "null" ]; then
        # Set auto_next so the next subcommand picks it up
        jq --arg next "$ROUTE_NEXT" '.auto_next = ($next | tonumber)' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
        echo "  CrewAI Flow route: task $TASK_ID -> task $ROUTE_NEXT ($STATUS)"
      fi
    fi

    # If all tasks done, mark pipeline as complete
    ALL_DONE=$(jq '(.tasks | length) as $n | ([.tasks[] | select(.status=="done" or .status=="failed")] | length) == $n' "$FILE" 2>/dev/null)
    if [ "$ALL_DONE" = "true" ]; then
      jq '.status = "complete"' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      # Clear auto_next since we're done
      jq 'del(.auto_next)' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE" 2>/dev/null || true
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
    
    # Check for CrewAI Flow routed task (auto_next from route resolution)
    AUTO_NEXT=$(jq -r '.auto_next // empty' "$FILE" 2>/dev/null)
    if [ -n "$AUTO_NEXT" ]; then
      # Clear auto_next and check if the routed task is still pending
      jq 'del(.auto_next)' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      NEXT=$(jq -r --arg an "$AUTO_NEXT" '.tasks[] | select(.id == ($an | tonumber) and .status == "pending") | {id, description}' "$FILE" 2>/dev/null)
      if [ -n "$NEXT" ] && [ "$NEXT" != "null" ]; then
        TASK_ID=$(echo "$NEXT" | jq -r '.id' 2>/dev/null)
        TASK_DESC=$(echo "$NEXT" | jq -r '.description' 2>/dev/null)
        jq --arg id "$TASK_ID" --arg pid "$PIPELINE_ID" '
          (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "in-progress")
          | .current_task = ($id | tonumber)
        ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
        echo "Task $TASK_ID (routed): $TASK_DESC"
        # Check if this task has a handoff agent (OpenAI SDK handoff pattern)
        HANDOFF_INFO=$(jq -r --arg tid "$AUTO_NEXT" '[.routes[] | select(.on_success == ($tid | tonumber) or .on_failure == ($tid | tonumber))][0].handoff_agent // empty' "$FILE" 2>/dev/null)
        if [ -n "$HANDOFF_INFO" ]; then
          echo "  Handoff agent: $HANDOFF_INFO (OpenAI SDK handoff pattern)"
        fi
        echo ""
        echo "Guardrails (recommended for every task):"
        echo "  Pre:  bash ./scripts/pipeline-run.sh guardrail $PIPELINE_ID $TASK_ID pre"
        echo "  Post: bash ./scripts/pipeline-run.sh guardrail $PIPELINE_ID $TASK_ID post"
        echo ""
        echo "Dispatch to @worker:"
        echo "  Use the task tool to spawn subagent_type=worker"
        echo "  Prompt includes: task description, files to modify, verification target"
        echo ""
        echo "After worker returns:"
        echo "  bash ./scripts/pipeline-run.sh update $PIPELINE_ID $TASK_ID done|failed \"notes\""
        echo "  bash ./scripts/pipeline-run.sh guardrail $PIPELINE_ID $TASK_ID post"
        echo "  bash ./scripts/pipeline-run.sh next $PIPELINE_ID"
        echo ""
        echo "For high-stakes tasks:"
        echo "  bash ./scripts/pipeline-run.sh human-checkpoint $PIPELINE_ID $TASK_ID"
        exit 0
      fi
    fi

    # Fallback: find first pending task by ID order
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
    echo "Guardrails (recommended for every task):"
    echo "  Pre:  bash ./scripts/pipeline-run.sh guardrail $PIPELINE_ID $TASK_ID pre"
    echo "  Post: bash ./scripts/pipeline-run.sh guardrail $PIPELINE_ID $TASK_ID post"
    echo ""
    echo "Dispatch to @worker:"
    echo "  Use the task tool to spawn subagent_type=worker"
    echo "  Prompt includes: task description, files to modify, verification target"
    echo ""
    echo "After worker returns:"
    echo "  bash ./scripts/pipeline-run.sh update $PIPELINE_ID $TASK_ID done|failed \"notes\""
    echo "  bash ./scripts/pipeline-run.sh guardrail $PIPELINE_ID $TASK_ID post"
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
    
  route)
    # Add a routing rule (CrewAI Flow @router pattern).
    # When from-task-id completes, route to success-task if done,
    # or to failure-task if failed. Tasks can chain multiple routes.
    #
    # Usage:
    #   pipeline-run.sh route <pipeline-id> <from-task-id> --success <to-task-id> [--failure <to-task-id>]
    #
    # Examples:
    #   pipeline-run.sh route pipe-001 1 --success 3 --failure 2
    #   pipeline-run.sh route pipe-001 3 --success 4
    #   pipeline-run.sh route pipe-001 1 --success 3 --handoff pi
    PIPELINE_ID="${2:-}"
    FROM_TASK="${3:-}"
    SUCCESS_FLAG=false
    FAILURE_FLAG=false
    SUCCESS_TASK=""
    FAILURE_TASK=""
    HANDOFF_AGENT=""

    shift 3
    while [ $# -gt 0 ]; do
      case "$1" in
        --success)
          SUCCESS_FLAG=true
          SUCCESS_TASK="$2"
          shift 2
          ;;
        --failure)
          FAILURE_FLAG=true
          FAILURE_TASK="$2"
          shift 2
          ;;
        --handoff)
          HANDOFF_AGENT="$2"
          shift 2
          ;;
        *)
          echo "Unknown option: $1"
          echo "Usage: pipeline-run.sh route <pipeline-id> <from-task-id> --success <to-task-id> [--failure <to-task-id>] [--handoff <agent>]"
          exit 1
          ;;
      esac
    done

    [ -z "$PIPELINE_ID" ] && echo "Usage: pipeline-run.sh route <pipeline-id> <from-task-id> --success <to-task-id> [--failure <to-task-id>] [--handoff <agent>]" && exit 1
    [ -z "$FROM_TASK" ] && echo "Usage: pipeline-run.sh route <pipeline-id> <from-task-id> --success <to-task-id> [--failure <to-task-id>] [--handoff <agent>]" && exit 1
    [ "$SUCCESS_FLAG" = false ] && [ "$FAILURE_FLAG" = false ] && echo "Provide at least --success or --failure." && exit 1

    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1

    # Validate tasks exist
    TASK_COUNT=$(jq '.tasks | length' "$FILE" 2>/dev/null)
    FROM_OK=$(jq --argjson ft "$FROM_TASK" '[.tasks[] | select(.id == $ft)] | length' "$FILE" 2>/dev/null)
    [ "$FROM_OK" = "0" ] && echo "From-task $FROM_TASK not found in pipeline." && exit 1

    if [ "$SUCCESS_FLAG" = true ]; then
      SUCCESS_OK=$(jq --argjson st "$SUCCESS_TASK" '[.tasks[] | select(.id == $st)] | length' "$FILE" 2>/dev/null)
      [ "$SUCCESS_OK" = "0" ] && echo "Success-task $SUCCESS_TASK not found in pipeline." && exit 1
    fi
    if [ "$FAILURE_FLAG" = true ]; then
      FAILURE_OK=$(jq --argjson ft "$FAILURE_TASK" '[.tasks[] | select(.id == $ft)] | length' "$FILE" 2>/dev/null)
      [ "$FAILURE_OK" = "0" ] && echo "Failure-task $FAILURE_TASK not found in pipeline." && exit 1
    fi

    # Add the routing rule (use --arg for task IDs, convert to number in jq)
    # OpenAI SDK handoff pattern: specify which agent handles the routed task
    if [ -n "$HANDOFF_AGENT" ]; then
      HANDOFF_JQ="| . + {\"handoff_agent\": \"$HANDOFF_AGENT\"}"
    else
      HANDOFF_JQ=""
    fi

    if [ "$SUCCESS_FLAG" = true ] && [ "$FAILURE_FLAG" = true ]; then
      jq --arg from "$FROM_TASK" \
         --arg success "$SUCCESS_TASK" \
         --arg failure "$FAILURE_TASK" \
         --arg handoff "$HANDOFF_AGENT" \
         '.routes += [{"from": ($from | tonumber), "on_success": ($success | tonumber), "on_failure": ($failure | tonumber)} + if $handoff != "" then {"handoff_agent": $handoff} else {} end]' \
         "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    elif [ "$SUCCESS_FLAG" = true ]; then
      jq --arg from "$FROM_TASK" \
         --arg success "$SUCCESS_TASK" \
         --arg handoff "$HANDOFF_AGENT" \
         '.routes += [{"from": ($from | tonumber), "on_success": ($success | tonumber)} + if $handoff != "" then {"handoff_agent": $handoff} else {} end]' \
         "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    else
      jq --arg from "$FROM_TASK" \
         --arg failure "$FAILURE_TASK" \
         --arg handoff "$HANDOFF_AGENT" \
         '.routes += [{"from": ($from | tonumber), "on_failure": ($failure | tonumber)} + if $handoff != "" then {"handoff_agent": $handoff} else {} end]' \
         "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    fi

    echo "Route added: task $FROM_TASK -> success=$SUCCESS_TASK failure=$FAILURE_TASK${HANDOFF_AGENT:+ (handoff: $HANDOFF_AGENT)}"
    echo "  (CrewAI Flow @router pattern)"
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

  guardrail)
    # Run a guardrail check on a task (OpenAI Agents SDK guardrail pattern)
    # pre:  validate task before dispatch (input guardrail)
    # post: validate result after completion (output guardrail)
    PIPELINE_ID="${2:-}"
    TASK_ID="${3:-}"
    GUARD_TYPE="${4:-}"   # "pre" or "post"
    GUARD_SCRIPT="${5:-}" # optional custom guardrail script

    [ -z "$PIPELINE_ID" ] && echo "Usage: pipeline-run.sh guardrail <pipeline-id> <task-id> <pre|post> [script]" && exit 1
    [ -z "$TASK_ID" ] && echo "Usage: pipeline-run.sh guardrail <pipeline-id> <task-id> <pre|post> [script]" && exit 1
    [ -z "$GUARD_TYPE" ] && echo "Usage: pipeline-run.sh guardrail <pipeline-id> <task-id> <pre|post> [script]" && exit 1

    FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
    [ ! -f "$FILE" ] && echo "Pipeline not found: $PIPELINE_ID" && exit 1

    # Determine guardrail script
    if [ -z "$GUARD_SCRIPT" ]; then
      GUARD_SCRIPT="$REPO_ROOT/scripts/guardrails/${GUARD_TYPE}-default.sh"
      # Fallback: use external validation scripts
      if [ ! -f "$GUARD_SCRIPT" ] && [ "$GUARD_TYPE" = "pre" ]; then
        GUARD_SCRIPT="$REPO_ROOT/scripts/implement-preflight.sh"
      fi
    fi

    if [ ! -f "$GUARD_SCRIPT" ]; then
      echo "Guardrail script not found: $GUARD_SCRIPT"
      echo "  Create one at: $REPO_ROOT/scripts/guardrails/${GUARD_TYPE}-default.sh"
      exit 1
    fi

    echo "Guardrail ($GUARD_TYPE): $(basename "$GUARD_SCRIPT")"
    echo "  Pipeline: $PIPELINE_ID"
    echo "  Task:     $TASK_ID"
    echo ""

    # Run guardrail script with task context
    set +e
    OUTPUT=$(bash "$GUARD_SCRIPT" "$PIPELINE_ID" "$TASK_ID" 2>&1)
    EXIT_CODE=$?
    set -e

    echo "$OUTPUT" | head -10

    if [ "$EXIT_CODE" -ne 0 ]; then
      # Guardrail failed -- mark task as blocked
      GUARD_MSG=$(echo "$OUTPUT" | grep 'GUARDRAIL_FAIL' | head -1 | sed 's/^GUARDRAIL_FAIL: //' || echo "guardrail $GUARD_TYPE failed")
      jq --arg id "$TASK_ID" --arg msg "$GUARD_MSG" '
        (.tasks[] | select(.id == ($id | tonumber))) |= (.status = "blocked" | .notes = $msg)
      ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      echo ""
      echo "  GUARDRAIL_BLOCKED: $GUARD_MSG"
      echo "  Task $TASK_ID has been marked as blocked."
      exit 1
    else
      echo ""
      echo "  GUARDRAIL_OK"

      # Post-guardrail pass: mark the note as verified
      if [ "$GUARD_TYPE" = "post" ]; then
        TASK_STATUS=$(jq -r --arg id "$TASK_ID" '.tasks[] | select(.id == ($id | tonumber)) | .status' "$FILE" 2>/dev/null)
        if [ "$TASK_STATUS" = "done" ]; then
          jq --arg id "$TASK_ID" '
            (.tasks[] | select(.id == ($id | tonumber))) |= (.notes = (.notes // "verified"))
          ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
          echo "  Output verified."
        fi
      fi
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
    echo "  route   <id> <from> --succ <to> [--fail <to>] [--handoff <agent>]  Add routing rule + optional agent handoff"
    echo "  human-checkpoint <id> [task]   Pause for human approval (12-factor F7)"
    echo "  dispatch <id> [agent]          Dispatch pending tasks to agent asynchronously"
    echo "  collect <id>                   Collect results from dispatched tasks"
    echo "  guardrail <id> <task> <p|po>   Run pre/post guardrail on a task"
    echo ""
    echo "Error handling (n8n per-node pattern):"
    echo "  Appends :: continue or :: retry:3 to a task description:"
    echo '    pipeline-run.sh init "Build auth" "Handle errors :: retry:2" "Send email :: continue"'
    echo ""
    echo "Guardrails (OpenAI Agents SDK pattern):"
    echo "  Pre-task: pipeline-run.sh guardrail <id> <task> pre"
    echo "  Post-task: pipeline-run.sh guardrail <id> <task> post"
    echo "  Custom:   pipeline-run.sh guardrail <id> <task> pre /path/to/script.sh"
    echo ""
    echo "Routing (CrewAI Flow @router + OpenAI SDK handoff):"
    echo "  After a task completes, route to the next task based on status:"
    echo "    pipeline-run.sh route <id> <from> --success <on-done> --failure <on-fail>"
    echo "    pipeline-run.sh route <id> <from> --success <on-done>"
    echo "    pipeline-run.sh route <id> <from> --success <on-done> --handoff <agent>"
    echo '  Example: pipeline-run.sh route "pipe-001" 1 --success 3 --failure 2'
    echo '  Example: pipeline-run.sh route "pipe-001" 1 --success 3 --handoff pi'
    echo "    (task 1 done -> task 3 via pi agent -- OpenAI SDK handoff pattern)"
    echo ""
    echo "Agents for dispatch: pi (default), codex, claude"
    echo ""
    echo "Example:"
    echo '  pipeline-run.sh init "Auth module" "Implement JWT" "Add login endpoint :: retry:3" "Write tests" "Deploy"'
    echo '  pipeline-run.sh route <id> 1 --success 2 --failure 5  # CrewAI @router skip to deploy on failure'
    echo "  pipeline-run.sh dispatch <id> pi"
    echo "  pipeline-run.sh collect <id>"
    echo "  pipeline-run.sh guardrail <id> 1 pre"
    ;;
esac
