#!/usr/bin/env bash
# =============================================================================
# harvest-topic-insights.sh - Harvest topic insights from topic folders
# =============================================================================
# Reads repo-owned topic-insights.md files from topic folders and writes
# a central workflow snapshot without mutating the topic repos themselves.
#
# Usage:
#   ./harvest-topic-insights.sh                  # Harvest all folders
#   ./harvest-topic-insights.sh --preview       # Preview only
#   ./harvest-topic-insights.sh --output FILE   # Custom output file
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/propagation-contract.sh"
WORKFLOW_DIR="$REPO_ROOT/workflow"
OUTPUT_FILE="$WORKFLOW_DIR/harvested-topic-insights.md"

PARENT_DIR="${AI_PROMPTING_WORKSPACE_ROOT:-$(propagation_parent_dir)}"

PREVIEW=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --preview|-p)
            PREVIEW=true
            ;;
        --output|-o)
            OUTPUT_FILE="$2"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --preview, -p       Preview only"
            echo "  --output, -o FILE   Output file (default: workflow/harvested-topic-insights.md)"
            echo "  --help, -h          Show this help"
            exit 0
            ;;
    esac
    shift
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "============================================="
echo "Harvest Topic Insights"
echo "============================================="
echo ""

# Find all topic folders with topic-insights.md
folders_with_insights=()
while IFS= read -r folder; do
    [[ -z "$folder" ]] && continue
    insights_file="$folder/topic-insights.md"
    if [[ -f "$insights_file" ]]; then
        folders_with_insights+=("$folder")
    fi
done < <(propagation_collect_topic_folders)

echo "Found ${#folders_with_insights[@]} folders with topic-insights.md"
echo ""

if [[ ${#folders_with_insights[@]} -eq 0 ]]; then
    log_warn "No folders with topic-insights.md found"
    exit 0
fi

# Build the output
output="# Harvested Topic Insights

Generated: $(date '+%Y-%m-%d %H:%M:%S %z')

## Summary

- Harvest mode: read-only topic-insights snapshot
- Topic folders included: ${#folders_with_insights[@]}

## Included

"

for folder in "${folders_with_insights[@]}"; do
    folder_name="$(basename "$folder")"
    insights_file="$folder/topic-insights.md"
    output+="- $folder_name | $insights_file
"
done

output+="
## Snapshots

"

for folder in "${folders_with_insights[@]}"; do
    folder_name="$(basename "$folder")"
    insights_file="$folder/topic-insights.md"

    output+="## Folder: $folder_name

- Path: $folder
- Source: $insights_file

### Begin Topic Insights
"
    output+="$(cat "$insights_file")
"
    output+="### End Topic Insights

"
done

# Write output
if [[ "$PREVIEW" == "true" ]]; then
    log_info "Preview mode - would write to: $OUTPUT_FILE"
    echo ""
    echo "$output" | head -50
    echo "..."
else
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    echo "$output" > "$OUTPUT_FILE"
    log_ok "Written to: $OUTPUT_FILE"
fi

echo ""
log_ok "Done."
