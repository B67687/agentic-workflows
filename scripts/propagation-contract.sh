#!/usr/bin/env bash
# NOTE: No set -euo pipefail here --- this file is sourced by propagate-to-all.sh
# and would propagate shell options to the caller.

PROPAGATION_CONTRACT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROPAGATION_TEMPLATES_DIR="${PROPAGATION_TEMPLATES_DIR:-$PROPAGATION_CONTRACT_ROOT/propagation}"
MANAGED_MARKER="Managed-By: AI-Prompting-Library"

# Auto-detected from repo root --- dynamically handles any rename
PROPAGATION_HUB_NAME="$(basename "$PROPAGATION_CONTRACT_ROOT")"
PROPAGATION_PARENT_DIR="$(dirname "$PROPAGATION_CONTRACT_ROOT")"

declare -a PROPAGATION_MANAGED_CORE=(
  "ai-prompting-hub.template.sh:propagated/.ai-prompting-hub.sh"
  "AGENTS.template.md:AGENTS.md"
  "CLAUDE.template.md:CLAUDE.md"
  "claude-settings/settings.template.json:.claude/settings.json"
  "claude-settings/rules/testing.md:.claude/rules/testing.md"
  "claude-settings/hooks/session-context.sh:.claude/hooks/session-context.sh"
  "claude-settings/hooks/dangerous-command-guard.sh:.claude/hooks/dangerous-command-guard.sh"
  "git-github-best-practices.template.md:propagated/git-github-best-practices.md"
  "quality-standards.template.md:propagated/quality-standards.md"
  "buglog.template.json:buglog.json"
  "command/task.template.md:commands/task.md"
  "command/task.template.md:.opencode/commands/task.md"
  "command/session.template.md:commands/session.md"
  "command/session.template.md:.opencode/commands/session.md"
  "command/git.template.md:commands/git.md"
  "command/git.template.md:.opencode/commands/git.md"
  "command/counsel.template.md:commands/counsel.md"
  "command/counsel.template.md:.opencode/commands/counsel.md"
  "command/plan.template.md:commands/plan.md"
  "command/plan.template.md:.opencode/commands/plan.md"
  "command/implement.template.md:commands/implement.md"
  "command/implement.template.md:.opencode/commands/implement.md"
  "command/research.template.md:commands/research.md"
  "command/research.template.md:.opencode/commands/research.md"
  "command/route.template.md:commands/route.md"
  "command/route.template.md:.opencode/commands/route.md"
  "command/optimize.template.md:commands/optimize.md"
  "command/optimize.template.md:.opencode/commands/optimize.md"
  "command/parley.template.md:commands/parley.md"
  "command/parley.template.md:.opencode/commands/parley.md"
  "command/pipeline.template.md:commands/pipeline.md"
  "command/pipeline.template.md:.opencode/commands/pipeline.md"
  "command/prompt-contract.template.md:commands/prompt-contract.md"
  "command/prompt-contract.template.md:.opencode/commands/prompt-contract.md"
  "command/repo-map.template.md:commands/repo-map.md"
  "command/repo-map.template.md:.opencode/commands/repo-map.md"
  "command/query.template.md:commands/query.md"
  "command/query.template.md:.opencode/commands/query.md"
  "a2h-contact.template.sh:propagated/a2h-contact.sh"
  "audit-folder-quality.template.sh:propagated/audit-folder-quality.sh"
  "check-sync-status.template.sh:propagated/check-sync-status.sh"
  "sync-from-hub.template.sh:propagated/sync-from-hub.sh"
  "checkpoint-commit.template.sh:propagated/checkpoint-commit.sh"
  "git-session-start.template.sh:propagated/git-session-start.sh"
  "task-intake.template.sh:propagated/task-intake.sh"
  "google-models.template.sh:propagated/google-models.sh"
  "opencode-auth-profile.template.sh:propagated/opencode-auth-profile.sh"
  "opencode-model-profile.template.sh:propagated/opencode-model-profile.sh"
  "pi/settings.template.json:.pi/settings.json"
  "pi/prompts/task.template.md:.pi/prompts/task.md"
  "pi/prompts/session.template.md:.pi/prompts/session.md"
  "pi/prompts/git.template.md:.pi/prompts/git.md"
  "pi/prompts/counsel.template.md:.pi/prompts/counsel.md"
  "pi/prompts/plan.template.md:.pi/prompts/plan.md"
  "pi/prompts/implement.template.md:.pi/prompts/implement.md"
  "pi/prompts/research.template.md:.pi/prompts/research.md"
  "pi/prompts/route.template.md:.pi/prompts/route.md"
  "pi/prompts/optimize.template.md:.pi/prompts/optimize.md"
  "pi/prompts/parley.template.md:.pi/prompts/parley.md"
  "pi/prompts/pipeline.template.md:.pi/prompts/pipeline.md"
  "pi/prompts/prompt-contract.template.md:.pi/prompts/prompt-contract.md"
  "pi/prompts/repo-map.template.md:.pi/prompts/repo-map.md"
  "pi/prompts/query.template.md:.pi/prompts/query.md"
  "pi/extensions/workflow-guard.template.ts:.pi/extensions/workflow-guard.ts"
  "prompt-contract.template.sh:propagated/prompt-contract.sh"
  "product-shape.template.sh:propagated/product-shape.sh"
  "counsel-gate.template.sh:propagated/counsel-gate.sh"
  "counsel-model-select.template.sh:propagated/counsel-model-select.sh"
  "counsel-run.template.sh:propagated/counsel-run.sh"
  "task-tree.template.sh:propagated/task-tree.sh"
  "north-star.template.sh:propagated/north-star.sh"
  "milestone-shape.template.sh:propagated/milestone-shape.sh"
  "task-slice.template.sh:propagated/task-slice.sh"
  "git-worktree-branch.template.sh:propagated/git-worktree-branch.sh"
  "phase-gate.template.sh:propagated/phase-gate.sh"
  "plan-guard.template.sh:propagated/plan-guard.sh"
  "optimize-gate.template.sh:propagated/optimize-gate.sh"
  "implement-preflight.template.sh:propagated/implement-preflight.sh"
  "retrieve-context.template.sh:propagated/retrieve-context.sh"
  "repo-map.template.sh:propagated/repo-map.sh"
  "workflow-router.template.sh:propagated/workflow-router.sh"
  "session-boundary.template.sh:propagated/session-boundary.sh"
  "handoff.template.sh:propagated/handoff.sh"
  "checkpoint-review.template.sh:propagated/checkpoint-review.sh"
  "close-task.template.sh:propagated/close-task.sh"
  "error-counter.template.sh:propagated/error-counter.sh"
  "finish-task.template.sh:propagated/finish-task.sh"
  "log-error.template.sh:propagated/log-error.sh"
  "prefetch-context.template.sh:propagated/prefetch-context.sh"
  "propagate.template.sh:propagated/propagate.sh"
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
  # Only exclude the hub itself --- all siblings are valid topic folders
  [[ "$folder_name" == "$PROPAGATION_HUB_NAME" ]] && return 0
  return 1
}

# Discover the parent directory that contains all topic folders
propagation_parent_dir() {
  echo "$PROPAGATION_PARENT_DIR"
}

# Collect all topic folders (siblings except hub and hidden dirs)
propagation_collect_topic_folders() {
  local parent_dir item item_name
  parent_dir="$(propagation_parent_dir)"
  for item in "$parent_dir"/*/; do
    item_name="$(basename "$item")"
    [[ "$item_name" == .* ]] && continue
    propagation_folder_excluded "$item_name" && continue
    printf '%s\n' "${item%/}"
  done
}

# Check if a folder is a topic folder (has AGENTS.md marker)
propagation_is_topic_folder() {
  local folder="$1"
  [[ -f "$folder/AGENTS.md" ]] && return 0
  return 1
}
