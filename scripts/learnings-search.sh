#!/bin/bash
# Search saved learnings for relevant context.
# Fallback when agentmemory MCP is unavailable.
# Usage: bash ./scripts/learnings-search.sh [query]

set -euo pipefail

QUERY="${1:-}"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"

if [ ! -f "$LEARNINGS_FILE" ]; then
  echo "No learnings saved yet."
  exit 0
fi

TOTAL=$(wc -l < "$LEARNINGS_FILE")

if [ -z "$QUERY" ]; then
  echo "Learnings ($TOTAL total):"
  echo ""
  while IFS= read -r line; do
    INSIGHT=$(echo "$line" | jq -r '.insight // "?"' 2>/dev/null)
    TAGS=$(echo "$line" | jq -r '.tags // ""' 2>/dev/null)
    TS=$(echo "$line" | jq -r '.ts // ""' 2>/dev/null | sed 's/T/ /' | cut -d. -f1)
    echo "  [$TS] $INSIGHT"
    [ -n "$TAGS" ] && echo "        tags: $TAGS"
  done < "$LEARNINGS_FILE"
  exit 0
fi

# Simple grep-based search (agentmemory is better for semantic search)
# This is a lightweight fallback
RESULTS=$(grep -i "$QUERY" "$LEARNINGS_FILE" 2>/dev/null || true)
COUNT=$(echo "$RESULTS" | grep -c . || echo 0)

if [ "$COUNT" -eq 0 ]; then
  echo "No learnings match: $QUERY"
  echo "Use agentmemory's memory_smart_search for semantic search."
  exit 0
fi

echo "Matching learnings ($COUNT):"
echo ""
while IFS= read -r line; do
  INSIGHT=$(echo "$line" | jq -r '.insight // "?"' 2>/dev/null)
  TAGS=$(echo "$line" | jq -r '.tags // ""' 2>/dev/null)
  TS=$(echo "$line" | jq -r '.ts // ""' 2>/dev/null | sed 's/T/ /' | cut -d. -f1)
  echo "  [$TS] $INSIGHT"
  [ -n "$TAGS" ] && echo "        tags: $TAGS"
done < <(echo "$RESULTS")
