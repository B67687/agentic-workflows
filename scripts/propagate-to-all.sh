#!/usr/bin/env bash
# =============================================================================
# propagate-to-all.sh - Propagate templates to all topic folders
# =============================================================================
# Behavior: CREATE ONLY mode
#   - Files are only created if they don't exist
#   - Existing files are NEVER overwritten or merged
#   - This preserves all custom content in topic folders
#
# Usage:
#   ./propagate-to-all.sh          # Preview mode (default)
#   ./propagate-to-all.sh --apply  # Actually apply changes
#   ./propagate-to-all.sh --check  # Check status only
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/propagate-templates"

# Parent is M-Namikaz-Others - check both possible locations
if [[ -d "/mnt/m/M-Namikaz-Others" ]]; then
    PARENT_DIR="/mnt/m/M-Namikaz-Others"
elif [[ -d "/home/namikaz/projects/dev" ]]; then
    PARENT_DIR="/home/namikaz/projects/dev"
else
    echo "ERROR: Cannot find M-Namikaz-Others folder"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Mode flags
MODE="preview"
APPLY_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply|-a)
            APPLY_MODE=true
            MODE="apply"
            ;;
        --check|-c)
            MODE="check"
            ;;
        --preview|-p)
            MODE="preview"
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --apply, -a    Actually apply changes (default: preview)"
            echo "  --check, -c    Check status only"
            echo "  --preview, -p  Preview what would happen (default)"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# =============================================================================
# Template mapping (source file → target file)
# =============================================================================
declare -A TEMPLATES
TEMPLATES=(
    ["AGENTS.template.md"]="AGENTS.md"
    ["topic-insights.template.md"]="topic-insights.md"
    ["git-github-best-practices.template.md"]="git-github-best-practices.md"
    ["workspace-system-overview.template.md"]="workspace-system-overview.md"
    ["quality-standards.template.md"]="quality-standards.md"
    ["audit-folder-quality.template.sh"]="audit-folder-quality.sh"
    ["check-sync-status.template.sh"]="check-sync-status.sh"
    ["sync-from-hub.template.sh"]="sync-from-hub.sh"
    ["opencode.template.json"]="opencode.json"
    # opencode-agent-system merged into AGENTS.template.md
    [".cleanup-protect.template.md"]=".cleanup-protect"
    ["session-state.template.json"]="session-state.json"
    ["history.template.md"]="archive/history.md"
    ["README.md"]="README.md"
)

MANAGED_MARKER="Managed-By: AI-Prompting-Library"

# =============================================================================
# Helper functions
# =============================================================================

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log_create() { echo -e "${CYAN}[CREATE]${NC} $1"; }

# Convert folder name to kebab-case for content folder
to_kebab_case() {
    local name="$1"
    # Replace spaces with dashes first
    local result="${name// /-}"
    # Handle acronyms (PR, API, URL) - don't split them
    result="${result//([A-Z]{2,})([A-Z])/$1-$2}"
    result="${result//([a-z0-9])([A-Z]{2,})/$1-$2}"
    # Handle normal CamelCase
    result="${result//([A-Z]+)([A-Z][a-z])/$1-$2}"
    result="${result//([a-z0-9])([A-Z])/$1-$2}"
    # Clean up
    result="${result//-+/-}"
    result="${result/#-/}"
    result="${result/-$/}"
    echo "${result,,}"
}

# Ensure content folder exists
ensure_content_folder() {
    local folder="$1"
    local folder_name="$(basename "$folder")"
    local kebab_name="$(to_kebab_case "$folder_name")"
    local content_folder="$folder/${kebab_name}-content"
    
    if [[ -d "$content_folder" ]]; then
        echo "  content folder already exists"
        return 1
    fi
    
    if [[ "$MODE" == "preview" ]]; then
        echo "  would create content folder: ${kebab_name}-content/"
    elif [[ "$MODE" == "apply" ]]; then
        mkdir -p "$content_folder"
        echo "  created content folder: ${kebab_name}-content/"
    fi
    
    return 0
}

# =============================================================================
# Main propagation logic
# =============================================================================

propagate_to_folder() {
    local folder="$1"
    local folder_name="$(basename "$folder")"
    
    echo ""
    echo -e "${YELLOW}Processing: $folder_name${NC}"
    
    # Ensure content folder
    ensure_content_folder "$folder"
    
    # Process each template
    for template_file in "${!TEMPLATES[@]}"; do
        local target_file="${TEMPLATES[$template_file]}"
        local template_path="$TEMPLATES_DIR/$template_file"
        local target_path="$folder/$target_file"
        
        # Skip if template doesn't exist
        if [[ ! -f "$template_path" ]]; then
            continue
        fi
        
        # CREATE ONLY mode
        if [[ -f "$target_path" ]]; then
            echo "  $target_file: SKIP (exists)"
        else
            if [[ "$MODE" == "preview" ]]; then
                echo "  $target_file: PREVIEW CREATE"
            elif [[ "$MODE" == "apply" ]]; then
                cp "$template_path" "$target_path"
                echo "  $target_file: CREATED"
            else
                echo "  $target_file: would CREATE"
            fi
        fi
    done
}

# =============================================================================
# Main execution
# =============================================================================

# Find all topic folders (exclude AI Prompting itself and hidden folders)
echo "Scanning for topic folders in: $PARENT_DIR"
TOPIC_FOLDERS=()
for item in "$PARENT_DIR"/*/; do
    item_name="$(basename "$item")"
    if [[ "$item_name" != "AI Prompting" ]] && [[ ! "$item_name" == .* ]]; then
        TOPIC_FOLDERS+=("$item")
    fi
done

echo "Found ${#TOPIC_FOLDERS[@]} folders to process"
echo ""
echo "Mode: $MODE"

if [[ "$MODE" == "preview" ]]; then
    echo -e "${YELLOW}Running in PREVIEW mode. Use --apply to actually apply changes.${NC}"
fi

# Process each folder
for folder in "${TOPIC_FOLDERS[@]}"; do
    propagate_to_folder "$folder"
done

echo ""
echo "Done."