#!/usr/bin/env bash
# =============================================================================
# merge-and-propagate.sh - Merge approved candidate and propagate
# =============================================================================
# After approving a cross-domain candidate:
#   1. Reads the approved candidate from workflow/cross-domain-candidates.md
#   2. Inserts the generalized lesson into the target doc in ai-prompting
#   3. Updates merge-log.md
#   4. Optionally runs propagate-to-all.sh
#
# Usage:
#   ./merge-and-propagate.sh --id CANDIDATE_ID --target DOC --wording "Generalized wording"
#   ./merge-and-propagate.sh --id CANDIDATE_ID --preview
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOW_DIR="$REPO_ROOT/workflow"
DOCS_DIR="$REPO_ROOT/docs"

CANDIDATES_FILE="$WORKFLOW_DIR/cross-domain-candidates.md"
MERGE_LOG="$WORKFLOW_DIR/merge-log.md"

CANDIDATE_ID=""
TARGET_DOC=""
WORDING=""
PREVIEW=false
RUN_PROPAGATION=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --id)
            CANDIDATE_ID="$2"
            shift
            ;;
        --target)
            TARGET_DOC="$2"
            shift
            ;;
        --wording|-w)
            WORDING="$2"
            shift
            ;;
        --preview|-p)
            PREVIEW=true
            ;;
        --propagate)
            RUN_PROPAGATION=true
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --id CANDIDATE_ID      Candidate ID to merge"
            echo "  --target DOC           Target doc (e.g., core-agent-doctrine.md)"
            echo "  --wording TEXT         Generalized wording for the lesson"
            echo "  --preview, -p         Preview only"
            echo "  --propagate           After merge, refresh managed core in topic repos"
            echo "  --help, -h             Show this help"
            echo ""
            echo "Example:"
            echo "  $0 --id abc123 --target core-agent-doctrine.md --wording \"Verify environment first\""
            exit 0
            ;;
    esac
    shift
done

# Validate required args
if [[ -z "$CANDIDATE_ID" ]]; then
    echo "ERROR: --id is required"
    echo "Use --help for usage"
    exit 1
fi

if [[ -z "$TARGET_DOC" ]]; then
    echo "ERROR: --target is required"
    echo "Use --help for usage"
    exit 1
fi

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
echo "Merge and Propagate"
echo "============================================="
echo ""

log_info "Candidate ID: $CANDIDATE_ID"
log_info "Target Doc: $TARGET_DOC"
log_info "Wording: $WORDING"
log_info "Propagate After Merge: $RUN_PROPAGATION"
echo ""

TARGET_PATH="$DOCS_DIR/$TARGET_DOC"

if [[ ! -f "$TARGET_PATH" ]]; then
    log_warn "Target doc not found: $TARGET_PATH"
    log_info "Available docs in $DOCS_DIR:"
    ls "$DOCS_DIR"/*.md 2>/dev/null | xargs -n1 basename
    exit 1
fi

if [[ ! -f "$CANDIDATES_FILE" ]]; then
    log_warn "Candidates file not found: $CANDIDATES_FILE"
    log_info "Run ./scripts/harvest-topic-insights.sh and ./scripts/build-cross-domain-candidates.sh first"
    exit 1
fi

extract_candidate_field() {
    local field_name="$1"
    awk -v cid="$CANDIDATE_ID" -v field="$field_name" '
        $0 == "### Candidate: " cid { in_block=1; next }
        in_block && /^### Candidate: / { exit }
        in_block && index($0, "- " field ": ") == 1 {
            sub("^- " field ": ", "", $0)
            print
            exit
        }
    ' "$CANDIDATES_FILE"
}

CANDIDATE_SOURCE_FOLDER="$(extract_candidate_field "Source folder")"
CANDIDATE_SOURCE_FILE="$(extract_candidate_field "Source file")"
CANDIDATE_CAPTURE_TYPE="$(extract_candidate_field "Capture type")"
CANDIDATE_SUGGESTED_TARGET="$(extract_candidate_field "Suggested target")"
CANDIDATE_TEXT="$(extract_candidate_field "Candidate text")"

if [[ -z "$CANDIDATE_TEXT" ]]; then
    log_warn "Candidate ID not found in $CANDIDATES_FILE: $CANDIDATE_ID"
    exit 1
fi

if [[ "$PREVIEW" == "true" ]]; then
    log_info "Preview mode - would merge:"
    echo ""
    echo "  Candidate: $CANDIDATE_ID"
    echo "  Source folder: $CANDIDATE_SOURCE_FOLDER"
    echo "  Source file: $CANDIDATE_SOURCE_FILE"
    echo "  Capture type: $CANDIDATE_CAPTURE_TYPE"
    echo "  Suggested target: $CANDIDATE_SUGGESTED_TARGET"
    echo "  Target doc: $TARGET_DOC"
    echo "  Candidate text: $CANDIDATE_TEXT"
    echo "  Generalized wording: $WORDING"
    echo ""
    if [[ "$RUN_PROPAGATION" == "true" ]]; then
        echo "  Then run managed refresh automatically"
    else
        echo "  Managed refresh is not automatic unless --propagate is passed"
    fi
else
    # Add the lesson to the target doc
    echo "" >> "$TARGET_PATH"
    echo "## Cross-Domain Lesson (merged $(date '+%Y-%m-%d'))" >> "$TARGET_PATH"
    echo "" >> "$TARGET_PATH"
    echo "- $WORDING (from cross-domain candidate: $CANDIDATE_ID, source: $CANDIDATE_SOURCE_FOLDER)" >> "$TARGET_PATH"
    
    log_ok "Added to: $TARGET_DOC"
    
    # Update merge log
    echo "" >> "$MERGE_LOG"
    echo "## $(date '+%Y-%m-%d %H:%M:%S')" >> "$MERGE_LOG"
    echo "" >> "$MERGE_LOG"
    echo "- Merged candidate: $CANDIDATE_ID" >> "$MERGE_LOG"
    echo "- Source folder: $CANDIDATE_SOURCE_FOLDER" >> "$MERGE_LOG"
    echo "- Source file: $CANDIDATE_SOURCE_FILE" >> "$MERGE_LOG"
    echo "- Capture type: $CANDIDATE_CAPTURE_TYPE" >> "$MERGE_LOG"
    echo "- Candidate text: $CANDIDATE_TEXT" >> "$MERGE_LOG"
    echo "- Target: $TARGET_DOC" >> "$MERGE_LOG"
    echo "- Wording: $WORDING" >> "$MERGE_LOG"
    
    log_ok "Updated merge log"
    
    echo ""
    if [[ "$RUN_PROPAGATION" == "true" ]]; then
        bash "$SCRIPT_DIR/propagate-to-all.sh" --apply
        log_ok "Managed refresh complete"
    else
        log_info "Now run: ./scripts/propagate-to-all.sh --apply"
    fi
fi

echo ""
log_ok "Done."
