#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/decomposition
#
# Ensures a documented milestone ladder exists before implementation.
# Calls decomposition-gate.sh validate under the hood.
#
# This implements the key finding from decomposition enforcement research:
# programmatic gates at the plan→implement boundary catch the common failure
# of "planning as you go" — starting implementation without a clear decomposition.
#
# Standard gate interface:
#   Exit 0 = PASS (decomposition documented and valid)
#   Exit 1 = FAIL (decomposition missing or invalid — block)
#   Exit 2 = WARN (decomposition exists with minor issues)
#   Exit 3 = SKIP (no artifact to check)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"

echo "  ── Gate: implement/decomposition"

# Check the decomposition-gate.sh exists
dg="$REPO_ROOT/scripts/decomposition-gate.sh"
if [[ ! -f "$dg" ]]; then
  echo "    SKIP   decomposition-gate.sh not found"
  exit 3
fi

# Check for milestone ladder artifact
MILESTONE_FILE="$RUNTIME_DIR/milestone-ladder.json"
if [[ ! -f "$MILESTONE_FILE" ]]; then
  echo "    SKIP   No milestone-ladder.json found in .runtime/"
  echo ""
  echo "    Before implementation, document your decomposition:"
  echo "      bash scripts/decomposition-gate.sh init \"<task description>\""
  echo "      # Then edit .runtime/milestone-ladder.json"
  echo "      bash scripts/decomposition-gate.sh validate"
  exit 3
fi

echo "    Artifact: $(basename "$MILESTONE_FILE")"
echo ""

# Run the validation
# Note: $? captures exit code from $( ) correctly even without || true.
# $( ) subshell failures do not propagate to the outer script with set -e.
output=$(bash "$dg" validate "$MILESTONE_FILE" 2>&1)
rc=$?
echo "$output" | sed 's/^/      /'

echo ""

case $rc in
0)
  echo "    ✓ PASS  Decomposition complete and valid"
  exit 0
  ;;
2)
  echo "    ⚠ WARN  Decomposition exists but has minor issues — review warnings above"
  exit 2
  ;;
*)
  echo "    ✗ FAIL  Decomposition check failed — run decomposition-gate.sh init to create milestone ladder"
  exit 1
  ;;
esac
