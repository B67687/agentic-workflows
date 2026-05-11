#!/usr/bin/env bash
# =============================================================================
# repo-map.sh — Build a compact, ranked map of the workspace (tree-sitter)
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

# Delegate to Python
exec python3 "$SCRIPT_DIR/repo-map.py" "$@"
