#!/bin/bash
# =============================================================================
# serve-mcp.sh --- MCP stdio server launcher for agentic-workflows
#
# Launches the MCP server that exposes tools.toml and skills.toml as MCP
# tools and resources. Compatible with DeepSeek-TUI, OpenCode, Claude Code,
# and any MCP client.
#
# MCP protocol: JSON-RPC 2.0 over stdio
# Schema version: 2025-11-25
#
# Usage:
#   bash scripts/serve-mcp.sh              # stdio mode (for MCP clients)
#   bash scripts/serve-mcp.sh --check      # validate config, print summary
#   bash scripts/serve-mcp.sh --mcp-add-self  # print MCP config block
#
# For DeepSeek-TUI integration, add to ~/.deepseek/mcp.json:
#   {
#     "servers": {
#       "agentic-workflows": {
#         "command": "bash",
#         "args": ["<path>/scripts/serve-mcp.sh"],
#         "env": {},
#         "disabled": false
#       }
#     }
#   }
#
# For OpenCode integration, add to opencode.jsonc mcp section.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

case "${1:-}" in
  --check)
    exec python3 "$SCRIPT_DIR/serve-mcp.py" --check
    ;;

  --mcp-add-self)
    # Print the MCP config block for integration
    SELF_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    echo "Add this to your MCP config (e.g., ~/.deepseek/mcp.json):"
    echo ""
    echo '{'
    echo '  "servers": {'
    echo '    "agentic-workflows": {'
    echo "      \"command\": \"bash\","
    echo "      \"args\": [\"$SELF_PATH\"],"
    echo '      "env": {},'
    echo '      "disabled": false'
    echo '    }'
    echo '  }'
    echo '}'
    echo ""
    echo "Then run: deepseek-tui mcp validate"
    ;;

  *)
    exec python3 "$SCRIPT_DIR/serve-mcp.py"
    ;;
esac
