#!/usr/bin/env bash
# workflow-graph.sh --- Generate Workflow DAG (HTML + SVG)
# Shows all workflows: phase pipeline, propagation, agent dispatch, decision gates, etc.
# Usage:
#   bash scripts/workflow-graph.sh              # both HTML + SVG
#   bash scripts/workflow-graph.sh output.html   # custom HTML + default SVG
#   bash scripts/workflow-graph.sh --svg-only    # SVG only (for README update)
#   bash scripts/workflow-graph.sh --inline      # inline SVG to clipboard (WSL)

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || { echo "ERROR: cannot cd to $REPO_ROOT"; exit 1; }

if [[ "${1:-}" == "--inline" ]]; then
    # Generate SVG and show inline HTML snippet for README
    python3 scripts/workflow-graph.py --svg-only
    echo ""
    echo "--- Copy this into README.md ---"
    echo ""
    echo '<p align="center">'
    echo '  <a href="https://b67687.github.io/agentic-workflows/workflow-graph.html">'
    echo '    <picture>'
    echo '      <source media="(prefers-color-scheme: dark)" srcset="workflow-graph.svg">'
    echo '      <img src="workflow-graph.svg" width="100%" alt="Workflow Diagram" style="max-width:1100px;">'
    echo '    </picture>'
    echo '  </a>'
    echo '  <br><sub><a href="https://b67687.github.io/agentic-workflows/workflow-graph.html" target="_blank">Open interactive version ↗</a> (click nodes for details, expand gates to see decision chains)</sub>'
    echo '</p>'
    echo ""
    echo "--- End snippet ---"
else
    echo "🧩 Building Workflow DAG..."
    python3 scripts/workflow-graph.py "$@"
    # Deploy interactive HTML to docs/ for GitHub Pages
    cp workflow-graph.html docs/workflow-graph.html 2>/dev/null
    echo "📄 Deployed to docs/workflow-graph.html (GitHub Pages)"
    echo ""
    echo "📄 To update README: bash scripts/workflow-graph.sh --inline"
fi
