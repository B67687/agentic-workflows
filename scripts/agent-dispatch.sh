#!/bin/bash
# =============================================================================
# agent-dispatch.sh --- Async agent task dispatcher
#
# Fire-and-forget tasks to external coding agents and collect results.
# Supports pi-coding-agent (available now), with slots for codex/claude/gemini.
#
# Usage:
#   bash ./scripts/agent-dispatch.sh run <agent> "<task>" [options]
#   bash ./scripts/agent-dispatch.sh status [job-id]
#   bash ./scripts/agent-dispatch.sh list
#   bash ./scripts/agent-dispatch.sh cancel <job-id>
#   bash ./scripts/agent-dispatch.sh log <job-id>
#
# Examples:
#   bash ./scripts/agent-dispatch.sh run pi "Research what Yjs does"
#   bash ./scripts/agent-dispatch.sh run pi "Fix test warnings" --dir /tmp/task-1
#   bash ./scripts/agent-dispatch.sh status
#   bash ./scripts/agent-dispatch.sh log job-001
#
# Agent backends:
#   pi       --- pi-coding-agent (default, available now)
#   codex    --- Codex CLI (requires npm install -g @openai/codex)
#   claude   --- Claude Code (requires npm install -g @anthropic/claude-code)
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JOBS_DIR="$REPO_ROOT/.runtime/agent-jobs"
mkdir -p "$JOBS_DIR"

CMD="${1:-help}"
shift 1 || true

case "$CMD" in
  run)
    AGENT="${1:-pi}"
    TASK="${2:-}"
    shift 2 || true

    if [ -z "$TASK" ]; then
      echo "Usage: bash ./scripts/agent-dispatch.sh run <agent> \"<task>\" [options]"
      exit 1
    fi

    # Parse optional flags
    WORKDIR="$REPO_ROOT"
    MODEL=""
    FORMAT="text"
    MAX_LOOPS=1
    REASONING=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --dir) WORKDIR="$2"; shift 2 ;;
        --model) MODEL="$2"; shift 2 ;;
        --format)
          FORMAT="$2"
          if [ "$FORMAT" != "text" ] && [ "$FORMAT" != "json" ]; then
            echo "Format must be 'text' or 'json'"
            exit 1
          fi
          shift 2 ;;
        --loop)
          MAX_LOOPS="$2"
          if ! [ "$MAX_LOOPS" -gt 0 ] 2>/dev/null; then
            echo "Loop count must be a positive integer"
            exit 1
          fi
          # Hermes Agent pattern: force JSON format for iterative refinement
          if [ "$FORMAT" = "text" ]; then
            FORMAT="json"
          fi
          shift 2 ;;
        --reasoning)
          REASONING="$2"
          if [ "$REASONING" != "auto" ] && [ "$REASONING" != "high" ] && [ "$REASONING" != "max" ] && [ "$REASONING" != "non-think" ]; then
            echo "Reasoning must be: auto, high, max, or non-think"
            exit 1
          fi
          shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    # Auto-classify reasoning level if not explicitly set
    if [ -z "$REASONING" ]; then
      # Default: auto-classify
      REASONING=$(bash "$REPO_ROOT/scripts/reasoning-level.sh" "$TASK" 2>/dev/null || echo "high")
    elif [ "$REASONING" = "auto" ]; then
      REASONING=$(bash "$REPO_ROOT/scripts/reasoning-level.sh" "$TASK" 2>/dev/null || echo "high")
    fi

    # Pydantic AI structured output pattern: append JSON instruction
    if [ "$FORMAT" = "json" ]; then
      TASK="$TASK

IMPORTANT: Return your entire response as valid JSON. Start with { and end with }.
Do not include any text, markdown, or backticks before or after the JSON object.
The JSON must be parseable by json.loads()."
    fi

    # Generate job ID
    JOB_ID="job-$(date -u +%Y%m%d%H%M%S)-$$"
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Build the command based on agent
    case "$AGENT" in
      pi)
        CMD_ARGS=("pi" "-p" "$TASK")
        if [ -n "$MODEL" ]; then
          CMD_ARGS+=("--model" "$MODEL")
        fi
        ;;
      codex)
        if ! command -v codex &>/dev/null; then
          echo "Codex CLI not found. Install: npm install -g @openai/codex"
          exit 1
        fi
        CMD_ARGS=("codex" "$TASK")
        if [ -n "$MODEL" ]; then
          CMD_ARGS+=("-m" "$MODEL")
        fi
        ;;
      claude)
        if ! command -v claude &>/dev/null; then
          echo "Claude Code not found. Install: npm install -g @anthropic/claude-code"
          exit 1
        fi
        CMD_ARGS=("claude" "-p" "$TASK")
        if [ -n "$MODEL" ]; then
          CMD_ARGS+=("--model" "$MODEL")
        fi
        ;;
      *)
        echo "Unknown agent: $AGENT"
        echo "Available: pi, codex, claude"
        exit 1
        ;;
    esac

    # Create job record
    cat > "$JOBS_DIR/$JOB_ID.json" << JEOF
{
  "id": "$JOB_ID",
  "agent": "$AGENT",
  "task": $(echo "$TASK" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "\"$TASK\""),
  "workdir": "$WORKDIR",
  "format": "$FORMAT",
  "max_loops": $MAX_LOOPS,
  "reasoning": "$REASONING",
  "status": "running",
  "result": null,
  "iterations": [],
  "created": "$TIMESTAMP",
  "started": "$TIMESTAMP",
  "completed": null,
  "exit_code": null,
  "pid": null
}
JEOF

    # Encode command args as JSON (avoids all shell quoting issues)
    # Write args to a temp file, let Python read them
    ARGS_FILE="$JOBS_DIR/${JOB_ID}_args.txt"
    printf '%s\n' "${CMD_ARGS[@]}" > "$ARGS_FILE"
    CMD_ARGS_JSON=$(python3 -c "
import json
with open('$ARGS_FILE') as f:
    args = [line.rstrip('\n') for line in f if line.strip()]
print(json.dumps(args))
")

    # Launch the pre-built runner via nohup
    RUNNER="$REPO_ROOT/scripts/_agent_runner.py"
    nohup env \
      _RUNNER_WORKDIR="$WORKDIR" \
      _RUNNER_JOBS_DIR="$JOBS_DIR" \
      _RUNNER_JOB_ID="$JOB_ID" \
      _CMD_ARGS_JSON="$CMD_ARGS_JSON" \
      _RUNNER_MAX_LOOPS="$MAX_LOOPS" \
      python3 "$RUNNER" > /dev/null 2>&1 &

    PID=$!
    echo "$JOB_ID"
    echo "  Reasoning level: $REASONING"
    if [ "$REASONING" = "max" ]; then
      echo "    (complex/agentic task — +5-20% on hard work, higher cost)"
    elif [ "$REASONING" = "non-think" ]; then
      echo "    (trivial task — no reasoning needed, cheapest)"
    else
      echo "    (routine task — default, good balance)"
    fi
    ;;

  handoff)
    # A2A Protocol pattern: delegate a subtask to another agent.
    # The parent job waits while the child agent processes the task.
    # Result is the combined output when the child completes.
    #
    # Usage:
    #   bash ./scripts/agent-dispatch.sh handoff <parent-job> <agent> "<task>" [--dir <path>]
    #
    # The parent job enters 'waiting' state. A child job is created and
    # dispatched to the target agent. Use 'status' to check both jobs.
    PARENT_ID="${1:-}"
    CHILD_AGENT="${2:-}"
    CHILD_TASK="${3:-}"
    shift 3 || true

    if [ -z "$PARENT_ID" ] || [ -z "$CHILD_AGENT" ] || [ -z "$CHILD_TASK" ]; then
      echo "Usage: bash ./scripts/agent-dispatch.sh handoff <parent-job> <agent> \"<task>\" [--dir <path>]"
      exit 1
    fi

    # Verify parent exists
    if [ ! -f "$JOBS_DIR/$PARENT_ID.json" ]; then
      echo "Parent job not found: $PARENT_ID"
      echo "Run 'bash ./scripts/agent-dispatch.sh list' to see all jobs."
      exit 1
    fi

    # Parse handoff options
    CHILD_WORKDIR="$REPO_ROOT"
    while [ $# -gt 0 ]; do
      case "$1" in
        --dir) CHILD_WORKDIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    # Generate child job ID
    CHILD_ID="${PARENT_ID}-child-$(date -u +%Y%m%d%H%M%S)"
    CHILD_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Build command based on agent
    case "$CHILD_AGENT" in
      pi)
        CHILD_CMD_ARGS=("pi" "-p" "$CHILD_TASK")
        ;;
      codex)
        if ! command -v codex &>/dev/null; then
          echo "Codex CLI not found. Install: npm install -g @openai/codex"
          exit 1
        fi
        CHILD_CMD_ARGS=("codex" "$CHILD_TASK")
        ;;
      claude)
        if ! command -v claude &>/dev/null; then
          echo "Claude Code not found. Install: npm install -g @anthropic/claude-code"
          exit 1
        fi
        CHILD_CMD_ARGS=("claude" "-p" "$CHILD_TASK")
        ;;
      *)
        echo "Unknown agent: $CHILD_AGENT"
        echo "Available: pi, codex, claude"
        exit 1
        ;;
    esac

    # Create child job record
    cat > "$JOBS_DIR/$CHILD_ID.json" << CJOEF
{
  "id": "$CHILD_ID",
  "agent": "$CHILD_AGENT",
  "task": $(echo "$CHILD_TASK" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "\"$CHILD_TASK\""),
  "workdir": "$CHILD_WORKDIR",
  "format": "json",
  "max_loops": 1,
  "status": "running",
  "result": null,
  "iterations": [],
  "parent_id": "$PARENT_ID",
  "created": "$CHILD_TIMESTAMP",
  "started": "$CHILD_TIMESTAMP",
  "completed": null,
  "exit_code": null,
  "pid": null
}
CJOEF

    # Encode command args for child runner
    CHILD_ARGS_FILE="$JOBS_DIR/${CHILD_ID}_args.txt"
    printf '%s\n' "${CHILD_CMD_ARGS[@]}" > "$CHILD_ARGS_FILE"
    CHILD_CMD_ARGS_JSON=$(python3 -c "
import json
with open('$CHILD_ARGS_FILE') as f:
    args = [line.rstrip('\n') for line in f if line.strip()]
print(json.dumps(args))
")

    # Launch child runner
    RUNNER="$REPO_ROOT/scripts/_agent_runner.py"
    nohup env \
      _RUNNER_WORKDIR="$CHILD_WORKDIR" \
      _RUNNER_JOBS_DIR="$JOBS_DIR" \
      _RUNNER_JOB_ID="$CHILD_ID" \
      _CMD_ARGS_JSON="$CHILD_CMD_ARGS_JSON" \
      _RUNNER_MAX_LOOPS="1" \
      python3 "$RUNNER" > /dev/null 2>&1 &

    CHILD_PID=$!

    # Update child record with PID
    python3 -c "
import json
with open('$JOBS_DIR/$CHILD_ID.json') as f:
    j = json.load(f)
j['pid'] = $CHILD_PID
with open('$JOBS_DIR/$CHILD_ID.json', 'w') as f:
    json.dump(j, f, indent=2)
" 2>/dev/null || true

    # Update parent record with handoff info
    python3 -c "
import json
with open('$JOBS_DIR/$PARENT_ID.json') as f:
    p = json.load(f)
p['status'] = 'waiting'
p['handoff_child'] = '$CHILD_ID'
p['handoff_agent'] = '$CHILD_AGENT'
with open('$JOBS_DIR/$PARENT_ID.json', 'w') as f:
    json.dump(p, f, indent=2)
" 2>/dev/null || true

    echo "Handoff: $PARENT_ID -> $CHILD_ID"
    echo "  Parent status: waiting (child processing)"
    echo "  Child agent: $CHILD_AGENT"
    echo "  Task: ${CHILD_TASK:0:80}..."
    echo "  Child PID: $CHILD_PID"
    echo ""
    echo "Check: bash ./scripts/agent-dispatch.sh status $PARENT_ID"
    echo "       bash ./scripts/agent-dispatch.sh status $CHILD_ID"
    echo "Result: bash ./scripts/agent-dispatch.sh result $CHILD_ID"
    ;;

  status)
    JOB_ID="${1:-}"
    if [ -z "$JOB_ID" ]; then
      # Show all jobs summary
      echo "Recent jobs:"
      echo ""
      for f in "$JOBS_DIR"/*.json; do
        [ -f "$f" ] || continue
        python3 -c "
import json
with open('$f') as fh:
    j = json.load(fh)
status = j.get('status', 'unknown')
task = j.get('task', '')[:60]
agent = j.get('agent', '?')
jid = j.get('id', '?')
created = j.get('created', '?')[:19]
print(f'  {jid}  [{status:7}]  {agent:6}  {created}  {task}')
" 2>/dev/null || true
      done
      echo ""
      echo "Total: $(ls "$JOBS_DIR"/*.json 2>/dev/null | wc -l) job(s)"
    else
      # Show specific job
      if [ ! -f "$JOBS_DIR/$JOB_ID.json" ]; then
        echo "Job not found: $JOB_ID"
        echo "Run 'bash ./scripts/agent-dispatch.sh list' to see all jobs."
        exit 1
      fi
      python3 -m json.tool "$JOBS_DIR/$JOB_ID.json" 2>/dev/null || cat "$JOBS_DIR/$JOB_ID.json"
      echo ""
      if [ -f "$JOBS_DIR/$JOB_ID.log" ]; then
        LOG_LINES=$(wc -l < "$JOBS_DIR/$JOB_ID.log")
        echo "Log: $LOG_LINES lines (bash ./scripts/agent-dispatch.sh log $JOB_ID)"
      fi
    fi
    ;;

  list)
    echo "All jobs:"
    echo ""
    for f in "$JOBS_DIR"/*.json; do
      [ -f "$f" ] || continue
      python3 -c "
import json
with open('$f') as fh:
    j = json.load(fh)
jid = j.get('id', '?')
status = j.get('status', 'unknown')
agent = j.get('agent', '?')
created = j.get('created', '?')[:19]
completed = j.get('completed', '')[:19] or 'in progress'
exit_code = j.get('exit_code', '')
ec = f' exit={exit_code}' if exit_code is not None else ''
task = j.get('task', '')[:80]
print(f'{jid} {status:7} {agent:6} {created} -> {completed}{ec}')
print(f'       {task}')
print()
" 2>/dev/null || true
    done
    ;;

  result)
    JOB_ID="${1:-}"
    if [ -z "$JOB_ID" ]; then
      echo "Usage: bash ./scripts/agent-dispatch.sh result <job-id>"
      echo "Jobs:"
      ls "$JOBS_DIR"/*.json 2>/dev/null | sed 's/.*\///;s/\.json$//' | head -10
      exit 1
    fi
    if [ ! -f "$JOBS_DIR/$JOB_ID.json" ]; then
      echo "Job not found: $JOB_ID"
      exit 1
    fi
    python3 -c "
import json
with open('$JOBS_DIR/$JOB_ID.json') as f:
    job = json.load(f)

# A2A Protocol: follow handoff chain
handoff = job.get('handoff_child')
if handoff:
    print(f'[Parent job — delegated to child: {handoff}]')
    print(f'  Agent: {job.get(\"handoff_agent\", \"?\")}')
    print(f'  Status: {job.get(\"status\", \"?\")}')
    print()
    # Show child result instead
    child_path = '$JOBS_DIR/' + handoff + '.json'
    try:
        with open(child_path) as cf:
            child = json.load(cf)
        cr = child.get('result')
        if child.get('format') == 'json' and cr is not None:
            if isinstance(cr, dict) and '_error' in cr:
                print(f'Child JSON parse error: {cr[\"_error\"]}')
            else:
                print(json.dumps(cr, indent=2))
        else:
            print(f'Child status: {child.get(\"status\")} exit={child.get(\"exit_code\")}')
    except FileNotFoundError:
        print('Child job not yet complete.')
    sys.exit(0)

fmt = job.get('format', 'text')
result = job.get('result')
if fmt == 'json' and result is not None:
    if isinstance(result, dict) and '_error' in result:
        print(f'JSON parse error: {result[\"_error\"]}')
        print(f'Raw output: {result[\"_raw\"][:200]}')
    else:
        print(json.dumps(result, indent=2))
else:
    log_path = '$JOBS_DIR/$JOB_ID.log'
    try:
        with open(log_path) as lf:
            print(lf.read())
    except FileNotFoundError:
        print('No log output yet.')
" 2>/dev/null
    ;;

  log)
    JOB_ID="${1:-}"
    if [ -z "$JOB_ID" ]; then
      echo "Usage: bash ./scripts/agent-dispatch.sh log <job-id>"
      echo "Jobs:"
      ls "$JOBS_DIR"/*.json 2>/dev/null | sed 's/.*\///;s/\.json$//' | head -10
      exit 1
    fi
    if [ ! -f "$JOBS_DIR/$JOB_ID.log" ]; then
      echo "No log for job: $JOB_ID"
      echo "Job may still be running. Check: bash ./scripts/agent-dispatch.sh status $JOB_ID"
      exit 1
    fi
    cat "$JOBS_DIR/$JOB_ID.log"
    ;;

  cancel)
    JOB_ID="${1:-}"
    if [ -z "$JOB_ID" ]; then
      echo "Usage: bash ./scripts/agent-dispatch.sh cancel <job-id>"
      exit 1
    fi
    if [ ! -f "$JOBS_DIR/$JOB_ID.json" ]; then
      echo "Job not found: $JOB_ID"
      exit 1
    fi
    STATUS=$(python3 -c "import json; print(json.load(open('$JOBS_DIR/$JOB_ID.json')).get('status',''))" 2>/dev/null)
    PID=$(python3 -c "import json; j=json.load(open('$JOBS_DIR/$JOB_ID.json')); print(j.get('pid') or '')" 2>/dev/null)
    if [ "$STATUS" = "running" ] && [ -n "$PID" ]; then
      kill "$PID" 2>/dev/null || true
      python3 -c "
import json
with open('$JOBS_DIR/$JOB_ID.json') as f:
    j = json.load(f)
j['status'] = 'cancelled'
j['completed'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('$JOBS_DIR/$JOB_ID.json', 'w') as f:
    json.dump(j, f, indent=2)
" 2>/dev/null || true
      echo "Cancelled: $JOB_ID (PID $PID)"
    else
      echo "Job $JOB_ID is not running (status: $STATUS)"
    fi
    ;;

  help|--help|-h|*)
    echo "Async agent task dispatcher"
    echo ""
    echo "Usage:"
    echo "  bash ./scripts/agent-dispatch.sh run <agent> \"<task>\" [options]"
    echo "  bash ./scripts/agent-dispatch.sh handoff <parent> <agent> \"<task>\" [--dir <path>]"
    echo "  bash ./scripts/agent-dispatch.sh status [job-id]"
    echo "  bash ./scripts/agent-dispatch.sh list"
    echo "  bash ./scripts/agent-dispatch.sh cancel <job-id>"
    echo "  bash ./scripts/agent-dispatch.sh log <job-id>"
    echo "  bash ./scripts/agent-dispatch.sh result <job-id>"
    echo ""
    echo "Agents (available):"
    echo "  pi       pi-coding-agent (default)"
    echo ""
    echo "Agents (installable):"
    echo "  codex    npm install -g @openai/codex"
    echo "  claude   npm install -g @anthropic/claude-code"
    echo ""
    echo "Options for 'run':"
    echo "  --dir <path>     Working directory (default: workspace root)"
    echo "  --model <id>     Model to use (agent-specific)"
    echo "  --format <type>  Output format: 'text' (default) or 'json' (Pydantic AI pattern)"
    echo "  --loop <N>       Iterative refinement (Hermes Agent pattern, N=iterations)"
    echo ""
    echo "Examples:"
    echo "  bash ./scripts/agent-dispatch.sh run pi 'Research what Yjs does'"
    echo "  bash ./scripts/agent-dispatch.sh run pi 'Extract config' --format json"
    echo "  bash ./scripts/agent-dispatch.sh run pi 'Refactor module' --loop 3"
    echo "  bash ./scripts/agent-dispatch.sh result job-001"
    echo "  bash ./scripts/agent-dispatch.sh status"
    echo "  bash ./scripts/agent-dispatch.sh log job-001"
    ;;
esac
