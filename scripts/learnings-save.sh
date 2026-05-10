#!/bin/bash
# Save a durable project learning/insight to a local file.
# Fallback when agentmemory MCP is unavailable.
# Usage: bash ./scripts/learnings-save.sh "insight text" [tag1,tag2]

set -e

INSIGHT="${1:-}"
TAGS="${2:-general}"

if [ -z "$INSIGHT" ]; then
  echo "Usage: bash ./scripts/learnings-save.sh \"insight text\" [tag1,tag2]"
  echo "Example: bash ./scripts/learnings-save.sh \"The auth middleware uses JWT with RS256\" auth,architecture"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Create entry
ENTRY=$(cat << EOF
{"ts":"$TIMESTAMP","insight":$(echo "$INSIGHT" | jq -Rs . 2>/dev/null || echo "\"$INSIGHT\""),"tags":"$TAGS","source":"agent"}
EOF
)

echo "$ENTRY" >> "$LEARNINGS_FILE"
COUNT=$(wc -l < "$LEARNINGS_FILE")

echo "Learning saved. Total learnings: $COUNT"
echo "  $INSIGHT"
echo "  tags: $TAGS"
