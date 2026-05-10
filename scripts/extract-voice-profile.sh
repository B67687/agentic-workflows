#!/usr/bin/env bash
# =============================================================================
# extract-voice-profile.sh - Analyzes writing samples and extracts voice patterns
# =============================================================================
# Reads all .txt and .md files from personal-voice/samples/,
# analyzes them for voice patterns, and outputs statistics.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SAMPLES_DIR="$REPO_ROOT/personal-voice/samples"
OUTPUT_FILE="$REPO_ROOT/personal-voice/VOICE-PROFILE.md"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Analyzes writing samples and extracts voice patterns.

Options:
    -h, --help         Show this help
    -o, --output FILE  Output file (default: personal-voice/VOICE-PROFILE.md)
    -q, --quiet        Quiet mode (no output)

Examples:
    $(basename "$0")
    $(basename "$0") -o custom-profile.md
EOF
}

QUIET=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage; exit 0 ;;
        -o|--output) OUTPUT_FILE="$2"; shift 2 ;;
        -q|--quiet) QUIET=true; shift ;;
        *) echo "Unknown option: $1"; show_usage; exit 1 ;;
    esac
done

# Check samples directory
if [[ ! -d "$SAMPLES_DIR" ]]; then
    echo "ERROR: Samples directory not found: $SAMPLES_DIR"
    exit 1
fi

# Get all text files
mapfile -t sample_files < <(find "$SAMPLES_DIR" -type f \( -name "*.txt" -o -name "*.md" \) 2>/dev/null)

if [[ ${#sample_files[@]} -eq 0 ]]; then
    echo "ERROR: No sample files found in $SAMPLES_DIR"
    exit 1
fi

$QUIET || log_info "Found ${#sample_files[@]} sample files"

# Combine all samples
ALL_TEXT=""
for file in "${sample_files[@]}"; do
    ALL_TEXT+=$(cat "$file")" "
done

# Calculate sentence statistics
get_sentence_stats() {
    local text="$1"
    local sentences
    mapfile -t sentences < <(echo "$text" | grep -oP '(?<=[.!?])\s+' || true)
    
    local total=${#sentences[@]}
    if [[ $total -eq 0 ]]; then
        echo "0 0 0 0"
        return
    fi
    
    local total_len=0
    local short=0
    local long=0
    
    for sent in "${sentences[@]}"; do
        local len=${#sent}
        total_len=$((total_len + len))
        [[ $len -lt 10 ]] && ((short++)) || true
        [[ $len -gt 25 ]] && ((long++)) || true
    done
    
    local avg=$((total_len / total))
    echo "$avg $short $long $total"
}

# Calculate word statistics
get_word_stats() {
    local text="$1"
    local words
    mapfile -t words < <(echo "$text" | grep -oE '\b[a-zA-Z]+\b' | tr '[:upper:]' '[:lower:]' | sort)
    
    local total=${#words[@]}
    if [[ $total -eq 0 ]]; then
        echo "0"
        return
    fi
    
    # Unique words
    local unique
    unique=$(printf '%s\n' "${words[@]}" | uniq | wc -l)
    echo "$unique"
}

# Count contractions
count_contractions() {
    local text="$1"
    local count
    count=$(echo "$text" | grep -oE "\b(can't|won't|don't|doesn't|didn't|isn't|aren't|I'm|I've|I'd|you're|we're|they're|that's|it's|there's|here's|let's|can't|wouldn't|couldn't|shouldn't|haven't|hasn't|hadn't)\b" | wc -l)
    echo "$count"
}

# Common transition words
get_transitions() {
    local text="$1"
    local transitions="however moreover furthermore consequently thus hence therefore meanwhile additionally subsequently accordingly consequently"
    local found=0
    for word in $transitions; do
        local c
        c=$(echo "$text" | grep -oi "\b$word\b" | wc -l)
        found=$((found + c))
    done
    echo "$found"
}

# Analyze
SENT_STATS=$(get_sentence_stats "$ALL_TEXT")
read avg_len short_count long_count total_sentences <<< "$SENT_STATS"

WORD_COUNT=$(get_word_stats "$ALL_TEXT")
CONTRACTION_COUNT=$(count_contractions "$ALL_TEXT")
TRANSITION_COUNT=$(get_transitions "$ALL_TEXT")

# Output results
$QUIET || log_pass "Analysis complete"

cat << EOF
# Voice Profile Analysis

Generated: $(date '+%Y-%m-%d %H:%M:%S')

## Statistics

| Metric | Value |
|--------|-------|
| Total Sentences | $total_sentences |
| Avg Sentence Length | $avg_len chars |
| Short Sentences (<10) | $short_count |
| Long Sentences (>25) | $long_count |
| Unique Words | $WORD_COUNT |
| Contractions | $CONTRACTION_COUNT |
| Transition Words | $TRANSITION_COUNT |

## Patterns Detected

- **Burstiness**: $([ $avg_len -gt 20 ] && echo "High (long sentences)" || [ $avg_len -gt 15 ] && echo "Medium" || echo "Low (short sentences)")
- **Formality**: $([ $CONTRACTION_COUNT -gt 10 ] && echo "Informal (many contractions)" || echo "Formal")
- **Connectivity**: $([ $TRANSITION_COUNT -gt 5 ] && echo "Well-connected" || echo "Direct")

## Files Analyzed

$(printf '%s\n' "${sample_files[@]}" | sed 's|.*/||')
EOF
