#!/usr/bin/env bash
# cleanup-deprecated.sh — Remove deprecated files from topic repos
#
# Removes session-state.json, history-index.md, history-full-detailed.md
# from all topic repos (they were repo-owned bootstrap entries, now removed
# from the propagation contract).
#
# Usage: bash scripts/tools/cleanup-deprecated.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source the propagation contract to find sibling repos
source "$REPO_ROOT/scripts/propagation-contract.sh"

# Find topic folders
HUB_NAME="$(basename "$REPO_ROOT")"
PARENT="$(dirname "$REPO_ROOT")"

REMOVED=0
SKIPPED=0

for topic_dir in "$PARENT"/*/; do
  topic_name="$(basename "$topic_dir")"
  [[ "$topic_name" == "$HUB_NAME" ]] && continue
  [[ "$topic_name" == .* ]] && continue
  [[ ! -f "$topic_dir/AGENTS.md" ]] && continue

  # Remove deprecated files
  for f in "session-state.json" "archive/history-index.md" "archive/history-full-detailed.md"; do
    target="$topic_dir/$f"
    if [[ -f "$target" ]]; then
      rm -f "$target"
      echo "  Removed $topic_name/$f"
      REMOVED=$((REMOVED + 1))
    fi
  done
done

echo ""
echo "Done: $REMOVED files removed across all topic repos"
