#!/bin/bash
# =============================================================================
# post-edit.sh --- Post-edit quality verification hook
#
# Runs after any file edit/write/creation. Verifies quality, feeds results
# into the feedback aggregator, and surfaces issues for the next agent turn.
#
# This is the orchestration-layer equivalent of DeepSeek-TUI's LSP post-edit
# diagnostics --- automatically inspecting changes and feeding results back
# into the feedback loop before the agent continues.
#
# Usage:
#   bash scripts/hooks/post-edit.sh <file> [file2 ...]
#   bash scripts/hooks/post-edit.sh --staged   (check staged files)
#   bash scripts/hooks/post-edit.sh --all      (check all changed files)
#
# Called automatically by checkpoint-commit.sh and serve-mcp.py.
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGGREGATOR="$REPO_ROOT/scripts/feedback-aggregator.sh"
QUALITY_GATE="$REPO_ROOT/scripts/hooks/quality-gate.sh"

FILES=()
MODE="explicit"

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
    # Get list of staged files
    mapfile -t FILES < <(git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
    ;;
  all)
    # Get all changed files (staged + unstaged + untracked)
    mapfile -t FILES < <(git -C "$REPO_ROOT" diff --name-only --diff-filter=ACMR 2>/dev/null || true)
    while IFS= read -r f; do
      FILES+=("$f")
    done < <(git -C "$REPO_ROOT" ls-files --others --exclude-standard 2>/dev/null || true)
    ;;
  explicit)
    # FILES already populated from args
    ;;
esac

if [ ${#FILES[@]} -eq 0 ]; then
  echo "[post-edit] No files to verify."
  exit 0
fi

echo "[post-edit] Verifying ${#FILES[@]} file(s)..."

ALL_PASSED=true

# Filter to shell scripts for quality gate checks
SH_FILES=()
for f in "${FILES[@]}"; do
  if [[ "$f" == *.sh ]] || [[ "$f" == *.bash ]]; then
    SH_FILES+=("$REPO_ROOT/$f")
  fi
done

# Run quality gate on shell scripts
if [ ${#SH_FILES[@]} -gt 0 ]; then
  if [ -f "$QUALITY_GATE" ]; then
    if bash "$QUALITY_GATE" "${SH_FILES[@]}" 2>&1; then
      echo "[post-edit] Quality gate: PASSED (${#SH_FILES[@]} shell files)"
      bash "$AGGREGATOR" record "quality-gate" "passed" "${#SH_FILES[@]} shell files ok" > /dev/null 2>&1 || true
    else
      echo "[post-edit] Quality gate: FAILED"
      bash "$AGGREGATOR" record "quality-gate" "failed" "Quality violations in shell files" > /dev/null 2>&1 || true
      ALL_PASSED=false
    fi
  fi
fi

# Check for specific file patterns
for f in "${FILES[@]}"; do
  case "$f" in
    *.sh|*.bash)
      # Check set -euo pipefail
      if ! head -20 "$REPO_ROOT/$f" | grep -q "set -euo pipefail\|set -eo pipefail"; then
        echo "[post-edit] ⚠  $f: missing 'set -euo pipefail'"
      fi
      ;;
    *.md)
      # Check for common doc issues
      if grep -q 'TODO\|FIXME\|HACK' "$REPO_ROOT/$f" 2>/dev/null; then
        echo "[post-edit] ⚠  $f: contains TODOs/FIXMEs"
      fi
      ;;
  esac
done

# Check for binary file modifications (unusual for this repo)
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
  echo "[post-edit] Script files changed --- running smoke tests..."
  if bash "$REPO_ROOT/scripts/test-smoke.sh" > /dev/null 2>&1; then
    echo "[post-edit] Smoke tests: PASSED"
    bash "$AGGREGATOR" record "smoke-tests" "passed" "All smoke tests pass" > /dev/null 2>&1 || true
  else
    echo "[post-edit] Smoke tests: FAILED"
    bash "$AGGREGATOR" record "smoke-tests" "failed" "Smoke test failures detected" > /dev/null 2>&1 || true
    ALL_PASSED=false
  fi
fi

if $ALL_PASSED; then
  echo "[post-edit] All checks passed."
else
  echo "[post-edit] Some checks FAILED --- review above before continuing."
fi

# Exit with status (non-zero if any check failed)
$ALL_PASSED
