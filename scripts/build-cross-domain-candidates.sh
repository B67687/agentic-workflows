#!/usr/bin/env bash
# =============================================================================
# build-cross-domain-candidates.sh - Build cross-domain review queue
# =============================================================================
# Scans the harvested topic-insights snapshot and extracts reusable lessons
# into a candidate review queue with stable IDs.
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
log_info "Scanning harvested insights for cross-domain candidates..."

output="# Cross-Domain Candidates

Generated: $(date '+%Y-%m-%d %H:%M:%S %z')

## Candidates

"

declare -A SEEN=()
candidates_found=0
current_folder=""
current_source=""
in_snapshot=false
current_section=""
pending_cross_heading=""
pending_cross_body=""

normalize_text() {
    local text="$1"
    printf '%s' "$text" | tr '\r\n' ' ' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//'
}

is_placeholder_line() {
    local text="$1"
    [[ "$text" =~ ^Add\ insights ]] && return 0
    [[ "$text" =~ ^Capture\ insights ]] && return 0
    [[ "$text" =~ ^Use\ tags ]] && return 0
    [[ "$text" =~ ^If\ a\ lesson\ applies ]] && return 0
    [[ "$text" =~ ^When\ a\ new\ insight ]] && return 0
    return 1
}

suggest_target() {
    local text="$1"
    local lower
    lower="$(printf '%s' "$text" | tr '[:upper:]' '[:lower:]')"

    if [[ "$lower" == *"test"* ]] || [[ "$lower" == *"verify"* ]] || [[ "$lower" == *"debug"* ]]; then
        printf 'core-agent-doctrine.md\n'
    elif [[ "$lower" == *"token"* ]] || [[ "$lower" == *"context"* ]]; then
        printf 'token-efficient-prompting.md\n'
    elif [[ "$lower" == *"tool"* ]] || [[ "$lower" == *"shell"* ]] || [[ "$lower" == *"wsl"* ]]; then
        printf 'repo-tooling.md\n'
    else
        printf 'core-agent-doctrine.md\n'
    fi
}

emit_candidate() {
    local capture_type="$1"
    local raw_text="$2"
    local text candidate_id suggested

    text="$(normalize_text "$raw_text")"
    [[ -n "$text" ]] || return
    is_placeholder_line "$text" && return

    candidate_id="$(printf '%s' "$current_source|$capture_type|$text" | sha1sum | cut -c1-12)"
    [[ -n "${SEEN[$candidate_id]:-}" ]] && return
    SEEN["$candidate_id"]=1
    suggested="$(suggest_target "$text")"

    output+="### Candidate: $candidate_id
- Source folder: $current_folder
- Source file: $current_source
- Capture type: $capture_type
- Suggested target: $suggested
- Status: pending
- Candidate text: $text

"
    ((candidates_found++))
}

flush_pending_cross_heading() {
    if [[ -n "$pending_cross_heading" ]]; then
        emit_candidate "cross-domain-section" "$pending_cross_heading ${pending_cross_body:-}"
    fi
    pending_cross_heading=""
    pending_cross_body=""
}

while IFS= read -r line; do
    line="${line%$'\r'}"

    if [[ "$line" =~ ^##\ Folder:\  ]]; then
        flush_pending_cross_heading
        current_folder="${line#### Folder: }"
        current_source=""
        in_snapshot=false
        current_section=""
        continue
    fi

    if [[ "$line" =~ ^-\ Source:\  ]]; then
        current_source="${line#- Source: }"
        continue
    fi

    if [[ "$line" == "### Begin Topic Insights" ]]; then
        in_snapshot=true
        current_section=""
        pending_cross_heading=""
        pending_cross_body=""
        continue
    fi

    if [[ "$line" == "### End Topic Insights" ]]; then
        flush_pending_cross_heading
        in_snapshot=false
        current_section=""
        continue
    fi

    [[ "$in_snapshot" == true ]] || continue

    if [[ "$line" =~ ^##\  ]]; then
        flush_pending_cross_heading
        current_section="${line#### }"
        continue
    fi

    if [[ "$line" =~ ^###\  ]]; then
        flush_pending_cross_heading
        if [[ "$line" == *"Cross-Domain"* ]]; then
            pending_cross_heading="${line#\#\#\# }"
            pending_cross_body=""
        fi
        continue
    fi

    if [[ "$current_section" == "Transferable Lessons" && "$line" =~ ^-\  ]]; then
        emit_candidate "transferable-lesson" "${line#- }"
        continue
    fi

    if [[ "$line" == *"#cross-domain"* ]]; then
        emit_candidate "tagged-line" "${line#- }"
        continue
    fi

    if [[ -n "$pending_cross_heading" && -n "$line" ]]; then
        if [[ "$line" =~ ^-\  ]]; then
            pending_cross_body+=" ${line#- }"
        else
            pending_cross_body+=" $line"
        fi
    fi
done < "$HARVESTED_FILE"

flush_pending_cross_heading

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
3. Choose the smallest correct central doc
4. Use \`merge-and-propagate.sh --id ... --target ... --wording ...\` to merge approved candidates
"

if [[ "$candidates_found" -eq 0 ]]; then
    log_warn "No cross-domain candidates found"
    log_info "Add real transferable lessons or #cross-domain markers to topic-insights.md in topic folders"
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
