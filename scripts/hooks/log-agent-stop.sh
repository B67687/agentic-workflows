#!/usr/bin/env bash
# =============================================================================
# log-agent-stop.sh — SubagentStop lifecycle hook
# Logs subagent completion to .cache/agent-audit.log.
#
# Input: JSON via stdin (Claude Code SubagentStop schema) or empty
# Usage:
#   echo '{"agent_type":"worker","status":"completed"}' | bash ./scripts/hooks/log-agent-stop.sh
# or with positional args:
#   bash ./scripts/hooks/log-agent-stop.sh worker "completed"
# =============================================================================

set -euo pipefail

AUDIT_DIR=".cache"
AUDIT_FILE="$AUDIT_DIR/agent-audit.log"
mkdir -p "$AUDIT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
AGENT_TYPE=""
STATUS=""

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
            STATUS=$(echo "$INPUT" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get('status', d.get('result', 'completed')))
except: print('completed')
" 2>/dev/null || echo "completed")
        else
            STATUS="completed"
        fi
    fi
fi

# Fallback to positional args
if [ -z "$AGENT_TYPE" ] && [ $# -ge 1 ]; then
    AGENT_TYPE="$1"
    STATUS="${2:-completed}"
fi

[ -z "$AGENT_TYPE" ] && AGENT_TYPE="unknown"

echo "$TIMESTAMP | STOP  | $AGENT_TYPE | $STATUS" >> "$AUDIT_FILE"
exit 0
