#!/usr/bin/env bash
# =============================================================================
# build-cross-domain-candidates.sh - Build cross-domain review queue
# =============================================================================
# Scans harvested insights for cross-domain candidates and builds a review queue.
#
# Usage:
#   ./build-cross-domain-candidates.sh              # Build candidates
#   ./build-cross-domain-candidates.sh --preview    # Preview only
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOW_DIR="$REPO_ROOT/workflow"

HARVESTED_FILE="$WORKFLOW_DIR/harvested-topic-insights.md"
OUTPUT_FILE="$WORKFLOW_DIR/cross-domain-candidates.md"
STATE_FILE="$WORKFLOW_DIR/cross-domain-review-state.json"

PREVIEW=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --preview|-p)
            PREVIEW=true
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --preview, -p  Preview only"
            echo "  --help, -h     Show this help"
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
echo "Build Cross-Domain Candidates"
echo "============================================="
echo ""

# Check if harvested file exists
if [[ ! -f "$HARVESTED_FILE" ]]; then
    log_warn "No harvested insights found"
    log_info "Run harvest-topic-insights.sh first"
    exit 1
fi

# Look for transferable lessons sections
log_info "Scanning for cross-domain candidates..."

# This is a simplified version - extracts sections that look transferable
output="# Cross-Domain Candidates

Generated: $(date '+%Y-%m-%d %H:%M:%S %z')

## Candidates

"

# Check for Transferable Lessons sections in harvested file
candidates_found=0

# Parse the harvested file and find transferable lessons
in_section=false
current_section=""
current_folder=""

while IFS= read -r line; do
    # Check for folder header
    if [[ "$line" =~ ^\#\#\#\  ]]; then
        current_folder="${line#### }"
        in_section=false
    fi
    
    # Check for Transferable Lessons section
    if [[ "$line" =~ ^##\  ]]; then
        section_name="${line#### }"
        if [[ "$section_name" == "Transferable Lessons" ]]; then
            in_section=true
        else
            in_section=false
        fi
    fi
    
    # Skip template/boilerplate content
    if [[ "$in_section" == true ]]; then
        if [[ "$line" =~ ^-\ If\ a\ lesson ]] || [[ "$line" =~ ^-\ Add\ insights ]] || [[ "$line" =~ ^-\ Use\ tags ]]; then
            continue
        fi
        
        # This is actual content
        if [[ -n "$line" ]] && [[ ! "$line" =~ ^\ \# ]]; then
            ((candidates_found++))
            output+="- **$current_folder**: $line
"
        fi
    fi
done < "$HARVESTED_FILE"

output+="
## Review Status

| Status | Description |
|--------|-------------|
| pending | Not yet reviewed |
| reviewing | Under review |
| promoted | Approved and integrated |
| rejected | Not suitable for cross-domain |

## How to Review

1. Review the candidates above
2. Check if the lesson applies to other domains
3. Use \`set-promotion-review-status.sh\` to update status
4. Use \`merge-and-propagate.sh\` to merge approved candidates
"

if [[ "$candidates_found" -eq 0 ]]; then
    log_warn "No cross-domain candidates found"
    log_info "Add transferable lessons to topic-insights.md in topic folders"
else
    log_ok "Found $candidates_found candidates"
    
    if [[ "$PREVIEW" == "true" ]]; then
        echo "$output" | head -30
    else
        echo "$output" > "$OUTPUT_FILE"
        log_ok "Written to: $OUTPUT_FILE"
    fi
fi

echo ""
log_ok "Done."