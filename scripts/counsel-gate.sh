#!/usr/bin/env bash
# =============================================================================
# counsel-gate.sh - Decide when a multi-perspective review is worth the cost
# =============================================================================

set -euo pipefail

TASK="${1:-}"
FETCH=true

usage() {
  cat <<'EOF'
Usage: ./scripts/counsel-gate.sh "task" [--no-fetch]

Decides whether to use a counsel-style review:
- none: ordinary execution
- lite: 3-role independent review
- full: structured product or architecture council
EOF
}

if [[ -z "$TASK" ]]; then
  usage >&2
  exit 2
fi

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-fetch)
      FETCH=false
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
  shift
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
intake_args=("$TASK")
if [[ "$FETCH" == false ]]; then
  intake_args+=("--no-fetch")
fi

intake="$(bash "$script_dir/task-intake.sh" "${intake_args[@]}")"
goal_horizon="$(printf '%s\n' "$intake" | awk -F': ' '/^Goal horizon:/ {print $2}')"
lane="$(printf '%s\n' "$intake" | awk -F': ' '/^Recommended lane:/ {print $2}')"
iteration="$(printf '%s\n' "$intake" | awk -F': ' '/^Iteration strategy:/ {print $2}')"
task_lower="$(printf '%s' "$TASK" | tr '[:upper:]' '[:lower:]')"

mode="none"
reason="single-thread execution is enough"
roles="none"
next="/start-task $TASK"

if [[ "$goal_horizon" == "north-star" ]]; then
  mode="full"
  reason="long-horizon product goals benefit from independent framing, risk, and compression views"
  roles="facilitator, product-framer, user-advocate, systems-reviewer, red-team, secretary"
  next="/shape-product $TASK"
elif [[ "$task_lower" =~ (milestone|bet|architecture|platform|irreversible|strategy|tradeoff|pivot|fundamental|roadmap) ]]; then
  mode="lite"
  reason="strategic or architectural decisions deserve a small independent challenge before commitment"
  roles="facilitator, systems-reviewer, red-team, secretary"
  next="/research $TASK"
elif [[ "$lane" == "grill" || "$iteration" == "slice-first" ]]; then
  mode="lite"
  reason="broad or ambiguous tasks benefit from a short independent challenge before planning"
  roles="facilitator, product-framer, red-team, secretary"
  next="/shape-product $TASK"
fi

cat <<EOF
Task: $TASK
Counsel mode: $mode
Reason: $reason
Goal horizon: $goal_horizon
Recommended lane: $lane
Iteration strategy: $iteration
Roles: $roles

Counsel rules:
- Use counsel only for shaping, milestone choice, architecture review, or high-cost decisions.
- Keep implementation single-threaded unless there is a clearly bounded parallel worktree task.
- Generate independent views first, then compress conflicts into one decision.
- Prefer fewer strong roles over a large noisy panel.

Output required:
- decision being reviewed
- strongest supporting view
- strongest objection
- missing facts
- compressed recommendation
- next command

Next command: $next
EOF
