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
  "AGENTS.template.md:AGENTS.md"
  "workspace-system-overview.template.md:docs/workspace-system-overview.md"
  "git-github-best-practices.template.md:git-github-best-practices.md"
  "quality-standards.template.md:quality-standards.md"
  "command/query.template.md:command/query.md"
  "command/start-task.template.md:command/start-task.md"
  "command/session-boundary.template.md:command/session-boundary.md"
  "command/research.template.md:command/research.md"
  "command/plan.template.md:command/plan.md"
  "command/implement.template.md:command/implement.md"
  "command/checkpoint.template.md:command/checkpoint.md"
  "audit-folder-quality.template.sh:audit-folder-quality.sh"
  "check-sync-status.template.sh:check-sync-status.sh"
  "sync-from-hub.template.sh:sync-from-hub.sh"
  "checkpoint-commit.template.sh:checkpoint-commit.sh"
  "phase-gate.template.sh:phase-gate.sh"
  "retrieve-context.template.sh:retrieve-context.sh"
  "session-boundary.template.sh:session-boundary.sh"
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
