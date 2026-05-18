#!/usr/bin/env bash
# =============================================================================
# Gate plugin: research/sufficiency
#
# Auto-discovers the most recent research note and checks for red flags.
# Calls research-sufficiency.sh note <file> under the hood.
#
# Standard gate interface:
#   Exit 0 = PASS (research sufficient)
#   Exit 1 = FAIL (critical gaps --- block phase transition)
#   Exit 2 = WARN (minor gaps --- proceed with caution)
#   Exit 3 = SKIP (no research note found)
#
# Output: structured gate result to stdout
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"

echo "  ── Gate: research/sufficiency"

# Auto-discover the most recent research note
research_note=""

# Check .runtime/ for evidence files first
for candidate in "$RUNTIME_DIR"/research-evidence*.md "$RUNTIME_DIR"/research-note*.md; do
  if [[ -f "$candidate" ]]; then
    research_note="$candidate"
    break
  fi
done

# Fall back to research/*.md
if [[ -z "$research_note" ]]; then
  for candidate in "$REPO_ROOT"/research/*.md; do
    if [[ -f "$candidate" ]]; then
      research_note="$candidate"
    fi
  done
fi

if [[ -z "$research_note" ]] || [[ ! -f "$research_note" ]]; then
  echo "    SKIP   No research note found (checked .runtime/ and research/)"
  echo "           Run: bash scripts/research-sufficiency.sh assess"
  exit 3
fi

rs="$REPO_ROOT/scripts/research-sufficiency.sh"
if [[ ! -f "$rs" ]]; then
  echo "    SKIP   research-sufficiency.sh not found"
  exit 3
fi

echo "    Note:  $(basename "$research_note")"
echo ""

# Capture output and exit code from the research-sufficiency check
output=$(bash "$rs" note "$research_note" 2>/dev/null) || true
rc=$?
echo "$output" | sed 's/^/      /'

echo ""

case $rc in
  0)
    echo "    ✓ PASS"
    exit 0
    ;;
  2)
    echo "    ⚠ WARN  Research has gaps --- review warnings above"
    exit 2
    ;;
  *)
    echo "    ✗ FAIL  Research has critical gaps --- go back to research"
    exit 1
    ;;
esac
