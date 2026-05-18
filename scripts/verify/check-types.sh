#!/usr/bin/env bash
# =============================================================================
# check-types.sh — Run type checking on the project
#
# Detects the project type and runs appropriate type checker.
# Outputs JSON with type check results.
#
# Usage: bash scripts/verify/check-types.sh
# Output: JSON
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

STATUS="pass"
ERROR_MSGS=""

# ── TypeScript ──
if [[ -f "tsconfig.json" ]]; then
  TSC_OUTPUT=$(npx tsc --noEmit 2>&1 || true)
  ERR_COUNT=$(echo "$TSC_OUTPUT" | grep -c "error TS" || true)
  if [[ "$ERR_COUNT" -gt 0 ]]; then
    STATUS="fail"
    ERROR_MSGS="$ERROR_MSGS TypeScript: $ERR_COUNT error(s)."
  fi
fi

# ── Python (if mypy available) ──
if command -v mypy &>/dev/null && ls mypy.ini setup.cfg pyproject.toml 2>/dev/null | grep -q .; then
  MYPY_OUTPUT=$(mypy --ignore-missing-imports 2>&1 || true)
  ERR_COUNT=$(echo "$MYPY_OUTPUT" | grep -c "error:" || true)
  if [[ "$ERR_COUNT" -gt 0 ]]; then
    STATUS="fail"
    ERROR_MSGS="$ERROR_MSGS mypy: $ERR_COUNT error(s)."
  fi
fi

SUMMARY="Type checking: $STATUS"
if [[ -n "$ERROR_MSGS" ]]; then
  SUMMARY="$SUMMARY $ERROR_MSGS"
fi

python3 -c "
import json
print(json.dumps({
    'status': '$STATUS',
    'errors': '$ERROR_MSGS',
    'summary': '$SUMMARY'
}))
"
exit 0
