#!/usr/bin/env bash
# =============================================================================
# counsel-run.sh - Optional OpenRouter-backed counsel runner
# =============================================================================

set -euo pipefail

TASK="${1:-}"
MODE="${COUNSEL_MODE:-lite}"
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: ./scripts/counsel-run.sh "decision" [--mode lite|full] [--dry-run]

Runs a counsel-style review.

Requires OPENROUTER_API_KEY for live calls.
Without a key, use --dry-run to see the role plan.
EOF
}

if [[ -z "$TASK" ]]; then
  usage >&2
  exit 2
fi

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift
      ;;
    --dry-run)
      DRY_RUN=true
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

case "$MODE" in
  lite|full) ;;
  *)
    echo "ERROR: mode must be lite or full" >&2
    exit 2
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/.." && pwd)"
registry="$root/counsel-models.json"

if [[ ! -f "$registry" ]]; then
  echo "ERROR: missing counsel-models.json" >&2
  exit 1
fi

echo "Task: $TASK"
bash "$script_dir/counsel-gate.sh" "$TASK" --no-fetch
echo
bash "$script_dir/counsel-model-select.sh" "$MODE"
echo

if [[ "$DRY_RUN" == true || -z "${OPENROUTER_API_KEY:-}" ]]; then
  echo "Counsel execution: dry-run"
  echo "Reason: OPENROUTER_API_KEY is not set or --dry-run was requested"
  echo "Next: set OPENROUTER_API_KEY and rerun when live model calls are desired"
  exit 0
fi

pick_model() {
  local index="$1"
  jq -r ".current_free_candidate_pool[$index].id" "$registry"
}

facilitator_model="${COUNSEL_FACILITATOR_MODEL:-$(pick_model 0)}"
specialist_model="${COUNSEL_SPECIALIST_MODEL:-$(pick_model 2)}"
red_team_model="${COUNSEL_RED_TEAM_MODEL:-$(pick_model 4)}"
secretary_model="${COUNSEL_SECRETARY_MODEL:-$(pick_model 7)}"

call_model() {
  local role="$1"
  local model="$2"
  local prompt="$3"

  jq -n \
    --arg model "$model" \
    --arg system "You are the $role in a counsel review. Be concise, specific, and decision-oriented." \
    --arg user "$prompt" \
    '{model: $model, messages: [{role: "system", content: $system}, {role: "user", content: $user}], temperature: 0.2}' |
    curl -sS https://openrouter.ai/api/v1/chat/completions \
      -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
      -H "Content-Type: application/json" \
      -H "HTTP-Referer: https://github.com/B67687/ai-prompting" \
      -H "X-Title: ai-prompting counsel" \
      -d @- |
    jq -r '.choices[0].message.content // .error.message // "ERROR: empty response"'
}

base_prompt="Decision to review: $TASK

Return:
- your role view
- strongest supporting point
- strongest objection or risk
- missing facts
- recommended next workflow command"

echo "Counsel execution: live"
echo "Facilitator model: $facilitator_model"
echo "Specialist model: $specialist_model"
echo "Red team model: $red_team_model"
echo "Secretary model: $secretary_model"
echo

facilitator_out="$(call_model facilitator "$facilitator_model" "$base_prompt")"
specialist_out="$(call_model specialist "$specialist_model" "$base_prompt")"
red_team_out="$(call_model red-team "$red_team_model" "$base_prompt")"

secretary_prompt="Compress these counsel views into one decision artifact for: $TASK

Facilitator:
$facilitator_out

Specialist:
$specialist_out

Red team:
$red_team_out

Return:
- decision reviewed
- strongest support
- strongest objection
- missing facts
- compressed recommendation
- next command"

call_model secretary "$secretary_model" "$secretary_prompt"
