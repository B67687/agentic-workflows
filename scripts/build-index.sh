#!/usr/bin/env bash
# =============================================================================
# build-index.sh — Build BM25 text index for the workspace
# =============================================================================
# Usage: bash ./scripts/build-index.sh [root-dir]
#
# Scans all text files in the workspace, builds a BM25 search index,
# and saves it to .cache/bm25/.
#
# Dependencies: bm25s (pip install bm25s)
# =============================================================================

set -euo pipefail

ROOT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- Dependency check ----
python3 -c "import bm25s" 2>/dev/null || {
    echo "ERROR: bm25s is not installed." >&2
    echo "  Run: pip install bm25s" >&2
    exit 1
}

echo "=== Building BM25 index ==="
echo "  Root: $ROOT"
echo ""

exec python3 "$SCRIPT_DIR/build-index.py" "$ROOT"
