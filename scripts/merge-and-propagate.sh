#!/usr/bin/env bash
# =============================================================================
# merge-and-propagate.sh - Merge approved candidate and propagate
# =============================================================================
# After approving a cross-domain candidate:
#   1. Reads the approved candidate
#   2. Inserts it into the target doc in AI Prompting
#   3. Creates back-link note in source folder's topic-insights.md
#   4. Updates merge log
#   5. Runs propagate-to-all.sh
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
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --id CANDIDATE_ID      Candidate ID to merge"
            echo "  --target DOC           Target doc (e.g., core-agent-doctrine.md)"
            echo "  --wording TEXT         Generalized wording for the lesson"
            echo "  --preview, -p         Preview only"
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
echo ""

TARGET_PATH="$DOCS_DIR/$TARGET_DOC"

if [[ ! -f "$TARGET_PATH" ]]; then
    log_warn "Target doc not found: $TARGET_PATH"
    log_info "Available docs in $DOCS_DIR:"
    ls "$DOCS_DIR"/*.md 2>/dev/null | xargs -n1 basename
    exit 1
fi

if [[ "$PREVIEW" == "true" ]]; then
    log_info "Preview mode - would merge:"
    echo ""
    echo "  Add to: $TARGET_DOC"
    echo "  Content: $WORDING"
    echo ""
    echo "  Then run: ./scripts/propagate-to-all.sh --apply"
else
    # Add the lesson to the target doc
    echo "" >> "$TARGET_PATH"
    echo "## Cross-Domain Lesson (merged $(date '+%Y-%m-%d'))" >> "$TARGET_PATH"
    echo "" >> "$TARGET_PATH"
    echo "- $WORDING (from cross-domain candidate: $CANDIDATE_ID)" >> "$TARGET_PATH"
    
    log_ok "Added to: $TARGET_DOC"
    
    # Update merge log
    echo "" >> "$MERGE_LOG"
    echo "## $(date '+%Y-%m-%d %H:%M:%S')" >> "$MERGE_LOG"
    echo "" >> "$MERGE_LOG"
    echo "- Merged candidate: $CANDIDATE_ID" >> "$MERGE_LOG"
    echo "- Target: $TARGET_DOC" >> "$MERGE_LOG"
    echo "- Wording: $WORDING" >> "$MERGE_LOG"
    
    log_ok "Updated merge log"
    
    echo ""
    log_info "Now run: ./scripts/propagate-to-all.sh --apply"
fi

echo ""
log_ok "Done."