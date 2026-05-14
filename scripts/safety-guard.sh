#!/bin/bash
# safety-guard.sh --- Blast radius, budget limits, and human escalation gates.
# Integrates with pipeline-run.sh state. Each pipeline gets a safety profile
# that constrains autonomous execution.
#
# Usage:
#   bash ./scripts/safety-guard.sh init <pipeline-id> [--allow <paths>] [--max-tasks <N>]
#   bash ./scripts/safety-guard.sh allow <pipeline-id> <path> [path...]
#   bash ./scripts/safety-guard.sh block <pipeline-id> <path> [path...]
#   bash ./scripts/safety-guard.sh gate <pipeline-id> --on <task-type>
#   bash ./scripts/safety-guard.sh check <pipeline-id> <task-id> [--file <path>]
#   bash ./scripts/safety-guard.sh budget <pipeline-id> --max-tasks <N> --max-loops <N>
#   bash ./scripts/safety-guard.sh show <pipeline-id>

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
PIPELINE_DIR="$REPO_ROOT/.runtime/pipeline"

CMD="${1:-help}"
PIPELINE_ID="${2:-}"

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
show_help() {
  echo "Safety Guard --- Blast radius, budget, and escalation controls"
  echo ""
  echo "Usage:"
  echo "  init   <id> [--allow <paths>] [--max-tasks N] [--max-loops N]    Init safety for pipeline"
  echo "  allow  <id> <path> [path...]                                       Add allowed paths"
  echo "  block  <id> <path> [path...]                                       Add blocked paths"
  echo "  gate   <id> --on <task-type>                                       Require human for task type"
  echo "  budget <id> --max-tasks N --max-loops N                            Set budget limits"
  echo "  check  <id> <task-id> [--file <path>]                              Check if action is safe"
  echo "  show   <id>                                                        Show safety profile"
  echo ""
  echo "Examples:"
  echo "  bash scripts/safety-guard.sh init pipe-001 --allow scripts/ --max-tasks 10"
  echo "  bash scripts/safety-guard.sh check pipe-001 1 --file README.md"
  echo "  bash scripts/safety-guard.sh gate pipe-001 --on delete"
}

# ---------------------------------------------------------------------------
# Check pipeline exists
# ---------------------------------------------------------------------------
require_pipeline() {
  if [ ! -f "$PIPELINE_DIR/$PIPELINE_ID.json" ]; then
    echo "Pipeline not found: $PIPELINE_ID"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------
case "$CMD" in
  init)
    shift 2
    [ -z "$PIPELINE_ID" ] && echo "Usage: safety-guard.sh init <pipeline-id>" && show_help && exit 1
    require_pipeline

    ALLOWED_PATHS=()
    MAX_TASKS=""
    MAX_LOOPS=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --allow)
          shift
          while [ $# -gt 0 ] && ! [[ "$1" =~ ^-- ]]; do
            ALLOWED_PATHS+=("$1")
            shift
          done
          ;;
        --max-tasks) MAX_TASKS="$2"; shift 2 ;;
        --max-loops) MAX_LOOPS="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    # Build allowed paths JSON array
    ALLOW_JSON="[]"
    if [ ${#ALLOWED_PATHS[@]} -gt 0 ]; then
      ALLOW_JSON=$(python3 -c "
import json
paths = ${ALLOWED_PATHS[@]@Q}
print(json.dumps([json.dumps(str(p)) for p in $ALLOW_JSON]))
" 2>/dev/null || echo "[]")
    fi

    # More robust approach
    # Build safe allowed paths JSON
    ALLOW_JSON="[]"
    if [ ${#ALLOWED_PATHS[@]} -gt 0 ]; then
      # Build a jq-compatible array literal
      ALLOW_JSON="["
      FIRST=true
      for p in "${ALLOWED_PATHS[@]}"; do
        if [ "$FIRST" = true ]; then FIRST=false; else ALLOW_JSON+=", "; fi
        ALLOW_JSON+="\"$p\""
      done
      ALLOW_JSON+="]"
    fi

    # Build jq filter
    JQ_FILTER=".safety = {"
    JQ_FILTER+="\"allowed_paths\": $ALLOW_JSON, "
    JQ_FILTER+="\"blocked_paths\": [], "
    JQ_FILTER+="\"max_tasks\": ${MAX_TASKS:-null}, "
    JQ_FILTER+="\"max_loops\": ${MAX_LOOPS:-null}, "
    JQ_FILTER+="\"human_gates\": [], "
    JQ_FILTER+="\"task_count\": (.tasks | length)"
    JQ_FILTER+="}"

    jq "$JQ_FILTER" "$PIPELINE_DIR/$PIPELINE_ID.json" > "$PIPELINE_DIR/$PIPELINE_ID.json.tmp" && \
      mv "$PIPELINE_DIR/$PIPELINE_ID.json.tmp" "$PIPELINE_DIR/$PIPELINE_ID.json"

    echo "Safety initialized for $PIPELINE_ID"
    echo "  Allowed paths: ${ALLOWED_PATHS[*]:-(none)}"
    echo "  Max tasks: ${MAX_TASKS:-unlimited}"
    echo "  Max loops: ${MAX_LOOPS:-unlimited}"
    ;;

  allow)
    shift 2
    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    require_pipeline

    for p in "$@"; do
      jq --arg path "$p" 'if .safety then .safety.allowed_paths |= (. + [$path] | unique) else .safety = {"allowed_paths": [$path], "blocked_paths": [], "max_tasks": null, "max_loops": null, "human_gates": []} end' \
        "$PIPELINE_DIR/$PIPELINE_ID.json" > "$PIPELINE_DIR/$PIPELINE_ID.json.tmp" && \
        mv "$PIPELINE_DIR/$PIPELINE_ID.json.tmp" "$PIPELINE_DIR/$PIPELINE_ID.json"
      echo "Allowed: $p"
    done
    ;;

  block)
    shift 2
    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    require_pipeline

    for p in "$@"; do
      jq --arg path "$p" 'if .safety then .safety.blocked_paths |= (. + [$path] | unique) else .safety = {"allowed_paths": [], "blocked_paths": [$path], "max_tasks": null, "max_loops": null, "human_gates": []} end' \
        "$PIPELINE_DIR/$PIPELINE_ID.json" > "$PIPELINE_DIR/$PIPELINE_ID.json.tmp" && \
        mv "$PIPELINE_DIR/$PIPELINE_ID.json.tmp" "$PIPELINE_DIR/$PIPELINE_ID.json"
      echo "Blocked: $p"
    done
    ;;

  gate)
    shift 2
    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    require_pipeline

    GATE_TYPE=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --on) GATE_TYPE="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    [ -z "$GATE_TYPE" ] && echo "Provide --on <task-type>" && exit 1

    python3 -c "
import json
with open('$PIPELINE_DIR/$PIPELINE_ID.json') as f:
    p = json.load(f)
if 'safety' not in p:
    p['safety'] = {'allowed_paths': [], 'blocked_paths': [], 'max_tasks': None, 'max_loops': None, 'human_gates': []}
gl = p['safety'].get('human_gates', [])
if '$GATE_TYPE' not in gl:
    gl.append('$GATE_TYPE')
p['safety']['human_gates'] = gl
with open('$PIPELINE_DIR/$PIPELINE_ID.json', 'w') as f:
    json.dump(p, f, indent=2)
print(f'Gate added: human required for task type \"$GATE_TYPE\"')
" 2>/dev/null
    ;;

  budget)
    shift 2
    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    require_pipeline

    MAX_TASKS=""
    MAX_LOOPS=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --max-tasks) MAX_TASKS="$2"; shift 2 ;;
        --max-loops) MAX_LOOPS="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    python3 -c "
import json
with open('$PIPELINE_DIR/$PIPELINE_ID.json') as f:
    p = json.load(f)
if 'safety' not in p:
    p['safety'] = {'allowed_paths': [], 'blocked_paths': [], 'max_tasks': None, 'max_loops': None, 'human_gates': []}
$( [ -n "$MAX_TASKS" ] && echo "p['safety']['max_tasks'] = $MAX_TASKS" || true )
$( [ -n "$MAX_LOOPS" ] && echo "p['safety']['max_loops'] = $MAX_LOOPS" || true )
with open('$PIPELINE_DIR/$PIPELINE_ID.json', 'w') as f:
    json.dump(p, f, indent=2)
echo 'Budget updated'
" 2>/dev/null
    ;;

  check)
    TASK_ID="${3:-}"
    shift 3 || true
    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    [ -z "$TASK_ID" ] && echo "Usage: safety-guard.sh check <pipeline-id> <task-id> [--file <path>]" && exit 1
    require_pipeline

    CHECK_FILE=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --file) CHECK_FILE="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    python3 -c "
import json, os, sys

with open('$PIPELINE_DIR/$PIPELINE_ID.json') as f:
    p = json.load(f)

safety = p.get('safety', {})
checks_passed = True

# 1. Budge check: max_tasks
mt = safety.get('max_tasks')
if mt is not None:
    done = len([t for t in p.get('tasks', []) if t.get('status') in ('done', 'failed')])
    if done >= mt:
        print(f'FAIL: Max tasks reached ({done}/{mt})')
        checks_passed = False

# 2. File check against allowed paths
check_file = '${CHECK_FILE:-}'
if check_file:
    allowed = safety.get('allowed_paths', [])
    blocked = safety.get('blocked_paths', [])
    rel = os.path.relpath(check_file, '$REPO_ROOT')

    # Check blocked first
    for bp in blocked:
        if rel.startswith(bp) or check_file.startswith(bp):
            print(f'FAIL: \"{check_file}\" is in blocked path \"{bp}\"')
            checks_passed = False
            break

    # Check allowed (if any are specified)
    if allowed:
        in_allowed = False
        for ap in allowed:
            if rel.startswith(ap) or check_file.startswith(ap):
                in_allowed = True
                break
        if not in_allowed:
            print(f'FAIL: \"{check_file}\" is not in allowed paths')
            checks_passed = False

    print(f'  Allowed paths: {allowed}')
    print(f'  Blocked paths: {blocked}')
    print(f'  Target file:   {check_file}')
    print(f'  Relative:      {rel}')

# 3. Human gate check for task type
gates = safety.get('human_gates', [])
if gates:
    task = next((t for t in p.get('tasks', []) if t.get('id') == $TASK_ID), None)
    if task:
        desc = task.get('description', '')
        for g in gates:
            if g.lower() in desc.lower():
                print(f'HUMAN GATE: Task \"{g}\" requires human approval')
                print(f'  Run: bash ./scripts/pipeline-run.sh human-checkpoint $PIPELINE_ID $TASK_ID')

if checks_passed:
    print('CHECK PASSED: Task is safe to execute')
else:
    print('CHECK FAILED: See above')
    sys.exit(1)
" 2>/dev/null
    ;;

  show)
    shift 2
    [ -z "$PIPELINE_ID" ] && show_help && exit 1
    require_pipeline

    python3 -c "
import json
with open('$PIPELINE_DIR/$PIPELINE_ID.json') as f:
    p = json.load(f)
s = p.get('safety', {})
print(f'Safety profile: $PIPELINE_ID')
print(f'  Allowed paths: {s.get(\"allowed_paths\", [])}')
print(f'  Blocked paths: {s.get(\"blocked_paths\", [])}')
print(f'  Max tasks:     {s.get(\"max_tasks\", \"unlimited\")}')
print(f'  Max loops:     {s.get(\"max_loops\", \"unlimited\")}')
print(f'  Human gates:   {s.get(\"human_gates\", [])}')
tasks = p.get('tasks', [])
done = len([t for t in tasks if t.get('status') in ('done', 'failed')])
print(f'  Task progress: {done}/{len(tasks)}')
" 2>/dev/null
    ;;

  help|--help|-h|*)
    show_help
    ;;
esac
