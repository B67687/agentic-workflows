#!/usr/bin/env bash
# =============================================================================
# sync-learnings.sh --- Push consolidated learnings into agentmemory MCP
#
# Reads the pending sync file created by consolidate-memory.sh --sync and
# pushes each entry to agentmemory via memory_save (MCP tool).
#
# This bridges .learnings.jsonl (durable) and agentmemory (semantic search).
# Run after consolidation, or on session start to catch up.
#
# Usage:
#   bash ./scripts/sync-learnings.sh              # sync to agentmemory
#   bash ./scripts/sync-learnings.sh --status     # check pending sync file
#   bash ./scripts/sync-learnings.sh --clear      # clear pending sync file
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PENDING_FILE="$REPO_ROOT/.runtime/pending-sync.json"

MODE="${1:-sync}"

case "$MODE" in
  --status|status)
    if [ ! -f "$PENDING_FILE" ]; then
      echo "No pending sync file found."
      exit 0
    fi
    python3 -c "
import json
with open('$PENDING_FILE') as f:
    data = json.load(f)
count = data.get('count', 0)
synced = data.get('synced', False)
print(f'Pending: {count} entries')
print(f'Synced: {synced}')
if count > 0 and not synced:
    print('Status: READY TO SYNC')
elif synced:
    print('Status: ALREADY SYNCED')
else:
    print('Status: EMPTY')
" 2>/dev/null
    ;;

  --clear|clear)
    rm -f "$PENDING_FILE"
    echo "Pending sync file cleared."
    ;;

  sync)
    if [ ! -f "$PENDING_FILE" ]; then
      echo "No pending sync file found."
      echo "Run: bash ./scripts/consolidate-memory.sh --sync"
      exit 0
    fi

    # Check if already synced
    ALREADY=$(python3 -c "import json; print(json.load(open('$PENDING_FILE')).get('synced', False))" 2>/dev/null)
    if [ "$ALREADY" = "True" ]; then
      echo "Already synced. Use --clear to re-sync."
      exit 0
    fi

    echo "=== Syncing Learnings to Agent Memory ==="
    echo ""

    # Read entries from pending file
    python3 -c "
import json, sys

with open('$PENDING_FILE') as f:
    data = json.load(f)

entries = data.get('entries', [])
print(f'Entries to sync: {len(entries)}')

for i, e in enumerate(entries):
    content = e.get('insight', e.get('content', ''))
    tags = e.get('tags', '')
    ts = e.get('ts', '')
    
    print()
    print(f'[{i+1}/{len(entries)}] {content[:80]}...')
    print(f'      tags: {tags}')
    print(f'      ts:   {ts}')
    print(f'      To sync to agentmemory, call:')
    print(f'        memory_save(type=\"learning\", content=..., concepts=\"{tags}\")')

# Mark as synced
data['synced'] = True
data['synced_at'] = __import__('datetime').datetime.utcnow().isoformat() + 'Z'
with open('$PENDING_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print()
print('  Flagged as synced. Next agent session will pick up via MCP tools.')
" 2>/dev/null

    echo ""
    echo "Tip: In the next agent session, run:"
    echo "  agentmemory memory_save(type=\"learning\", concepts=\"...\")"
    echo "  for each entry in .runtime/pending-sync.json"
    ;;

  *)
    echo "Usage: sync-learnings.sh [--status|--clear|sync]"
    exit 1
    ;;
esac
