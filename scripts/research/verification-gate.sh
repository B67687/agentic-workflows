#!/usr/bin/env bash
# =============================================================================
# verification-gate.sh — Research output verification gate
#
# Validates research output against the methodology's quality standards:
#   - Every claim has an explicit confidence label
#   - No unresolved NEEDS_VERIFICATION flags
#   - Sources are cited with URLs
#   - Claims are time-stamped
#
# Usage:
#   bash scripts/research/verification-gate.sh check <research-output.md>
#   bash scripts/research/verification-gate.sh check-stdin   (reads from stdin)
#
# Exit codes:
#   0 = PASS  — all checks pass
#   1 = FAIL  — critical checks failed (missing confidence labels, unresolved flags)
#   2 = WARN  — passable with minor issues (missing timestamps, uncited claims)
#   3 = SKIP  — no research output to verify (file not found or empty)
#
# Integration: This gate is called automatically at the end of Phase 3
# (Triangulate & Synthesize) before advancing to Phase 4 (Apply).
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Colors ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
  cat <<'USAGE'
Usage: bash scripts/research/verification-gate.sh <command> [file]

Commands:
  check <file>         Verify research output in a markdown file
  check-stdin          Verify research output from stdin

Exit codes:
  0 = PASS   — all checks pass
  1 = FAIL   — critical checks failed
  2 = WARN   — warnings only (minor issues)
  3 = SKIP   — no content to verify
USAGE
}

# ── Checks ──

errors=0
warnings=0

check_confidence_labels() {
  local content="$1"
  local lines
  lines=$(echo "$content" | grep -cE '\[(ESTABLISHED|CONFIRMED|PLAUSIBLE|SPECULATIVE)\]' 2>/dev/null || true)

  if [[ "$lines" -eq 0 ]]; then
    echo -e "  ${RED}✗ FAIL  No confidence labels found in content${NC}"
    echo "         Every claim must have a bracketed confidence label:"
    echo "         [ESTABLISHED], [CONFIRMED], [PLAUSIBLE], or [SPECULATIVE]"
    errors=$((errors + 1))
    return
  fi

  echo -e "  ${GREEN}✓ PASS  ${lines} claim(s) with confidence labels${NC}"

  # Check for claims without labels (lines with claim-like content but no label)
  local unlabeled
  unlabeled=$(echo "$content" | grep -ciE '(claim|finding|pattern|conclusion|recommendation):' 2>/dev/null || true)
  local labeled
  labeled=$(echo "$content" | grep -cE '(claim|finding|pattern|conclusion|recommendation):.*\[(ESTABLISHED|CONFIRMED|PLAUSIBLE|SPECULATIVE)\]' 2>/dev/null || true)

  if [[ "$unlabeled" -gt 0 && "$labeled" -lt "$unlabeled" ]]; then
    local missing=$((unlabeled - labeled))
    echo -e "  ${YELLOW}⚠ WARN  ${missing} claim-like line(s) without explicit confidence label${NC}"
    warnings=$((warnings + 1))
  fi
}

check_needs_verification() {
  local content="$1"
  local unresolved
  unresolved=$(echo "$content" | grep -cE 'NEEDS_VERIFICATION' 2>/dev/null || true)

  if [[ "$unresolved" -gt 0 ]]; then
    echo -e "  ${RED}✗ FAIL  ${unresolved} unresolved NEEDS_VERIFICATION flag(s)${NC}"
    echo "         All NEEDS_VERIFICATION flags must be resolved before integration."
    echo "         See Integration Rules in research/research-prompt.md."
    errors=$((errors + 1))
  else
    echo -e "  ${GREEN}✓ PASS  No unresolved NEEDS_VERIFICATION flags${NC}"
  fi
}

check_source_citations() {
  local content="$1"

  # Count inline citations: [text](URL) or bare URLs
  local cited
  cited=$(echo "$content" | grep -cE 'http[s]?://' 2>/dev/null || true)

  if [[ "$cited" -eq 0 ]]; then
    echo -e "  ${YELLOW}⚠ WARN  No source URL citations found in content${NC}"
    echo "         Every claim should cite its source. See Phase 5 requirements."
    warnings=$((warnings + 1))
  else
    echo -e "  ${GREEN}✓ PASS  ${cited} source URL citation(s) found${NC}"
  fi
}

check_timestamps() {
  local content="$1"
  local stamped
  stamped=$(echo "$content" | grep -cE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2}\]' 2>/dev/null || true)

  if [[ "$stamped" -eq 0 ]]; then
    echo -e "  ${YELLOW}⚠ WARN  No date-stamped claims found${NC}"
    echo "         Add [YYYY-MM-DD] timestamps to claims per Integration Rules."
    warnings=$((warnings + 1))
  else
    echo -e "  ${GREEN}✓ PASS  ${stamped} date-stamped claim(s)${NC}"
  fi
}

check_has_content() {
  local content="$1"
  local total_lines
  total_lines=$(echo "$content" | wc -l 2>/dev/null || echo 0)

  if [[ "$total_lines" -lt 3 ]]; then
    echo -e "  ${YELLOW}⚠ SKIP   Research output too short (${total_lines} lines) -- nothing to verify${NC}"
    exit 3
  fi
}

check_output_sections() {
  local content="$1"
  local has_question=false
  local has_findings=false

  echo "$content" | grep -qiE '(research question|sharpened scope|done.criteria)' && has_question=true
  echo "$content" | grep -qiE '(key findings|findings|triangulat|synthesize)' && has_findings=true

  if ! $has_question && ! $has_findings; then
    echo -e "  ${YELLOW}⚠ WARN  Content does not match expected research output structure${NC}"
    echo "         Expected sections: Research Question, Key Findings, etc."
    warnings=$((warnings + 1))
  elif ! $has_findings; then
    echo -e "  ${YELLOW}⚠ WARN  No findings/triangulation section detected${NC}"
    warnings=$((warnings + 1))
  else
    echo -e "  ${GREEN}✓ PASS  Research output structure detected${NC}"
  fi
}

# ── Main verification ──

cmd_check() {
  local target_file="$1"

  if [[ ! -f "$target_file" ]]; then
    echo -e "  ${YELLOW}SKIP   File not found: ${target_file}${NC}"
    exit 3
  fi

  local content
  content=$(cat "$target_file" 2>/dev/null || true)
  if [[ -z "$content" ]]; then
    echo -e "  ${YELLOW}SKIP   Empty file: ${target_file}${NC}"
    exit 3
  fi

  echo ""
  echo -e "${BOLD}═══ Research Verification Gate${NC}"
  echo -e "  File: ${target_file}"
  echo ""

  check_has_content "$content"
  check_confidence_labels "$content"
  check_needs_verification "$content"
  check_source_citations "$content"
  check_timestamps "$content"
  check_output_sections "$content"

  echo ""
  if [[ "$errors" -gt 0 ]]; then
    echo -e "  ${RED}✗ FAIL  ${errors} error(s), ${warnings} warning(s)${NC}"
    echo ""
    echo "  Fix errors, then re-run: bash scripts/research/verification-gate.sh check \"${target_file}\""
    exit 1
  elif [[ "$warnings" -gt 0 ]]; then
    echo -e "  ${YELLOW}⚠ WARN  ${warnings} warning(s)${NC}"
    echo ""
    echo "  Review warnings and consider addressing them for higher quality."
    exit 2
  else
    echo -e "  ${GREEN}✓ PASS  all checks passed${NC}"
    exit 0
  fi
}

cmd_check_stdin() {
  local tmp_file
  tmp_file=$(mktemp /tmp/research-verify-XXXXXX.md)
  cat >"$tmp_file"
  cmd_check "$tmp_file"
  rm -f "$tmp_file"
}

# ── Main ──

main() {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
  check)
    local file="${1:-}"
    if [[ -z "$file" ]]; then
      echo "Usage: bash scripts/research/verification-gate.sh check <file>"
      exit 2
    fi
    cmd_check "$file"
    ;;
  check-stdin)
    cmd_check_stdin
    ;;
  --help | -h | help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
  esac
}

main "$@"
