#!/usr/bin/env bash
# map-current-state.sh — Map codebase state relevant to the current task
# Writes JSON to stdout.

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_FILE="$REPO_ROOT/workflow-state.json"

# Get task summary from context
QUERY=""
if [[ -f "$STATE_FILE" ]]; then
  QUERY=$(
    python3 <<'PYEOF'
import json
with open('workflow-state.json') as f:
    s = json.load(f)
ctx = s.get('context', {})
print(ctx.get('task_summary', ctx.get('query', '')))
PYEOF
  )
fi

# Collect directory structure
DIR_STRUCTURE=$(find . -maxdepth 2 -type d \
  -not -path './node_modules/*' \
  -not -path './.git/*' \
  -not -path './archive/*' 2>/dev/null | head -40)

# Count files by type
FILE_COUNTS=$(
  python3 <<'PYEOF'
import os, json
extensions = {}
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in ('node_modules', '.git', 'archive')]
    for f in files:
        ext = os.path.splitext(f)[1]
        extensions[ext] = extensions.get(ext, 0) + 1
print(json.dumps(dict(sorted(extensions.items(), key=lambda x: -x[1])[:15])))
PYEOF
)

# Build JSON output using a temp Python script
TMP_SCRIPT=$(mktemp /tmp/map-state-XXXXXX.py)
cat >"$TMP_SCRIPT" <<PYEOF
import json

dirs_raw = """$DIR_STRUCTURE"""
dirs = [d.strip() for d in dirs_raw.strip().split('\n') if d.strip()]

output = {
    'query': """$QUERY""",
    'file_counts': $FILE_COUNTS,
    'top_dirs': dirs,
    'repo_map_available': False
}
print(json.dumps(output, indent=2))
PYEOF

python3 "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"
