#!/usr/bin/env bash
# =============================================================================
# task-tree.sh - Break a large goal into a navigable domain/milestone/slice tree
# =============================================================================

set -euo pipefail

TASK="${1:-}"
FETCH=true

usage() {
  cat <<'EOF'
Usage: ./scripts/task-tree.sh "big goal" [--no-fetch]

Builds a decomposition tree:
- domains
- milestones
- first slices
- dependency notes
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
iteration="$(printf '%s\n' "$intake" | awk -F': ' '/^Iteration strategy:/ {print $2}')"
task_lower="$(printf '%s' "$TASK" | tr '[:upper:]' '[:lower:]')"

domains="product-experience, technical-foundation, content, feedback-polish"
if [[ "$task_lower" =~ (game|roblox|battlegrounds|multiplayer|3d|avatar|combat) ]]; then
  domains="product-experience, game-design, player-controller, 3d-world, combat-system, client-server, content-pipeline, feedback-polish"
elif [[ "$task_lower" =~ (app|platform|saas|tool|dashboard) ]]; then
  domains="product-experience, data-model, core-workflows, interface, backend-services, integration, operations, feedback-polish"
fi

cat <<EOF
Task: $TASK
Goal horizon: $goal_horizon
Iteration strategy: $iteration
Tree decision: required for broad goals before milestone planning

Recommended domains: $domains

Tree shape:
- Goal
- Domains
- Milestones per domain
- First verified slice per milestone
- Dependencies and not-now notes

Output required:
- one-line goal
- domain tree
- first milestone candidates
- dependency order
- recommended first milestone
- recommended first slice
- next command

Rules:
- Keep the big tree coarse.
- Detail only the recommended first slice.
- Do not turn every leaf into a full plan yet.
- Use the tree to prevent forgetting major workstreams, not to plan the whole project in detail.

Next command: /shape-milestone $TASK
EOF
