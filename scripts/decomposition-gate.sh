#!/usr/bin/env bash
# =============================================================================
# decomposition-gate.sh — Milestone ladder generation and validation
#
# Ensures that every implementation task has a documented decomposition into
# a milestone ladder before code is written. The milestone ladder artifact
# serves as the programmatic proof that decomposition happened.
#
# This implements the key finding from decomposition enforcement research:
# programmatic gates > prompt-based enforcement for compliance-critical paths.
#
# Usage:
#   bash scripts/decomposition-gate.sh init     "task description" [options]
#   bash scripts/decomposition-gate.sh validate [milestone-ladder.json]
#   bash scripts/decomposition-gate.sh show     [milestone-ladder.json]
#
# Options for init:
#   --max-milestones <N>   Maximum milestones (default: 5)
#   --min-milestones <N>   Minimum milestones (default: 2)
#   --output <path>        Output path (default: .runtime/milestone-ladder.json)
#   --force                Overwrite existing artifact
#
# Exit codes (validate mode, for phase-gate.sh integration):
#   0 = PASS  — decomposition is complete and valid
#   1 = FAIL  — decomposition missing or invalid
#   2 = WARN  — decomposition exists but has minor issues
#   3 = SKIP  — no artifact to check (first-time init needed)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DEFAULT_OUTPUT="$RUNTIME_DIR/milestone-ladder.json"

# ── Defaults ──
MAX_MILESTONES=5
MIN_MILESTONES=2
OUTPUT_PATH="$DEFAULT_OUTPUT"
FORCE=false

# ── Colors ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
  cat <<'USAGE'
Usage: bash scripts/decomposition-gate.sh <command> [args]

Commands:
  init "task description"   Create a new milestone ladder artifact
  validate [file]           Validate an existing milestone ladder
  show [file]               Display the milestone ladder

Options for init:
  --max-milestones <N>      Max milestones (default: 5)
  --min-milestones <N>      Min milestones (default: 2)
  --output <path>           Output path (default: .runtime/milestone-ladder.json)
  --force                   Overwrite existing

Exit codes (validate mode):
  0 = PASS   — decomposition complete
  1 = FAIL   — missing or invalid
  2 = WARN   — exists with minor issues
  3 = SKIP   — no artifact found
USAGE
}

# ── Commands ──

cmd_init() {
  local task_desc="$1"
  shift

  # Parse init-specific options
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --max-milestones)
      MAX_MILESTONES="$2"
      shift 2
      ;;
    --min-milestones)
      MIN_MILESTONES="$2"
      shift 2
      ;;
    --output)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 2
      ;;
    esac
  done

  mkdir -p "$(dirname "$OUTPUT_PATH")"

  if [[ -f "$OUTPUT_PATH" && "$FORCE" != true ]]; then
    echo "  EXISTS: $(basename "$OUTPUT_PATH") already exists."
    echo "  Use --force to overwrite, or run: bash scripts/decomposition-gate.sh validate"
    exit 0
  fi

  echo ""
  echo -e "${BOLD}═══ Decomposition: Milestone Ladder${NC}"
  echo -e "  Task: ${task_desc:0:120}"
  echo ""

  # Generate the milestone ladder template
  cat >"$OUTPUT_PATH" <<JSONEOF
{
  "task": "$(echo "$task_desc" | sed 's/"/\\"/g')",
  "generated_at": $(date +%s),
  "milestones": [
    {
      "id": 1,
      "name": "Research and discovery",
      "deliverable": "Understand the system, identify files, map dependencies",
      "acceptance_criteria": "Relevant source files identified, dependency graph mapped, risks documented"
    },
    {
      "id": 2,
      "name": "Plan and design",
      "deliverable": "Detailed implementation approach with scope boundaries",
      "acceptance_criteria": "Design decisions made, interfaces defined, out-of-scope documented"
    },
    {
      "id": 3,
      "name": "Core implementation (first slice)",
      "deliverable": "Working implementation of the core change",
      "acceptance_criteria": "Implementation passes verification, tests pass"
    }
  ],
  "first_slice": {
    "target": "First milestone deliverable",
    "scope": "What this slice covers",
    "files": [],
    "verification": "How to verify this slice works"
  },
  "out_of_scope": [
    "Items explicitly excluded from this task"
  ],
  "verification_target": "Overall acceptance criteria for the complete task"
}
JSONEOF

  echo -e "  ${GREEN}✓ Created: ${OUTPUT_PATH}${NC}"
  echo ""
  echo "  Edit the artifact to match your task:"
  echo "    1. Set the milestone ladder (${MIN_MILESTONES}-${MAX_MILESTONES} milestones)"
  echo "    2. Fill in first_slice target, scope, files, verification"
  echo "    3. List out_of_scope items"
  echo "    4. Define verification_target"
  echo ""
  echo "  Then validate: bash scripts/decomposition-gate.sh validate"
}

cmd_validate() {
  local target_file="${1:-$DEFAULT_OUTPUT}"

  if [[ ! -f "$target_file" ]]; then
    echo -e "  ${YELLOW}SKIP   No milestone ladder found at: ${target_file}${NC}"
    echo ""
    echo "  Run: bash scripts/decomposition-gate.sh init \"task description\""
    exit 3
  fi

  echo "  Artifact: $(basename "$target_file")"
  echo ""

  # Parse and validate
  local errors=0
  local warnings=0

  # Check valid JSON
  if ! python3 -c "import json; json.load(open('$target_file'))" 2>/dev/null; then
    echo -e "  ${RED}✗ FAIL  Invalid JSON in ${target_file}${NC}"
    exit 1
  fi

  # Check milestones array
  local milestone_count
  milestone_count=$(python3 -c "
import json
d = json.load(open('$target_file'))
ms = d.get('milestones', [])
print(len(ms))
" 2>/dev/null || echo 0)

  if [[ "$milestone_count" -lt "$MIN_MILESTONES" ]]; then
    echo -e "  ${RED}✗ FAIL  Too few milestones: ${milestone_count} (min ${MIN_MILESTONES})${NC}"
    errors=$((errors + 1))
  elif [[ "$milestone_count" -gt "$MAX_MILESTONES" ]]; then
    echo -e "  ${YELLOW}⚠ WARN  Too many milestones: ${milestone_count} (max ${MAX_MILESTONES})${NC}"
    warnings=$((warnings + 1))
  else
    echo -e "  ${GREEN}✓ PASS  ${milestone_count} milestones${NC}"
  fi

  # Check each milestone has required fields
  local bad_milestones
  bad_milestones=$(python3 -c "
import json, sys
d = json.load(open('$target_file'))
ms = d.get('milestones', [])
bad = 0
for m in ms:
    if not all(k in m and m[k] for k in ['id', 'name', 'deliverable', 'acceptance_criteria']):
        bad += 1
print(bad)
" 2>/dev/null || echo 0)

  if [[ "$bad_milestones" -gt 0 ]]; then
    echo -e "  ${RED}✗ FAIL  ${bad_milestones} milestone(s) missing required fields (id, name, deliverable, acceptance_criteria)${NC}"
    errors=$((errors + 1))
  fi

  # Check first_slice
  local has_first_slice
  has_first_slice=$(python3 -c "
import json
d = json.load(open('$target_file'))
fs = d.get('first_slice', {})
if all(k in fs and fs[k] for k in ['target', 'scope', 'verification']):
    print('yes')
else:
    print('no')
" 2>/dev/null || echo no)

  if [[ "$has_first_slice" != "yes" ]]; then
    echo -e "  ${RED}✗ FAIL  first_slice missing required fields (target, scope, verification)${NC}"
    errors=$((errors + 1))
  else
    echo -e "  ${GREEN}✓ PASS  first_slice defined${NC}"
  fi

  # Check out_of_scope
  local has_oos
  has_oos=$(python3 -c "
import json
d = json.load(open('$target_file'))
oos = d.get('out_of_scope', [])
print('yes' if len(oos) > 0 else 'no')
" 2>/dev/null || echo no)

  if [[ "$has_oos" != "yes" ]]; then
    echo -e "  ${YELLOW}⚠ WARN  out_of_scope is empty — add items explicitly excluded${NC}"
    warnings=$((warnings + 1))
  else
    echo -e "  ${GREEN}✓ PASS  out_of_scope defined${NC}"
  fi

  # Check verification_target
  local has_vt
  has_vt=$(python3 -c "
import json
d = json.load(open('$target_file'))
vt = d.get('verification_target', '')
print('yes' if vt and len(vt) > 10 else 'no')
" 2>/dev/null || echo no)

  if [[ "$has_vt" != "yes" ]]; then
    echo -e "  ${YELLOW}⚠ WARN  verification_target is missing or too short${NC}"
    warnings=$((warnings + 1))
  else
    echo -e "  ${GREEN}✓ PASS  verification_target defined${NC}"
  fi

  echo ""
  if [[ "$errors" -gt 0 ]]; then
    echo -e "  ${RED}✗ FAIL  ${errors} error(s), ${warnings} warning(s)${NC}"
    exit 1
  elif [[ "$warnings" -gt 0 ]]; then
    echo -e "  ${YELLOW}⚠ WARN  ${warnings} warning(s)${NC}"
    exit 2
  else
    echo -e "  ${GREEN}✓ PASS  decomposition valid${NC}"
    exit 0
  fi
}

cmd_show() {
  local target_file="${1:-$DEFAULT_OUTPUT}"

  if [[ ! -f "$target_file" ]]; then
    echo "No milestone ladder found at: $target_file"
    echo "Run: bash scripts/decomposition-gate.sh init \"task description\""
    exit 1
  fi

  echo ""
  echo -e "${BOLD}═══ Milestone Ladder${NC}"
  echo ""

  python3 -c "
import json, sys
d = json.load(open('$target_file'))
print(f\"  Task: {d.get('task', 'N/A')}\\n\")
ms = d.get('milestones', [])
for m in ms:
    print(f\"  [{m.get('id', '?')}] {m.get('name', 'Unnamed')}\")
    print(f\"       Deliverable: {m.get('deliverable', 'N/A')}\")
    print(f\"       Accept:      {m.get('acceptance_criteria', 'N/A')}\")
    print()
fs = d.get('first_slice', {})
print(f\"  First slice: {fs.get('target', 'N/A')}\")
print(f\"    Scope:  {fs.get('scope', 'N/A')}\")
print(f\"    Verify: {fs.get('verification', 'N/A')}\")
files = fs.get('files', [])
if files:
    print(f\"    Files: {', '.join(files)}\")
print()
oos = d.get('out_of_scope', [])
print(f\"  Out of scope: {', '.join(oos) if oos else '(none)'}\")
print(f\"  Verification target: {d.get('verification_target', 'N/A')}\")
"

  echo ""
  echo "  Validate: bash scripts/decomposition-gate.sh validate"
}

# ── Main ──

main() {
  local cmd="${1:-}"
  shift || true

  mkdir -p "$RUNTIME_DIR"

  case "$cmd" in
  init)
    local task_desc="$*"
    if [[ -z "$task_desc" ]]; then
      echo "Usage: bash scripts/decomposition-gate.sh init \"task description\""
      exit 2
    fi
    cmd_init "$task_desc"
    ;;
  validate)
    cmd_validate "${1:-}"
    ;;
  show)
    cmd_show "${1:-}"
    ;;
  *)
    usage
    exit 2
    ;;
  esac
}

main "$@"
