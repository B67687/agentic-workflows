#!/usr/bin/env bash
# =============================================================================
# session-fork.sh — Fork current session into an isolated worktree branch
#
# Creates ../.worktrees/<repo>/<branch>/ with a new branch off HEAD,
# copies session-state.json, and reports the path. Run this when starting
# a new task so parallel sessions don't conflict.
#
# Usage:
#   bash ./scripts/session-fork.sh [task-name]
#     Create a worktree branch for task-name (auto-slugged).
#     If omitted, reads from session-state.json currentTask.name.
#
#   bash ./scripts/session-fork.sh --close
#     Commit any staged changes, push branch, remove worktree.
#     Must be run from within the worktree.
#
#   bash ./scripts/session-fork.sh --list
#     List all active session worktrees.
#
#   bash ./scripts/session-fork.sh --cleanup
#     Remove worktrees for branches already merged/closed.
# =============================================================================

set -euo pipefail

MODE="create"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --close)    MODE="close" ;;
    --list)     MODE="list" ;;
    --cleanup)  MODE="cleanup" ;;
    --help|-h)
      sed -n '2,/^$/p' "$0" | sed 's/^# //;s/^#$//;s/^#//'
      exit 0
      ;;
    *)
      if [ "$MODE" = "create" ]; then
        TASK_NAME="$1"
      else
        echo "Unknown option: $1" >&2
        exit 2
      fi
      ;;
  esac
  shift
done

# ── Shared helpers ──────────────────────────────────────────────────────────

ROOT="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$ROOT")"
PARENT="$(dirname "$ROOT")"
WORKTREE_ROOT="$PARENT/.worktrees/$REPO_NAME"

slugify() {
  echo "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9]/-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//;s/-$//' \
    | cut -c1-40
}

get_session_id() {
  python3 -c "
import json
try: s = json.load(open('session-state.json')); print(s.get('session', '0'))
except: print('0')
" 2>/dev/null || echo "0"
}

# ── List active worktrees ───────────────────────────────────────────────────

list_worktrees() {
  echo "Active session worktrees:"
  git worktree list --porcelain \
    | awk '/^worktree /{wt=$2} /^branch refs\/heads\//{sub("refs/heads/",""); print wt"  "$2}' \
    | while read -r wt_path branch; do
        if echo "$branch" | grep -q "^s[0-9]"; then
          echo "  $branch  →  $wt_path"
        fi
      done
}

# ── Close worktree ──────────────────────────────────────────────────────────

close_worktree() {
  local wt_path
  wt_path="$(git rev-parse --git-common-dir)"

  # Are we inside a worktree?
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local common
    common="$(git rev-parse --git-common-dir 2>/dev/null || true)"
    if [ "$common" = "$(git rev-parse --git-dir)" ]; then
      echo "Not in a worktree — run this from inside a session worktree."
      exit 1
    fi
  else
    echo "Not inside a git repo."
    exit 1
  fi

  # Find the worktree path from branch name
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD)"
  local branch_ref
  branch_ref="refs/heads/$branch"

  # Find the worktree path for this branch
  local wt_dir=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^worktree\ (.*) ]]; then
      wt_dir="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^branch\ (.*) ]]; then
      if [ "${BASH_REMATCH[1]}" = "$branch_ref" ]; then
        break
      fi
    fi
  done < <(git worktree list --porcelain)

  if [ -z "$wt_dir" ]; then
    echo "Could not find worktree for branch: $branch"
    exit 1
  fi

  echo "Closing worktree: $wt_dir (branch: $branch)"

  # Push if remote exists
  if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    echo "Pushing branch..."
    git push --quiet || echo "  (push skipped — no remote or offline)"
  else
    echo "  (no upstream — not pushing)"
  fi

  # Remove worktree
  cd "$ROOT" >/dev/null 2>&1 || true
  git worktree remove "$wt_dir" 2>/dev/null || {
    echo "  Worktree has uncommitted changes. Committing..."
    git -C "$wt_dir" add -A
    git -C "$wt_dir" commit -m "auto-save before worktree close" 2>/dev/null || true
    git worktree remove "$wt_dir" 2>/dev/null || {
      echo "  Could not remove: $wt_dir"
      echo "  Try: git worktree remove --force $wt_dir"
      exit 1
    }
  }

  echo "✓ Worktree removed"
  echo "Branch '$branch' still exists locally. Delete with: git branch -d $branch"
}

# ── Cleanup orphaned worktrees ──────────────────────────────────────────────

cleanup_worktrees() {
  echo "Pruning stale worktree metadata..."
  git worktree prune 2>/dev/null || true

  echo "Checking for merged session branches..."
  for branch in $(git branch --list 's*' --format='%(refname:short)'); do
    if git merge-base --is-ancestor "$branch" HEAD 2>/dev/null; then
      echo "  Branch '$branch' is merged — removing worktree if exists..."
      local wt_path="$WORKTREE_ROOT/$branch"
      if [ -d "$wt_path" ]; then
        git worktree remove "$wt_path" 2>/dev/null || true
      fi
      git branch -d "$branch" 2>/dev/null || true
    fi
  done
  echo "✓ Cleanup done"
}

# ── Create worktree ─────────────────────────────────────────────────────────

create_worktree() {
  # Only create from main — worktrees should branch off main
  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"

  if [ "$current_branch" != "main" ]; then
    echo "You're on '$current_branch', not 'main'."
    echo "Only fork from main. Either:"
    echo "  a) 'git checkout main' and re-run, or"
    echo "  b) work directly on this branch (no worktree needed)"
    exit 1
  fi

  # Check for dirty files
  if [ -n "$(git status --short)" ]; then
    echo "⚠  You have uncommitted changes on main."
    echo "   Please commit or stash before forking."
    echo ""
    git status --short | head -10
    exit 1
  fi

  # Determine task slug
  local slug
  if [ -n "${TASK_NAME:-}" ]; then
    slug="$(slugify "$TASK_NAME")"
  else
    local task_name
    task_name="$(python3 -c "
import json
try:
    s = json.load(open('session-state.json'))
    t = s.get('currentTask', {}).get('name', '')
    print(t)
except: print('')
" 2>/dev/null || echo "")"
    if [ -n "$task_name" ]; then
      slug="$(slugify "$task_name")"
    else
      echo "No task name given and no currentTask in session-state.json."
      echo "Usage: bash ./scripts/session-fork.sh \"task-name\""
      exit 1
    fi
  fi

  local session_id
  session_id="$(get_session_id)"
  local branch="s${session_id}-${slug}"
  local worktree_path="$WORKTREE_ROOT/$branch"

  # Check if branch already exists
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Branch '$branch' already exists."
    exit 1
  fi

  mkdir -p "$WORKTREE_ROOT"

  echo "Creating worktree..."
  git worktree add -b "$branch" "$worktree_path" HEAD

  # Copy session-state.json to worktree
  if [ -f "session-state.json" ]; then
    cp session-state.json "$worktree_path/"
    echo "  session-state.json copied"
  fi

  echo ""
  echo "========================================"
  echo "  Session forked!"
  echo "  Branch:  $branch"
  echo "  Path:    $worktree_path"
  echo "========================================"
  echo ""
  echo "To work in this session:"
  echo "  cd $worktree_path"
  echo "  opencode"
  echo ""
  echo "To close when done (from within worktree):"
  echo "  bash ./scripts/session-fork.sh --close"
}

# ── Dispatch ────────────────────────────────────────────────────────────────

case "$MODE" in
  list)
    list_worktrees
    ;;
  close)
    close_worktree
    ;;
  cleanup)
    cleanup_worktrees
    ;;
  create)
    create_worktree
    ;;
esac
