#!/usr/bin/env bash
# =============================================================================
# session-start.sh --- Compact SessionStart lifecycle hook
#
# Merged from session-start.sh + detect-gaps.sh.
# Prints compact orientation context at session start.
#
# COMPACT=1 (default): 3-5 line summary on success.
# COMPACT=0:           Full verbose diagnostics.
# =============================================================================

set -euo pipefail

COMPACT=${COMPACT:-1}
FOUND_GAP=false

say() {
  [[ "$COMPACT" == "0" ]] && echo "$@"
  :
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"

# ── Gather data ──────────────────────────────────────────────────────────────
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null || true)"
GIT_COMMON_DIR="$(git rev-parse --git-common-dir 2>/dev/null || true)"
IS_WORKTREE=false
[ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && IS_WORKTREE=true

RECENT=$(git log --oneline -3 2>/dev/null | paste -sd '|' - || echo "(no commits)")
DIRTY=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
# Check workflow-state.json first, fall back to session-state.json
STATE_FILE="$REPO_ROOT/workflow-state.json"
if [ ! -f "$STATE_FILE" ]; then
  STATE_FILE="$REPO_ROOT/session-state.json"
fi

# Session state health
STATE_HEALTH="ok"
STATE_TASK=""
if [ -f "$STATE_FILE" ]; then
  STATE_AGE=$((($(date +%s) - $(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)) / 3600))
  [ "$STATE_AGE" -gt 24 ] && STATE_HEALTH="stale (${STATE_AGE}h old)"
  STATE_TASK=$(python3 -c "
import json
try:
    s = json.load(open('$STATE_FILE'))
    t = s.get('currentTask', {})
    n = t.get('name', '')
    st = t.get('status', '')
    print(f'{n} [{st}]' if n else '')
except: pass
" 2>/dev/null || true)
fi

# Reasoning level
REASONING_LEVEL=$(python3 -c "
import json, re
try:
    with open('$HOME/.config/opencode/opencode.jsonc') as f:
        c = f.read()
    m = re.search(r'\"reasoning_effort\":\s*\"([^\"]+)\"', c)
    print(m.group(1) if m else 'high')
except: print('high (default)')
" 2>/dev/null || echo "unknown")

# ── Compact output ──────────────────────────────────────────────────────────
if [[ "$COMPACT" == "1" ]]; then
  echo "=== Session Start ==="
  echo "Branch: ${BRANCH}$([ "$IS_WORKTREE" = true ] && echo " (worktree)") | ${RECENT}"
  echo "Session: ${STATE_TASK:-$(basename "$REPO_ROOT")} | reasoning: ${REASONING_LEVEL}"
  if [ "$DIRTY" -gt 0 ]; then
    echo "⚠  Uncommitted: ${DIRTY} file(s), ${UNTRACKED} untracked"
  fi
  [ "$STATE_HEALTH" != "ok" ] && echo "⚠  session-state.json: ${STATE_HEALTH}"
  if [[ -f "$REPO_ROOT/.runtime/challenge-response.json" ]]; then
    CSIZE=$(stat -c%s "$REPO_ROOT/.runtime/challenge-response.json" 2>/dev/null || echo 0)
    [ "$CSIZE" -ge 10 ] && echo "⚠  Unaddressed plan dissent found. Run: bash scripts/decision.sh audit"
  fi

  # Compact cleanup check (only warn above 500M)
  PRUNE=$(git -C "$REPO_ROOT" count-objects -v 2>/dev/null | grep "prune-packable" | awk '{print $2}' || echo 0)
  PACK_KB=$(git -C "$REPO_ROOT" count-objects -v 2>/dev/null | grep "size-pack" | awk '{print $2}' || echo 0)
  if [ "${PRUNE:-0}" -gt "50" ] || [ "${PACK_KB:-0}" -gt "204800" ]; then
    echo "💾  Project bloat detected. Run: /cleanup"
    echo "    or: bash scripts/tools/cleanup-project.sh"
  fi

  # Goal tree display (compact mode — always show)
  GOAL_TREE="$REPO_ROOT/.runtime/goal-tree.json"
  if [ -f "$GOAL_TREE" ]; then
    python3 -c "
import json
try:
    with open('$GOAL_TREE') as f:
        d = json.load(f)
    active_id = d.get('active')
    root_id = d.get('root')
    if active_id and active_id in d.get('nodes', {}):
        n = d['nodes'][active_id]
        path = []; cur = active_id
        while cur:
            if cur in d.get('nodes', {}):
                path.append(d['nodes'][cur]['title'][:50])
                cur = d['nodes'][cur].get('parent')
            else:
                break
        path.reverse()
        print('  🎯 ' + ' → '.join(path))
except:
    pass
" 2>/dev/null || true
  fi

  echo "=== End ==="
  exit 0
fi

# ── Verbose output ──────────────────────────────────────────────────────────
echo "=== Session Start --- Diagnostics ==="

# Worktree
if [ "$IS_WORKTREE" = true ]; then
  echo "Branch: $BRANCH (session worktree)"
else
  echo "Branch: $BRANCH (main checkout)"
fi

# Recent commits
echo ""
echo "Recent commits:"
git log --oneline -5 2>/dev/null | sed 's/^/  /' || echo "  (no commits)"

# Dirty worktree
if [ "$DIRTY" -gt 0 ]; then
  echo ""
  echo "⚠  Uncommitted changes: $DIRTY file(s)"
  git status --short 2>/dev/null | head -10 | sed 's/^/  /'
  [ "$DIRTY" -gt 10 ] && echo "  ... and $(($DIRTY - 10)) more"
fi

# Session state
echo ""
STATE_NAME="$(basename "$STATE_FILE")"
if [ -f "$STATE_FILE" ]; then
  echo "✓  $STATE_NAME is current ($STATE_AGE hours old)"
  [ -n "$STATE_TASK" ] && echo "  Current task: $STATE_TASK"
else
  echo "⚠  $STATE_NAME not found"
fi

# Interruption check
INTERRUPTED=$(python3 -c "
import json
try:
    s = json.load(open('$STATE_FILE'))
    print(s.get('interruptedCount', 0))
except: print(0)
" 2>/dev/null || echo 0)
if [ "$INTERRUPTED" -gt 0 ] && [ "$INTERRUPTED" -lt 3 ]; then
  echo "ℹ  Session had $INTERRUPTED interruption(s)"
fi

# Context snapshot
SNAPSHOT="$REPO_ROOT/.runtime/session-snapshot.json"
if [ -f "$SNAPSHOT" ]; then
  SNAP_AGE=$((($(date +%s) - $(stat -c %Y "$SNAPSHOT" 2>/dev/null || echo 0)) / 60))
  [ "$SNAP_AGE" -lt 120 ] && echo "ℹ  Recent context snapshot ($SNAP_AGE min old)"
fi

# Reasoning level
echo ""
echo "Reasoning: ${REASONING_LEVEL} (bash ./scripts/reasoning.sh to change)"

# RTK
if command -v rtk &>/dev/null; then
  RTK_GAIN=$(rtk gain --quiet 2>/dev/null | head -1 || echo "gathering data")
  echo "rtk: ${RTK_GAIN}"
fi

# Worktree info
if [ "$IS_WORKTREE" = false ] && [ "$BRANCH" = "main" ] && [ "$DIRTY" -eq 0 ]; then
  echo "On main with a clean state. Multi-file task? bash scripts/session-fork.sh \"<name>\""
elif [ "$IS_WORKTREE" = true ]; then
  echo "Worktree session. Finish: session-fork.sh --merge or --close"
fi

# ── Goal Tree display ──
GOAL_TREE="$REPO_ROOT/.runtime/goal-tree.json"
if [ -f "$GOAL_TREE" ]; then
  python3 -c "
import json
try:
    with open('$GOAL_TREE') as f:
        d = json.load(f)
    active_id = d.get('active')
    root_id = d.get('root')
    if active_id and active_id in d.get('nodes', {}):
        n = d['nodes'][active_id]
        # Build path to root
        path = []
        cur = active_id
        while cur:
            if cur in d.get('nodes', {}):
                path.append(d['nodes'][cur]['title'][:50])
                cur = d['nodes'][cur].get('parent')
            else:
                break
        path.reverse()
        print('🎯 ' + ' → '.join(path))
    elif root_id and root_id in d.get('nodes', {}):
        print(f'🎯 {d[\"nodes\"][root_id][\"title\"][:60]}')
except:
    pass
" 2>/dev/null || true
fi

echo ""
echo "=== End Diagnostics ==="

# ── Workflow gate (runs every session start) ──
bash "$(cd "$(dirname "$0")/../.." && pwd)/scripts/workflow/startup-gate.sh"
