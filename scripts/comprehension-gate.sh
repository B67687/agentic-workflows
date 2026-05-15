#!/usr/bin/env bash
# =============================================================================
# comprehension-gate.sh --- Recognition-pattern enforced participation gate
#
# Implements the Recognition model (Attaguile, 2026): before acting on an
# instruction file (skill, command, or workflow doc), the agent must demonstrate
# comprehension by extracting specific, verifiable content from it.
#
# The gate checks that the agent has produced a structured comprehension
# evidence file with the required extraction markers. It does NOT check
# semantic correctness -- the act of extraction is the participation
# requirement. Semantic quality is a separate concern.
#
# Usage:
#   extract  <instructions-path> [--out <evidence-file>]
#            Produce a comprehension template for the given instruction file.
#            The agent fills it with extracted content.
#
#   verify   <evidence-file>
#            Check that the evidence file exists and has the required markers
#            with non-empty content. Exit 0 = pass, 1 = fail, 2 = warn.
#
#   summary  [--recent] [--all]
#            Show comprehension gate history from .runtime/comprehension-audit.jsonl
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"
AUDIT_LOG="$RUNTIME_DIR/comprehension-audit.jsonl"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  extract  <instructions-path> [--out <evidence-file>]
           Create a structured comprehension template from an instruction file.
           The agent fills in the template to demonstrate understanding before acting.

  verify   <evidence-file>
           Check the evidence file for required markers with non-empty content.
           Returns PASS (exit 0), WARN (exit 2), or FAIL (exit 1).

  summary  [--recent] [--all]
           Show comprehension gate history.
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

source_name() {
  local path="$1"
  basename "$(dirname "$path")/$(basename "$path")" | sed 's/\.md$//'
}

instruction_type() {
  local path="$1"
  if echo "$path" | grep -qE 'skills/'; then
    echo "skill"
  elif echo "$path" | grep -qE 'commands/'; then
    echo "command"
  elif echo "$path" | grep -qE 'docs/'; then
    echo "doc"
  elif echo "$path" | grep -qE 'AGENTS\.md'; then
    echo "contract"
  else
    echo "reference"
  fi
}

log_audit() {
  local action="$1" source="$2" result="$3"
  mkdir -p "$RUNTIME_DIR"
  echo "{\"event\":\"comprehension_gate\",\"action\":\"$action\",\"source\":\"$source\",\"result\":\"$result\",\"timestamp\":$(date +%s)}" >> "$AUDIT_LOG"
}

# ---------------------------------------------------------------------------
# Extract relevant content from an instruction file
# ---------------------------------------------------------------------------
extract_sections() {
  local instr_file="$1"
  local evidence_file="$2"

  if [[ ! -f "$instr_file" ]]; then
    echo "ERROR: instruction file not found: $instr_file" >&2
    exit 1
  fi

  local name
  name=$(source_name "$instr_file")
  local itype
  itype=$(instruction_type "$instr_file")

  # Extract key sections from the instruction file for the template
  local verification_found=""
  local anti_rationalizations=""
  local red_flags=""

  # Verification target: look for "verification" or "Verification target" or "verify"
  verification_found=$(grep -i -m 3 'verification\|verify\|test\|check' "$instr_file" 2>/dev/null | head -3 || echo "")

  # Anti-rationalizations: grab the whole rationalization table if present
  if grep -q '<rationalizations>' "$instr_file" 2>/dev/null; then
    anti_rationalizations=$(sed -n '/<rationalizations>/,/<\/rationalizations>/p' "$instr_file" 2>/dev/null | head -20 || echo "")
  fi

  # Red flags
  if grep -q '<red_flags>' "$instr_file" 2>/dev/null; then
    red_flags=$(sed -n '/<red_flags>/,/<\/red_flags>/p' "$instr_file" 2>/dev/null | head -15 || echo "")
  fi

  # Write the evidence template
  cat > "$evidence_file" <<TEMPLATE
## Comprehension Evidence

**Instruction file:** $instr_file
**Type:** $itype
**Name:** $name

### 1. Verification Target for This Task
<!--REQUIRED-->

### 2. Most Relevant Anti-Rationalization
<!--REQUIRED-->

### 3. Red Flag Most Likely to Be Violated
<!--REQUIRED-->

### 4. What Is Deliberately Out of Scope
<!--REQUIRED-->

---

*Generated from: $instr_file*
TEMPLATE

  # Optionally append extracted sections as reference
  if [[ -n "$verification_found" ]]; then
    echo "" >> "$evidence_file"
    echo "### Reference: Verification patterns from instruction" >> "$evidence_file"
    echo '```' >> "$evidence_file"
    echo "$verification_found" >> "$evidence_file"
    echo '```' >> "$evidence_file"
  fi

  echo "Comprehension template written to: $evidence_file"
  echo ""
  echo "Fill in each <!--REQUIRED--> section with extracted content from"
  echo "the instruction file before implementing. The quality gate checks"
  echo "that these sections are filled before commit."
}

# ---------------------------------------------------------------------------
# Verify comprehension evidence
# ---------------------------------------------------------------------------
verify_evidence() {
  local evidence_file="$1"

  if [[ ! -f "$evidence_file" ]]; then
    echo "FAIL: comprehension evidence not found: $evidence_file"
    echo "  Run: bash scripts/comprehension-gate.sh extract <instruction-file> --out $evidence_file"
    echo "  Then fill in the <!--REQUIRED--> sections before implementing."
    log_audit "verify" "$evidence_file" "fail_not_found"
    exit 1
  fi

  local content
  content=$(cat "$evidence_file" 2>/dev/null || true)
  local failures=0
  local warnings=0

  # Check 1: Required markers exist
  if ! echo "$content" | grep -q '<!--REQUIRED-->'; then
    echo "FAIL: No <!--REQUIRED--> markers found in $evidence_file"
    echo "  The template requires filling in specific sections from the instruction."
    failures=$((failures + 1))
  fi

  # Check 2: Each required section has substantive content
  # Count non-empty lines between <!--REQUIRED--> and the next heading or end
  local sections_filled=0
  local in_section=false
  local has_content=false
  while IFS= read -r line; do
    if echo "$line" | grep -q '<!--REQUIRED-->'; then
      in_section=true
      has_content=false
    elif echo "$line" | grep -qE '^### |^$|---'; then
      if [[ "$in_section" == true && "$has_content" == true ]]; then
        sections_filled=$((sections_filled + 1))
      fi
      in_section=false
    elif [[ "$in_section" == true ]] && echo "$line" | grep -qE '[A-Za-z]{4,}'; then
      has_content=true
    fi
  done <<< "$content"

  if [[ "$sections_filled" -lt 3 ]]; then
    echo "WARN: Only $sections_filled of 4 required sections have substantive content."
    echo "  At least 3 sections must be filled to demonstrate comprehension."
    echo "  Fill each <!--REQUIRED--> section between the marker and next heading."
    warnings=$((warnings + 1))
  fi

  # Check 3: Evidence file has reasonable size (not empty boilerplate)
  local line_count
  line_count=$(echo "$content" | wc -l)
  if [[ "$line_count" -lt 15 ]]; then
    echo "WARN: Evidence file is very short ($line_count lines). Expected ~25+ lines of extracted content."
    warnings=$((warnings + 1))
  fi

  if [[ "$failures" -gt 0 ]]; then
    echo "FAIL: Comprehension gate has $failures failure(s) and $warnings warning(s)"
    log_audit "verify" "$evidence_file" "fail"
    exit 1
  fi

  if [[ "$warnings" -gt 0 ]]; then
    echo "PASS (with warnings): $warnings advisory note(s)"
    log_audit "verify" "$evidence_file" "warn"
    exit 2
  fi

  echo "PASS: Comprehension evidence verified"
  log_audit "verify" "$evidence_file" "pass"
  exit 0
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
show_summary() {
  local mode="${1:-recent}"

  if [[ ! -f "$AUDIT_LOG" ]]; then
    echo "No comprehension gate history found."
    echo "  Audit log: $AUDIT_LOG"
    exit 0
  fi

  case "$mode" in
    recent)
      echo "=== Recent Comprehension Gate Activity ==="
      tail -10 "$AUDIT_LOG" | python3 -c "
import json, sys, time
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        e = json.loads(line)
        ts = time.strftime('%H:%M', time.localtime(e.get('timestamp', 0)))
        act = e.get('action', '?')
        src = e.get('source', '?')
        res = e.get('result', '?')
        print(f'  {ts} | {act:8s} | {src:40s} | {res}')
    except json.JSONDecodeError:
        pass
"
      ;;
    all)
      local count
      count=$(wc -l < "$AUDIT_LOG" 2>/dev/null || echo 0)
      echo "=== Complete Comprehension Gate History ($count entries) ==="
      cat "$AUDIT_LOG" | python3 -c "
import json, sys, time
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        e = json.loads(line)
        ts = time.strftime('%m-%d %H:%M', time.localtime(e.get('timestamp', 0)))
        act = e.get('action', '?')
        src = e.get('source', '?')
        res = e.get('result', '?')
        print(f'  {ts} | {act:8s} | {src:40s} | {res}')
    except json.JSONDecodeError:
        pass
"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------
case "$CMD" in
  extract)
    INSTR_FILE=""
    EVIDENCE_FILE=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --out) EVIDENCE_FILE="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *)
          if [[ -z "$INSTR_FILE" ]]; then
            INSTR_FILE="$1"
          else
            echo "Unknown: $1" >&2
            usage
            exit 2
          fi
          shift
          ;;
      esac
    done

    if [[ -z "$INSTR_FILE" ]]; then
      echo "ERROR: instruction file path is required" >&2
      usage
      exit 2
    fi

    if [[ ! -f "$INSTR_FILE" ]]; then
      echo "ERROR: file not found: $INSTR_FILE" >&2
      exit 1
    fi

    if [[ -z "$EVIDENCE_FILE" ]]; then
      # Default: .runtime/comprehension-evidence.md in repo root
      mkdir -p "$RUNTIME_DIR"
      EVIDENCE_FILE="$RUNTIME_DIR/comprehension-evidence.md"
    fi

    extract_sections "$INSTR_FILE" "$EVIDENCE_FILE"
    log_audit "extract" "$INSTR_FILE" "created"
    ;;

  verify)
    EVIDENCE_FILE=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --help|-h) usage; exit 0 ;;
        *)
          if [[ -z "$EVIDENCE_FILE" ]]; then
            EVIDENCE_FILE="$1"
          else
            echo "Unknown: $1" >&2
            usage
            exit 2
          fi
          shift
          ;;
      esac
    done

    if [[ -z "$EVIDENCE_FILE" ]]; then
      # Default: check default path
      EVIDENCE_FILE="$RUNTIME_DIR/comprehension-evidence.md"
    fi

    verify_evidence "$EVIDENCE_FILE"
    ;;

  summary)
    smode="recent"
    if [[ "$*" == *"--all"* ]]; then
      smode="all"
    fi
    show_summary "$smode"
    ;;

  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
