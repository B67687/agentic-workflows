#!/usr/bin/env bash
# =============================================================================
# cleanup-folders.sh - Folder cleanup utility for M-Namikaz-Others workspace
# =============================================================================
# Finds empty directories, stale folders, structural issues.
# Use --apply to actually perform changes.

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

WORKSPACE_ROOT="${WORKSPACE_ROOT:-/home/namikaz/projects/dev}"
DAYS_STALE="${DAYS_STALE:-30}"

REMOVE_EMPTY=false
DETECT_STALE=false
CHECK_STRUCTURE=false
ARCHIVE_OLD=false
REPORT_ONLY=true
APPLY=false

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    --remove-empty     Find empty directories
    --detect-stale     Find stale folders
    --check-structure  Validate repo structure
    --archive-old      Archive stale folders
    --report-only      Preview only (default)
    --apply            Actually perform changes
    --days N           Days threshold for stale (default: $DAYS_STALE)
    -h, --help         Show this help

Examples:
    $(basename "$0") --report-only
    $(basename "$0") --detect-stale --check-structure
    $(basename "$0") --remove-empty --apply
EOF
}

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --remove-empty) REMOVE_EMPTY=true; shift ;;
        --detect-stale) DETECT_STALE=true; shift ;;
        --check-structure) CHECK_STRUCTURE=true; shift ;;
        --archive-old) ARCHIVE_OLD=true; shift ;;
        --report-only) REPORT_ONLY=true; shift ;;
        --apply) APPLY=true; REPORT_ONLY=false; shift ;;
        --days) DAYS_STALE="$2"; shift 2 ;;
        -h|--help) show_usage; exit 0 ;;
        *) echo "Unknown option: $1"; show_usage; exit 1 ;;
    esac
done

# Default to all checks if none specified
if ! $REMOVE_EMPTY && ! $DETECT_STALE && ! $CHECK_STRUCTURE; then
    REMOVE_EMPTY=true
    DETECT_STALE=true
    CHECK_STRUCTURE=true
fi

echo "============================================="
echo "Folder Cleanup Utility"
echo "============================================="
echo "Workspace: $WORKSPACE_ROOT"
echo "Stale threshold: $DAYS_STALE days"
echo "Mode: $([ "$REPORT_ONLY" = true ] && echo "REPORT ONLY" || echo "APPLY")"
echo ""

# Check for cleanup-ignore file
has_ignore_file() {
    local dir="$1"
    [[ -f "$dir/.cleanup-ignore" ]]
}

# Get last activity (newest file modification)
get_last_activity() {
    local dir="$1"
    local newest
    newest=$(find "$dir" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1)
    if [[ -n "$newest" ]]; then
        echo "$newest" | cut -d' ' -f2-
    fi
}

# Check if directory is empty
is_empty_dir() {
    local dir="$1"
    [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]
}

# Find empty directories
find_empty_dirs() {
    local root="$1"
    log_info "Scanning for empty directories..."
    local count=0
    while IFS= read -r -d '' dir; do
        if ! has_ignore_file "$dir"; then
            echo "  $dir"
            ((count++))
        fi
    done < <(find "$root" -type d -empty -print0 2>/dev/null)
    echo "Found $count empty directories"
}

# Find stale folders
find_stale_dirs() {
    local root="$1"
    local threshold
    threshold=$(date -d "$DAYS_STALE days ago" +%s 2>/dev/null || echo "0")
    
    log_info "Scanning for stale folders (>$DAYS_STALE days inactive)..."
    local count=0
    while IFS= read -r -d '' dir; do
        if ! has_ignore_file "$dir"; then
            local lastmod
            lastmod=$(stat -c %Y "$dir" 2>/dev/null || echo "0")
            if [[ "$lastmod" -lt "$threshold" ]]; then
                local days_since=$(( ($(date +%s) - lastmod) / 86400 ))
                echo "  $dir (${days_since}d inactive)"
                ((count++))
            fi
        fi
    done < <(find "$root" -type d -print0 2>/dev/null)
    echo "Found $count stale directories"
}

# Check structure
check_structure() {
    local root="$1"
    log_info "Validating repo structure..."
    
    local required_dirs=("docs" "scripts" "archive" "workflow")
    local missing=0
    
    for d in "${required_dirs[@]}"; do
        if [[ -d "$root/$d" ]]; then
            log_pass "$root/$d exists"
        else
            log_warn "$root/$d missing"
            ((missing++))
        fi
    done
    
    echo "Structure check: $missing missing directories"
}

# Main execution
if $REMOVE_EMPTY; then
    find_empty_dirs "$WORKSPACE_ROOT"
fi

if $DETECT_STALE; then
    find_stale_dirs "$WORKSPACE_ROOT"
fi

if $CHECK_STRUCTURE; then
    check_structure "$WORKSPACE_ROOT"
fi

echo ""
if $REPORT_ONLY; then
    log_pass "Report complete. Use --apply to make changes."
else
    log_warn "Apply mode not yet implemented"
fi
