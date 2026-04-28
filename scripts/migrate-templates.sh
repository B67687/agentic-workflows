#!/usr/bin/env bash
# =============================================================================
# migrate-templates.sh - Migrate existing files to new template format
# =============================================================================
# This script is for when YOU change the template format/standards and need to
# propagate the new format to all folders while converting existing content.
#
# It does:
#   1. Read existing content from each topic folder
#   2. Transform/convert it to the new format
#   3. Write back to each folder (overwrites existing!)
#
# Usage:
#   ./migrate-templates.sh                    # Preview mode
#   ./migrate-templates.sh --apply            # Actually apply migration
#   ./migrate-templates.sh --template AGENTS  # Migrate specific template
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
MAGENTA='\033[0;35m'
NC='\033[0m'

MODE="preview"
SPECIFIC_TEMPLATE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply|-a)
            MODE="apply"
            ;;
        --template|-t)
            SPECIFIC_TEMPLATE="$2"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --apply, -a              Actually apply migration (default: preview)"
            echo "  --template, -t NAME      Migrate specific template (AGENTS, topic-insights, etc)"
            echo "  --help, -h               Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 --template AGENTS --apply"
            echo "  $0 --preview"
            exit 0
            ;;
        *)
            MODE="preview"
            ;;
    esac
    shift
done

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_migrate() { echo -e "${MAGENTA}[MIGRATE]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }

# =============================================================================
# Migration functions for each template type
# =============================================================================

migrate_agents() {
    local existing="$1"
    local template="$2"
    
    # This is where you define HOW to convert existing content to new format
    # Example: You changed the section headers, so you need to migrate old format
    
    # For now, this is a placeholder - you'd customize this based on what changed
    echo "$template"
}

migrate_topic_insights() {
    local existing="$1"
    local template="$2"
    
    # Migration logic for topic-insights.md
    # Example: If you added new required sections
    
    echo "$template"
}

migrate_session_state() {
    local existing="$1"
    local template="$2"
    
    # If existing is already valid JSON, return template
    if echo "$existing" | jq -e . >/dev/null 2>&1; then
        log_info "Already JSON - using new template"
        echo "$template"
        return
    fi
    
    # For Markdown format: just use template (simpler and more reliable)
    # The new format is cleaner
    echo "$template"
}

# =============================================================================
# Main migration logic
# =============================================================================

migrate_file() {
    local template_name="$1"
    local folder="$2"
    local folder_name="$(basename "$folder")"
    
    # Map template name to file
    case "$template_name" in
        AGENTS)
            local template_file="AGENTS.template.md"
            local target_file="AGENTS.md"
            ;;
        topic-insights|topic-insights.md)
            local template_file="topic-insights.template.md"
            local target_file="topic-insights.md"
            ;;
        session-state|session-state.json)
            local template_file="session-state.template.json"
            local target_file="session-state.json"
            ;;
        *)
            log_warn "Unknown template: $template_name"
            return 1
            ;;
    esac
    
    local template_path="$TEMPLATES_DIR/$template_file"
    local target_path="$folder/$target_file"
    
    # Check if files exist
    if [[ ! -f "$template_path" ]]; then
        log_warn "Template not found: $template_file"
        return 1
    fi
    
    if [[ ! -f "$target_path" ]]; then
        log_skip "$folder_name/$target_file: file doesn't exist, use propagate instead"
        return 1
    fi
    
    local existing_content
    local template_content
    existing_content="$(cat "$target_path")"
    template_content="$(cat "$template_path")"
    
    # Run migration
    local migrated
    case "$template_name" in
        AGENTS)
            migrated="$(migrate_agents "$existing_content" "$template_content")"
            ;;
        topic-insights|topic-insights.md)
            migrated="$(migrate_topic_insights "$existing_content" "$template_content")"
            ;;
        session-state|session-state.json)
            migrated="$(migrate_session_state "$existing_content" "$template_content")"
            ;;
    esac
    
    if [[ "$MODE" == "preview" ]]; then
        echo "  $target_file: would MIGRATE (preview)"
    elif [[ "$MODE" == "apply" ]]; then
        echo "$migrated" > "$target_path"
        echo "  $target_file: MIGRATED"
    fi
}

# =============================================================================
# Main execution
# =============================================================================

echo "Template Migration Script"
echo "=========================="
echo ""
echo "Mode: $MODE"

if [[ "$MODE" == "preview" ]]; then
    echo -e "${YELLOW}Running in PREVIEW mode. Use --apply to actually apply migration.${NC}"
fi

if [[ -z "$SPECIFIC_TEMPLATE" ]]; then
    log_warn "No template specified. Use --template to specify which template to migrate."
    echo ""
    echo "Available templates:"
    echo "  - AGENTS"
    echo "  - topic-insights"
    echo "  - session-state"
    exit 0
fi

# Find topic folders
TOPIC_FOLDERS=()
for item in "$PARENT_DIR"/*/; do
    item_name="$(basename "$item")"
    if [[ "$item_name" != "AI Prompting" ]] && [[ ! "$item_name" == .* ]]; then
        TOPIC_FOLDERS+=("$item")
    fi
done

echo ""
log_info "Found ${#TOPIC_FOLDERS[@]} folders to process"
log_info "Migrating: $SPECIFIC_TEMPLATE"
echo ""

# Process each folder
for folder in "${TOPIC_FOLDERS[@]}"; do
    folder_name="$(basename "$folder")"
    echo -e "${YELLOW}Processing: $folder_name${NC}"
    migrate_file "$SPECIFIC_TEMPLATE" "$folder"
done

echo ""
echo "Done."