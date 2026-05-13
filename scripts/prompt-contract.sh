#!/usr/bin/env bash
# =============================================================================
# prompt-contract.sh - Self-prompt checklist before phase work
# =============================================================================

set -euo pipefail

PHASE="task"
TASK=""

usage() {
  cat <<'EOF'
Usage: ./scripts/prompt-contract.sh "task" [--phase task|research|plan|implement|review]

Builds a compact self-prompt contract from frontier prompting practice:
- outcome
- context
- constraints
- examples
- verification
- ask/proceed policy

Use this before non-trivial phase work so the model asks only for missing
high-impact information and otherwise proceeds with stated assumptions.
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
    --phase)
      PHASE="${2:-}"
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

case "$PHASE" in task|research|plan|implement|review) ;; *) echo "ERROR: invalid phase" >&2; exit 2 ;; esac

task_lower="$(printf '%s' "$TASK" | tr '[:upper:]' '[:lower:]')"

outcome="inferred"
context="select"
constraints="assume-light"
examples="optional"
verification="define"
ask_policy="proceed-with-assumptions"
rigor="standard"

if [[ "$task_lower" =~ (maybe|idk|not\ sure|somehow|whatever|thing|stuff|vague|help\ me\ figure) ]]; then
  outcome="unclear"
fi

if [[ "$task_lower" =~ (authoritative|extensive|comprehensive|thorough|deep\ research|deep\ dive|wide\ research|rigorous|in\ depth|exhaustive|wide\ and\ deep) ]]; then
  rigor="high"
  constraints="present"
fi

if [[ "$task_lower" =~ (exactly|1:1|one\ to\ one|recreate|clone|same\ as|like|style|feel|experience|nostalgia|ui|visual|gameplay|behavior) ]]; then
  examples="required"
fi

if [[ "$task_lower" =~ (must|only|without|never|budget|quota|deadline|cost|privacy|security|legal|safe|risk|license|public|upstream) ]]; then
  constraints="present"
fi

if [[ "$task_lower" =~ (test|verify|benchmark|measure|prove|acceptance|done\ when|success) ]]; then
  verification="present"
fi

case "$PHASE" in
  research)
    context="map-then-retrieve"
    ;;
  plan)
    context="use-research-only"
    ;;
  implement)
    context="use-plan-only"
    [[ "$verification" != "present" ]] && verification="must-define-before-edit"
    ;;
  review)
    context="use-diff-and-acceptance"
    [[ "$verification" != "present" ]] && verification="must-define-before-review"
    ;;
esac

if [[ "$outcome" == "unclear" || "$examples" == "required" || "$verification" == must-define* ]]; then
  ask_policy="ask-if-missing-high-impact-info"
fi

echo "Task: $TASK"
echo "Phase: $PHASE"
echo "Outcome: $outcome"
echo "Context: $context"
echo "Constraints: $constraints"
echo "Examples: $examples"
echo "Verification: $verification"
echo "Rigor: $rigor"
echo "Ask policy: $ask_policy"
echo "Self-prompt: State the intended outcome, use only relevant context, name constraints, request examples only when they change the result, define verification, then proceed unless a missing answer would materially change the work."
echo "If rigor is high: apply the research quality framework (source triangulation, confidence levels, authority weighting) to every finding by default --- no need to be asked."
