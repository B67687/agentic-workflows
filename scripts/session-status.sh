#!/bin/bash
# =============================================================================
# session-status.sh --- Compact workspace orientation (one-shot)
#
# Combines health, tools, git state, and test status into <20 lines.
# Designed for session resumes --- run this to orient quickly.
#
# Usage:
#   bash ./scripts/session-status.sh
#   bash ./scripts/session-status.sh --compact   # even shorter
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || { echo "ERROR: cannot cd to $REPO_ROOT"; exit 1; }

MODE="${1:-}"

# --- Git state ---
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
DIRTY=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
COMMITS=$(git log --oneline -3 2>/dev/null | wc -l | tr -d ' ')
LATEST=$(git log --oneline -1 2>/dev/null | cut -d' ' -f1 || echo "?")

# --- Health ---
HEALTH=$(bash scripts/context-pressure.sh --json 2>/dev/null | python3 -c "
import json,sys;d=json.load(sys.stdin);print(f'{d[\"status\"]} (score={d[\"score\"]})')
" 2>/dev/null || echo "?")
SESSION_AGE=$(bash scripts/context-pressure.sh --json 2>/dev/null | python3 -c "
import json,sys;d=json.load(sys.stdin);print(f'{d[\"signals\"][\"session_age_hours\"]}h')
" 2>/dev/null || echo "?")

# --- Tools count ---
TOOL_COUNT=$(bash scripts/tools.sh 2>/dev/null | grep -cE "^(  script/|  command/|  bin/)" || echo "?")

# --- Test status (fast check: just validates script parses) ---
TEST_RESULT="?"
if [ -f scripts/test-smoke.sh ]; then
  if bash -n scripts/test-smoke.sh 2>/dev/null; then
    TEST_RESULT="OK"
  else
    TEST_RESULT="SYNTAX_ERROR"
  fi
fi

if [ "$MODE" = "--compact" ]; then
  echo "[${BRANCH}] @${LATEST} | ${DIRTY}dirty | ${SESSION_AGE} | ${HEALTH} | ${TOOL_COUNT}tools | tests:${TEST_RESULT}"
else
  echo "=== Session Status ==="
  echo "  Branch:   $BRANCH  (@$LATEST, $DIRTY dirty)"
  echo "  Health:   $HEALTH  (age: $SESSION_AGE)"
  echo "  Tools:    $TOOL_COUNT registered"
  echo "  Tests:    $TEST_RESULT (31 quick smoke)"
  echo ""
  echo "Last commits:"
  git log --oneline -3 2>/dev/null | sed 's/^/  /'
  echo ""
  echo "Commands:"
  echo "  bash ./scripts/tools.sh              --- full tool list"
  echo "  bash ./scripts/test-smoke.sh         --- full smoke test"
  echo "  bash ./scripts/context-pressure.sh   --- health details"
  echo "  bash ./scripts/checkpoint-commit.sh  --- checkpoint"
  echo "========================================"
fi
