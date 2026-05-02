#!/usr/bin/env bash
# =============================================================================
# git-worktree-branch.sh - Create an isolated short-lived worktree branch
# =============================================================================

set -euo pipefail

BRANCH=""
BASE_REF="HEAD"

usage() {
  cat <<'EOF'
Usage: ./scripts/git-worktree-branch.sh branch-name [base-ref]

Creates a sibling worktree under ../.worktrees/<repo>/<branch-name>
EOF
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

BRANCH="$1"
BASE_REF="${2:-HEAD}"

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi

root="$(git rev-parse --show-toplevel)"
repo_name="$(basename "$root")"
parent_dir="$(dirname "$root")"
worktree_root="$parent_dir/.worktrees/$repo_name"
worktree_path="$worktree_root/$BRANCH"

mkdir -p "$worktree_root"

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git worktree add "$worktree_path" "$BRANCH"
else
  git worktree add -b "$BRANCH" "$worktree_path" "$BASE_REF"
fi

echo "Created worktree:"
echo "$worktree_path"
echo "Branch:"
echo "$BRANCH"
