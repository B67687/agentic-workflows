#!/usr/bin/env bash
# Default pre-task guardrail: validate task context before dispatch.
# Input guardrail pattern from OpenAI Agents SDK.
# Called by: pipeline-run.sh guardrail <pipeline-id> <task-id> pre
# Location: scripts/guardrails/pre-default.sh
# Source: https://github.com/openai/openai-agents-python (guardrails)
#
# Fails if:
#   - Task description is missing or too short
#   - Task status is not pending/in-progress (already done/failed)

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

PIPELINE_ID="${1:-}"
TASK_ID="${2:-}"

[ -z "$PIPELINE_ID" ] && echo "GUARDRAIL_FAIL: pipeline-id required" && exit 1
[ -z "$TASK_ID" ] && echo "GUARDRAIL_FAIL: task-id required" && exit 1

# Load task from pipeline state
PIPELINE_FILE="$REPO_ROOT/.runtime/pipeline/$PIPELINE_ID.json"

[ ! -f "$PIPELINE_FILE" ] && echo "GUARDRAIL_FAIL: pipeline file not found" && exit 1

TASK=$(jq --arg id "$TASK_ID" '.tasks[] | select(.id == ($id | tonumber))' "$PIPELINE_FILE" 2>/dev/null)
[ -z "$TASK" ] || [ "$TASK" = "null" ] && echo "GUARDRAIL_FAIL: task $TASK_ID not found in pipeline" && exit 1

DESCRIPTION=$(echo "$TASK" | jq -r '.description // ""' 2>/dev/null)
STATUS=$(echo "$TASK" | jq -r '.status // ""' 2>/dev/null)

# Check 1: description exists
if [ -z "$DESCRIPTION" ] || [ ${#DESCRIPTION} -lt 10 ]; then
  echo "GUARDRAIL_FAIL: task description too short or empty (${#DESCRIPTION} chars)"
  echo "  Task descriptions should include target files and verification steps."
  exit 1
fi

# Check 2: status is actionable
if [ "$STATUS" != "pending" ] && [ "$STATUS" != "in-progress" ]; then
  echo "GUARDRAIL_FAIL: task status is '$STATUS', expected 'pending' or 'in-progress'"
  exit 1
fi

# Check 3: description references files (has a file path pattern)
if ! echo "$DESCRIPTION" | grep -qE '[a-zA-Z0-9_/-]+\.[a-zA-Z]+'; then
  echo "GUARDRAIL_WARN: task description may not reference specific files"
  echo "  Recommendation: include file paths in task descriptions for @worker dispatch."
fi

echo "GUARDRAIL_PASS: pre-task validation OK"
exit 0
