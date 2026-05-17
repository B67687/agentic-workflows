#!/usr/bin/env bash
# map-current-state.sh — Map codebase state relevant to the current task
#
# Uses repo-map, grep, and file discovery to build a compact map.
# Outputs JSON with the current codebase structure relevant to the task.
#
# Usage: bash scripts/workflow/map-current-state.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

STATE_FILE="$REPO_ROOT/workflow-state.json"

# Get task keywords from context
QUERY=""
if [[ -f "$STATE_FILE" ]]; then
  QUERY=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
ctx = s.get('context', {})
print(ctx.get('task_summary', ctx.get('query', '')))
")
fi

# Run repo-map for structure
REPO_MAP_OUTPUT=""
if [[ -f "$REPO_ROOT/scripts/repo-map.sh" ]]; then
  REPO_MAP_OUTPUT=$(bash "$REPO_ROOT/scripts/repo-map.sh" --max-tokens 512 2>/dev/null || echo "repo-map unavailable")
fi

# Collect directory structure
DIR_STRUCTURE=$(find "$REPO_ROOT" -maxdepth 2 -type d \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/archive/*' 2>/dev/null | head -40 | sed "s|$REPO_ROOT/||")

# Count files by type
FILE_COUNTS=$(python3 -c "
import os, json
extensions = {}
repo = '$REPO_ROOT'
for root, dirs, files in os.walk(repo):
    dirs[:] = [d for d in dirs if d not in ('node_modules', '.git', 'archive')]
    for f in files:
        ext = os.path.splitext(f)[1]
        extensions[ext] = extensions.get(ext, 0) + 1
print(json.dumps(dict(sorted(extensions.items(), key=lambda x: -x[1])[:15])))
")

cat <<EOF
{
  "query": "$QUERY",
  "file_counts": $FILE_COUNTS,
  "top_dirs": $(echo "$DIR_STRUCTURE" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))"),
  "repo_map_available": $([[ -n "$REPO_MAP_OUTPUT" ]] && echo "true" || echo "false")
}
EOF
