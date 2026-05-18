#!/usr/bin/env bash
# =============================================================================
# Gate plugin: verify/quality-speed
#
# Recommends verification depth based on change size and risk.
# Calls quality-speed-gate.sh quick under the hood.
#
# Standard gate interface:
#   Exit 0 = PASS (verification depth recommended)
#   Exit 1 = FAIL (cannot assess)
#   Exit 2 = WARN (verification gap)
#   Exit 3 = SKIP (no quality-speed gate available)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "  ── Gate: verify/quality-speed"

qsg="$REPO_ROOT/scripts/quality-speed-gate.sh"
if [[ ! -f "$qsg" ]]; then
  echo "    SKIP   quality-speed-gate.sh not found"
  exit 3
fi

echo ""

output=$(bash "$qsg" quick 2>/dev/null) || true
rc=$?
echo "$output" | sed 's/^/      /'

echo ""

if [[ $rc -eq 0 ]]; then
  echo "    ✓ PASS  Verification depth determined"
  exit 0
else
  echo "    ⚠ WARN  Verification assessment incomplete"
  echo "           Run: bash scripts/quality-speed-gate.sh assess --changed-lines N"
  exit 2
fi
