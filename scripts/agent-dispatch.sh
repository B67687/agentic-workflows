#!/bin/bash
# =============================================================================
# agent-dispatch.sh — Async agent task dispatcher
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
#   pi       — pi-coding-agent (default, available now)
#   codex    — Codex CLI (requires npm install -g @openai/codex)
#   claude   — Claude Code (requires npm install -g @anthropic/claude-code)
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JOBS_DIR="$REPO_ROOT/.agent-jobs"
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
    while [ $# -gt 0 ]; do
      case "$1" in
        --dir) WORKDIR="$2"; shift 2 ;;
        --model) MODEL="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

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
  "status": "running",
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
      python3 "$RUNNER" > /dev/null 2>&1 &

    PID=$!
    echo "$JOB_ID"
    echo "Dispatched to $AGENT: $JOB_ID"
    echo "  Task: ${TASK:0:80}..."
    echo "  Workdir: $WORKDIR"
    echo "  PID: $PID"
    echo ""
    echo "Check: bash ./scripts/agent-dispatch.sh status $JOB_ID"
    echo "Log:   bash ./scripts/agent-dispatch.sh log $JOB_ID"

    # Update job record with PID
    python3 -c "
import json
with open('$JOBS_DIR/$JOB_ID.json') as f:
    j = json.load(f)
j['pid'] = $PID
with open('$JOBS_DIR/$JOB_ID.json', 'w') as f:
    json.dump(j, f, indent=2)
" 2>/dev/null || true
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
    echo "  bash ./scripts/agent-dispatch.sh status [job-id]"
    echo "  bash ./scripts/agent-dispatch.sh list"
    echo "  bash ./scripts/agent-dispatch.sh cancel <job-id>"
    echo "  bash ./scripts/agent-dispatch.sh log <job-id>"
    echo ""
    echo "Agents (available):"
    echo "  pi       pi-coding-agent (default)"
    echo ""
    echo "Agents (installable):"
    echo "  codex    npm install -g @openai/codex"
    echo "  claude   npm install -g @anthropic/claude-code"
    echo ""
    echo "Options for 'run':"
    echo "  --dir <path>   Working directory (default: workspace root)"
    echo "  --model <id>   Model to use (agent-specific)"
    echo ""
    echo "Examples:"
    echo "  bash ./scripts/agent-dispatch.sh run pi 'Research what Yjs does'"
    echo "  bash ./scripts/agent-dispatch.sh status"
    echo "  bash ./scripts/agent-dispatch.sh log job-001"
    ;;
esac
