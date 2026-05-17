#!/usr/bin/env bash
# =============================================================================
# milestone-shape.sh - Turn a big goal into one bounded milestone bet
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./scripts/milestone-shape.sh "goal" [task-intake options]

Shape one milestone bet from a big goal before slice execution starts.
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

GOAL="$1"
shift

INTAKE_OUTPUT="$(bash "$SCRIPT_DIR/task-intake.sh" "$GOAL" "$@")"
SLICE_OUTPUT="$(bash "$SCRIPT_DIR/task-slice.sh" "$GOAL" "$@")"

extract_field() {
  local label="$1"
  local text="$2"
  printf '%s\n' "$text" | awk -F': ' -v key="$label" '$1 == key {print $2; exit}'
}

TASK_NORM="$(extract_field "Task" "$INTAKE_OUTPUT")"
ITERATION_STRATEGY="$(extract_field "Iteration strategy" "$INTAKE_OUTPUT")"
FIRST_SLICE_GOAL="$(extract_field "First slice goal" "$SLICE_OUTPUT")"
VERIFICATION_TARGET="$(extract_field "Verification target" "$SLICE_OUTPUT")"

milestone_bet="one bounded user-visible capability that moves the large goal forward"
appetite="1-3 verified slices"
not_now="full parity, broad polish, and adjacent systems"
next="/research $TASK_NORM"

if [[ "$ITERATION_STRATEGY" != "slice-first" ]]; then
  appetite="1 verified slice"
  not_now="anything beyond the current straightforward task"
fi

echo "Task: $TASK_NORM"
echo "Milestone bet: $milestone_bet"
echo "Milestone appetite: $appetite"
echo "Milestone proof: $VERIFICATION_TARGET"
echo "Not now: $not_now"
echo "First slice target: $FIRST_SLICE_GOAL"
echo "Next command: $next"
