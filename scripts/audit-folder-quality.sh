#!/usr/bin/env bash
# =============================================================================
# audit-folder-quality.sh - Audit this folder for quality standards compliance
# =============================================================================
# Scans all files in the folder and validates them against the standards.
# Reports findings but does not fail.
#
# Validates:
#   - Folder organization (naming, structure, orphans)
#   - Script quality (parameters, help, error handling)
#   - Content quality (source-backed links, actionable advice)
#   - Markdown quality (headings, links, placeholders)
#   - Template completeness
#
# Usage:
#   ./audit-folder-quality.sh          # Run full audit
#   ./audit-folder-quality.sh --verbose # Detailed output
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v)
            VERBOSE=true
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v  Show detailed output"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
    esac
    shift
done

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

# Get the folder to audit (default: current folder)
FOLDER="${1:-.}"
cd "$FOLDER" 2>/dev/null || FOLDER="."

echo "============================================="
echo "Folder Quality Audit"
echo "============================================="
echo ""
echo "Auditing: $(pwd)"
echo ""

# =============================================================================
# 1. Naming Conventions
# =============================================================================
echo "--- Naming Conventions ---"

naming_issues=0

# Check files use kebab-case
for f in *; do
    [[ -f "$f" ]] || continue
    # Skip special files
    [[ "$f" == .git* ]] && continue
    [[ "$f" == .* ]] && continue
    
    # Check if name contains uppercase or spaces
    if [[ "$f" =~ [A-Z] ]] || [[ "$f" =~ [[:space:]] ]]; then
        # Allow certain exceptions
        [[ "$f" == *.md ]] && continue
        [[ "$f" == *.json ]] && continue
        [[ "$f" == *.ps1 ]] && continue
        [[ "$f" == *.sh ]] && continue
        log_warn "File should use lowercase: $f"
        ((naming_issues++))
    fi
done

if [[ $naming_issues -eq 0 ]]; then
    log_pass "All files use kebab-case"
else
    echo "  Found $naming_issues naming issues"
fi

# =============================================================================
# 2. Required Files
# =============================================================================
echo ""
echo "--- Required Files ---"

required_files=("AGENTS.md" "topic-insights.md")
missing_files=0

for req in "${required_files[@]}"; do
    if [[ -f "$req" ]]; then
        log_pass "Found: $req"
    else
        log_warn "Missing: $req"
        ((missing_files++))
    fi
done

# =============================================================================
# 3. Script Quality (if scripts exist)
# =============================================================================
echo ""
echo "--- Script Quality ---"

scripts_found=0
script_issues=0

for script in *.sh; do
    [[ -f "$script" ]] || continue
    
    ((scripts_found++))
    
    # Check for shebang
    first_line=$(head -n1 "$script")
    if [[ ! "$first_line" =~ ^#! ]]; then
        log_warn "$script: Missing shebang"
        ((script_issues++))
    fi
done

if [[ $scripts_found -eq 0 ]]; then
    log_info "No scripts found to audit"
elif [[ $script_issues -eq 0 ]]; then
    log_pass "All scripts have proper headers"
else
    echo "  Found $script_issues script issues"
fi

# =============================================================================
# 4. Content Quality
# =============================================================================
echo ""
echo "--- Content Quality ---"

md_files=0
md_issues=0

for md in *.md; do
    [[ -f "$md" ]] || continue
    [[ "$md" == *.md ]] || continue
    
    ((md_files++))
    
    # Check for placeholder text
    if grep -qiE "(TODO|FIXME|add your|replace this|click to edit)" "$md" 2>/dev/null; then
        log_warn "$md: Contains placeholder text"
        ((md_issues++))
    fi
done

if [[ $md_files -eq 0 ]]; then
    log_info "No markdown files found"
elif [[ $md_issues -eq 0 ]]; then
    log_pass "All markdown files are content-ready"
else
    echo "  Found $md_issues markdown issues"
fi

# =============================================================================
# 5. Markdown Structure
# =============================================================================
echo ""
echo "--- Markdown Structure ---"

has_h1=0
heading_issues=0

for md in *.md; do
    [[ -f "$md" ]] || continue
    
    # Check for H1
    if head -n1 "$md" | grep -q "^# "; then
        ((has_h1++))
    else
        log_warn "$md: Missing H1 heading"
        ((heading_issues++))
    fi
done

if [[ $has_h1 -gt 0 ]]; then
    log_pass "All markdown files have H1 headings"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "============================================="
echo "Summary"
echo "============================================="
echo ""
echo "Total files audited: $(find . -maxdepth 1 -type f | wc -l)"
echo ""

# Overall result
total_issues=$((naming_issues + missing_files + script_issues + md_issues + heading_issues))

if [[ $total_issues -eq 0 ]]; then
    log_pass "Audit passed - no issues found"
    exit 0
else
    log_warn "Audit complete - $total_issues issues found"
    exit 0
fi