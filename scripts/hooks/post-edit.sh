#!/bin/bash
# =============================================================================
# post-edit.sh --- Post-edit pattern verification hook
#
# Runs after file edits to inspect changed files for common patterns.
# Does NOT run quality-gate.sh (that's called once by checkpoint-commit.sh).
#
# Checks performed:
#   - Missing set -euo pipefail in shell scripts
#   - TODO/FIXME markers in markdown files
#   - Binary file modifications (unusual for this repo)
#   - Smoke tests when test/script files changed
#
# Usage:
#   bash scripts/hooks/post-edit.sh <file> [file2 ...]
#   bash scripts/hooks/post-edit.sh --staged   (check staged files)
#   bash scripts/hooks/post-edit.sh --all      (check all changed files)
# =============================================================================
set -euo pipefail

COMPACT=${COMPACT:-1}
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

FILES=()
MODE="explicit"
ALL_PASSED=true

# Suppress informational output in COMPACT mode
say() { [[ "$COMPACT" == "0" ]] && echo "$@"; :; }

while [ $# -gt 0 ]; do
  case "$1" in
    --staged) MODE="staged"; shift ;;
    --all)    MODE="all"; shift ;;
    --help)   echo "Usage: bash scripts/hooks/post-edit.sh [file...|--staged|--all]"; exit 0 ;;
    *)        FILES+=("$1"); shift ;;
  esac
done

case "$MODE" in
  staged)
    mapfile -t FILES < <(git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
    ;;
  all)
    mapfile -t FILES < <(git -C "$REPO_ROOT" diff --name-only --diff-filter=ACMR 2>/dev/null || true)
    while IFS= read -r f; do
      FILES+=("$f")
    done < <(git -C "$REPO_ROOT" ls-files --others --exclude-standard 2>/dev/null || true)
    ;;
  explicit)
    ;;
esac

if [ ${#FILES[@]} -eq 0 ]; then
  say "[post-edit] No files to verify."
  exit 0
fi

say "[post-edit] Verifying ${#FILES[@]} file(s)..."

# Check for specific file patterns
for f in "${FILES[@]}"; do
  case "$f" in
    *.sh|*.bash)
      if ! head -20 "$REPO_ROOT/$f" 2>/dev/null | grep -q "set -euo pipefail\|set -eo pipefail"; then
        echo "[post-edit] ⚠  $f: missing 'set -euo pipefail'"
      fi
      ;;
    *.md)
      if grep -q 'TODO\|FIXME\|HACK' "$REPO_ROOT/$f" 2>/dev/null; then
        echo "[post-edit] ⚠  $f: contains TODOs/FIXMEs"
      fi
      ;;
  esac
done

# Check for binary file modifications
for f in "${FILES[@]}"; do
  if [ -f "$REPO_ROOT/$f" ] && file "$REPO_ROOT/$f" | grep -q "ELF\|Mach-O\|PE32"; then
    echo "[post-edit] ⚠  $f: binary file added/modified --- verify intent"
  fi
done

# Run smoke tests if test files or scripts changed
TEST_FILES=false
for f in "${FILES[@]}"; do
  if [[ "$f" == scripts/test-smoke.sh ]] || [[ "$f" == scripts/*.sh ]] && [[ "$f" != scripts/hooks/* ]]; then
    TEST_FILES=true
    break
  fi
done

if $TEST_FILES; then
  say "[post-edit] Script files changed --- running smoke tests..."
  if bash "$REPO_ROOT/scripts/test-smoke.sh" > /dev/null 2>&1; then
    say "[post-edit] Smoke tests: PASSED"
  else
    echo "[post-edit] Smoke tests: FAILED"
    ALL_PASSED=false
  fi
fi

$ALL_PASSED
