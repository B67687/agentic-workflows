#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/change-visibility
#
# Checks that staged changes have adequate documentation context.
# Advisory only — does not block implementation, but flags when changes
# might need better documentation.
#
# Standard gate interface:
#   Exit 0 = PASS (changes are visible and documented)
#   Exit 2 = WARN (changes may need better documentation)
#   Exit 3 = SKIP (no changes staged)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "  ── Gate: implement/change-visibility"

# Check for staged changes
staged_files=$(git -C "$REPO_ROOT" diff --cached --name-only 2>/dev/null || true)
if [[ -z "$staged_files" ]]; then
  echo "    SKIP   No staged changes to review"
  exit 3
fi

# Count changes by type
new_files=$(echo "$staged_files" | grep -c '^A\|^?' 2>/dev/null || true)
modified=$(echo "$staged_files" | wc -l | tr -d ' ')
changed_docs=$(echo "$staged_files" | grep -c '\.md$' 2>/dev/null || true)
changed_scripts=$(echo "$staged_files" | grep -c '\.sh$' 2>/dev/null || true)

echo "    Files staged: $modified"
echo "    New files: $new_files"
echo "    Docs changed: $changed_docs"
echo "    Scripts changed: $changed_scripts"

# Check active goal for context
warnings=0
active_goal=$(python3 -c "
import json
try:
    with open('$REPO_ROOT/.runtime/goal-tree.json') as f:
        d = json.load(f)
    active = d.get('active', '')
    if active and active in d.get('nodes', {}):
        print(d['nodes'][active]['title'][:80])
except:
    pass
" 2>/dev/null || true)

if [[ -z "$active_goal" ]]; then
  echo "    ⚠  No active goal tree node — consider creating one with goal-tree.sh"
  warnings=$((warnings + 1))
else
  echo "    Active goal: $active_goal"
fi

# Warn on large unstaged changes (changes that won't be visible)
unstaged=$(git -C "$REPO_ROOT" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
if [[ "$unstaged" -gt 0 ]]; then
  echo "    ℹ  $unstaged unstaged change(s) not included"
fi

echo ""

if [[ "$warnings" -eq 0 ]]; then
  echo "    ✓ PASS  Changes are trackable"
  exit 0
else
  echo "    ⚠ WARN  $warnings visibility suggestion(s)"
  exit 2
fi
