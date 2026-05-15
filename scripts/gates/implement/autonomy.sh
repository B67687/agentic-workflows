#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/autonomy
#
# Assesses the current autonomy level based on git state and task risk.
# Calls autonomy-gate.sh quick under the hood.
#
# Standard gate interface:
#   Exit 0 = PASS (autonomy level determined)
#   Exit 1 = FAIL (cannot assess - block)
#   Exit 2 = WARN (autonomy limited)
#   Exit 3 = SKIP (autonomy-gate not available)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "  ── Gate: implement/autonomy"

ag="$REPO_ROOT/scripts/autonomy-gate.sh"
if [[ ! -f "$ag" ]]; then
  echo "    SKIP   autonomy-gate.sh not found"
  exit 3
fi

echo ""

output=$(bash "$ag" quick 2>/dev/null) || true
rc=$?
echo "$output" | sed 's/^/      /'

echo ""

if [[ $rc -eq 0 ]]; then
  # Extract autonomy level from output for summary
  level=$(echo "$output" | grep 'Autonomy:' | sed 's/.*Autonomy:\s*//' || echo "SUPERVISED")
  echo "    ✓ PASS  Autonomy level: $level"
  exit 0
else
  echo "    ⚠ WARN  Autonomy assessment incomplete"
  exit 2
fi
