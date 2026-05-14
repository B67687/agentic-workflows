#!/usr/bin/env bash
# =============================================================================
# session-start.sh --- SessionStart lifecycle hook
# Prints orientation context at the beginning of every session:
#   - Current branch and recent commits
#   - session-state.json health
#   - Stale working context from prior sessions
#   - Index freshness
#
# Compatible with: Claude Code (via hooks.json), manual invocation, AGENTS.md
# Output appears in conversation or terminal --- informative, non-blocking.
# =============================================================================

set -euo pipefail

echo "=== Session Start --- Diagnostics ==="

# ---- Worktree Detection ----
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null || true)"
GIT_COMMON_DIR="$(git rev-parse --git-common-dir 2>/dev/null || true)"
IS_WORKTREE=false
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ]; then
  IS_WORKTREE=true
fi

# ---- Branch and Recent Commits ----
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
if [ "$IS_WORKTREE" = true ]; then
  echo "Branch: $BRANCH (session worktree)"
  echo "  cd ../.worktrees/ to list all workspaces"
else
  echo "Branch: $BRANCH (main checkout)"
fi

echo ""
echo "Recent commits:"
git log --oneline -5 2>/dev/null | sed 's/^/  /' || echo "  (no commits)"

# ---- Dirty Worktree ----
DIRTY=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
if [ "$DIRTY" -gt 0 ]; then
    echo ""
    echo "⚠  Uncommitted changes: $DIRTY file(s)"
    git status --short 2>/dev/null | head -10 | sed 's/^/  /'
    if [ "$DIRTY" -gt 10 ]; then
        echo "  ... and $(($DIRTY - 10)) more"
    fi
fi

# ---- Session State Health ----
echo ""
STATE_FILE="session-state.json"
if [ -f "$STATE_FILE" ]; then
    # Check if state is stale (older than 24h)
    NOW=$(date +%s)
    STATE_MTIME=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)
    AGE_HOURS=$(( (NOW - STATE_MTIME) / 3600 ))
    if [ "$AGE_HOURS" -gt 24 ]; then
        echo "⚠  session-state.json is $AGE_HOURS hours old --- may be stale"
    else
        echo "✓  session-state.json is current ($AGE_HOURS hours old)"
    fi
    # Show task name if set
    TASK_NAME=$(python3 -c "
import json
try:
    s = json.load(open('$STATE_FILE'))
    t = s.get('currentTask', {})
    name = t.get('name', '')
    status = t.get('status', '')
    if name:
        print(f'  Current task: {name} [{status}]')
except: pass
" 2>/dev/null || true)
    if [ -n "$TASK_NAME" ]; then
        echo "$TASK_NAME"
    fi
else
    echo "⚠  session-state.json not found --- create for context persistence"
fi

# ---- Session Health Check ----
HEALTH_STATUS=$(bash "$(dirname "$0")/../context-pressure.sh" --check 2>/dev/null || true)
if echo "$HEALTH_STATUS" | grep -q "CRITICAL"; then
    echo ""
    echo "⚠  SESSION HEALTH: CRITICAL --- run context-pressure.sh for details"
fi

# ---- Saved Context Snapshot ----
SNAPSHOT=".runtime/session-snapshot.json"
if [ -f "$SNAPSHOT" ]; then
    SNAP_AGE=$(( ($(date +%s) - $(stat -c %Y "$SNAPSHOT" 2>/dev/null || echo 0)) / 60 ))
    if [ "$SNAP_AGE" -lt 120 ]; then
        echo ""
        echo "ℹ  Recent context snapshot found ($SNAP_AGE min old)"
        echo "   If resuming from compaction, run: bash ./scripts/hooks/post-compact.sh"
    fi
fi

# ---- Session Status Overview ----
bash "$(dirname "$0")/../session-status.sh" --compact 2>/dev/null || true
echo "  bash ./scripts/tools.sh            --- full tool list"
echo "  bash ./scripts/test-smoke.sh       --- 31-tool smoke test"
echo "  bash ./scripts/session-status.sh   --- this overview"

# ---- RTK Status (if installed) ----
if command -v rtk &>/dev/null; then
  RTK_GAIN=$(rtk gain --quiet 2>/dev/null | head -1 || echo "gathering data")
  echo "  rtk: ${RTK_GAIN}  (rtk discover to find missed savings)"
fi

# ---- Worktree Fork Offer / Auto-Fork ----
if [ "$IS_WORKTREE" = false ] && [ "$BRANCH" = "main" ]; then
  DIRTY=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  if [ "$DIRTY" -eq 0 ]; then
    # Check if a task name is already set (resuming with context)
    AUTO_TASK=$(python3 -c "
import json
try:
    s = json.load(open('session-state.json'))
    t = s.get('currentTask', {}).get('name', '')
    st = s.get('currentTask', {}).get('status', '')
    if t and st in ('pending', 'planned', 'in_progress'):
        print(t)
except: pass
" 2>/dev/null || echo "")
    if [ -n "$AUTO_TASK" ]; then
      echo ""
      echo "ℹ  Resuming task: $AUTO_TASK"
      echo "   The AI will fork a worktree if this is a multi-file task."
    else
      echo ""
      echo "ℹ  On main with a clean state."
      echo "   Multi-file task? -> bash ./scripts/session-fork.sh \"<task-name>\""
      echo "   Quick fix (1-3 files)? -> work directly on main"
      echo "   bash ./scripts/session-fork.sh --list   --- show active worktrees"
    fi
  fi
elif [ "$IS_WORKTREE" = true ]; then
  echo ""
  echo "ℹ  Working in a session worktree. Finish with:"
  echo "   bash ./scripts/session-fork.sh --merge   (merge into default branch)"
  echo "   bash ./scripts/session-fork.sh --close   (just cleanup)"
fi

# ---- Ruflo Integration (CLI-only, if available) ----
if command -v ruflo &>/dev/null; then
  echo ""
  echo "Ruflo CLI available (0MB persistent):"
  echo "  bash ruflo hooks session-restore   --- restore previous session context"
  echo "  bash ruflo hooks route -t \"...\"    --- route task via learned patterns"
  echo "  bash ruflo hooks pretrain          --- re-analyze repo for patterns"
fi

echo "=== End Diagnostics ==="
