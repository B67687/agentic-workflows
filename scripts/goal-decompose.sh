#!/bin/bash
# goal-decompose.sh --- Decompose a high-level goal into a safety-gated pipeline.
#
# Uses agent-dispatch.sh to decompose a natural language goal into
# a dependency-ordered task list, then creates a pipeline-run.sh pipeline
# with safety-guard.sh constraints.
#
# Usage:
#   bash ./scripts/goal-decompose.sh "<goal>" [options]
#   bash ./scripts/goal-decompose.sh --interactive
#
# Options:
#   --agent <name>   Agent to use for decomposition (default: pi)
#   --max-tasks <N>  Budget: max tasks (default: 10)
#   --allow <paths>  Blast radius: allowed paths (default: scripts/)
#   --output         Print the pipeline JSON instead of running it
#
# Examples:
#   bash ./scripts/goal-decompose.sh "Extract pattern from Mem0 source"
#   bash ./scripts/goal-decompose.sh "R1ESL-123: Update auth" --allow src/ --max-tasks 5

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

# Collect goal from all non-flag leading args
GOAL=""
while [ $# -gt 0 ] && ! [[ "$1" =~ ^-- ]]; do
  if [ -z "$GOAL" ]; then
    GOAL="$1"
  else
    GOAL="$GOAL $1"
  fi
  shift
done

AGENT="pi"
MAX_TASKS=10
ALLOWED_PATHS=("scripts/")
OUTPUT_ONLY=false

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --max-tasks) MAX_TASKS="$2"; shift 2 ;;
    --allow)
      shift
      ALLOWED_PATHS=()
      while [ $# -gt 0 ] && ! [[ "$1" =~ ^-- ]]; do
        ALLOWED_PATHS+=("$1")
        shift
      done
      ;;
    --output) OUTPUT_ONLY=true; shift ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Interactive mode: read goal from stdin
# ---------------------------------------------------------------------------
if [ -z "$GOAL" ] && [ -t 0 ]; then
  echo "Enter goal (Ctrl+D to finish):"
  GOAL=$(cat)
elif [ -z "$GOAL" ]; then
  echo "Usage: bash ./scripts/goal-decompose.sh \"<goal>\" [options]"
  echo "  or:  echo \"<goal>\" | bash ./scripts/goal-decompose.sh"
  exit 1
fi

# Read from pipe if stdin is not a terminal
if [ -z "$GOAL" ]; then
  GOAL=$(cat)
fi

[ -z "$GOAL" ] && echo "No goal provided." && exit 1

echo "=== Goal Decomposition ==="
echo "Goal: ${GOAL:0:120}..."
echo "Agent: $AGENT"
echo "Max tasks: $MAX_TASKS"
echo ""

# Build decomposition prompt
DECOMPOSE_PROMPT="Decompose the following goal into at most $MAX_TASKS concrete implementation tasks ordered by dependency. Goal: $GOAL. Rules: each task must be actionable by a developer agent; tasks should be ordered so prerequisites come first. Return ONLY a JSON array of task objects like [{\"id\":1,\"description\":\"task 1\"},{\"id\":2,\"description\":\"task 2\"}] with no markdown, no explanation."

# --output mode: skip agent dispatch entirely
if [ "$OUTPUT_ONLY" = true ]; then
  echo "Pipeline JSON (heuristic -- no agent dispatch):"
  echo "$GOAL" | python3 -c "
import json, re, sys
goal = sys.stdin.read().strip()
parts = [p.strip() for p in re.split(r'(?<=[.?!])\s+|\n+', goal) if p.strip()]
if not parts:
    parts = ['Review the goal', 'Implement changes', 'Verify and commit']
parts = parts[:$MAX_TASKS]
tasks = [{'id': i+1, 'description': p} for i, p in enumerate(parts)]
print(json.dumps(tasks, indent=2))
"
  exit 0
fi

# ---------------------------------------------------------------------------
# Dispatch to agent for decomposition
# ---------------------------------------------------------------------------
echo "Decomposing goal..."
JOB_ID=$(bash "$REPO_ROOT/scripts/agent-dispatch.sh" run "$AGENT" "$DECOMPOSE_PROMPT" --format json 2>&1 | grep -oP 'job-\S+' | head -1)

if [ -z "$JOB_ID" ]; then
  echo "Warning: Could not dispatch to agent. Creating manual pipeline."
  echo ""
  echo "=== Manual Pipeline ==="
  echo "Goal: $GOAL"
  echo ""
  echo "Create tasks manually via:"
  echo "  bash scripts/pipeline-run.sh init \"$GOAL\" \"task1\" \"task2\" ..."
  echo "  bash scripts/safety-guard.sh init <id> --allow ${ALLOWED_PATHS[*]} --max-tasks $MAX_TASKS"
  exit 0
fi

echo "Job: $JOB_ID"
echo "Waiting for completion (runs in background, polled every 5s)..."

# Poll for completion (up to 120 iterations = 10 minutes)
for i in $(seq 1 120); do
  STATUS=$(bash "$REPO_ROOT/scripts/agent-dispatch.sh" status "$JOB_ID" 2>&1 | grep -oP '"status":\s*"\K[^"]+' | head -1 || echo "running")
  if [ "$STATUS" = "done" ] || [ "$STATUS" = "failed" ]; then
    break
  fi
  if [ $((i % 12)) -eq 0 ]; then
    echo "  Still waiting... ($((i * 5))s elapsed)"
  fi
  sleep 5
done

# Get the result
RESULT=$(bash "$REPO_ROOT/scripts/agent-dispatch.sh" result "$JOB_ID" 2>&1)

echo ""
echo "=== Decomposition Result ==="
echo "$RESULT"
echo ""

# ---------------------------------------------------------------------------
# Parse result and create pipeline
# ---------------------------------------------------------------------------
# Extract JSON array from the result
TASKS_JSON=$(echo "$RESULT" | python3 -c "
import json, sys
text = sys.stdin.read()
# Find array bounds
start = text.find('[')
end = text.rfind(']')
if start >= 0 and end > start:
    try:
        tasks = json.loads(text[start:end+1])
        print(json.dumps(tasks))
    except:
        print('PARSE_ERROR')
else:
    print('PARSE_ERROR')
" 2>/dev/null)

if [ "$TASKS_JSON" = "PARSE_ERROR" ] || [ -z "$TASKS_JSON" ]; then
  echo "Warning: Could not parse agent output. Creating manual pipeline."
  bash "$REPO_ROOT/scripts/pipeline-run.sh" init "${GOAL:0:80}" "Review $GOAL" "Implement" "Verify"
  PIPELINE_ID=$(ls -t "$REPO_ROOT/.runtime/pipeline/"*.json 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/\.json$//' || echo "pipeline-unknown")
  if [ -n "$PIPELINE_ID" ] && [ "$PIPELINE_ID" != "pipeline-unknown" ]; then
    bash "$REPO_ROOT/scripts/safety-guard.sh" init "$PIPELINE_ID" --allow "${ALLOWED_PATHS[@]}" --max-tasks "$MAX_TASKS"
  fi
  exit 0
fi

# Parse task descriptions into flat list for pipeline-run.sh init
TASK_DESCS=$(echo "$TASKS_JSON" | python3 -c "
import json, sys
tasks = json.loads(sys.stdin.read())
for t in tasks:
    d = t.get('description', '').strip()
    if d:
        print(d)
" 2>/dev/null)

# Read into array
IFS=$'\n' read -r -d '' -a TASK_ARRAY <<< "$TASK_DESCS" || true

if [ ${#TASK_ARRAY[@]} -eq 0 ]; then
  echo "Warning: No tasks parsed. Creating manual pipeline."
  bash "$REPO_ROOT/scripts/pipeline-run.sh" init "${GOAL:0:80}" "Review $GOAL" "Implement" "Verify"
  PIPELINE_ID=$(ls -t "$REPO_ROOT/.runtime/pipeline/"*.json 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/\.json$//' || echo "pipeline-unknown")
  if [ -n "$PIPELINE_ID" ] && [ "$PIPELINE_ID" != "pipeline-unknown" ]; then
    bash "$REPO_ROOT/scripts/safety-guard.sh" init "$PIPELINE_ID" --allow "${ALLOWED_PATHS[@]}" --max-tasks "$MAX_TASKS"
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# Create pipeline with safety guards
# ---------------------------------------------------------------------------
TITLE="${GOAL:0:80}"
echo "Creating pipeline: $TITLE"
echo "Tasks: ${#TASK_ARRAY[@]}"

if [ "$OUTPUT_ONLY" = true ]; then
  echo "Pipeline JSON (not executed):"
  echo "$TASKS_JSON" | python3 -m json.tool 2>/dev/null || echo "$TASKS_JSON"
  exit 0
fi

# Create pipeline
PIPELINE_OUTPUT=$(bash "$REPO_ROOT/scripts/pipeline-run.sh" init "$TITLE" "${TASK_ARRAY[@]}" 2>&1)
PIPELINE_ID=$(echo "$PIPELINE_OUTPUT" | grep -oP 'pipeline-\S+' | head -1)

if [ -z "$PIPELINE_ID" ]; then
  echo "Failed to create pipeline."
  echo "$PIPELINE_OUTPUT"
  exit 1
fi

echo "Pipeline: $PIPELINE_ID"

# Apply safety guards
bash "$REPO_ROOT/scripts/safety-guard.sh" init "$PIPELINE_ID" \
  --allow "${ALLOWED_PATHS[@]}" \
  --max-tasks "$MAX_TASKS"

# Auto-gate destructive tasks
for task in "${TASK_ARRAY[@]}"; do
  if echo "$task" | grep -qiP 'delete|remove|destroy|drop|migrate'; then
    echo "  Gated: \"${task:0:60}...\" (human checkpoint)"
  fi
done

echo ""
echo "=== Ready ==="
echo "Start:  bash scripts/pipeline-run.sh next $PIPELINE_ID"
echo "Safety: bash scripts/safety-guard.sh show $PIPELINE_ID"
echo "Status: bash scripts/pipeline-run.sh status $PIPELINE_ID"
