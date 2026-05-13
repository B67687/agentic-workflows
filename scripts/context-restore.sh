#!/bin/bash
# Restore working context from a saved snapshot.
# Usage: bash ./scripts/context-restore.sh [context-id]
#   Without context-id, lists available contexts.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
CONTEXT_DIR="$REPO_ROOT/.context"
CONTEXT_ID="${1:-}"

if [ ! -d "$CONTEXT_DIR" ]; then
  echo "No saved contexts found."
  exit 0
fi

if [ -z "$CONTEXT_ID" ]; then
  echo "Available contexts:"
  echo ""
  for f in $(ls -t "$CONTEXT_DIR"/*.json 2>/dev/null); do
    NAME=$(basename "$f" .json)
    SUMMARY=$(jq -r '.summary // "no summary"' "$f" 2>/dev/null || echo "unknown")
    TS=$(jq -r '.timestamp // "?"' "$f" 2>/dev/null)
    BRANCH=$(jq -r '.git.branch // "?"' "$f" 2>/dev/null)
    echo "  $NAME"
    echo "    saved: $TS"
    echo "    branch: $BRANCH"
    echo "    summary: $SUMMARY"
    echo "    restore: bash ./scripts/context-restore.sh $NAME"
    echo ""
  done
  exit 0
fi

CONTEXT_FILE="$CONTEXT_DIR/$CONTEXT_ID.json"
if [ ! -f "$CONTEXT_FILE" ]; then
  echo "Context not found: $CONTEXT_ID"
  echo "Run without arguments to list available contexts."
  exit 1
fi

echo "=== Restoring context: $CONTEXT_ID ==="
echo ""
jq -r '
  "Summary: " + (.summary // "none"),
  "Branch:  " + (.git.branch // "?") + " (" + (.git.hash // "?") + ")",
  "Saved:   " + (.timestamp // "?"),
  "",
  if .git.dirty_files_count > 0 then
    "Dirty files (" + (.git.dirty_files_count | tostring) + "):",
    (.dirty_files | .[] | "  " + .)
  else
    "Clean working tree"
  end,
  "",
  if .freeze then "Frozen to: " + .freeze else "No freeze restriction" end
' "$CONTEXT_FILE" 2>/dev/null || echo "Error reading context file."

echo ""
echo "To restore git state: git checkout $(jq -r '.git.branch // "main"' "$CONTEXT_FILE" 2>/dev/null)"
echo "To restore freeze:    bash ./scripts/freeze.sh $(jq -r '.freeze // ""' "$CONTEXT_FILE" 2>/dev/null)"