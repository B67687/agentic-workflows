#!/usr/bin/env bash
# =============================================================================
# ambiguity-check.sh — Gate plugin: check for unresolved [NEEDS CLARIFICATION]
# Exit codes: 0=pass (no markers), 1=fail (markers found), 3=skip (no artifacts)
#
# Part of the convention-based gate plugin system.
# Discovered automatically by phase-gate.sh --check-quality implement.
# =============================================================================

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"
RUNTIME_DIR="$REPO_ROOT/.runtime"

echo "  Gate: ambiguity-check.sh"
echo "  Check: scanning for unresolved [NEEDS CLARIFICATION] markers..."

# Collect files to scan
FILES=()
while IFS= read -r -d '' f; do
  FILES+=("$f")
done < <(find "$REPO_ROOT/research" -maxdepth 1 -name '*.md' -type f 2>/dev/null || true)
while IFS= read -r -d '' f; do
  FILES+=("$f")
done < <(find "$REPO_ROOT/specs" -maxdepth 2 -name 'spec.md' -type f 2>/dev/null || true)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "  Result: SKIP (no plan/spec files to scan)"
  exit 3
fi

TOTAL=0
for f in "${FILES[@]}"; do
  markers=$(grep -c '\[NEEDS CLARIFICATION' "$f" 2>/dev/null || echo 0)
  if [[ "$markers" -gt 0 ]]; then
    echo "  WARN: $markers unresolved marker(s) in $(basename "$f")"
    grep -n '\[NEEDS CLARIFICATION' "$f" 2>/dev/null | head -3 | sed 's/^/        /'
    TOTAL=$((TOTAL + markers))
  fi
done

if [[ "$TOTAL" -gt 0 ]]; then
  echo "  Result: FAIL ($TOTAL unresolved ambiguity markers)"
  echo "  Action: Resolve [NEEDS CLARIFICATION] markers before implementing."
  echo "          Each marker represents an assumption the LLM flagged instead of guessing."
  exit 1
fi

echo "  Result: PASS (no ambiguity markers found)"
exit 0
