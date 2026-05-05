#!/usr/bin/env bash
# =============================================================================
# north-star.sh - Preserve the large goal while preventing one-shot execution
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./scripts/north-star.sh "goal" [task-intake options]

Use this for long-horizon goals that should stay big while execution stays small.
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

GOAL="$1"
shift

INTAKE_OUTPUT="$(bash "$SCRIPT_DIR/task-intake.sh" "$GOAL" "$@")"

extract_field() {
  local label="$1"
  local text="$2"
  printf '%s\n' "$text" | awk -F': ' -v key="$label" '$1 == key {print $2; exit}'
}

TASK_NORM="$(extract_field "Task" "$INTAKE_OUTPUT")"
HORIZON="$(extract_field "Goal horizon" "$INTAKE_OUTPUT")"

decision="optional"
reason="goal does not strictly need north-star shaping first"
planning_rule="normal phased execution is probably enough"
first_artifact="a short milestone bet"
next="/start-task $TASK_NORM"

if [[ "$HORIZON" == "north-star" ]]; then
  decision="required"
  reason="goal is large enough that the vision should be preserved separately from the next slice"
  planning_rule="keep the goal large, but only bet on one milestone at a time"
  first_artifact="a north-star note with fidelity target, proof target, and anti-goals"
  next="/shape-milestone $TASK_NORM"
fi

echo "Task: $TASK_NORM"
echo "North-star decision: $decision"
echo "North-star reason: $reason"
echo "Planning rule: $planning_rule"
echo "First artifact: $first_artifact"
echo "Next command: $next"
