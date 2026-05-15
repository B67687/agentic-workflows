#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/comprehension
#
# Verifies that comprehension evidence exists and passes before implementation.
# Calls comprehension-gate.sh verify <evidence> under the hood.
#
# Standard gate interface:
#   Exit 0 = PASS (comprehension demonstrated)
#   Exit 1 = FAIL (comprehension missing  --  block)
#   Exit 2 = WARN (comprehension partial)
#   Exit 3 = SKIP (no evidence file to check)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"

echo "  ── Gate: implement/comprehension"

# Find comprehension evidence
evidence_file=""
for candidate in "$RUNTIME_DIR"/comprehension-evidence*; do
  if [[ -f "$candidate" ]]; then
    evidence_file="$candidate"
    break
  fi
done

if [[ -z "$evidence_file" ]]; then
  echo "    SKIP   No comprehension evidence found in .runtime/"
  echo "           Run: bash scripts/comprehension-gate.sh extract <instruction-file>"
  exit 3
fi

cg="$REPO_ROOT/scripts/comprehension-gate.sh"
if [[ ! -f "$cg" ]]; then
  echo "    SKIP   comprehension-gate.sh not found"
  exit 3
fi

echo "    Evidence: $(basename "$evidence_file")"
echo ""

output=$(bash "$cg" verify "$evidence_file" 2>/dev/null) || true
rc=$?
echo "$output" | sed 's/^/      /'

echo ""

case $rc in
  0)
    echo "    ✓ PASS  Comprehension demonstrated"
    exit 0
    ;;
  2)
    echo "    ⚠ WARN  Comprehension partial  --  fill missing sections"
    exit 2
    ;;
  *)
    echo "    ✗ FAIL  Comprehension check failed  --  extract then fill"
    exit 1
    ;;
esac
