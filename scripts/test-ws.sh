#!/usr/bin/env bash
# =============================================================================
# test-ws.sh - Self-tests the ws.sh workspace command wrapper
# =============================================================================
# Tests common wrapper paths and verifies preview commands don't mutate files.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
WS_SH="$SCRIPT_DIR/ws.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

declare -a FAILURES=()

log_pass() { echo -e "${GREEN}PASS${NC}: $1"; }
log_fail() { echo -e "${RED}FAIL${NC}: $1"; }
log_info() { echo -e "${YELLOW}INFO${NC}: $1"; }

add_failure() {
    FAILURES+=("$1")
    log_fail "$1"
}

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    --parser-only    Only run parser checks
    -h, --help      Show this help
EOF
}

PARSER_ONLY=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --parser-only) PARSER_ONLY=true; shift ;;
        -h|--help) show_usage; exit 0 ;;
        *) echo "Unknown option: $1"; show_usage; exit 1 ;;
    esac
done

# Check bash version
check_bash_syntax() {
    local file="$1"
    if bash -n "$file" 2>/dev/null; then
        log_pass "$file syntax OK"
        return 0
    else
        add_failure "$file has syntax errors"
        return 1
    fi
}

# Run ws.sh command
invoke_ws() {
    local args=("$@")
    local output
    local exit_code
    
    output=$("$WS_SH" "${args[@]}" 2>&1)
    exit_code=$?
    
    echo "$output"
    return $exit_code
}

# Get file hash
get_file_hash() {
    local file="$1"
    if [[ -f "$file" ]]; then
        md5sum "$file" | cut -d' ' -f1
    else
        echo "FILE_NOT_FOUND"
    fi
}

# Check file unchanged
assert_unchanged() {
    local before_hash="$1"
    local after_hash="$2"
    local label="$3"
    
    if [[ "$before_hash" == "$after_hash" ]]; then
        log_pass "$label: unchanged"
    else
        add_failure "$label: file was modified"
    fi
}

echo "============================================="
echo "Testing ws.sh wrapper"
echo "============================================="

# Parser checks
echo ""
echo "== Parser Checks =="

if [[ ! -f "$WS_SH" ]]; then
    add_failure "ws.sh not found at $WS_SH"
else
    check_bash_syntax "$WS_SH"
    check_bash_syntax "$0"
fi

if $PARSER_ONLY; then
    if [[ ${#FAILURES[@]} -gt 0 ]]; then
        echo ""
        echo "FAILED: ${#FAILURES[@]} test(s)"
        exit 1
    fi
    log_pass "All parser checks passed"
    exit 0
fi

# Guarded files (shouldn't be mutated by preview commands)
GUARDED_FILES=(
    "workflow/harvested-topic-insights.md"
    "workflow/cross-domain-candidates.md"
    "workflow/sync-state.json"
)

declare -A before_hashes
for f in "${GUARDED_FILES[@]}"; do
    before_hashes[$f]=$(get_file_hash "$REPO_ROOT/$f")
done

echo ""
echo "== Command Matrix =="

# Test help
output=$(invoke_ws help 2>&1)
if [[ $? -eq 0 ]] && echo "$output" | grep -q "Usage:"; then
    log_pass "help exits 0 and prints usage"
else
    add_failure "help failed"
fi

# Test default command
output=$(invoke_ws 2>&1)
if [[ $? -eq 0 ]] && echo "$output" | grep -q "Commands:"; then
    log_pass "default command shows help"
else
    add_failure "default command failed"
fi

# Test invalid command
output=$(invoke_ws bogus 2>&1) || true
if echo "$output" | grep -qiE "unknown|invalid|not found"; then
    log_pass "invalid command fails gracefully"
else
    add_failure "invalid command didn't report error"
fi

# Test search
output=$(invoke_ws search "session-state" 2>&1)
if [[ $? -eq 0 ]] && echo "$output" | grep -q "session-state"; then
    log_pass "search finds active file"
else
    add_failure "search failed"
fi

# Test hotspots
output=$(invoke_ws hotspots 2>&1)
if [[ $? -eq 0 ]] && echo "$output" | grep -q "AGENTS"; then
    log_pass "hotspots exits 0"
else
    add_failure "hotspots failed"
fi

# Test status
output=$(invoke_ws status 2>&1)
if [[ $? -eq 0 ]] && echo "$output" | grep -q "Status"; then
    log_pass "status exits 0"
else
    add_failure "status failed"
fi

# Test validate
output=$(invoke_ws validate 2>&1)
if [[ $? -eq 0 ]]; then
    log_pass "validate exits 0"
else
    add_failure "validate failed"
fi

# Verify guarded files unchanged
echo ""
echo "== File Mutation Check =="
for f in "${GUARDED_FILES[@]}"; do
    after_hash=$(get_file_hash "$REPO_ROOT/$f")
    assert_unchanged "${before_hashes[$f]}" "$after_hash" "$f"
done

# Summary
echo ""
if [[ ${#FAILURES[@]} -gt 0 ]]; then
    echo "FAILED: ${#FAILURES[@]} test(s)"
    for f in "${FAILURES[@]}"; do
        echo "  - $f"
    done
    exit 1
else
    log_pass "All ws.sh tests passed"
    exit 0
fi
