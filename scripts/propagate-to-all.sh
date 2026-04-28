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
TEMPLATES_DIR="$REPO_ROOT/propagation"

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
    ["workspace-system-overview.template.md"]="docs/workspace-system-overview.md"
    ["quality-standards.template.md"]="quality-standards.md"
    ["audit-folder-quality.template.sh"]="audit-folder-quality.sh"
    ["check-sync-status.template.sh"]="check-sync-status.sh"
    ["sync-from-hub.template.sh"]="sync-from-hub.sh"
    ["opencode.template.json"]="opencode.json"
    # opencode-agent-system merged into AGENTS.template.md
    [".cleanup-protect.template.md"]=".cleanup-protect"
    ["session-state.template.json"]="session-state.json"
    ["history.template.md"]="archive/history.md"
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
log_artifact() { echo -e "${RED}[ARTIFACT]${NC} $1"; }

# Detect old artifacts in a topic folder
detect_artifacts() {
    local folder="$1"
    local folder_name="$(basename "$folder")"
    
    echo ""
    echo -e "${YELLOW}Checking for old artifacts in: $folder_name${NC}"
    
    local artifact_count=0
    
    # Check for .ps1 files (old PowerShell scripts)
    while IFS= read -r -d '' ps1file; do
        local filename="$(basename "$ps1file")"
        log_artifact "Old PowerShell file: $filename"
        ((artifact_count++))
    done < <(find "$folder" -maxdepth 1 -name "*.ps1" -print0 2>/dev/null)
    
    # Check for old templates that are no longer propagated (have Managed-By marker)
    while IFS= read -r -d '' oldfile; do
        local filename="$(basename "$oldfile")"
        # Check if this file is in current templates
        local is_current=false
        for target in "${TEMPLATES[@]}"; do
            if [[ "$filename" == "$target" ]]; then
                is_current=true
                break
            fi
        done
        if [[ "$is_current" == "false" ]]; then
            # Check if it has the Managed-By marker (it's a propagated file)
            if grep -q "Managed-By: AI-Prompting-Library" "$oldfile" 2>/dev/null; then
                log_artifact "Old propagated file (no longer in template list): $filename"
                ((artifact_count++))
            fi
        fi
    done < <(find "$folder" -maxdepth 1 -name "*.md" -print0 2>/dev/null)
    
    if [[ $artifact_count -eq 0 ]]; then
        echo "  No old artifacts detected"
    else
        echo ""
        echo -e "${RED}Found $artifact_count old artifact(s) in $folder_name${NC}"
        echo "  These files are no longer propagated but may exist in the folder."
        echo "  To clean up: manually delete or run cleanup in that folder."
    fi
}

# Convert folder name to kebab-case for content folder
to_kebab_case() {
    local name="$1"
    # Replace spaces with dashes, lowercase
    local result="${name// /-}"
    result="${result,,}"
    # Clean up multiple dashes
    result="${result//-+/-}"
    result="${result/#-/}"
    result="${result/-$/}"
    echo "$result"
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
    detect_artifacts "$folder"
done

echo ""
echo "Done."
echo ""
echo "============================================="
echo "ARTIFACT SUMMARY"
echo "============================================="
echo "If any [ARTIFACT] warnings appeared above,"
echo "those files exist in topic folders but are"
echo "no longer in the propagation list."
echo ""
echo "To clean up old artifacts:"
echo "1. Review the detected files"
echo "2. Delete them manually or add cleanup logic"
echo "============================================="