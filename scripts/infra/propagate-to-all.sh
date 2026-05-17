#!/usr/bin/env bash
# =============================================================================
# propagate-to-all.sh - Bootstrap missing files and refresh managed core files
# =============================================================================
#
# Usage:
#   ./propagate-to-all.sh                    # Preview mode (default)
#   ./propagate-to-all.sh --apply           # Apply bootstrap + managed refresh
#   ./propagate-to-all.sh --folder PATH     # Restrict to one topic folder
#   ./propagate-to-all.sh --managed-only    # Refresh only hub-owned managed core
# =============================================================================

set -uo pipefail

# Resolve symlinks so this works from any call path (symlink vs real path)
resolve_script_root() {
  local script_path="${BASH_SOURCE[0]}"
  while [[ -L "$script_path" ]]; do
    script_path="$(readlink "$script_path")"
    [[ "$script_path" != /* ]] && script_path="$(dirname "${BASH_SOURCE[0]}")/$script_path"
  done
  cd "$(dirname "$script_path")" && pwd
}
SCRIPT_DIR="$(resolve_script_root)"
# SCRIPT_DIR is now scripts/infra/ (always resolved)
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/scripts/propagation-contract.sh"

PARENT_DIR="${AI_PROMPTING_WORKSPACE_ROOT:-$(propagation_parent_dir)}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

MODE="preview"
TARGET_FOLDER=""
MANAGED_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --apply | -a)
    MODE="apply"
    ;;
  --check | -c | --preview | -p)
    MODE="preview"
    ;;
  --folder)
    TARGET_FOLDER="$2"
    shift
    ;;
  --managed-only)
    MANAGED_ONLY=true
    ;;
  --help | -h)
    cat <<'EOF'
Usage: ./scripts/propagate-to-all.sh [options]

Options:
  --apply, -a       Apply bootstrap + managed refresh
  --preview, -p     Preview planned changes (default)
  --folder PATH     Restrict to a single topic folder
  --managed-only    Refresh only hub-owned managed core files
  --help, -h        Show this help
EOF
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
  shift
done

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_drift() { echo -e "${RED}[DRIFT]${NC} $1"; }
log_artifact() { echo -e "${RED}[ARTIFACT]${NC} $1"; }

to_kebab_case() {
  local name="$1"
  local result="${name// /-}"
  result="${result,,}"
  echo "${result#-}" | sed 's/-\{2,\}/-/g; s/-$//'
}

ensure_parent_dir() {
  local target_path="$1"
  local parent_dir
  parent_dir="$(dirname "$target_path")"
  [[ "$parent_dir" == "." ]] || mkdir -p "$parent_dir"
}

ensure_content_folder() {
  local folder="$1"
  local folder_name kebab_name content_folder

  folder_name="$(basename "$folder")"
  kebab_name="$(to_kebab_case "$folder_name")"
  content_folder="$folder/${kebab_name}-content"

  if [[ -d "$content_folder" ]]; then
    echo "  ${kebab_name}-content/: OK"
    return
  fi

  if [[ "$MODE" == "apply" ]]; then
    mkdir -p "$content_folder"
    echo "  ${kebab_name}-content/: CREATED"
  else
    echo "  ${kebab_name}-content/: WOULD CREATE"
  fi
}

copy_template_file() {
  local template_path="$1"
  local target_path="$2"

  ensure_parent_dir "$target_path"
  cp "$template_path" "$target_path"
  [[ "$target_path" == *.sh ]] && chmod +x "$target_path"
}

process_entry() {
  local folder="$1"
  local entry="$2"
  local owner template_path target_rel target_path

  owner="$(propagation_entry_owner "$entry")"
  template_path="$(propagation_template_path "$entry")"
  target_rel="$(propagation_entry_target "$entry")"
  target_path="$folder/$target_rel"

  if [[ ! -f "$template_path" ]]; then
    log_warn "$target_rel: missing template source"
    return
  fi

  if [[ ! -f "$target_path" ]]; then
    if [[ "$MODE" == "apply" ]]; then
      copy_template_file "$template_path" "$target_path"
      echo "  $target_rel: CREATED ($owner)"
    else
      echo "  $target_rel: WOULD CREATE ($owner)"
    fi
    return
  fi

  if [[ "$owner" == "repo-owned" ]]; then
    echo "  $target_rel: SKIP (repo-owned)"
    return
  fi

  if cmp -s "$template_path" "$target_path"; then
    echo "  $target_rel: OK (managed core)"
    return
  fi

  if [[ "$MODE" == "apply" ]]; then
    copy_template_file "$template_path" "$target_path"
    echo "  $target_rel: REFRESHED (managed core)"
  else
    echo "  $target_rel: WOULD REFRESH (managed drift)"
  fi
}

detect_artifacts() {
  local folder="$1"
  local folder_name artifact_count=0

  folder_name="$(basename "$folder")"
  echo ""
  echo -e "${YELLOW}Checking for legacy artifacts in: $folder_name${NC}"

  while IFS= read -r -d '' old_script; do
    log_artifact "Legacy PowerShell file: $(basename "$old_script")"
    ((artifact_count++))
  done < <(find "$folder" -maxdepth 1 -name "*.ps1" -print0 2>/dev/null)

  if [[ $artifact_count -eq 0 ]]; then
    echo "  No root-level legacy artifacts detected"
  fi
}

collect_folders() {
  if [[ -n "$TARGET_FOLDER" ]]; then
    printf '%s\n' "$TARGET_FOLDER"
    return
  fi
  propagation_collect_topic_folders
}
process_folder() {
  local folder="$1"
  local scope="all"
  local entry

  echo ""
  echo -e "${YELLOW}Processing: $(basename "$folder")${NC}"
  ensure_content_folder "$folder"

  if [[ "$MANAGED_ONLY" == true ]]; then
    scope="managed"
  fi

  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    process_entry "$folder" "$entry"
  done < <(propagation_iter_entries "$scope")

  detect_artifacts "$folder"
}

mapfile -t TOPIC_FOLDERS < <(collect_folders)

log_info "Scanning topic folders in: $PARENT_DIR"
log_info "Found ${#TOPIC_FOLDERS[@]} folder(s) to process"
log_info "Mode: $MODE"

if [[ "$MANAGED_ONLY" == true ]]; then
  log_info "Scope: managed core only"
else
  log_info "Scope: managed core + repo-owned bootstrap"
fi

for folder in "${TOPIC_FOLDERS[@]}"; do
  process_folder "$folder"
done

echo ""
log_ok "Done."
