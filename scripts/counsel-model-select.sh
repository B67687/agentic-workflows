#!/usr/bin/env bash
# =============================================================================
# counsel-model-select.sh - Explain current counsel role/model policy
# =============================================================================

set -euo pipefail

MODE="${1:-lite}"

usage() {
  cat <<'EOF'
Usage: ./scripts/counsel-model-select.sh [lite|full]

Prints the current role-first counsel model-selection policy.
This does not call OpenRouter. It uses the local refreshable registry.
EOF
}

case "$MODE" in
  lite|full) ;;
  --help|-h)
    usage
    exit 0
    ;;
  *)
    echo "ERROR: mode must be lite or full" >&2
    usage >&2
    exit 2
    ;;
esac

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
registry="$root/counsel-models.json"

if [[ ! -f "$registry" ]]; then
  echo "ERROR: missing counsel-models.json" >&2
  exit 1
fi

echo "Counsel mode: $MODE"
echo "Registry: $registry"
echo "Selection principle: role-based first, model-based second"
echo
echo "Evidence order:"
echo "1. OpenRouter free-model availability"
echo "2. Artificial Analysis broad intelligence, speed, latency, and cost"
echo "3. LiveBench broad contamination-limited capability"
echo "4. SWE-rebench / SWE-bench style software-agent results"
echo "5. Scale-style private evals when available"
echo "6. Hugging Face open-weight discovery and sanity checks"
echo "7. Local workspace performance"
echo
if [[ "$MODE" == "lite" ]]; then
  echo "Roles: facilitator, one role specialist, red team, secretary"
  echo "Use for: milestone choice, architecture review, optimization review, high-cost framing"
else
  echo "Roles: facilitator, product framer, user advocate, systems reviewer, red team, secretary"
  echo "Use for: long-horizon product shaping or major architecture direction"
fi
echo
echo "Rule: refresh current free availability before live OpenRouter calls."
echo "Next: read docs/counsel-model-selection.md before wiring providers."
