#!/usr/bin/env bash
# =============================================================================
# task-slice.sh - Force oversized tasks into a milestone ladder plus first slice
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./scripts/task-slice.sh "task" [task-intake options]

This helper is for oversized or broad tasks that should be broken into the
next executable slice before normal planning.
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

TASK="$1"
shift

INTAKE_OUTPUT="$(bash "$SCRIPT_DIR/task-intake.sh" "$TASK" "$@")"

extract_field() {
  local label="$1"
  local text="$2"
  printf '%s\n' "$text" | awk -F': ' -v key="$label" '$1 == key {print $2; exit}'
}

TASK_NORM="$(extract_field "Task" "$INTAKE_OUTPUT")"
ITERATION_STRATEGY="$(extract_field "Iteration strategy" "$INTAKE_OUTPUT")"

task_lower="$(printf '%s' "$TASK_NORM" | tr '[:upper:]' '[:lower:]')"

decision="normal-planning"
reason="task already fits a normal research or planning cycle"
ladder_shape="3 milestones max; 1 milestone detailed now"
detail_scope="plan the whole task normally"
first_slice_goal="produce the next coherent, testable slice"
stop_line="avoid expanding into unrelated later milestones"
verification_target="one concrete proof that the first slice works"
next_command="/plan $TASK_NORM"

if [[ "$ITERATION_STRATEGY" == "slice-first" ]]; then
  decision="slice-first"
  reason="task is too large or too mixed for one efficient cycle"
  detail_scope="only detail the first executable slice; keep later milestones coarse"
  next_command="/research $TASK_NORM"

  if [[ "$task_lower" =~ (recreate|clone|1:1|game|engine|platform|system|app|from\ scratch) ]]; then
    first_slice_goal="prove one small end-to-end loop instead of the whole system"
    stop_line="exclude content expansion, full parity, and multi-system polish until the first loop works"
    verification_target="one user-visible loop can be demonstrated end to end"
  elif [[ "$task_lower" =~ (refactor|migrate|workflow|architecture|integrate) ]]; then
    first_slice_goal="change one bounded seam that proves the new direction"
    stop_line="exclude full migration, broad cleanup, and adjacent systems until the first seam is verified"
    verification_target="one bounded seam passes its targeted checks"
  fi
fi

echo "Task: $TASK_NORM"
echo "Slice decision: $decision"
echo "Slice reason: $reason"
echo "Milestone ladder shape: $ladder_shape"
echo "Detailed scope now: $detail_scope"
echo "First slice goal: $first_slice_goal"
echo "Stop line: $stop_line"
echo "Verification target: $verification_target"
echo "Next command: $next_command"
