#!/usr/bin/env bash
# =============================================================================
# search-index.sh — Query the workspace BM25 index
# =============================================================================
# Usage: bash ./scripts/search-index.sh <query> [root-dir] [--top-k N]
#
# Returns files ranked by BM25 relevance score.  Requires a pre-built index
# (run build-index.sh first).
#
# Examples:
#   bash ./scripts/search-index.sh "find_user"
#   bash ./scripts/search-index.sh "error handling" --top-k 5
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Delegate to Python
exec python3 "$SCRIPT_DIR/search-index.py" "$@"
