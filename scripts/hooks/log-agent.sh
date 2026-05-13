#!/usr/bin/env bash
# =============================================================================
# log-agent.sh --- SubagentStart lifecycle hook
# Logs subagent invocations to .cache/agent-audit.log for debugging and
# understanding usage patterns.
#
# Input: JSON via stdin (Claude Code SubagentStart schema) or empty
#   { "agent_type": "...", "task_description": "..." }
#
# Usage (from task prompt preamble):
#   echo '{"agent_type":"worker","task":"implement X"}' | bash ./scripts/hooks/log-agent.sh
# or with no input (generic invocation):
#   bash ./scripts/hooks/log-agent.sh worker "implement X"
# =============================================================================

set -euo pipefail

AUDIT_DIR=".cache"
AUDIT_FILE="$AUDIT_DIR/agent-audit.log"
mkdir -p "$AUDIT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
AGENT_TYPE=""
TASK_DESC=""

# Try stdin JSON first (Claude Code hook protocol)
if [ ! -t 0 ]; then
    INPUT=$(cat 2>/dev/null || echo "")
    if [ -n "$INPUT" ]; then
        if command -v python3 >/dev/null 2>&1; then
            AGENT_TYPE=$(echo "$INPUT" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get('agent_type', d.get('agentType', d.get('type', 'unknown'))))
except: print('unknown')
" 2>/dev/null || echo "unknown")
            TASK_DESC=$(echo "$INPUT" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get('task_description', d.get('task', d.get('description', ''))))
except: print('')
" 2>/dev/null || echo "")
        else
            AGENT_TYPE=$(echo "$INPUT" | grep -o '"agent_type"[^,]*' | head -1 | cut -d: -f2 | tr -d ' "')
            [ -z "$AGENT_TYPE" ] && AGENT_TYPE="unknown"
        fi
    fi
fi

# Fallback to positional args
if [ -z "$AGENT_TYPE" ] && [ $# -ge 1 ]; then
    AGENT_TYPE="$1"
    TASK_DESC="${2:-}"
fi

[ -z "$AGENT_TYPE" ] && AGENT_TYPE="unknown"

echo "$TIMESTAMP | START | $AGENT_TYPE | $TASK_DESC" >> "$AUDIT_FILE"
exit 0
