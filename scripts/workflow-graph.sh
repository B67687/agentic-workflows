#!/usr/bin/env bash
# workflow-graph.sh --- Generate an interactive Workflow DAG
# Shows all workflows: phase pipeline, propagation, agent dispatch, decision gates, etc.
# Usage: bash scripts/workflow-graph.sh [output.html]
# Default output: workflow-graph.html

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

OUTPUT="${1:-workflow-graph.html}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || { echo "ERROR: cannot cd to $REPO_ROOT"; exit 1; }

echo "🧩 Building Workflow DAG..."
python3 scripts/workflow-graph.py "$OUTPUT"
