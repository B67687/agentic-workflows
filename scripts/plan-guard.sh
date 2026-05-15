#!/usr/bin/env bash
# =============================================================================
# plan-guard.sh - Keep planning from expanding beyond the next executable slice
#
# Also integrates plan-challenge.sh (CATFISH protocol) when --challenge is
# passed. See scripts/plan-challenge.sh for the dynamic dissent engine.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"

ROUND_COUNT=1
CHALLENGE_FLAG=false
TRIVIAL_FLAG=false

usage() {
  cat <<'EOF'
Usage: ./scripts/plan-guard.sh "task" [task-intake options] [--rounds N] [--challenge]

Protects against planning paralysis by forcing large tasks and repeated planning
rounds back to a first-slice plan.

Options:
  --rounds N        Set planning round count (default 1)
  --challenge       Run CATFISH collapse detection and generate challenge prompt
  --trivial         Mark task as trivial (challenge overrides if plan is complex)
  --size, --clarity, --risk, --verification, --separate-work, --upstream-facing, --no-fetch
                    Passed through to task-intake.sh
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
    --challenge)
      CHALLENGE_FLAG=true
      shift
      ;;
    --trivial)
      TRIVIAL_FLAG=true
      shift
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

# ---------------------------------------------------------------------------
# CATFISH collapse detection (only with --challenge)
# ---------------------------------------------------------------------------
if [[ "$CHALLENGE_FLAG" == true ]] && [[ "$decision" != "go-back" ]]; then
  CHALLENGE_SCRIPT="$SCRIPT_DIR/plan-challenge.sh"
  PLAN_JSON="$RUNTIME_DIR/plan.json"

  if [[ -f "$CHALLENGE_SCRIPT" ]]; then
    # Write a minimal plan.json for collapse detection.
    # The agent should overwrite this with a full plan before execution.
    mkdir -p "$RUNTIME_DIR"
    python3 -c "
import json, sys
plan = {
    'task': '$TASK_NORM',
    'planning_rounds': $ROUND_COUNT,
    'plan_mode': '$plan_mode',
    'plan_decision': '$decision',
    'files': [],
    'steps': [],
    'verification': '',
    'risks': [],
    'alternatives': []
}
with open('$PLAN_JSON', 'w') as f:
    json.dump(plan, f, indent=2)
" 2>/dev/null || true

    # Run collapse detection
    trivial_arg=""
    if [[ "$TRIVIAL_FLAG" == true ]]; then
      trivial_arg="--trivial"
    fi

    detect_result="$(bash "$CHALLENGE_SCRIPT" detect --plan "$PLAN_JSON" $trivial_arg 2>/dev/null || echo '{"challenge_required": false}')"

    challenge_req="$(echo "$detect_result" | python3 -c "import json,sys; print(json.load(sys.stdin).get('challenge_required', False))" 2>/dev/null || echo "false")"

    echo ""
    echo "--- CATFISH Challenge ---"

    if [[ "$challenge_req" == "True" ]] || [[ "$challenge_req" == "true" ]]; then
      signals="$(echo "$detect_result" | python3 -c "
import json,sys
d = json.load(sys.stdin)
print(', '.join(d.get('signals', [])))
" 2>/dev/null || echo "complexity,verification,risk")"

      prompt_file="$RUNTIME_DIR/plan-challenge-prompt.json"
      bash "$CHALLENGE_SCRIPT" prompt --plan "$PLAN_JSON" --out "$prompt_file" 2>/dev/null || true

      echo "Challenge: REQUIRED"
      echo "Collapse signals: $signals"
      echo ""
      echo "To dispatch a challenge subagent:"
      echo "  1. Read the challenge prompt from: $prompt_file"
      echo "  2. Spawn a @worker with that prompt (fresh context, information isolation)"
      echo "  3. Save the response to: $RUNTIME_DIR/challenge-response.json"
      echo "  4. Run: bash scripts/plan-challenge.sh reconcile --plan $PLAN_JSON --response $RUNTIME_DIR/challenge-response.json"
      echo ""
      echo "The challenge uses counterfactual post-mortem framing:"
      echo "\"Assume this plan has already failed catastrophically --- what caused it?\""
      echo "It is NOT a generic 'find flaws' review."
      echo ""
      echo "If reconcile fails: address blocking findings before proceeding."
      echo "If reconcile passes: proceed with the revised plan."
      echo ""
      echo "To skip: bash scripts/plan-challenge.sh reconcile --plan $PLAN_JSON --response /dev/null --out /dev/null 2>&1 || true"
    else
      d_reason="$(echo "$detect_result" | python3 -c "import json,sys; print(json.load(sys.stdin).get('deferred_reason', 'plan is within safe scope'))" 2>/dev/null || echo "plan is within safe scope")"
      echo "Challenge: DEFERRED ($d_reason)"
    fi
    echo "-----------------------"
  fi
fi
