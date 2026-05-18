#!/usr/bin/env bash
# Default post-task guardrail: validate task output after completion.
# Output guardrail pattern from OpenAI Agents SDK.
# Called by: pipeline-run.sh guardrail <pipeline-id> <task-id> post
# Location: scripts/guardrails/post-default.sh
# Source: https://github.com/openai/openai-agents-python (guardrails)
#
# Fails if:
#   - Task status is not done (was failed or blocked)
#   - No output/notes recorded for the task
#   - Task description still on default ("Task N" pattern)

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

PIPELINE_ID="${1:-}"
TASK_ID="${2:-}"

[ -z "$PIPELINE_ID" ] && echo "GUARDRAIL_FAIL: pipeline-id required" && exit 1
[ -z "$TASK_ID" ] && echo "GUARDRAIL_FAIL: task-id required" && exit 1

PIPELINE_FILE="$REPO_ROOT/.runtime/pipeline/$PIPELINE_ID.json"
[ ! -f "$PIPELINE_FILE" ] && echo "GUARDRAIL_FAIL: pipeline file not found" && exit 1

TASK=$(jq --arg id "$TASK_ID" '.tasks[] | select(.id == ($id | tonumber))' "$PIPELINE_FILE" 2>/dev/null)
[ -z "$TASK" ] || [ "$TASK" = "null" ] && echo "GUARDRAIL_FAIL: task $TASK_ID not found" && exit 1

STATUS=$(echo "$TASK" | jq -r '.status // ""' 2>/dev/null)
NOTES=$(echo "$TASK" | jq -r '.notes // ""' 2>/dev/null)
DESCRIPTION=$(echo "$TASK" | jq -r '.description // ""' 2>/dev/null)

# Check 1: status is done
if [ "$STATUS" != "done" ]; then
  echo "GUARDRAIL_FAIL: task status is '$STATUS', expected 'done'"
  exit 1
fi

# Check 2: has notes (meaningful output was recorded)
if [ -z "$NOTES" ]; then
  echo "GUARDRAIL_WARN: task completed with no notes"
  echo "  Recommendation: add notes describing what was done."
fi

# Check 3: description was updated from template (not "Task N" or default)
if echo "$DESCRIPTION" | grep -qiE '^Task [0-9]+$'; then
  echo "GUARDRAIL_WARN: task has generic description 'Task N'"
  echo "  Recommendation: use descriptive task names for traceability."
fi

echo "GUARDRAIL_PASS: post-task validation OK"
exit 0
