#!/usr/bin/env bash
# =============================================================================
# plan-guard.sh - Keep planning from expanding beyond the next executable slice
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ROUND_COUNT=1

usage() {
  cat <<'EOF'
Usage: ./scripts/plan-guard.sh "task" [task-intake options] [--rounds N]

Protects against planning paralysis by forcing large tasks and repeated planning
rounds back to a first-slice plan.
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

TASK="$1"
shift

INTAKE_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rounds)
      ROUND_COUNT="${2:-}"
      shift 2
      ;;
    --size|--clarity|--risk|--verification)
      INTAKE_ARGS+=("$1" "${2:-}")
      shift 2
      ;;
    --separate-work|--upstream-facing|--no-fetch)
      INTAKE_ARGS+=("$1")
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

INTAKE_OUTPUT="$(bash "$SCRIPT_DIR/task-intake.sh" "$TASK" "${INTAKE_ARGS[@]}")"

extract_field() {
  local label="$1"
  local text="$2"
  printf '%s\n' "$text" | awk -F': ' -v key="$label" '$1 == key {print $2; exit}'
}

TASK_NORM="$(extract_field "Task" "$INTAKE_OUTPUT")"
ITERATION_STRATEGY="$(extract_field "Iteration strategy" "$INTAKE_OUTPUT")"
LANE="$(extract_field "Recommended lane" "$INTAKE_OUTPUT")"

task_lower="$(printf '%s' "$TASK_NORM" | tr '[:upper:]' '[:lower:]')"
if [[ "$task_lower" =~ (more\ specific|better\ plan|refine|again|more\ detailed|sharper\ plan|tighter\ plan) ]] && [[ "$ROUND_COUNT" -lt 2 ]]; then
  ROUND_COUNT=2
fi

decision="normal-plan"
reason="one normal planning round is enough here"
plan_mode="standard"
max_detailed_milestones="2"
max_steps_now="7"
next="produce a normal explicit plan"

if [[ "$ITERATION_STRATEGY" == "slice-first" ]]; then
  decision="first-slice-only"
  reason="oversized work should not get a full end-to-end detailed plan"
  plan_mode="milestone-ladder-plus-first-slice"
  max_detailed_milestones="1"
  max_steps_now="5"
  next="produce only a coarse milestone ladder and a detailed first slice"
fi

if [[ "$ROUND_COUNT" -ge 2 ]]; then
  decision="stop-refining"
  reason="planning has already iterated enough; pick the next executable slice"
  plan_mode="next-slice-only"
  max_detailed_milestones="1"
  max_steps_now="5"
  next="stop broadening the plan and hand off the next verified slice to implementation"
fi

if [[ "$LANE" == "grill" ]]; then
  decision="go-back"
  reason="task framing is still too ambiguous for more planning refinement"
  plan_mode="grill-first"
  next="go back to grilling before more planning"
fi

echo "Task: $TASK_NORM"
echo "Planning rounds: $ROUND_COUNT"
echo "Plan decision: $decision"
echo "Plan reason: $reason"
echo "Plan mode: $plan_mode"
echo "Max detailed milestones: $max_detailed_milestones"
echo "Max steps now: $max_steps_now"
echo "Next: $next"
