#!/usr/bin/env bash
# =============================================================================
# repo-map.sh --- Build a compact, ranked map of the workspace (tree-sitter)
# =============================================================================
# Usage: bash ./scripts/repo-map.sh [root-dir]
#
# Uses tree-sitter to extract symbols, build a dependency graph, run PageRank,
# and output a token-budget-aware, importance-ranked repo map.
#
# Options:
#   [root-dir]         Default: current directory
#   --max-tokens N     Target output token count (default: 2048)
#   --no-headings      Skip markdown heading extraction
#   --no-symbols       Skip code symbol extraction
#   --help, -h         Show this help
#
# Examples:
#   bash ./scripts/repo-map.sh
#   bash ./scripts/repo-map.sh /path/to/project --max-tokens 1024
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- Help ----
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: bash ./scripts/repo-map.sh [root-dir] [options]"
  echo ""
  echo "Creates a compact, ranked repo map using tree-sitter + PageRank."
  echo ""
  echo "Options:"
  echo "  [root-dir]             Default: current directory"
  echo "  --max-tokens N         Target output token count (default: 2048)"
  echo "  --no-headings          Skip markdown heading extraction"
  echo "  --no-symbols           Skip code symbol extraction"
  echo "  --help, -h             Show this help"
  echo ""
  echo "Examples:"
  echo "  bash ./scripts/repo-map.sh"
  echo "  bash ./scripts/repo-map.sh /path/to/project --max-tokens 1024"
  exit 0
fi

# Delegate to Python
exec python3 "$SCRIPT_DIR/repo-map.py" "$@"
