#!/usr/bin/env bash

set -u

PROPAGATION_CONTRACT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROPAGATION_TEMPLATES_DIR="${PROPAGATION_TEMPLATES_DIR:-$PROPAGATION_CONTRACT_ROOT/propagation}"
MANAGED_MARKER="Managed-By: AI-Prompting-Library"

declare -a PROPAGATION_EXCLUDED_FOLDERS=(
  "ai-prompting"
  "open-codex"
)

declare -a PROPAGATION_MANAGED_CORE=(
  "ai-prompting-hub.template.sh:.ai-prompting-hub.sh"
  "AGENTS.template.md:AGENTS.md"
  "workspace-system-overview.template.md:docs/workspace-system-overview.md"
  "git-github-best-practices.template.md:git-github-best-practices.md"
  "quality-standards.template.md:quality-standards.md"
  "command/grill.template.md:command/grill.md"
  "command/grill.template.md:.opencode/commands/grill.md"
  "command/git-start.template.md:command/git-start.md"
  "command/git-start.template.md:.opencode/commands/git-start.md"
  "command/git-worktree.template.md:command/git-worktree.md"
  "command/git-worktree.template.md:.opencode/commands/git-worktree.md"
  "command/query.template.md:command/query.md"
  "command/query.template.md:.opencode/commands/query.md"
  "command/repo-map.template.md:command/repo-map.md"
  "command/repo-map.template.md:.opencode/commands/repo-map.md"
  "command/route.template.md:command/route.md"
  "command/route.template.md:.opencode/commands/route.md"
  "command/start-task.template.md:command/start-task.md"
  "command/start-task.template.md:.opencode/commands/start-task.md"
  "command/shape-product.template.md:command/shape-product.md"
  "command/shape-product.template.md:.opencode/commands/shape-product.md"
  "command/counsel.template.md:command/counsel.md"
  "command/counsel.template.md:.opencode/commands/counsel.md"
  "command/counsel-run.template.md:command/counsel-run.md"
  "command/counsel-run.template.md:.opencode/commands/counsel-run.md"
  "command/task-tree.template.md:command/task-tree.md"
  "command/task-tree.template.md:.opencode/commands/task-tree.md"
  "command/north-star.template.md:command/north-star.md"
  "command/north-star.template.md:.opencode/commands/north-star.md"
  "command/shape-milestone.template.md:command/shape-milestone.md"
  "command/shape-milestone.template.md:.opencode/commands/shape-milestone.md"
  "command/shape-task.template.md:command/shape-task.md"
  "command/shape-task.template.md:.opencode/commands/shape-task.md"
  "command/slice-task.template.md:command/slice-task.md"
  "command/slice-task.template.md:.opencode/commands/slice-task.md"
  "command/optimize.template.md:command/optimize.md"
  "command/optimize.template.md:.opencode/commands/optimize.md"
  "command/session-boundary.template.md:command/session-boundary.md"
  "command/session-boundary.template.md:.opencode/commands/session-boundary.md"
  "command/research.template.md:command/research.md"
  "command/research.template.md:.opencode/commands/research.md"
  "command/plan.template.md:command/plan.md"
  "command/plan.template.md:.opencode/commands/plan.md"
  "command/implement.template.md:command/implement.md"
  "command/implement.template.md:.opencode/commands/implement.md"
  "command/checkpoint.template.md:command/checkpoint.md"
  "command/checkpoint.template.md:.opencode/commands/checkpoint.md"
  "command/handoff.template.md:command/handoff.md"
  "command/handoff.template.md:.opencode/commands/handoff.md"
  "command/close-task.template.md:command/close-task.md"
  "command/close-task.template.md:.opencode/commands/close-task.md"
  "command/finish-task.template.md:command/finish-task.md"
  "command/finish-task.template.md:.opencode/commands/finish-task.md"
  "audit-folder-quality.template.sh:audit-folder-quality.sh"
  "check-sync-status.template.sh:check-sync-status.sh"
  "sync-from-hub.template.sh:sync-from-hub.sh"
  "checkpoint-commit.template.sh:checkpoint-commit.sh"
  "git-session-start.template.sh:git-session-start.sh"
  "task-intake.template.sh:task-intake.sh"
  "product-shape.template.sh:product-shape.sh"
  "counsel-gate.template.sh:counsel-gate.sh"
  "counsel-model-select.template.sh:counsel-model-select.sh"
  "counsel-run.template.sh:counsel-run.sh"
  "task-tree.template.sh:task-tree.sh"
  "north-star.template.sh:north-star.sh"
  "milestone-shape.template.sh:milestone-shape.sh"
  "task-slice.template.sh:task-slice.sh"
  "git-worktree-branch.template.sh:git-worktree-branch.sh"
  "phase-gate.template.sh:phase-gate.sh"
  "plan-guard.template.sh:plan-guard.sh"
  "optimize-gate.template.sh:optimize-gate.sh"
  "implement-preflight.template.sh:implement-preflight.sh"
  "retrieve-context.template.sh:retrieve-context.sh"
  "repo-map.template.sh:repo-map.sh"
  "workflow-router.template.sh:workflow-router.sh"
  "session-boundary.template.sh:session-boundary.sh"
  "handoff.template.sh:handoff.sh"
  "checkpoint-review.template.sh:checkpoint-review.sh"
  "close-task.template.sh:close-task.sh"
  "finish-task.template.sh:finish-task.sh"
)

declare -a PROPAGATION_REPO_OWNED_BOOTSTRAP=(
  "topic-insights.template.md:topic-insights.md"
  "session-state.template.json:session-state.json"
  ".cleanup-protect.template.md:.cleanup-protect"
  "history-index.template.md:archive/history-index.md"
  "history-full-detailed.template.md:archive/history-full-detailed.md"
)

propagation_iter_entries() {
  local scope="${1:-all}"

  case "$scope" in
    managed)
      printf '%s\n' "${PROPAGATION_MANAGED_CORE[@]}"
      ;;
    repo-owned)
      printf '%s\n' "${PROPAGATION_REPO_OWNED_BOOTSTRAP[@]}"
      ;;
    all)
      printf '%s\n' "${PROPAGATION_MANAGED_CORE[@]}" "${PROPAGATION_REPO_OWNED_BOOTSTRAP[@]}"
      ;;
    *)
      echo "ERROR: unknown propagation scope: $scope" >&2
      return 2
      ;;
  esac
}

propagation_entry_template() {
  printf '%s\n' "${1%%:*}"
}

propagation_entry_target() {
  printf '%s\n' "${1#*:}"
}

propagation_entry_owner() {
  local entry="$1"
  local managed

  for managed in "${PROPAGATION_MANAGED_CORE[@]}"; do
    if [[ "$managed" == "$entry" ]]; then
      printf 'managed\n'
      return 0
    fi
  done

  printf 'repo-owned\n'
}

propagation_template_path() {
  local entry="$1"
  printf '%s/%s\n' "$PROPAGATION_TEMPLATES_DIR" "$(propagation_entry_template "$entry")"
}

propagation_folder_excluded() {
  local folder_name="$1"
  local excluded

  for excluded in "${PROPAGATION_EXCLUDED_FOLDERS[@]}"; do
    if [[ "$excluded" == "$folder_name" ]]; then
      return 0
    fi
  done

  return 1
}
