#!/usr/bin/env bash
# =============================================================================
# pre-compact.sh --- PreCompact lifecycle hook
# Captures working context to .cache/session-snapshot.json before conversation
# compaction. Ensures critical state survives summarization so post-compact.sh
# can restore it.
#
# Compatible with: Claude Code (via hooks.json), manual invocation, checkpoint flow
# =============================================================================

set -euo pipefail

SNAPSHOT_DIR=".cache"
SNAPSHOT_FILE="$SNAPSHOT_DIR/session-snapshot.json"
mkdir -p "$SNAPSHOT_DIR"

echo "=== Pre-Compaction: Saving Session Snapshot ==="

# --- Git state ---
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
DIRTY_COUNT=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
DIRTY_FILES=$(git status --short 2>/dev/null | cut -c4- | head -20 | tr '\n' ';' | sed 's/;$//')

# --- Session task state ---
TASK_NAME=""
TASK_STATUS=""
if [ -f "session-state.json" ]; then
    TASK_NAME=$(python3 -c "
import json
try:
    s = json.load(open('session-state.json'))
    t = s.get('currentTask', {})
    print(t.get('name', ''))
except: pass
" 2>/dev/null || echo "")
    TASK_STATUS=$(python3 -c "
import json
try:
    s = json.load(open('session-state.json'))
    t = s.get('currentTask', {})
    print(t.get('status', ''))
except: pass
" 2>/dev/null || echo "")
fi

# --- Relative file modification times ---
FILES_CHANGED=""
if [ "$DIRTY_COUNT" -gt 0 ]; then
    FILES_CHANGED=$(git diff --name-only 2>/dev/null | head -20 | tr '\n' ';' | sed 's/;$//')
fi

# --- Build snapshot JSON ---
TIMESTAMP=$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")
SNAPSHOT_JSON=$(python3 -c "
import json
snap = {
    'timestamp': '$TIMESTAMP',
    'branch': '$BRANCH',
    'dirty_count': $DIRTY_COUNT,
    'dirty_files': '${DIRTY_FILES}'.split(';') if '${DIRTY_FILES}' else [],
    'files_changed': '${FILES_CHANGED}'.split(';') if '${FILES_CHANGED}' else [],
    'task_name': '$TASK_NAME',
    'task_status': '$TASK_STATUS',
    'note': 'Session snapshot before compaction --- restore with post-compact.sh'
}
print(json.dumps(snap, indent=2))
" 2>/dev/null || echo '{"error": "failed to build snapshot"}')

echo "$SNAPSHOT_JSON" > "$SNAPSHOT_FILE"
echo "Snapshot saved to $SNAPSHOT_FILE"
echo "  Branch: $BRANCH"
echo "  Dirty files: $DIRTY_COUNT"
if [ -n "$TASK_NAME" ]; then
    echo "  Task: $TASK_NAME [$TASK_STATUS]"
fi
echo "=== Snapshot Complete ==="
