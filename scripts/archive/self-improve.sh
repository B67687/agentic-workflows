#!/bin/bash
# self-improve.sh --- Learn from autonomous execution.
# Part of the autonomous runtime fork.
#
# Analyzes pipeline results to:
#   - Record what worked and what didn't
#   - Update skill prompts based on failure patterns
#   - Compact .learnings.jsonl after N completions
#   - Suggest new namedrop extractions
#
# Usage:
#   bash ./scripts/self-improve.sh --pipeline <pipeline-id> [--compact]
#   bash ./scripts/self-improve.sh --compact-only
#   bash ./scripts/self-improve.sh --status

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
PIPELINE_DIR="$REPO_ROOT/.runtime/pipeline"
AUTOPILOT_DIR="$REPO_ROOT/.runtime/autopilot"

CMD="${1:-help}"

# ---------------------------------------------------------------------------
# Analyze pipeline results
# ---------------------------------------------------------------------------
analyze() {
  local PIPELINE_ID="$1"
  local PIPELINE_FILE="$PIPELINE_DIR/$PIPELINE_ID.json"
  local AUTOPILOT_FILE="$AUTOPILOT_DIR/$PIPELINE_ID.json"

  echo "=== Self-Improvement: Analysis ==="

  if [ ! -f "$PIPELINE_FILE" ]; then
    echo "Pipeline $PIPELINE_ID not found."
    return 1
  fi

  # Count successes and failures
  local DATA
  DATA=$(python3 -c "
import json
with open('$PIPELINE_FILE') as f:
    p = json.load(f)
tasks = p.get('tasks', [])
done = [t for t in tasks if t.get('status') == 'done']
failed = [t for t in tasks if t.get('status') == 'failed']
total_attempts = sum(t.get('attempts', 1) for t in tasks)
print(f'{len(done)}|{len(failed)}|{total_attempts}')
" 2>/dev/null || echo "0|0|0")

  local DONE_COUNT=$(echo "$DATA" | cut -d'|' -f1)
  local FAIL_COUNT=$(echo "$DATA" | cut -d'|' -f2)
  local TOTAL_ATTEMPTS=$(echo "$DATA" | cut -d'|' -f3)

  echo "  Tasks done:    $DONE_COUNT"
  echo "  Tasks failed:  $FAIL_COUNT"
  echo "  Total calls:   $TOTAL_ATTEMPTS"

  # Record to learnings
  local PIPELINE_TITLE
  PIPELINE_TITLE=$(python3 -c "
import json
with open('$PIPELINE_FILE') as f:
    print(json.load(f).get('title', 'Unknown pipeline'))
" 2>/dev/null || echo "Unknown pipeline")

  echo "(self-improve) Pipeline \"$PIPELINE_TITLE\": $DONE_COUNT done, $FAIL_COUNT failed, $TOTAL_ATTEMPTS total agent calls" \
    >> "$REPO_ROOT/.learnings.jsonl"

  # Extract failure patterns
  if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "--- Failure Analysis ---"
    python3 -c "
import json
with open('$PIPELINE_FILE') as f:
    p = json.load(f)
for t in p.get('tasks', []):
    if t.get('status') == 'failed':
        attempts = t.get('attempts', 1)
        notes = t.get('retry_notes', [])
        escalations = t.get('escalations', [])
        print(f'  Task {t[\"id\"]}: {t.get(\"description\", \"?\")[:80]}')
        print(f'    Attempts: {attempts}')
        if notes:
            print(f'    Retries: {len(notes)}')
        if escalations:
            for e in escalations:
                print(f'    Escalated: {e.get(\"reason\", \"?\")}')
    print()
" 2>/dev/null || true

    # Record failure pattern
    echo "(self-improve) Failure: $FAIL_COUNT task(s) failed in pipeline \"$PIPELINE_TITLE\"" \
      >> "$REPO_ROOT/.learnings.jsonl"
  fi
}

# ---------------------------------------------------------------------------
# Compact learnings (dedup + consolidate)
# ---------------------------------------------------------------------------
compact() {
  echo "=== Self-Improvement: Compact Learnings ==="
  local LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"

  if [ ! -f "$LEARNINGS_FILE" ]; then
    echo "  No learnings file."
    return
  fi

  local PRE_COUNT POST_COUNT
  PRE_COUNT=$(wc -l < "$LEARNINGS_FILE")

  if command -v consolidate-memory.sh &>/dev/null; then
    bash "$REPO_ROOT/scripts/consolidate-memory.sh" 2>&1 | head -3 || true
  fi

  # Deduplicate
  sort "$LEARNINGS_FILE" | uniq > "$LEARNINGS_FILE.tmp"
  mv "$LEARNINGS_FILE.tmp" "$LEARNINGS_FILE"

  POST_COUNT=$(wc -l < "$LEARNINGS_FILE")
  echo "  $PRE_COUNT -> $POST_COUNT entries ($((PRE_COUNT - POST_COUNT)) removed)"
}

# ---------------------------------------------------------------------------
# Status
# ---------------------------------------------------------------------------
status() {
  echo "=== Self-Improvement: Status ==="
  local LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"

  if [ -f "$LEARNINGS_FILE" ]; then
    local COUNT
    COUNT=$(wc -l < "$LEARNINGS_FILE")
    echo "  Learnings entries: $COUNT"
    echo ""
    echo "  Recent patterns:"
    grep -oP '(?<=self-improve\)).*' "$LEARNINGS_FILE" 2>/dev/null | tail -5 || echo "  (none)"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "$CMD" in
  --pipeline)
    PIPELINE_ID="${2:-}"
    shift 2
    [ -z "$PIPELINE_ID" ] && echo "Provide --pipeline <id>" && exit 1
    analyze "$PIPELINE_ID"

    COMPACT=false
    while [ $# -gt 0 ]; do
      case "$1" in
        --compact) COMPACT=true; shift ;;
        *) shift ;;
      esac
    done
    if [ "$COMPACT" = true ]; then
      compact
    fi
    ;;

  --compact-only)
    compact
    ;;

  --status)
    status
    ;;

  help|--help|-h|*)
    echo "Usage:"
    echo "  bash ./scripts/self-improve.sh --pipeline <id> [--compact]"
    echo "  bash ./scripts/self-improve.sh --compact-only"
    echo "  bash ./scripts/self-improve.sh --status"
    ;;
esac
