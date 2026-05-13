#!/usr/bin/env bash
# =============================================================================
# git-branch-cleanup.sh --- Companion script for Git Workflow and Versioning
#
# Identifies stale, merged, and diverged branches. Designed for trunk-based
# development with short-lived branches (1-3 days).
#
# Usage:
#   bash ./scripts/git-branch-cleanup.sh scan
#     List all local branches with age, divergence, and merge status.
#
#   bash ./scripts/git-branch-cleanup.sh stale <days>
#     List branches older than <days> that should be merged or removed.
#     Default: 5 days (trunk-based: 1-3 ideal, 5+ is stale).
#
#   bash ./scripts/git-branch-cleanup.sh merged
#     List branches fully merged into main/HEAD.
#
#   bash ./scripts/git-branch-cleanup.sh diverged
#     List branches with significant divergence from main.
# =============================================================================

set -euo pipefail

MODE="${1:-scan}"
THRESHOLD_DAYS="${2:-5}"
MAIN_BRANCH="main"

# Detect default branch name
if git show-ref --quiet refs/heads/main 2>/dev/null; then
  MAIN_BRANCH="main"
elif git show-ref --quiet refs/heads/master 2>/dev/null; then
  MAIN_BRANCH="master"
fi

case "$MODE" in
  scan)
    echo "=== Branch Scan ==="
    printf "%-30s %-10s %-8s %s\n" "BRANCH" "AGE (days)" "STATUS" "DIVERGENCE"
    echo "──────────────────────────────────────────────────────────────"

    for branch in $(git branch --format='%(refname:short)' | grep -v "^${MAIN_BRANCH}$"); do
      AGE=$(git log -1 --format='%ar' "$branch" 2>/dev/null || echo "unknown")
      AGE_DAYS=$(git log -1 --format='%at' "$branch" 2>/dev/null || echo 0)
      NOW=$(date +%s)
      AGE_NUM=$(( (NOW - AGE_DAYS) / 86400 ))

      # Check merge status
      if git merge-base --is-ancestor "$branch" "$MAIN_BRANCH" 2>/dev/null; then
        STATUS="merged"
      elif git symbolic-ref -q HEAD >/dev/null && [ "$(git rev-parse --abbrev-ref HEAD)" = "$branch" ]; then
        STATUS="current"
      else
        STATUS="active"
      fi

      # Check divergence
      BEHIND=$(git rev-list --count "${MAIN_BRANCH}..${branch}" 2>/dev/null || echo "?")
      AHEAD=$(git rev-list --count "${branch}..${MAIN_BRANCH}" 2>/dev/null || echo "?")
      DIVERGENCE="${BEHIND}f ${AHEAD}b"

      printf "%-30s %-10s %-8s %s\n" "$branch" "${AGE_NUM}d" "$STATUS" "$DIVERGENCE"
    done
    ;;

  stale)
    echo "=== Stale Branches (>${THRESHOLD_DAYS} days) ==="
    found=0
    for branch in $(git branch --format='%(refname:short)' | grep -v "^${MAIN_BRANCH}$"); do
      AGE_DAYS=$(git log -1 --format='%at' "$branch" 2>/dev/null || echo 0)
      NOW=$(date +%s)
      AGE_NUM=$(( (NOW - AGE_DAYS) / 86400 ))
      if [ "$AGE_NUM" -gt "$THRESHOLD_DAYS" ]; then
        echo "  ${branch} (${AGE_NUM}d old, last: $(git log -1 --format='%ar' "$branch"))"
        found=$((found + 1))
      fi
    done
    if [ "$found" -eq 0 ]; then
      echo "  No stale branches found (threshold: ${THRESHOLD_DAYS}d)"
    fi
    ;;

  merged)
    echo "=== Branches merged into ${MAIN_BRANCH} ==="
    found=0
    for branch in $(git branch --format='%(refname:short)' | grep -v "^${MAIN_BRANCH}$"); do
      if git merge-base --is-ancestor "$branch" "$MAIN_BRANCH" 2>/dev/null; then
        echo "  ${branch} (last: $(git log -1 --format='%ar' "$branch"))"
        found=$((found + 1))
      fi
    done
    if [ "$found" -eq 0 ]; then
      echo "  No merged branches found."
    else
      echo ""
      echo "  To delete all merged branches:"
      echo "    git branch --merged ${MAIN_BRANCH} | grep -v '${MAIN_BRANCH}' | xargs git branch -d"
    fi
    ;;

  diverged)
    echo "=== Diverged Branches (behind ${MAIN_BRANCH}) ==="
    found=0
    for branch in $(git branch --format='%(refname:short)' | grep -v "^${MAIN_BRANCH}$"); do
      BEHIND=$(git rev-list --count "${MAIN_BRANCH}..${branch}" 2>/dev/null || echo 0)
      if [ "$BEHIND" -gt 10 ]; then
        echo "  ${branch} (${BEHIND} commits behind ${MAIN_BRANCH})"
        found=$((found + 1))
      fi
    done
    if [ "$found" -eq 0 ]; then
      echo "  No significantly diverged branches (threshold: 10+ commits behind)"
    fi
    ;;

  *)
    echo "Usage: $0 {scan|stale|merged|diverged} [threshold-days]"
    echo ""
    echo "  scan               List all branches with status"
    echo "  stale <days>       List branches older than N days (default: 5)"
    echo "  merged             List branches merged into ${MAIN_BRANCH}"
    echo "  diverged            List branches significantly behind ${MAIN_BRANCH}"
    exit 1
    ;;
esac
