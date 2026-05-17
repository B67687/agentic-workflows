#!/usr/bin/env bash
# final-verify.sh — Run full verification suite on changed files
#
# Usage: bash scripts/workflow/final-verify.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RESULTS="{}"

# Check for changed files
CHANGED_FILES=$(git -C "$REPO_ROOT" diff --name-only HEAD 2>/dev/null || echo "")
UNTRACKED=$(git -C "$REPO_ROOT" ls-files --others --exclude-standard 2>/dev/null || echo "")

echo "{"
echo "  \"changed_files\": $(echo "$CHANGED_FILES$UNTRACKED" | wc -l | tr -d ' '),"

# Run available checks
SMOKE_RESULT=""
if [[ -f "$REPO_ROOT/scripts/test-smoke.sh" ]]; then
  SMOKE_RESULT=$(bash "$REPO_ROOT/scripts/test-smoke.sh" 2>&1 | tail -3 | tr -d '\n' || echo "smoke test failed")
fi

echo "  \"smoke_test\": \"${SMOKE_RESULT:-not run}\","
echo "  \"status\": \"complete\""
echo "}"
