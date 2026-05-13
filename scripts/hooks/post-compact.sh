#!/usr/bin/env bash
# =============================================================================
# post-compact.sh --- PostCompact lifecycle hook
# Fires after conversation compaction to remind the agent to restore working
# context from session-state.json and the snapshot saved by pre-compact.sh.
#
# Compatible with: Claude Code (via hooks.json), manual invocation
# =============================================================================

set -euo pipefail

echo "=== Context Restored After Compaction ==="

STATE_FILE="session-state.json"
SNAPSHOT_FILE=".cache/session-snapshot.json"

# --- Restore from snapshot ---
if [ -f "$SNAPSHOT_FILE" ]; then
    echo ""
    echo "Previous session state (from snapshot):"
    python3 -c "
import json
try:
    snap = json.load(open('$SNAPSHOT_FILE'))
    for k, v in snap.items():
        if k in ('note', 'dirty_files', 'files_changed'):
            continue
        if isinstance(v, list) and len(v) > 0:
            print(f'  {k}: {\"; \".join(v)}')
            continue
        if v:
            print(f'  {k}: {v}')
    print()
    print(f'  Snapshot time: {snap.get(\"timestamp\", \"unknown\")}')
except Exception as e:
    print(f'  (failed to parse: {e})')
" 2>/dev/null || echo "  (snapshot unreadable)"
    echo ""
    echo "->  Read session-state.json to restore full working context."
    echo "   Then re-read any files being actively worked on."
else
    echo ""
    echo "  No pre-compaction snapshot found."
    if [ -f "$STATE_FILE" ]; then
        echo "  ->  Read session-state.json to recover context."
    else
        echo "  ->  No session-state.json either --- start fresh."
    fi
fi

echo "========================================="
