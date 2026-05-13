#!/usr/bin/env bash
# =============================================================================
# mcp-brave-search.sh --- MCP server wrapper for Brave Search
#
# Wraps @brave/brave-search-mcp-server with env var validation.
# Provides: brave_web_search, brave_news_search, brave_video_search,
#           brave_image_search, brave_local_search
#
# Authentication: BRAVE_API_KEY env var (free tier: 2,000 queries/month)
# Sign up: https://brave.com/search/api/
# =============================================================================
set -euo pipefail

MCP_SERVER="/home/namikaz/.local/share/mcp/node_modules/@brave/brave-search-mcp-server/dist/index.js"

if [[ ! -f "$MCP_SERVER" ]]; then
  echo "Error: Brave Search MCP server not found at $MCP_SERVER" >&2
  echo "Run: npm install --prefix=/home/namikaz/.local/share/mcp @brave/brave-search-mcp-server" >&2
  exit 1
fi

if [[ -z "${BRAVE_API_KEY:-}" ]]; then
  cat >&2 <<'EOF'
Error: BRAVE_API_KEY environment variable is not set.

The Brave Search MCP server requires a free API key.
Get one at: https://brave.com/search/api/
Free tier: 2,000 queries/month, no credit card needed.

Set it in your shell profile:
  export BRAVE_API_KEY="your_key_here"
EOF
  exit 1
fi

exec node "$MCP_SERVER"
