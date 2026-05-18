#!/usr/bin/env bash
# =============================================================================
# workflow-check.sh — Deterministic verification of workflow-state.json
#
# Validates the workflow state file for structural integrity, internal
# consistency, and trace correctness. Designed as a deterministic tool —
# the same state always produces the same result.
#
# This implements the "workflow self-check" pattern: a tool that the
# agent or user can run to verify the workflow state is not corrupted,
# stale, or inconsistent.
#
# Usage:
#   bash scripts/workflow-check.sh [--json] [--fix]
#
# Options:
#   --json     Output machine-readable JSON report
#   --fix      Auto-fix recoverable issues
#
# Exit codes:
#   0 = PASS   — workflow state is valid and consistent
#   1 = FAIL   — workflow state has errors (corrupt, missing, or inconsistent)
#   2 = WARN   — workflow state has warnings (stale, unusual, but not broken)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$REPO_ROOT/workflow-state.json"
WORKFLOW_DIR="$REPO_ROOT/workflow.d"

# ── Options ──
OUTPUT_JSON=false
AUTO_FIX=false

# ── Colors ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
  cat <<'USAGE'
Usage: bash scripts/workflow-check.sh [options]

Validate workflow-state.json for structural integrity and consistency.

Options:
  --json     Output machine-readable JSON report
  --fix      Auto-fix recoverable issues (reset state if corrupted)
  --help     Show this help

Exit codes:
  0 = PASS   — state is valid and consistent
  1 = FAIL   — state has errors
  2 = WARN   — state has warnings
USAGE
}

# ── Parsing ──

while [[ $# -gt 0 ]]; do
  case "$1" in
  --json)
    OUTPUT_JSON=true
    shift
    ;;
  --fix)
    AUTO_FIX=true
    shift
    ;;
  --help | -h)
    usage
    exit 0
    ;;
  *)
    echo "Unknown: $1"
    usage
    exit 2
    ;;
  esac
done

# ── Collect results ──

ERRORS=()
WARNINGS=()
INFO=()

pass() { INFO+=("$1"); }
warn() { WARNINGS+=("$1"); }
fail() { ERRORS+=("$1"); }

# ── Checks ──

check_state_file() {
  if [[ ! -f "$STATE_FILE" ]]; then
    fail "workflow-state.json not found at $STATE_FILE"
    return 1
  fi
  pass "State file exists: $STATE_FILE"
}

check_json() {
  if ! python3 -c "import json; json.load(open('$STATE_FILE'))" 2>/dev/null; then
    fail "workflow-state.json is not valid JSON"
    return 1
  fi
  pass "State file is valid JSON"
}

check_top_level_keys() {
  local data
  data=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
required = ['workflow', 'step', 'context', 'trace']
for k in required:
    if k not in d:
        print(f'missing:{k}')
for k in d:
    if k not in required:
        print(f'extra:{k}')
" 2>/dev/null)

  local has_error=false
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" == missing:* ]]; then
      fail "Missing required key: ${line#missing:}"
      has_error=true
    elif [[ "$line" == extra:* ]]; then
      warn "Unexpected key in state: ${line#extra:}"
    fi
  done <<<"$data"

  if [[ "$has_error" == false ]]; then
    pass "All required top-level keys present (workflow, step, context, trace)"
  fi
}

check_workflow_id() {
  local workflow_id
  workflow_id=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
w = d.get('workflow')
print(w if w else 'null')
" 2>/dev/null)

  if [[ "$workflow_id" == "null" ]]; then
    pass "No active workflow (expected at session start)"
    return 0
  fi

  # Validate workflow definition exists
  local wf_file="$WORKFLOW_DIR/${workflow_id}.yaml"
  if [[ ! -f "$wf_file" ]]; then
    # Try workflow/<id>.yaml (some are nested)
    wf_file="$WORKFLOW_DIR/workflow/${workflow_id}.yaml"
    if [[ ! -f "$wf_file" ]]; then
      # Try wildcard: any file with matching id in YAML frontmatter
      local found=false
      for f in "$WORKFLOW_DIR"/*.yaml; do
        if rtk grep -q "^id: ${workflow_id}$" "$f" 2>/dev/null; then
          wf_file="$f"
          found=true
          break
        fi
      done
      if [[ "$found" == false ]]; then
        fail "Active workflow '${workflow_id}' has no definition file in workflow.d/"
        return 1
      fi
    fi
  fi
  pass "Workflow definition found: $(basename "$wf_file")"
}

check_current_step() {
  local workflow_id step_id
  workflow_id=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
print(d.get('workflow') or 'null')
" 2>/dev/null)

  step_id=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
print(d.get('step') or 'null')
" 2>/dev/null)

  if [[ "$workflow_id" == "null" && "$step_id" != "null" ]]; then
    warn "Step is set ('$step_id') but no workflow is active"
    return 0
  fi

  if [[ "$workflow_id" == "null" ]]; then
    return 0
  fi

  if [[ "$step_id" == "null" ]]; then
    warn "Workflow '$workflow_id' is active but no step is set"
    return 0
  fi

  # Find the workflow file
  local wf_file="$WORKFLOW_DIR/${workflow_id}.yaml"
  [[ ! -f "$wf_file" ]] && wf_file="$WORKFLOW_DIR/workflow/${workflow_id}.yaml"
  [[ ! -f "$wf_file" ]] && {
    for f in "$WORKFLOW_DIR"/*.yaml; do
      if rtk grep -q "^id: ${workflow_id}$" "$f" 2>/dev/null; then
        wf_file="$f"
        break
      fi
    done
  }

  if [[ ! -f "$wf_file" ]]; then
    return 0 # already reported by check_workflow_id
  fi

  # Check if step exists in workflow definition
  if ! rtk grep -q "id: ${step_id}$" "$wf_file" 2>/dev/null; then
    # Try with indentation (steps are listed under the steps key)
    if ! rtk grep -Pq "^\s+- id:\s+${step_id}$" "$wf_file" 2>/dev/null; then
      warn "Step '${step_id}' not found in workflow definition $(basename "$wf_file")"
    else
      pass "Step '${step_id}' exists in workflow '${workflow_id}'"
    fi
  else
    pass "Step '${step_id}' exists in workflow '${workflow_id}'"
  fi
}

check_trace() {
  local trace_count step_count
  trace_count=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
print(len(d.get('trace', [])))
" 2>/dev/null || echo 0)

  step_count=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
s = d.get('step')
print('1' if s else '0')
" 2>/dev/null || echo 0)

  if [[ "$trace_count" -gt 0 ]]; then
    pass "Trace has ${trace_count} entries"
  elif [[ "$step_count" -gt 0 ]]; then
    warn "Workflow active but trace is empty (no steps recorded yet)"
  fi

  # Check trace entries have required fields
  local bad_trace
  bad_trace=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
trace = d.get('trace', [])
bad = 0
for t in trace:
    if not isinstance(t, dict):
        bad += 1
        continue
    if 'step' not in t and 'action' not in t and 'result' not in t:
        if 'phase' not in t:
            bad += 1
print(bad)
" 2>/dev/null || echo 0)

  if [[ "$bad_trace" -gt 0 ]]; then
    warn "${bad_trace} trace entr(ies) missing expected fields (step/action/result)"
  fi
}

check_context() {
  local context_keys
  context_keys=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
ctx = d.get('context', {})
if not isinstance(ctx, dict):
    print('NOT_DICT')
else:
    keys = list(ctx.keys())
    if keys:
        print('keys:' + ','.join(keys))
    else:
        print('empty')
" 2>/dev/null)

  if [[ "$context_keys" == "NOT_DICT" ]]; then
    fail "context is not a dictionary"
  elif [[ "$context_keys" == "empty" ]]; then
    pass "Context is empty (fresh state)"
  else
    local count
    count=$(echo "$context_keys" | sed 's/keys://' | tr ',' '\n' | wc -l)
    pass "Context has ${count} key(s): $(echo "$context_keys" | sed 's/keys://')"
  fi
}

check_stale() {
  local modified_age
  if [[ -f "$STATE_FILE" ]]; then
    modified_age=$(($(date +%s) - $(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)))
    if [[ "$modified_age" -gt 86400 ]]; then
      warn "State file is stale (last modified ${modified_age}s ago — over 24h)"
    elif [[ "$modified_age" -gt 3600 ]]; then
      warn "State file is stale (last modified ${modified_age}s ago — over 1h)"
    else
      pass "State file is recent (${modified_age}s ago)"
    fi
  fi
}

# ── Main ──

echo ""
echo -e "${BOLD}═══ Workflow State Check${NC}"
echo -e "  File: ${STATE_FILE}"
echo ""

check_state_file
check_json
check_top_level_keys
check_workflow_id
check_current_step
check_trace
check_context
check_stale

# ── Auto-fix ──

if [[ "$AUTO_FIX" == true && "${#ERRORS[@]}" -gt 0 ]]; then
  echo ""
  echo -e "${YELLOW}═══ Auto-fix${NC}"
  # Reset state if file is missing, not valid JSON, or missing required keys
  needs_reset=false
  if [[ ! -f "$STATE_FILE" ]]; then
    needs_reset=true
  elif ! python3 -c "import json; json.load(open('$STATE_FILE'))" 2>/dev/null; then
    needs_reset=true
  else
    missing_keys=$(python3 -c "
import json
d = json.load(open('$STATE_FILE'))
required = ['workflow', 'step', 'context', 'trace']
missing = [k for k in required if k not in d]
print(','.join(missing))" 2>/dev/null)
    if [[ -n "$missing_keys" ]]; then
      needs_reset=true
    fi
  fi

  if [[ "$needs_reset" == true ]]; then
    echo '{"workflow":null,"step":null,"context":{},"trace":[]}' >"$STATE_FILE"
    echo -e "  ${GREEN}✓ Reset to clean state${NC}"
    ERRORS=()
    WARNINGS=()
    INFO=()
    # Re-run checks on new state
    check_top_level_keys
  fi
fi

# ── Report ──

echo ""
echo -e "  ${BOLD}Results:${NC}"
echo -e "    ${GREEN}✓ Pass:${NC} ${#INFO[@]}"
echo -e "    ${YELLOW}⚠ Warn:${NC} ${#WARNINGS[@]}"
echo -e "    ${RED}✗ Fail:${NC} ${#ERRORS[@]}"

if [[ "${#ERRORS[@]}" -gt 0 ]]; then
  echo ""
  echo -e "  ${BOLD}Errors:${NC}"
  for e in "${ERRORS[@]}"; do
    echo -e "    ${RED}✗${NC} $e"
  done
fi

if [[ "${#WARNINGS[@]}" -gt 0 ]]; then
  echo ""
  echo -e "  ${BOLD}Warnings:${NC}"
  for w in "${WARNINGS[@]}"; do
    echo -e "    ${YELLOW}⚠${NC} $w"
  done
fi

if [[ "${#INFO[@]}" -gt 0 ]]; then
  echo ""
  echo -e "  ${BOLD}Detail:${NC}"
  for i in "${INFO[@]}"; do
    echo -e "    ${GREEN}✓${NC} $i"
  done
fi

# If there were errors, offer guidance
if [[ "${#ERRORS[@]}" -gt 0 ]]; then
  echo ""
  echo -e "  ${BOLD}Next steps:${NC}"
  echo "    bash scripts/workflow-check.sh --fix    (auto-reset corrupted state)"
  echo "    Or manually edit workflow-state.json to {'workflow':null,'step':null,'context':{},'trace':[]}"
fi

echo ""

# ── JSON output ──

if [[ "$OUTPUT_JSON" == true ]]; then
  python3 -c "
import json
report = {
    'status': 'fail' if ${#ERRORS[@]} > 0 else ('warn' if ${#WARNINGS[@]} > 0 else 'pass'),
    'errors': ${#ERRORS[@]},
    'warnings': ${#WARNINGS[@]},
    'passed': ${#INFO[@]},
    'error_list': [$(for e in "${ERRORS[@]}"; do echo -n "\"${e//\"/\\\"}\","; done)],
    'warning_list': [$(for w in "${WARNINGS[@]}"; do echo -n "\"${w//\"/\\\"}\","; done)],
    'pass_list': [$(for i in "${INFO[@]}"; do echo -n "\"${i//\"/\\\"}\","; done)]
}
print(json.dumps(report, indent=2))
" 2>/dev/null || true
fi

# ── Exit code ──

if [[ "${#ERRORS[@]}" -gt 0 ]]; then
  exit 1
elif [[ "${#WARNINGS[@]}" -gt 0 ]]; then
  exit 2
else
  exit 0
fi
