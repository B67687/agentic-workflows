#!/bin/bash
# Save working context (git state, decisions, remaining work) for resume.
# Usage: bash ./scripts/context-save.sh "optional summary of current state"

set -e

SUMMARY="${1:-}"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
CONTEXT_DIR="$REPO_ROOT/.context"
mkdir -p "$CONTEXT_DIR"

# Generate a context ID from timestamp
CONTEXT_ID=$(date -u +%Y%m%d%H%M%S)
CONTEXT_FILE="$CONTEXT_DIR/$CONTEXT_ID.json"

# Gather git state
BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DIRTY=$(git status --porcelain 2>/dev/null | wc -l)
DIRTY_FILES=$(git status --porcelain 2>/dev/null | head -20)
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
STASH_COUNT=$(git stash list 2>/dev/null | wc -l)

# Read current session state if available
SESSION_STATE=""
if [ -f "$REPO_ROOT/session-state.json" ]; then
  SESSION_STATE=$(cat "$REPO_ROOT/session-state.json" 2>/dev/null)
fi

# Check for .gstack-freeze
FREEZE=""
if [ -f "$REPO_ROOT/.gstack-freeze" ]; then
  FREEZE=$(cat "$REPO_ROOT/.gstack-freeze" 2>/dev/null)
fi

# Write context file
cat > "$CONTEXT_FILE" << EOF
{
  "context_id": "$CONTEXT_ID",
  "timestamp": "$TIMESTAMP",
  "summary": $(echo "$SUMMARY" | jq -Rs . 2>/dev/null || echo "\"$SUMMARY\""),
  "git": {
    "branch": "$BRANCH",
    "hash": "$HASH",
    "dirty_files_count": $DIRTY,
    "ahead": $AHEAD,
    "behind": $BEHIND,
    "stash_count": $STASH_COUNT
  },
  "freeze": $(if [ -n "$FREEZE" ]; then echo "\"$FREEZE\""; else echo "null"; fi),
  "dirty_files": $(echo "$DIRTY_FILES" | jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")
}
EOF

# Clean up old contexts (keep last 20)
ls -t "$CONTEXT_DIR"/*.json 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null || true

echo "Context saved: $CONTEXT_ID"
echo "  Branch: $BRANCH ($HASH)"
echo "  Dirty files: $DIRTY"
echo "  Run: bash ./scripts/context-restore.sh $CONTEXT_ID"
