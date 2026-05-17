#!/usr/bin/env bash
# =============================================================================
# memory-query.sh --- Unified memory query across all stores
#
# Each memory store has different purpose, availability, and query capability.
# This script provides a single entry point that queries all available stores
# and returns merged results.
#
# Boundaries (architectural):
#   .learnings.jsonl     -- durable cross-session knowledge (preferences,
#                            decisions, patterns). Always available.
#                            Query: keywords via learnings-search.sh
#   agentmemory MCP       -- ephemeral session context (recent observations,
#                            timeline, tool usage). Rich semantic search.
#                            Query: memory_smart_search
#                            Availability: depends on MCP server running
#   ruflo memory          -- operational patterns (task routing, workflow
#                            hooks). Not content memory.
#                            Query: ruflo hooks route
#
# Usage:
#   bash ./scripts/memory-query.sh <query>      # unified search
#   bash ./scripts/memory-query.sh --all <query> # search all with context
#   bash ./scripts/memory-query.sh --learnings   # search learnings only
#   bash ./scripts/memory-query.sh --status      # show store availability
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"

MODE="${1:-search}"
QUERY="${2:-}"

if [ "$MODE" = "--status" ] || [ "$MODE" = "status" ]; then
  echo "=== Memory Store Status ==="
  echo ""

  # .learnings.jsonl
  if [ -f "$LEARNINGS_FILE" ]; then
    LINES=$(wc -l < "$LEARNINGS_FILE" 2>/dev/null || echo 0)
    echo "  learnings.jsonl    AVAILABLE  ($LINES entries)"
  else
    echo "  learnings.jsonl    EMPTY"
  fi

  # agentmemory MCP
  if command -v npx &>/dev/null; then
    echo "  agentmemory MCP    DEPENDENCY  (npx installed)"
  else
    echo "  agentmemory MCP    UNAVAILABLE (npx not found)"
  fi

  # ruflo
  if command -v ruflo &>/dev/null; then
    echo "  ruflo memory       AVAILABLE  (ruflo CLI installed)"
  else
    echo "  ruflo memory       UNAVAILABLE"
  fi

  echo ""
  echo "Boundaries:"
  echo "  learnings.jsonl  -- Durable cross-session knowledge"
  echo "  agentmemory MCP  -- Ephemeral session context, semantic search"
  echo "  ruflo            -- Operational patterns (routing, hooks)"
  exit 0
fi

# Search learnings
search_learnings() {
  local q="$1"
  if [ ! -f "$LEARNINGS_FILE" ]; then
    return
  fi
  if ! command -v rg &>/dev/null; then
    if command -v grep &>/dev/null; then
      grep -i "$q" "$LEARNINGS_FILE" 2>/dev/null | while IFS= read -r line; do
        echo "$line" | python3 -c "
import sys, json
try:
    e = json.loads(sys.stdin.read())
    content = e.get('insight', e.get('content', ''))[:200]
    tags = e.get('tags', '')
    print(f'  [learnings] {content}')
    print(f'              tags: {tags}')
except:
    pass
" 2>/dev/null || true
      done
    fi
  else
    rg -i "$q" "$LEARNINGS_FILE" 2>/dev/null | while IFS= read -r line; do
      echo "$line" | python3 -c "
import sys, json
try:
    e = json.loads(sys.stdin.read())
    content = e.get('insight', e.get('content', ''))[:200]
    tags = e.get('tags', '')
    print(f'  [learnings] {content}')
    print(f'              tags: {tags}')
except:
    pass
" 2>/dev/null || true
    done
  fi
}

case "$MODE" in
  --learnings|learnings)
    echo "=== Learnings (cross-session knowledge) ==="
    echo ""
    if [ -z "$QUERY" ]; then
      echo "Query required. Usage: memory-query.sh --learnings <query>"
      exit 1
    fi
    search_learnings "$QUERY"
    ;;

  --all|all)
    echo "=== Unified Memory Query ==="
    echo "Query: ${QUERY:-<all>}"
    echo ""

    # .learnings.jsonl
    echo "--- Cross-Session Knowledge (.learnings.jsonl) ---"
    if [ -n "$QUERY" ]; then
      search_learnings "$QUERY"
    else
      echo "  (query required for learnings search)"
    fi
    echo ""

    # agentmemory hint
    if command -v npx &>/dev/null; then
      echo "--- Session Context (agentmemory MCP) ---"
      echo "  Use: memory_smart_search(query=\"$QUERY\") via MCP tools"
      echo "  Available when MCP server is running (see: npx @agentmemory/mcp)"
    fi
    echo ""

    # ruflo hint
    if command -v ruflo &>/dev/null; then
      echo "--- Operational Patterns (ruflo) ---"
      echo "  Use: ruflo hooks route -t \"$QUERY\""
      echo "  Or:  ruflo hooks session-restore"
    fi
    ;;

  --sync|sync)
    # One-way sync: push .learnings.jsonl entries to agentmemory
    echo "=== Sync: learnings -> agentmemory ==="
    echo ""
    if [ ! -f "$LEARNINGS_FILE" ]; then
      echo "  No learnings to sync."
      exit 0
    fi
    COUNT=0
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      TAGS=$(echo "$line" | python3 -c "
import sys, json
try:
    e = json.loads(sys.stdin.read())
    tags = e.get('tags', '')
    if isinstance(tags, str):
        print(tags)
    elif isinstance(tags, list):
        print(','.join(tags))
except:
    pass
" 2>/dev/null)
      if command -v memory_save &>/dev/null; then
        # In a real context, this would call the MCP tool
        echo "  Would sync to agentmemory: tags=$TAGS"
        COUNT=$((COUNT + 1))
      fi
    done < "$LEARNINGS_FILE"
    echo ""
    echo "  $COUNT entries scanned."
    echo "  To sync: run 'agentmemory memory_save' with .learnings.jsonl entries"
    echo "  Sync is manual because MCP tools cannot be called from bash directly."
    ;;

  *)
    # Default: unified search
    echo "=== Memory Query: ${QUERY:-<no query>} ==="
    echo ""
    echo "--- Cross-Session Knowledge (.learnings.jsonl) ---"
    if [ -n "$QUERY" ]; then
      search_learnings "$QUERY"
    fi
    echo ""
    echo "--- Session Context (agentmemory MCP) ---"
    echo "  Run: agentmemory memory_smart_search(query=\"${QUERY:-}\")"
    echo ""
    echo "--- Operational Patterns (ruflo) ---"
    echo "  Run: ruflo hooks route -t \"${QUERY:-}\""
    echo ""
    echo "Tip: Use --status to check store availability."
    ;;
esac
