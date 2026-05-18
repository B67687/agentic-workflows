#!/usr/bin/env bash
# =============================================================================
# research-sufficiency.sh --- Structured gate: "is research complete enough?"
#
# The agent self-assesses research coverage against the 6-phase methodology
# (Frame -> Discover Local -> Gather External -> Triangulate -> Apply ->
# Preserve). Checks for red flags: missing source URLs, no confidence
# levels, skipped phases, no gaps section.
#
# Outputs PASS (ready for planning), CONTINUE (gaps remain), or BLOCK
# (critical gaps -- go back to research).
#
# Usage:
#   assess [--research-note <file>]    Self-assess research coverage
#   note <research-note-file>          Parse a research note for red flags
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"
SUFFICIENCY_LOG="$RUNTIME_DIR/research-sufficiency-log.jsonl"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  assess [--research-note <file>] [--out <file>]
         Self-assess research coverage against the 6-phase methodology.
         If --research-note is provided, also checks for red flags.
         Outputs PASS/CONTINUE/BLOCK and a structured gap analysis.

  note <file>
         Parse a research note file for red flags only (no self-assessment).
         Checks: source URLs, confidence levels, phase coverage, gaps section.
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log_result() {
  local entry="$1"
  mkdir -p "$RUNTIME_DIR"
  echo "$entry" >> "$SUFFICIENCY_LOG"
}

# ---------------------------------------------------------------------------
# Parse a research note for red flags
# ---------------------------------------------------------------------------
check_note_redflags() {
  local note_file="$1"

  if [[ ! -f "$note_file" ]]; then
    echo "ERROR: research note not found: $note_file" >&2
    return 1
  fi

  python3 -c "
import re, sys

with open('$note_file') as f:
    content = f.read()

red_flags = 0
warnings = 0
output = []

# RF1: No source URLs
if not re.search(r'https?://|source:|arxiv\.org|doi\.org|github\.com', content, re.I):
    output.append('  BLOCK  No source URLs found in research note')
    red_flags += 1

# RF2: No confidence levels
if not re.search(r'CONFIRMED|ESTABLISHED|PLAUSIBLE|SPECULATIVE|confidence', content, re.I):
    output.append('  BLOCK  No confidence levels assigned to claims')
    red_flags += 1

# RF3: No gaps or uncertainty section
if not re.search(r'gap|uncertaint|unknown|limit|open question|not found', content, re.I):
    output.append('  WARN   No gaps or uncertainty section found')
    warnings += 1

# RF4: CONFIDENT claims without sources
confident_count = len(re.findall(r'CONFIDENT|CONFIRMED', content, re.I))
url_count = len(re.findall(r'https?://', content))
if confident_count > 0 and url_count == 0:
    output.append('  WARN   CONFIDENT/CONFIRMED claims but no source URLs')
    warnings += 1

# RF5: No question-framing phase
if not re.search(r'research question|sharpened scope|5w\+?h|frame', content, re.I):
    output.append('  WARN   No question-framing phase evident')
    warnings += 1

# RF6: No local knowledge discovery
if not re.search(r'repo\.?map|search\.?index|local|already known|existing', content, re.I):
    output.append('  WARN   No local knowledge discovery evident')
    warnings += 1

# RF7: No triangulation
if not re.search(r'triangulat|compare|converge|multiple source|cross\.?ref', content, re.I):
    output.append('  WARN   No triangulation across sources evident')
    warnings += 1

# Output
for line in output:
    print(line)
print()
print(f'  Red flags: {red_flags}  Warnings: {warnings}')
sys.exit(2 if red_flags > 0 else (1 if warnings > 2 else 0))
" 2>/dev/null
  local rf_rc=$?
  return $rf_rc
}

# ---------------------------------------------------------------------------
# Full assessment (self-assessment + optional note parse)
# ---------------------------------------------------------------------------
assess_sufficiency() {
  local note_file=""
  local out_file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --research-note) note_file="$2"; shift 2 ;;
      --out) out_file="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  echo "=========================================="
  echo "  Research Sufficiency Assessment"
  echo "=========================================="
  echo ""

  # --- Phase self-assessment template ---
  echo "Rate coverage for each research phase (0=none, 5=complete):"
  echo ""

  phases=(
    "Phase 0: Frame the Question (sharpened scope + 'done' criteria)"
    "Phase 1: Discover Local (what's already known + gaps)"
    "Phase 2: Gather External (raw claims with source URLs + dates)"
    "Phase 3: Triangulate (coherent model with confidence per claim)"
    "Phase 4: Apply to Problem (what changes, what must be true)"
    "Phase 5: Preserve (memory saved, docs updated, learnings logged)"
  )

  local total_score=0
  local gaps=0
  local critical_gaps=0

  for phase in "${phases[@]}"; do
    # Extract phase number and name
    local pnum
    pnum=$(echo "$phase" | grep -oP 'Phase \d+' || echo "Phase ?")
    local pname
    pname=$(echo "$phase" | grep -oP ': .+')

    echo "  $phase"
    echo "    Score (0-5): "

    # For automated use (non-interactive): read from command line or default
    # In interactive mode, we'd prompt. For agent use, we output the template.
  done

  echo ""
  echo "--- Red Flag Check ---"

  local rf_result=0
  if [[ -n "$note_file" ]]; then
    check_note_redflags "$note_file"
    rf_result=$?
  else
    echo "  (no research note provided for red flag check)"
    echo "  Provide one with: --research-note <file>"
    rf_result=1
  fi

  echo ""
  echo "--- Summary ---"

  local verdict=""
  if [[ "$rf_result" -eq 2 ]]; then
    verdict="BLOCK"
    echo "  Verdict: BLOCK --- critical gaps in research"
    echo "  Action:  go back to /research, address red flags"
  elif [[ "$rf_result" -eq 1 ]]; then
    verdict="CONTINUE"
    echo "  Verdict: CONTINUE --- gaps remain but not blocking"
    echo "  Action:  address warnings before planning, or proceed with caution"
  else
    verdict="PASS"
    echo "  Verdict: PASS --- research is sufficient for planning"
    echo "  Action:  proceed to /plan"
  fi

  echo ""

  # Log the assessment
  local timestamp
  timestamp=$(date +%s)
  local entry
  entry=$(cat <<EOF
{"event":"research_sufficiency","verdict":"$verdict","red_flags_blocks":$([[ "$rf_result" -eq 2 ]] && echo "1" || echo "0"),"note_provided":$([[ -n "$note_file" ]] && echo "1" || echo "0"),"timestamp":$timestamp}
EOF
)
  log_result "$entry"
  echo "Logged to: $SUFFICIENCY_LOG"

  # Exit code matches verdict
  case "$verdict" in
    BLOCK) exit 2 ;;
    CONTINUE) exit 1 ;;
    PASS) exit 0 ;;
  esac
}

# ---------------------------------------------------------------------------
# Quick note-only check
# ---------------------------------------------------------------------------
check_note() {
  local note_file="${1:-}"
  if [[ -z "$note_file" ]]; then
    echo "ERROR: usage: research-sufficiency.sh note <file>" >&2
    exit 2
  fi

  echo "=== Research Note Red Flag Check ==="
  echo ""

  check_note_redflags "$note_file"
  local rc=$?

  echo ""
  case $rc in
    0) echo "PASS: no critical issues found" ;;
    1) echo "CONTINUE: minor issues found (review warnings)" ;;
    2) echo "BLOCK: critical issues found (fix before planning)" ;;
  esac

  exit $rc
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "$CMD" in
  assess)
    assess_sufficiency "$@"
    ;;
  note)
    check_note "$@"
    ;;
  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
