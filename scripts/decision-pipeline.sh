#!/usr/bin/env bash
# =============================================================================
# decision-pipeline.sh --- Composable decision chain for phase transitions
#
# Runs the full decision chain for a phase transition in sequence, with
# short-circuit on failure. Mirrors 9Router's combo fallback pattern:
# each decision stage runs in order; if any fails, the pipeline stops
# and reports which stage blocked.
#
# Usage:
#   bash scripts/decision-pipeline.sh <transition> [task-description]
#
# Transitions:
#   research->plan      Model selection -> research sufficiency -> scope check
#   plan->implement     Model selection -> plan gates -> implement gates
#   implement->verify   Quality-speed assessment
#   list               Show all defined pipelines
#
# Each step runs a gate plugin or decision script. Steps pass the task
# description as argument where relevant. Exit codes:
#   0 = all steps pass
#   1 = any step fails (short-circuit)
#   2 = any step warns (continues)
#
# All steps are logged as a unified decision packet via decision.sh.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DECISION_LOG="$RUNTIME_DIR/decision-log.jsonl"
STATE_FILE="$REPO_ROOT/session-state.json"

# ── Pipeline Definitions ──────────────────────────────────────────────────────
# Each step: "description|script_path|args_template"
# __TASK__ in args_template is replaced with the actual task description.
#
# Script paths can be:
#   - Relative to REPO_ROOT (e.g., scripts/model-select.sh)
#   - Gate plugins (scripts/gates/<phase>/<name>.sh)
#   - "decision.log" for direct decision.sh log calls

declare -A PIPELINES

# research -> plan
PIPELINES["research->plan"]='research->plan|pipeline prereq check
model_select|scripts/model-select.sh|classify __TASK__
research_sufficiency|scripts/gates/research/sufficiency.sh|__TASK__
scope_check|scripts/gates/plan/scope-check.sh|plan->implement
populate_state|scripts/session-state-populate.sh|--phase=research'

# plan -> implement  (full decision chain)
PIPELINES["plan->implement"]='plan->implement|pipeline prereq check
model_select|scripts/model-select.sh|classify __TASK__
catfish|scripts/gates/plan/catfish.sh|__TASK__
scope_check|scripts/gates/plan/scope-check.sh|plan->implement
comprehension|scripts/gates/implement/comprehension.sh|__TASK__
decisions_check|scripts/gates/implement/decisions.sh|__TASK__
autonomy|scripts/gates/implement/autonomy.sh|__TASK__
preflight|scripts/gates/implement/preflight.sh|__TASK__
populate_state|scripts/session-state-populate.sh|--phase=plan'

# implement -> verify
PIPELINES["implement->verify"]='implement->verify|pipeline prereq check
quality_speed|scripts/gates/verify/quality-speed.sh|__TASK__
populate_state|scripts/session-state-populate.sh|--phase=implement'

# ── Colors ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ──

usage() {
  cat <<'USAGE'
Usage: bash scripts/decision-pipeline.sh <transition> [task-description]

Transitions:
  research->plan      Model selection -> research sufficiency -> scope check
  plan->implement     Model selection -> plan gates -> implement gates
  implement->verify   Quality-speed assessment
  list               Show all defined pipelines

Options:
  --help, -h         Show this help

Each step runs a gate plugin or decision script in sequence.
If any step fails (exit 1), the pipeline stops immediately.
If any step warns (exit 2), the pipeline continues with a warning.

A unified decision packet is logged to decision-log.jsonl.
USAGE
}

gen_id() {
  local ts
  ts=$(date +%s)
  local hash
  hash=$(echo "$ts$RANDOM" | md5sum 2>/dev/null | head -c 6 || echo "$RANDOM")
  echo "pipe-$(date +%H%M)-$hash"
}

log_decision_packet() {
  local transition="$1" task="$2" status="$3" packet_file="$4"
  local packet
  packet=$(cat "$packet_file" 2>/dev/null || echo "{}")

  local entry
  entry=$(python3 -c "
import json, sys
packet = json.loads('''$packet''')
entry = {
    'type': 'decision_pipeline',
    'transition': '$transition',
    'task': '''$task''',
    'status': '$status',
    'timestamp': $(date +%s),
    'steps': packet.get('steps', []),
    'overall': packet.get('overall', {}),
    'id': '$(gen_id)'
}
print(json.dumps(entry))
" 2>/dev/null || echo "{}")

  if [[ "$entry" != "{}" ]]; then
    mkdir -p "$RUNTIME_DIR"
    echo "$entry" >>"$DECISION_LOG"
    echo ""
    echo "  Decision packet logged: $(echo "$entry" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['id'])" 2>/dev/null || echo "unknown")"
  fi
}

# ── Main ──

main() {
  local transition="${1:-}"
  local task="${2:-}"

  if [[ "$transition" == "--help" ]] || [[ "$transition" == "-h" ]] || [[ -z "$transition" ]]; then
    usage
    exit 0
  fi

  if [[ "$transition" == "list" ]]; then
    echo "Defined pipelines:"
    for key in "${!PIPELINES[@]}"; do
      local desc
      desc=$(echo "${PIPELINES[$key]}" | head -1 | cut -d'|' -f1)
      echo "  $key  --- $desc"
    done
    exit 0
  fi

  if [[ ! -v "PIPELINES[$transition]" ]]; then
    echo "ERROR: Unknown transition '$transition'" >&2
    echo "Use 'list' to see defined pipelines." >&2
    exit 2
  fi

  local pipeline_def="${PIPELINES[$transition]}"
  local pipeline_desc
  pipeline_desc=$(echo "$pipeline_def" | head -1 | cut -d'|' -f1)

  # Auto-detect task from session state if not provided
  if [[ -z "$task" ]]; then
    if [[ -f "$STATE_FILE" ]]; then
      task=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
print(s.get('currentTask', {}).get('name', ''))
" 2>/dev/null || true)
    fi
  fi

  echo ""
  echo -e "${BOLD}═══ Decision Pipeline: $transition${NC}"
  echo -e "${BOLD}    Task: ${task:-"(no task)"}${NC}"
  echo ""

  local packet_file
  packet_file=$(mktemp /tmp/decision-packet-XXXXXX.json)
  # Initialize packet structure
  echo '{"steps":[],"overall":{"passed":0,"warned":0,"failed":0,"skipped":0,"blocked_by":null}}' >"$packet_file"

  local overall_status="pass"
  local blocked_by=""
  local step_index=0

  # Parse pipeline definition (skip the first line which is the description)
  while IFS='|' read -r step_name step_script step_args; do
    [[ -z "$step_name" ]] && continue
    # Skip the first line (pipeline description)
    [[ "$step_name" == *"->"* ]] && continue

    step_index=$((step_index + 1))

    # Replace __TASK__ placeholder with actual task
    local resolved_args="${step_args//__TASK__/$task}"

    # Resolve script path
    local script_path
    if [[ "$step_script" = /* ]]; then
      script_path="$step_script"
    else
      script_path="$REPO_ROOT/$step_script"
    fi

    echo -e "  ${CYAN}[$step_index]${NC} ${BOLD}$step_name${NC}"
    echo "       ${script_path} ${resolved_args}"
    echo ""

    mkdir -p "$RUNTIME_DIR"

    # Run the step
    set +e
    output=$(bash "$script_path" $resolved_args 2>&1)
    rc=$?
    set -e

    # Truncate output for display (keep last 3 lines)
    echo "$output" | tail -5 | sed 's/^/    /'

    local step_status
    case $rc in
    0)
      step_status="pass"
      overall_status="pass"
      echo -e "    ${GREEN}✓ PASS${NC}"
      ;;
    1)
      step_status="fail"
      overall_status="fail"
      [[ -z "$blocked_by" ]] && blocked_by="$step_name"
      echo -e "    ${RED}✗ FAIL${NC}"
      ;;
    2)
      step_status="warn"
      [[ "$overall_status" != "fail" ]] && overall_status="warn"
      echo -e "    ${YELLOW}⚠ WARN${NC}"
      ;;
    3)
      step_status="skip"
      echo "    -- SKIP"
      ;;
    *)
      step_status="error"
      [[ "$overall_status" != "fail" ]] && overall_status="fail"
      [[ -z "$blocked_by" ]] && blocked_by="$step_name"
      echo -e "    ${RED}? ERROR (exit $rc)${NC}"
      ;;
    esac

    echo ""

    # Append step result to packet
    python3 -c "
import json
with open('$packet_file') as f:
    p = json.load(f)
p['steps'].append({
    'order': $step_index,
    'name': '$step_name',
    'script': '$step_script',
    'status': '$step_status',
    'exit_code': $rc
})
o = p['overall']
if '$step_status' == 'pass': o['passed'] += 1
elif '$step_status' == 'fail': o['failed'] += 1
elif '$step_status' == 'warn': o['warned'] += 1
elif '$step_status' == 'skip': o['skipped'] += 1
o['blocked_by'] = '$blocked_by' if '$blocked_by' else None
with open('$packet_file', 'w') as f:
    json.dump(p, f, indent=2)
" 2>/dev/null || true

    # Short-circuit on failure
    if [[ "$rc" -eq 1 ]]; then
      echo -e "  ${RED}═══ Pipeline blocked at step $step_index ($step_name)${NC}"
      echo "       Resolve the issue above, then re-run the pipeline."
      log_decision_packet "$transition" "$task" "blocked" "$packet_file"
      rm -f "$packet_file"
      exit 1
    fi
  done <<<"$pipeline_def"

  # All steps completed
  echo -e "  ${GREEN}═══ Pipeline complete: $transition ($overall_status)${NC}"
  echo ""

  # Summary
  local passed warned failed skipped
  passed=$(python3 -c "import json; p=json.load(open('$packet_file')); print(p['overall']['passed'])" 2>/dev/null || echo 0)
  warned=$(python3 -c "import json; p=json.load(open('$packet_file')); print(p['overall']['warned'])" 2>/dev/null || echo 0)
  failed=$(python3 -c "import json; p=json.load(open('$packet_file')); print(p['overall']['failed'])" 2>/dev/null || echo 0)
  skipped=$(python3 -c "import json; p=json.load(open('$packet_file')); print(p['overall']['skipped'])" 2>/dev/null || echo 0)

  echo "  Steps: $step_index total"
  echo "    ✓ Pass:  $passed"
  echo "    ⚠ Warn:  $warned"
  echo "    ✗ Fail:  $failed"
  echo "    -- Skip:  $skipped"

  log_decision_packet "$transition" "$task" "$overall_status" "$packet_file"
  rm -f "$packet_file"

  case "$overall_status" in
  fail) exit 1 ;;
  warn) exit 2 ;;
  *) exit 0 ;;
  esac
}

main "$@"
