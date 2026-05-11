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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- Help ----
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: bash ./scripts/build-index.sh [root-dir]"
  echo ""
  echo "Builds a BM25 text index for the workspace (saved to .cache/bm25/)."
  echo "Default root-dir: current directory"
  echo ""
  echo "Dependencies: pip install bm25s"
  exit 0
fi

ROOT="${1:-$(pwd)}"

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
