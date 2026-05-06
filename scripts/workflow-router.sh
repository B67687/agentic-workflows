#!/usr/bin/env bash
# =============================================================================
# workflow-router.sh - Normal-language request router
# =============================================================================

set -euo pipefail

TASK=""
MAP=true
LIMIT="${LIMIT:-14}"

usage() {
  cat <<'EOF'
Usage: ./scripts/workflow-router.sh "task" [--no-map] [--limit n]

Routes a normal-language request through deterministic intake and returns:
- current lane
- why
- git safety
- one next action
- compact repo map when orientation is useful

This is the internal default for serious normal-language prompts.
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

TASK="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-map)
      MAP=false
      ;;
    --limit)
      LIMIT="${2:-}"
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
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

intake="$(bash "$SCRIPT_DIR/task-intake.sh" "$TASK")"
contract="$(bash "$SCRIPT_DIR/prompt-contract.sh" "$TASK" --phase task)"

field() {
  local name="$1"
  printf '%s\n' "$intake" | awk -F': ' -v key="$name" '$1 == key {print substr($0, length(key) + 3); exit}'
}

lane="$(field "Recommended lane")"
lane_reason="$(field "Lane reason")"
goal_horizon="$(field "Goal horizon")"
iteration_strategy="$(field "Iteration strategy")"
git_lane="$(field "Git lane")"
safe_to_edit="$(field "Safe to edit now")"
safety_note="$(field "Safety note")"
next_command="$(field "Next command")"
ask_policy="$(printf '%s\n' "$contract" | awk -F': ' '$1 == "Ask policy" {print $2; exit}')"

map_recommended="no"
if [[ "$MAP" == true && ( "$lane" == "research" || "$lane" == "slice-first" || "$goal_horizon" == "north-star" ) ]]; then
  map_recommended="yes"
fi

echo "Task: $TASK"
echo "Current lane: $lane"
echo "Why: $lane_reason"
echo "Goal horizon: $goal_horizon"
echo "Iteration strategy: $iteration_strategy"
echo "Git lane: $git_lane"
echo "Safe to edit: $safe_to_edit"
echo "Safety note: $safety_note"
echo "Ask policy: $ask_policy"
echo "Next action: $next_command"
echo "Repo map: $map_recommended"

if [[ "$map_recommended" == "yes" ]]; then
  echo ""
  echo "Repo map preview:"
  bash "$SCRIPT_DIR/repo-map.sh" . --limit "$LIMIT" | sed -n '1,120p'
fi
