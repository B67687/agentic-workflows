#!/bin/bash
# =============================================================================
# tools.sh --- Workspace tool registry
#
# Lists all agent-callable tools. Primary source is scripts/tools.toml (the
# structured manifest). Falls back to comment-header scanning when absent.
#
# Flags:
#   --json    Output JSON for machine consumption (reads tools.toml)
#   --compact Compact format (<400 tokens) for session-start injection
#
# Registry schema: scripts/tools.toml
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO_ROOT/scripts/tools.toml"
JSON_FLAG=false
COMPACT_FLAG=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON_FLAG=true ;;
    --compact) COMPACT_FLAG=true ;;
  esac
done

# ── JSON mode: parse tools.toml into JSON ──────────────────────────────────
if $JSON_FLAG; then
  if [ ! -f "$MANIFEST" ]; then
    echo '{"error":"tools.toml not found","tools":[]}'
    exit 1
  fi
  # Use Python's tomllib (3.11+) or tomli for structured parsing
  python3 -c "
import json, sys
try:
    import tomllib
except ImportError:
    import tomli as tomllib
with open('$MANIFEST', 'rb') as f:
    data = tomllib.load(f)
# [[tool]] creates an array of tables under key 'tool'
tool_entries = data.get('tool', [])
if not isinstance(tool_entries, list):
    tool_entries = [tool_entries]
tools = []
for tool in tool_entries:
    entry = {
        'name': tool.get('name', 'unknown'),
        'description': tool.get('description', ''),
        'category': tool.get('category', 'uncategorized'),
        'path': tool.get('path', ''),
        'type': tool.get('type', 'script')
    }
    if 'phases' in tool:
        entry['phases'] = tool['phases']
    if 'quality_gates' in tool:
        entry['quality_gates'] = tool['quality_gates']
    if 'inputs' in tool:
        entry['inputs'] = {k: v for k, v in tool['inputs'].items()}
    tools.append(entry)
result = {
    'schema_version': data.get('registry', {}).get('version', '1.0'),
    'tool_count': len(tools),
    'tools': tools
}
print(json.dumps(result, indent=2))
" 2>/dev/null || {
    echo '{"error":"failed to parse tools.toml","tools":[]}'
    exit 1
}
  exit 0
fi

# ── TOML available: human-readable with categories ─────────────────────────
if [ -f "$MANIFEST" ]; then
  COMPACT_VAL=$($COMPACT_FLAG && echo "True" || echo "False")
  python3 -c "
import sys
COMPACT = $COMPACT_VAL
try:
    import tomllib
except ImportError:
    import tomli as tomllib
with open('$MANIFEST', 'rb') as f:
    data = tomllib.load(f)
tool_entries = data.get('tool', [])
if not isinstance(tool_entries, list):
    tool_entries = [tool_entries]
categories = {}
for tool in tool_entries:
    cat = tool.get('category', 'uncategorized')
    categories.setdefault(cat, []).append(tool)
print('=== Agent Tools ===')
for cat in sorted(categories):
    if COMPACT and cat not in ('workflow', 'quality', 'session', 'agent'):
        continue
    if not COMPACT:
        print()
        print(f'  [{cat}]')
    for t in sorted(categories[cat], key=lambda x: x.get('name', '')):
        name = t.get('name', 'unknown')
        desc = t.get('description', '').split('.')[0] + '.' if t.get('description') else 'no description'
        print(f'  {name}  --- {desc}')
print()
print(f'=== {len(tool_entries)} tools, {len(categories)} categories ===')
" 2>/dev/null && exit 0
fi

# ── Fallback: comment-header scanning ──────────────────────────────────────
echo "=== Agent Tools ==="

# 1. Scripts
find "$REPO_ROOT/scripts" -maxdepth 1 -name '*.sh' -type f | sort | while read -r f; do
  name="$(basename "$f" .sh)"
  desc="$(head -5 "$f" | grep "^# " | grep -v "^# ===" | head -1 | sed 's/^# //' || true)"
  echo "  script/$name  --- ${desc:-(no description)}"
done

# 2. Commands
if [ -d "$REPO_ROOT/commands" ]; then
  find "$REPO_ROOT/commands" -name '*.md' -type f | sort | while read -r f; do
    name="$(basename "$f" .md)"
    desc="$(head -5 "$f" | grep "^#" | head -1 | sed 's/^#* *//' || true)"
    echo "  command/$name --- ${desc:-(no description)}"
  done
fi

# 3. Binary tools
if [ -d "$HOME/.local/bin" ]; then
  ls "$HOME/.local/bin" 2>/dev/null | while read -r name; do
    file="$HOME/.local/bin/$name"
    if [ -x "$file" ] && [ ! -d "$file" ]; then
      desc="$(head -3 "$file" | grep "^# " | head -1 | sed 's/^# //' || true)"
      echo "  bin/$name  --- ${desc:-custom binary}"
    fi
  done
fi

echo "=== End Tools ==="
