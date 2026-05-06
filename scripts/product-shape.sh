#!/usr/bin/env bash
# =============================================================================
# product-shape.sh - Extract product intent before milestone or slice planning
# =============================================================================

set -euo pipefail

TASK="${1:-}"
FETCH=true

usage() {
  cat <<'EOF'
Usage: ./scripts/product-shape.sh "goal" [--no-fetch]

Shapes a broad product goal into a compact target:
- final experience
- fidelity anchors
- edge cases
- anti-goals
- first proof
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

decision="optional"
depth="focused"
reason="goal looks close enough to ordinary task intake"

if [[ "$goal_horizon" == "north-star" ]]; then
  decision="required"
  depth="deep"
  reason="long-horizon goals need final-experience extraction before milestone shaping"
elif [[ "$lane" == "grill" || "$iteration" == "slice-first" ]]; then
  decision="recommended"
  depth="focused"
  reason="the task is broad or ambiguous enough that product intent should be compressed first"
fi

cat <<EOF
Task: $TASK
Product-shaping decision: $decision
Reason: $reason
Depth: $depth
Goal horizon: $goal_horizon
Recommended lane: $lane
Iteration strategy: $iteration

Return artifact:
- Product promise: one plain sentence describing the final lived experience.
- Fidelity anchors: 3-5 details that must feel right.
- Non-goals: what should not be solved in the first milestone.
- Edge cases: what would make the product feel false or broken.
- First proof: the smallest demo that proves the direction is real.

Grilling questions:
1. What should the user feel or be able to do when this is successful?
2. Which details are non-negotiable for the experience to feel faithful?
3. What can be fake, placeholder, or simplified in the first milestone?
4. What edge case would make the result feel wrong even if it technically works?
5. What is the smallest proof that would make you believe this direction is worth continuing?

Next command: /north-star $TASK
EOF
