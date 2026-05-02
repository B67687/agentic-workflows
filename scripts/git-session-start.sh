#!/usr/bin/env bash
# =============================================================================
# git-session-start.sh - Probe branch, upstream, and worktree state before edits
# =============================================================================

set -euo pipefail

FETCH=true

usage() {
  cat <<'EOF'
Usage: ./scripts/git-session-start.sh [--no-fetch]

Show a compact repo probe before meaningful edits.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-fetch)
      FETCH=false
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

root="$(git rev-parse --show-toplevel)"
branch="$(git rev-parse --abbrev-ref HEAD)"
dirty="clean"
if [[ -n "$(git status --short)" ]]; then
  dirty="dirty"
fi

if [[ "$FETCH" == true ]]; then
  git fetch --all --prune --quiet || true
fi

upstream=""
ahead=0
behind=0
if upstream_ref="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"; then
  upstream="$upstream_ref"
  counts="$(git rev-list --left-right --count HEAD...@{upstream})"
  ahead="${counts%% *}"
  behind="${counts##* }"
fi

worktrees="$(git worktree list --porcelain | awk '/^worktree /{count++} END {print count+0}')"

echo "Repo: $root"
echo "Branch: $branch"
echo "Worktree: $dirty"
if [[ -n "$upstream" ]]; then
  echo "Upstream: $upstream"
  echo "Ahead: $ahead"
  echo "Behind: $behind"
else
  echo "Upstream: none"
fi
echo "Worktree count: $worktrees"

if [[ "$dirty" == "dirty" ]]; then
  echo "Recommendation: review current changes before broad edits."
elif [[ "$behind" -gt 0 ]]; then
  echo "Recommendation: inspect incoming remote changes before editing."
else
  echo "Recommendation: state looks normal for a new work phase."
fi
