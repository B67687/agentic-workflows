#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/quality-check
#
# Runs the folder quality audit during implement phase transitions.
# Ensures quality standards are met before implementation proceeds.
#
# Standard gate interface:
#   Exit 0 = PASS (quality standards met)
#   Exit 2 = WARN (quality issues found — advisory, not blocking)
#   Exit 3 = SKIP (audit script not found)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "  ── Gate: implement/quality-check"

AUDIT_SCRIPT="$REPO_ROOT/scripts/audit-folder-quality.sh"
if [[ ! -f "$AUDIT_SCRIPT" ]]; then
  echo "    SKIP   audit-folder-quality.sh not found"
  exit 3
fi

echo "    Running folder quality audit..."

output=$(bash "$AUDIT_SCRIPT" 2>&1) || true
rc=$?

# Count warnings in output
warn_count=$(echo "$output" | grep -c '\[WARN\]' 2>/dev/null || true)
error_count=$(echo "$output" | grep -c '\[ERROR\]' 2>/dev/null || true)
total_issues=$((warn_count + error_count))

echo "$output" | grep -E '\[WARN\]|\[ERROR\]|PASS|FAIL' | sed 's/^/      /'

echo ""

if [[ "$total_issues" -eq 0 ]]; then
  echo "    ✓ PASS  All quality standards met"
  exit 0
else
  echo "    ⚠ WARN  $total_issues quality issue(s) found (advisory)"
  exit 2
fi
