#!/bin/bash
# =============================================================================
# task-retrospect.sh --- Structured post-task reflection
#
# Hermes-style self-improvement loop for our workspace.
# After meaningful work, captures what was learned so the next session benefits.
# Call at end of a checkout/commit, after a completed task, or at session end.
#
# Usage:
#   bash ./scripts/task-retrospect.sh                        # interactive (stdin)
#   bash ./scripts/task-retrospect.sh "got stuck on X fix Y"  # direct
#   bash ./scripts/task-retrospect.sh --session-end           # summarize session to history files
#   bash ./scripts/task-retrospect.sh --help                  # this help
#
# Stores to:
#   1. .learnings.jsonl  --- always (persistent, searchable)
#   2. buglog.json       --- only when --type bug or "bug" in tags
#   3. agentmemory       --- if MCP available (enables cross-session semantic search)
#
# Exit codes:
#   0 --- insight captured
#   0 --- nothing to learn (exit silently)
#   1 --- bad args
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || { echo "ERROR: cannot cd to $REPO_ROOT"; exit 1; }

# --- Parse args ---
INSIGHT=""
TAGS="general"
TYPE="learning"
MODE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      # Extract comment header (from after #! to before first code line)
      awk '/^#!/{p=1;next} /^[^#]/ && p{exit} p{print}' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    --session-end)
      MODE="session-end"
      ;;
    --type|--type=*)
      if [[ "$1" == --type=* ]]; then TYPE="${1#*=}"; else shift; TYPE="${1:-}"; fi
      ;;
    --tags|--tags=*)
      if [[ "$1" == --tags=* ]]; then TAGS="${1#*=}"; else shift; TAGS="${1:-}"; fi
      ;;
    --to-json)
      MODE="to-json"
      ;;
    *)
      if [ -z "$INSIGHT" ]; then
        INSIGHT="$1"
      elif [ "$TAGS" = "general" ]; then
        TAGS="$1"
      fi
      ;;
  esac
  shift
done

# --- Interactive mode (no args, stdin is a tty) ---
if [ "$MODE" = "session-end" ]; then
  # --- Session end mode: auto-document history from session-state.json ---
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  DATE_ONLY=$(date -u +%Y-%m-%d)
  
  # Read whatChanged from session-state.json
  WC_ITEMS=$(python3 -c "
import json
with open('$REPO_ROOT/session-state.json') as f:
    s = json.load(f)
wc = s.get('whatChanged', [])
task = s.get('currentTask', {}).get('name', 'unspecified work')
for w in wc[:15]:
    print(f\"- {w}\")
" 2>/dev/null || echo "- unspecified changes")
  
  # Count commits since last history entry
  LAST_HIST=$(git log -1 --format='%H' -- archive/history-full-detailed.md 2>/dev/null || echo "")
  if [ -n "$LAST_HIST" ]; then
    HIST_COMMITS=$(git log --oneline "${LAST_HIST}..HEAD" 2>/dev/null | wc -l || echo 0)
  else
    HIST_COMMITS=0
  fi
  HIST_COMMITS=${HIST_COMMITS:-0}
  
  echo "=== Session End Documentation ==="
  echo "  Commits since last history entry: $HIST_COMMITS"
  echo ""
  
  # Generate summary from session-state.json
  SESSION_TITLE=$(python3 -c "
import json
with open('$REPO_ROOT/session-state.json') as f:
    s = json.load(f)
print(s.get('currentTask', {}).get('name', 'unspecified work'))
")
  
  echo "Session title: $SESSION_TITLE"
  echo "Commits since last history entry: $HIST_COMMITS"
  echo "whatChanged entries: $(echo "$WC_ITEMS" | wc -l)"
  echo ""
  
  read -r -p "Accept? [Y/n]: " CONFIRM
  if [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "N" ]; then
    read -r -p "Custom title: " SESSION_TITLE
  fi
  
  # --- Prepend to history-full-detailed.md (top, newest-first) ---
  HIST_FILE="$REPO_ROOT/archive/history-full-detailed.md"
  if [ -f "$HIST_FILE" ]; then
    WC_TMP=$(mktemp)
    echo "$WC_ITEMS" > "$WC_TMP"
    
    python3 -c "
import re
with open('$HIST_FILE') as f:
    content = f.read()
with open('$WC_TMP') as f:
    wc = f.read()

m = re.search(r'\n# 2026-05-', content)
insert_at = m.start() + 1 if m else len(content)

new_entry = '\n\n# $DATE_ONLY --- $SESSION_TITLE\n\n**Session end:** $TIMESTAMP\n**Commits since last entry:** $HIST_COMMITS\n\n' + wc + '\n'

new_content = content[:insert_at] + new_entry + content[insert_at:]
with open('$HIST_FILE', 'w') as f:
    f.write(new_content)
" 2>/dev/null || true
    rm -f "$WC_TMP"
    echo "  ✓ Prepended to archive/history-full-detailed.md"
  fi
  
  # --- Prepend to history-index.md (top, newest-first) ---
  IDX_FILE="$REPO_ROOT/archive/history-index.md"
  if [ -f "$IDX_FILE" ]; then
    HEADER=$(head -6 "$IDX_FILE")
    REST=$(tail -n +7 "$IDX_FILE")
    
    NEXT_PHASE=$(echo "$REST" | grep -oP 'Phase \K\d+' | head -1 || echo 1)
    NEXT_PHASE=$((NEXT_PHASE + 1))
    
    TMP=$(mktemp)
    echo "$HEADER" > "$TMP"
    echo "" >> "$TMP"
    echo "## Phase ${NEXT_PHASE}: ${SESSION_TITLE} (${DATE_ONLY})" >> "$TMP"
    echo "$WC_ITEMS" | head -6 | sed 's/^P[0-4]: //' >> "$TMP" 2>/dev/null || true
    echo "" >> "$TMP"
    echo "$REST" >> "$TMP"
    mv "$TMP" "$IDX_FILE" 2>/dev/null || true
    echo "  ✓ Prepended Phase ${NEXT_PHASE} to archive/history-index.md"
  fi
  
  echo "  Done. Session documented."
  exit 0
fi

# --- Interactive mode (no args, stdin is a tty) ---
if [ -z "$INSIGHT" ] && [ -t 0 ]; then
  echo "=== Post-task Retrospect ==="
  echo "(Press Enter with empty answer to skip)"
  echo ""
  read -r -p "What was attempted? " ATTEMPTED
  [ -z "$ATTEMPTED" ] && echo "Nothing to learn." && exit 0
  read -r -p "What went wrong? (or 'nothing') " WRONG
  read -r -p "What to avoid next time? (or 'nothing') " AVOID
  read -r -p "Tags? (comma-sep, default: general) " TAGS_INPUT
  [ -n "$TAGS_INPUT" ] && TAGS="$TAGS_INPUT"

  INSIGHT="Attempted: $ATTEMPTED"
  [ "$WRONG" != "nothing" ] && [ -n "$WRONG" ] && INSIGHT="$INSIGHT | Issue: $WRONG"
  [ "$AVOID" != "nothing" ] && [ -n "$AVOID" ] && INSIGHT="$INSIGHT | Avoid: $AVOID"

  if echo "$WRONG $AVOID $TAGS" | grep -qi "bug\|error\|fail\|crash\|fix"; then
    TYPE="bug"
    TAGS="$TAGS,bug"
  fi

# --- Stdin mode (piped input) ---
elif [ -z "$INSIGHT" ] && [ ! -t 0 ]; then
  read -r INSIGHT
  [ -z "$INSIGHT" ] && exit 0
fi

# --- Skip empty insights ---
if [ -z "$INSIGHT" ]; then
  exit 0
fi

# --- Determine if this is a bug (auto-detect) ---
if [ "$TYPE" != "bug" ] && echo "$INSIGHT $TAGS" | grep -qi "bug\|error\|fail\|crash\|fix\|break\|regression\|rollback"; then
  TYPE="bug"
  [ ",$TAGS," != *",bug"* ] && TAGS="$TAGS,bug"
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# === 1. Always save to .learnings.jsonl ===
LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"

# Escape the insight for JSON (strip trailing whitespace, then stringify)
TRIMMED=$(echo "$INSIGHT" | sed 's/[[:space:]]*$//')
ESCAPED_INSIGHT=$(printf '%s' "$TRIMMED" | jq -Rs . 2>/dev/null || echo "\"$TRIMMED\"")
ENTRY="{\"ts\":\"$TIMESTAMP\",\"insight\":$ESCAPED_INSIGHT,\"tags\":\"$TAGS\",\"type\":\"$TYPE\",\"source\":\"retrospect\"}"
echo "$ENTRY" >> "$LEARNINGS_FILE"
LEARNINGS_COUNT=$(wc -l < "$LEARNINGS_FILE" | tr -d ' ')

echo "  ✓ Learning saved to .learnings.jsonl (#$LEARNINGS_COUNT): ${INSIGHT:0:60}..."

# === 2. If bug type, also save to buglog.json ===
if [ "$TYPE" = "bug" ]; then
  if [ -f "$REPO_ROOT/buglog.json" ]; then
    # Use python for safe JSON manipulation
    python3 -c "
import json, sys
with open('$REPO_ROOT/buglog.json') as f:
    log = json.load(f)
log['bugs'].append({
    'ts': '$TIMESTAMP',
    'summary': $(echo "$INSIGHT" | jq -Rs .),
    'tags': '$TAGS',
    'source': 'retrospect'
})
with open('$REPO_ROOT/buglog.json', 'w') as f:
    json.dump(log, f, indent=2)
"
    echo "  ✓ Bug pattern saved to buglog.json"
  fi
fi

# === 3. Try ruflo hooks post-task (best-effort, don't fail) ===
if command -v ruflo &>/dev/null; then
  TASK_ID="retrospect-$(echo "$TIMESTAMP" | sha256sum 2>/dev/null | cut -c1-12 || echo "$TIMESTAMP")"
  SUCCESS="true"
  if echo "$INSIGHT $TAGS" | grep -qi "fail\|error\|broken\|wrong\|issue\|blocked"; then
    SUCCESS="false"
  fi
  ruflo hooks post-task \
    --task-id "$TASK_ID" \
    --description "$(echo "$INSIGHT" | head -c 200)" \
    --success "$SUCCESS" \
    --quality 0.8 \
    --agent "retrospect" \
    2>/dev/null || true
  echo "  ✓ Pattern recorded to ruflo memory"
fi

# === 4. Try agentmemory (best-effort, don't fail) ===
# Check if the MCP server is running by looking for node agentmemory
if command -v npx &>/dev/null && npx --yes @agentmemory/mcp --help &>/dev/null 2>&1; then
  # Save via memory_save --- can't call MCP from bash directly
  # Instead note it in the learnings file for the next agent to pick up
  echo "  ℹ  Run 'agentmemory memory_save' with content from .learnings.jsonl to persist cross-session"
fi

# === 5. Track last retrospect in session-state.json ===
if [ -f "$REPO_ROOT/session-state.json" ]; then
  python3 -c "
import json
with open('$REPO_ROOT/session-state.json') as f:
    s = json.load(f)
s['lastRetrospect'] = '$TIMESTAMP'
# Track learnings count for easy reference
s['learningsCount'] = $LEARNINGS_COUNT
with open('$REPO_ROOT/session-state.json', 'w') as f:
    json.dump(s, f, indent=2)
" 2>/dev/null || true
fi

echo "  Done."
