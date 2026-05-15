#!/bin/bash
# =============================================================================
# session-sync.sh --- Session state auto-sync
#
# Updates session-state.json from runtime events. Called by the MCP server
# after tools/call execution and by phase-gate.sh at phase transitions.
#
# Prevents session-state.json drift --- the state file is always current.
#
# Usage:
#   bash scripts/session-sync.sh update <field> <value>
#   bash scripts/session-sync.sh append <field> <value>    (for list fields)
#   bash scripts/session-sync.sh phase <phase_name> <status>
#   bash scripts/session-sync.sh status                   # show current
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$REPO_ROOT/session-state.json"
EVENTS_LOG="$REPO_ROOT/.runtime/state-events.jsonl"
ensure_dir() { mkdir -p "$(dirname "$EVENTS_LOG")"; }

CMD="${1:-help}"

case "$CMD" in
  update)
    FIELD="${2:-}"
    VALUE="${3:-}"
    if [ -z "$FIELD" ]; then echo "Usage: session-sync.sh update <field> <value>" >&2; exit 1; fi

    if [ ! -f "$STATE_FILE" ]; then
      echo '{"session":0,"status":"initialized","events":[]}' > "$STATE_FILE"
    fi

    # Update the state file with the new field
    python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    state = json.load(f)

# Handle nested keys (e.g., 'currentTask.status' -> state['currentTask']['status'])
parts = '$FIELD'.split('.')
target = state
for p in parts[:-1]:
    if p not in target:
        target[p] = {}
    target = target[p]
target[parts[-1]] = '$VALUE'

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
    f.write('\n')
print(f'session-state: $FIELD = $VALUE')
" 2>/dev/null || {
      echo "Warning: failed to update $FIELD" >&2
      exit 1
    }
    ;;

  append)
    FIELD="${2:-}"
    VALUE="${3:-}"
    if [ -z "$FIELD" ]; then echo "Usage: session-sync.sh append <field> <value>" >&2; exit 1; fi

    if [ ! -f "$STATE_FILE" ]; then
      echo '{"session":0,"status":"initialized"}' > "$STATE_FILE"
    fi

    python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    state = json.load(f)

parts = '$FIELD'.split('.')
target = state
for p in parts:
    if p not in target:
        target[p] = []
    target = target[p]

if isinstance(target, list):
    target.append('$VALUE')
else:
    print(f'Error: $FIELD is not a list', file=sys.stderr)
    sys.exit(1)

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
    f.write('\n')
print(f'session-state: $FIELD += \"$VALUE\"')
" 2>/dev/null || {
      echo "Warning: failed to append to $FIELD" >&2
    }
    ;;

  phase)
    PHASE="${2:-unknown}"
    STATUS="${3:-started}"
    TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    # Update session state
    bash "$0" update "currentTask.status" "$STATUS"
    bash "$0" append "whatChanged" "$PHASE phase: $STATUS at $TIMESTAMP"

    # Log to events
    ensure_dir
    echo "{\"ts\":\"$TIMESTAMP\",\"type\":\"phase\",\"phase\":\"$PHASE\",\"status\":\"$STATUS\"}" >> "$EVENTS_LOG"
    echo "phase-sync: $PHASE -> $STATUS"
    ;;

  status)
    if [ ! -f "$STATE_FILE" ]; then
      echo "No session state file. Run 'session-sync.sh start' first."
      exit 0
    fi
    echo "=== Session State ==="
    python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
print(f'Session: {s.get(\"session\", \"?\")}')
print(f'Status: {s.get(\"status\", \"?\")}')
print(f'Context pressure: {s.get(\"contextPressure\", \"?\")}')
task = s.get('currentTask', {})
print(f'Current task: {task.get(\"name\", \"none\")} ({task.get(\"status\", \"?\")})')
wc = s.get('whatChanged', [])
print(f'Changes: {len(wc)} entries')
ft = s.get('filesTouched', [])
print(f'Files touched: {len(ft)}')
v = s.get('verification', [])
print(f'Verifications: {len(v)}')
rl = s.get('keyLearnings', [])
print(f'Learnings: {len(rl)}')
"
    ;;

  start)
    TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    SESSION_NUM=$(python3 -c "
import json
try:
    with open('$STATE_FILE') as f:
        s = json.load(f)
    print(s.get('session', 0) + 1)
except: print(1)
" 2>/dev/null || echo 1)

    # Create fresh state file
    cat > "$STATE_FILE" << STATE
{
  "session": $SESSION_NUM,
  "status": "in-progress",
  "interruptedCount": 0,
  "contextPressure": "healthy",
  "currentTask": {
    "name": "",
    "status": "started",
    "goal": ""
  },
  "whatChanged": [],
  "verification": [],
  "keyLearnings": [],
  "residualRisk": "",
  "immediateNextSteps": []
}
STATE

    ensure_dir
    echo "{\"ts\":\"$TIMESTAMP\",\"type\":\"session_start\",\"session\":$SESSION_NUM}" >> "$EVENTS_LOG"
    echo "Session $SESSION_NUM started."
    ;;

  help|*)
    echo "Usage: bash scripts/session-sync.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  start                         Initialize a new session"
    echo "  update <field> <value>        Set a field (supports nested: 'currentTask.name')"
    echo "  append <field> <value>        Append to a list field"
    echo "  phase <phase> <status>        Record a phase transition"
    echo "  status                        Show session summary"
    ;;
esac
