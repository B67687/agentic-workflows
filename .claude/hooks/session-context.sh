#!/usr/bin/env bash
# Injects current session context into Claude Code at startup
# Prints structured JSON with branch, health status, and recent commits

set -euo pipefail

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
COMMITS="$(git log --oneline -5 2>/dev/null || echo "")"
DIRTY="$(git status --short 2>/dev/null | wc -l)"
STATE_FILE="session-state.json"

# Build context for Claude
cat <<JSONEOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Current branch: $BRANCH\\nUncommitted changes: $DIRTY\\nRecent commits:\\n$(echo "$COMMITS" | sed 's/^/  /')\\nSession state: $(test -f "$STATE_FILE" && echo "found" || echo "not found")"
  }
}
JSONEOF
