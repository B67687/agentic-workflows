#!/usr/bin/env bash
# =============================================================================
# constitution.sh --- Workspace Constitution management
# Manages a constitution.md that encodes immutable governing principles.
# Each article defines gates checked before phase transitions.
#
# Usage:
#   ./scripts/constitution.sh init              Create constitution from template
#   ./scripts/constitution.sh check [article]    Check constitution compliance
#   ./scripts/constitution.sh amend              Record a constitution amendment
#   ./scripts/constitution.sh gate <from> <to>   Run gates for phase transition
#   ./scripts/constitution.sh list               List all articles with status
#   ./scripts/constitution.sh status             Show constitution health
#   ./scripts/constitution.sh path               Show constitution file path
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"

CONSTITUTION_FILE=""
for candidate in "$REPO_ROOT/constitution.md" "$REPO_ROOT/docs/constitution.md"; do
  if [[ -f "$candidate" ]]; then
    CONSTITUTION_FILE="$candidate"
    break
  fi
done

TEMPLATE_DIR="$REPO_ROOT/templates/core"

COMPACT=${COMPACT:-1}
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

say() { [[ "$COMPACT" == "0" ]] && echo "$@"; :; }

usage() {
  cat <<'USAGE'
Usage: ./scripts/constitution.sh <command> [options]

Commands:
  init                     Create constitution.md from template
  check [article]           Check article gates against current state
  amend                     Record a constitution amendment
  gate <from> <to>          Run gates for a phase transition
  list                      List all articles
  status                    Show constitution health
  path                      Show constitution file path

Options:
  --force  Overwrite existing constitution on init
  -h       Show this help

Phase transitions: research -> plan | plan -> implement | implement -> review
USAGE
}

ensure_constitution() {
  if [[ -z "$CONSTITUTION_FILE" ]]; then
    echo "ERROR: No constitution.md found. Run 'constitution.sh init' first." >&2
    exit 1
  fi
}

get_article_count() {
  ensure_constitution
  grep -c '^## Article ' "$CONSTITUTION_FILE" 2>/dev/null || echo 0
}

get_article_list() {
  ensure_constitution
  grep '^## Article ' "$CONSTITUTION_FILE" 2>/dev/null
}

get_article_severity() {
  local target="$1"; ensure_constitution
  local count=0; local in=false; local sev="ADVISORY"
  while IFS= read -r line; do
    if echo "$line" | grep -q '^## Article '; then
      count=$((count + 1))
      if [[ "$count" -eq "$target" ]]; then
        in=true; continue
      elif [[ "$in" == true ]]; then
        break
      fi
    fi
    [[ "$in" == true ]] && echo "$line" | grep -qi "BLOCKING" && sev="BLOCKING"
  done < "$CONSTITUTION_FILE"
  echo "$sev"
}

# ─── Gate check functions ────────────────────────────────────────────────

g_research_note() {
  for f in "$REPO_ROOT"/research/*.md; do
    [[ -f "$f" ]] && [[ "$(wc -c < "$f" 2>/dev/null || echo 0)" -gt 100 ]] && { echo "PASS"; return; }
  done
  [[ -f "$RUNTIME_DIR/research-note.md" ]] && { echo "PASS"; return; }
  echo "FAIL"
}

g_files_read() {
  for f in "$REPO_ROOT"/research/*.md; do
    [[ -f "$f" ]] && grep -qi 'read\|examined\|analyzed\|reviewed\|inspected\|studied' "$f" 2>/dev/null && { echo "PASS"; return; }
  done
  echo "FAIL"
}

g_verification() {
  for f in "$REPO_ROOT"/research/*.md; do
    [[ -f "$f" ]] && grep -qi 'verification\|verify\|test\|check\|validate\|confirm' "$f" 2>/dev/null && { echo "PASS"; return; }
  done
  [[ -f "$RUNTIME_DIR/comprehension-evidence.md" ]] && grep -qi 'verification\|verify\|test\|check' "$RUNTIME_DIR/comprehension-evidence.md" 2>/dev/null && { echo "PASS"; return; }
  echo "FAIL"
}

g_challenge() {
  if [[ -f "$RUNTIME_DIR/challenge-response.json" ]]; then
    local s; s=$(stat -c%s "$RUNTIME_DIR/challenge-response.json" 2>/dev/null || echo 0)
    [[ "$s" -gt 20 ]] && { echo "PASS"; return; }
  fi
  echo "FAIL"
}

g_comprehension() {
  [[ ! -f "$RUNTIME_DIR/comprehension-evidence.md" ]] && { echo "FAIL"; return; }
  local u; u=$(grep -c '<!--REQUIRED-->' "$RUNTIME_DIR/comprehension-evidence.md" 2>/dev/null || echo 0)
  [[ "$u" -eq 0 ]] && echo "PASS" || echo "WARN"
}

g_simplicity() {
  for f in "$REPO_ROOT"/research/*.md; do
    [[ -f "$f" ]] && grep -qi 'simpl\|complexity\|over-engine' "$f" 2>/dev/null && { echo "PASS"; return; }
  done
  echo "WARN"
}

g_errors() {
  [[ -d "$RUNTIME_DIR/error-counter" ]] || { echo "SKIP"; return; }
  local active=0
  for f in "$RUNTIME_DIR"/error-counter/*.json; do [[ -f "$f" ]] && active=$((active + 1)); done
  [[ "$active" -eq 0 ]] && { echo "SKIP"; return; }
  grep -q '"count": [3-9]\|"count": [1-9][0-9]' "$RUNTIME_DIR"/error-counter/*.json 2>/dev/null && { echo "ESCALATE"; return; }
  echo "PASS"
}

g_artifacts() {
  local from="$1"; local to="$2"
  case "${from}:${to}" in
    research:plan)
      local hr=false
      for f in "$REPO_ROOT"/research/*.md; do [[ -f "$f" ]] && hr=true && break; done
      [[ "$hr" != true ]] && { echo "FAIL:missing research note"; return; }
      ;;
    plan:implement)
      local hp=false
      for f in "$REPO_ROOT"/research/*.md; do
        [[ -f "$f" ]] && grep -qi 'plan\|step\|phase\|milestone' "$f" 2>/dev/null && hp=true && break
      done
      [[ "$hp" != true ]] && [[ ! -f "$RUNTIME_DIR/plan.json" ]] && { echo "FAIL:missing plan"; return; }
      ;;
  esac
  echo "PASS"
}

# ─── Commands ────────────────────────────────────────────────────────────

cmd_init() {
  local force=false
  while [[ $# -gt 0 ]]; do case "$1" in --force) force=true ;; -h) usage; exit 0 ;; *) echo "Unknown: $1" >&2; exit 2 ;; esac; shift; done
  [[ -n "$CONSTITUTION_FILE" && "$force" != true ]] && { echo "ERROR: Constitution exists at $CONSTITUTION_FILE (use --force)" >&2; exit 1; }
  local t="$TEMPLATE_DIR/constitution-template.md"
  [[ ! -f "$t" ]] && { echo "ERROR: Template not found at $t" >&2; exit 1; }
  local target="$REPO_ROOT/constitution.md"
  local ws; ws="$(basename "$REPO_ROOT")"
  local d; d="$(date +%Y-%m-%d)"
  sed -e "s/RATIFICATION_DATE/$d/g" -e "s/\[WORKSPACE\]/$ws/g" -e "s/\[PURPOSE\]/$ws/g" "$t" > "$target"
  CONSTITUTION_FILE="$target"
  echo "Constitution created at $target"
  echo "Version: 1.0 | Articles: 9 | Ratified: $d"
}

cmd_check() {
  ensure_constitution
  local filter="${1:-}"; local count; count=$(get_article_count); local all_pass=true

  if [[ "$COMPACT" == "0" ]]; then
    echo "=== Constitution Check ==="
    echo "File: $CONSTITUTION_FILE"
    echo ""
  fi
  for num in $(seq 1 "$count"); do
    local name; name=$(get_article_list | sed -n "${num}p" 2>/dev/null | sed 's/^## Article [IVXLCDM]*: //' || echo "Article $num")
    local sev; sev=$(get_article_severity "$num")
    [[ -n "$filter" ]] && { echo "$name" | grep -qi "$filter" || continue; }
    say "  Article $num: $name"
    say "  Severity: $sev"
    local result=""
    case "$num" in
      1) local a; a=$(g_research_note); local b; b=$(g_files_read)
         say "    Research note  -> $a"; say "    Files read     -> $b"
         [[ "$a" == "FAIL" || "$b" == "FAIL" ]] && result="FAIL" || result="PASS" ;;
      2) local a; a=$(g_verification); say "    Verification   -> $a"; result="$a" ;;
      3) say "    Checkpoints    -> INFO (checked at commit)"; result="INFO" ;;
      4) local a; a=$(g_challenge); say "    CATFISH        -> $a"; result="$a" ;;
      5) local a; a=$(g_comprehension); say "    Comprehension  -> $a"; result="$a" ;;
      6) local a; a=$(g_simplicity); say "    Simplicity     -> $a"; result="$a" ;;
      7) local a; a=$(g_errors); say "    Error tracking -> $a"
         [[ "$a" == "ESCALATE" ]] && result="FAIL" || result="PASS" ;;
      8) say "    Phase order    -> INFO (checked at transitions)"; result="INFO" ;;
      9) say "    Expectation    -> INFO (self-enforced)"; result="INFO" ;;
      *) result="SKIP" ;;
    esac
    if [[ "$result" == "FAIL" && "$sev" == "BLOCKING" ]]; then
      echo -e "  -> ${RED}BLOCKING${NC}"; all_pass=false
    elif [[ "$result" == "FAIL" ]]; then
      echo -e "  -> ${YELLOW}ADVISORY${NC}"
    elif [[ "$result" == "PASS" ]]; then
      say "  -> ${GREEN}PASS${NC}"
    else
      say "  -> $result"
    fi
    say ""
  done
  if [[ "$COMPACT" == "1" ]]; then
    if $all_pass; then echo "✓ Constitution check PASSED"; else echo "✗ Constitution check FAILED"; fi
  else
    [[ "$all_pass" == true ]] && echo -e "${GREEN}Check PASSED${NC}" || echo -e "${RED}Check FAILED${NC}"
  fi
  if $all_pass; then return 0; else return 1; fi
}

cmd_amend() {
  ensure_constitution
  echo "=== Amendment ==="; local a; local c; local r; local auth
  read -r -p "Article: " a; read -r -p "Change: " c; read -r -p "Rationale: " r; read -r -p "Author: " auth
  local d; d="$(date +%Y-%m-%d)"
  local ln; ln=$(grep -n '^| # | Date |' "$CONSTITUTION_FILE" | head -1 | cut -d: -f1)
  [[ -z "$ln" ]] && { echo "ERROR: Amendments table not found" >&2; exit 1; }
  ln=$((ln + 2))
  local cnt; cnt=$(grep -c '^| [0-9]' "$CONSTITUTION_FILE" 2>/dev/null || echo 0)
  cnt=$((cnt + 1))
  sed -i "${ln}i| $cnt | $d | $a | $c | $r | $auth |" "$CONSTITUTION_FILE"
  echo "Amendment #$cnt recorded"
  local v; v=$(grep '^version: ' "$CONSTITUTION_FILE" | sed 's/version: "\(.*\)"/\1/')
  local major="${v%%.*}"; local minor="${v#*.}"; minor=$((minor + 1))
  sed -i "s/version: \"$v\"/version: \"${major}.${minor}\"/" "$CONSTITUTION_FILE"
  echo "Version: ${major}.${minor}"
}

cmd_gate() {
  [[ $# -lt 2 ]] && { echo "ERROR: gate needs <from> <to>" >&2; exit 2; }
  local from="$1"; local to="$2"; ensure_constitution
  local pass=true; local results=""
  [[ "$COMPACT" == "0" ]] && echo "=== Gate: $from -> $to ===" && echo ""
  case "${from}:${to}" in
    research:plan)
      g_research_note | grep -q FAIL && { results="$results BLOCKING Article I (Research note)"; pass=false; } || say "  PASS Article I: Research note"
      g_files_read | grep -q FAIL && { results="$results BLOCKING Article I (Files read)"; pass=false; } || say "  PASS Article I: Files read"
      g_artifacts research plan | grep -q FAIL && { results="$results BLOCKING Article VIII (Artifacts)"; pass=false; } || say "  PASS Article VIII: Artifacts"
      ;;
    plan:implement)
      g_verification | grep -q FAIL && results="$results ADVISORY Article II (Verification)" || say "  PASS Article II: Verification"
      g_challenge | grep -q FAIL && { results="$results BLOCKING Article IV (CATFISH)"; pass=false; } || say "  PASS Article IV: CATFISH"
      g_comprehension | grep -q FAIL && { results="$results BLOCKING Article V (Comprehension)"; pass=false; } || say "  PASS Article V: Comprehension"
      g_simplicity | grep -q FAIL && results="$results ADVISORY Article VI (Simplicity)" || say "  PASS Article VI: Simplicity"
      g_artifacts plan implement | grep -q FAIL && { results="$results BLOCKING Article VIII (Artifacts)"; pass=false; } || say "  PASS Article VIII: Artifacts"
      ;;
    implement:review)
      local e; e=$(g_errors)
      echo "$e" | grep -q ESCALATE && { results="$results BLOCKING Article VII (Errors)"; pass=false; } || say "  PASS Article VII: Errors"
      ;;
    *) say "  No specific gates for this transition" ;;
  esac
  if [[ "$COMPACT" == "1" ]]; then
    if $pass; then echo "✓ Gate $from -> $to PASSED"; else echo "✗ Gate $from -> $to BLOCKED:${results}"; fi
  else
    echo ""; [[ "$pass" == true ]] && echo -e "${GREEN}Gate PASSED${NC}" || echo -e "${RED}Gate BLOCKED${NC}"
  fi
  if $pass; then return 0; else return 1; fi
}

cmd_list() {
  ensure_constitution; local c; c=$(get_article_count); local v; v=$(grep '^version: ' "$CONSTITUTION_FILE" | sed 's/version: "\(.*\)"/\1/' || echo "?")
  echo "=== Constitution Articles ==="; echo ""
  local i=1
  while IFS= read -r article; do
    local s; s=$(get_article_severity "$i")
    local tag; [[ "$s" == "BLOCKING" ]] && tag="BLOCK" || tag="ADVIS"
    echo "  Article $i: $(echo "$article" | sed 's/^## Article [IVXLCDM]*: //')  [$tag]"
    i=$((i + 1))
  done < <(get_article_list)
  echo ""; echo "  $c articles | Version $v"
}

cmd_status() {
  ensure_constitution
  local c; c=$(get_article_count); local v; v=$(grep '^version: ' "$CONSTITUTION_FILE" | sed 's/version: "\(.*\)"/\1/' || echo "?")
  local ac; ac=$(grep -c '^| [0-9]' "$CONSTITUTION_FILE" 2>/dev/null || echo 0)
  local t="$TEMPLATE_DIR/constitution-template.md"
  local tpl_status="current"
  [[ -f "$t" && "$CONSTITUTION_FILE" -ot "$t" ]] && tpl_status="OUTDATED"

  local pass=0; local fail=0
  for n in $(seq 1 "$c"); do
    case "$n" in
      1) [[ "$(g_research_note)" != "FAIL" || "$(g_files_read)" != "FAIL" ]] && pass=$((pass+1)) || fail=$((fail+1)) ;;
      2) [[ "$(g_verification)" != "FAIL" ]] && pass=$((pass+1)) || fail=$((fail+1)) ;;
      4) [[ "$(g_challenge)" != "FAIL" ]] && pass=$((pass+1)) || fail=$((fail+1)) ;;
      5) [[ "$(g_comprehension)" != "FAIL" ]] && pass=$((pass+1)) || fail=$((fail+1)) ;;
    esac
  done

  if [[ "$COMPACT" == "1" ]]; then
    if [[ "$fail" -gt 0 ]]; then
      echo "! Constitution: v$v | $c articles | $ac amendments | Template: $tpl_status | $pass passing, $fail failing"
    else
      echo "✓ Constitution: v$v | $c articles | $ac amendments | Template: $tpl_status | COMPLIANT"
    fi
  else
    echo "=== Health ==="; echo "  File: $CONSTITUTION_FILE"; echo "  Version $v | Articles $c | Amendments $ac"
    [[ -f "$t" && "$CONSTITUTION_FILE" -ot "$t" ]] && echo -e "  Template: ${YELLOW}OUTDATED${NC}" || echo "  Template: current"
    echo ""; echo "  Passing: $pass  Failing: $fail"
    [[ "$fail" -gt 0 ]] && echo -e "  Status: ${YELLOW}ATTENTION${NC} --- run 'check'" || echo -e "  Status: ${GREEN}COMPLIANT${NC}"
  fi
}

cmd_path() { ensure_constitution; echo "$CONSTITUTION_FILE"; }

# ─── Main ────────────────────────────────────────────────────────────────
[[ $# -eq 0 ]] && { usage >&2; exit 2; }
CMD="$1"; shift
case "$CMD" in
  init|check|amend|gate|list|status|path) "cmd_$CMD" "$@" ;;
  --help|-h) usage ;;
  *) echo "Unknown: $CMD" >&2; usage >&2; exit 2 ;;
esac
