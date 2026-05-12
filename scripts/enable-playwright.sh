#!/bin/bash
# =============================================================================
# enable-playwright.sh — Toggle Playwright MCP on/off
#
# Playwright MCP is disabled by default (saves ~200-500MB RAM per session).
# Run this to enable it temporarily for browser automation tasks.
#
# Usage:
#   bash ./scripts/enable-playwright.sh on   # enable for current session
#   bash ./scripts/enable-playwright.sh off  # disable
#   bash ./scripts/enable-playwright.sh      # show current status
# =============================================================================
set -euo pipefail

CONFIG="$HOME/.config/opencode/opencode.jsonc"
ACTION="${1:-status}"

case "$ACTION" in
  on)
    sed -i 's/"enabled": false$/"enabled": true/' "$CONFIG"
    echo "Playwright MCP enabled. Restart OpenCode session for changes to take effect."
    ;;
  off)
    sed -i 's/"enabled": true$/"enabled": false/' "$CONFIG"
    echo "Playwright MCP disabled."
    ;;
  status)
    # Find the playwright section and check its enabled state
    # (sed only: works on JSONC with comments)
    STATUS=$(sed -n '/"playwright":/,/^    }/{
      /"enabled":/{
        s/.*"enabled": *//
        s/,//
        s/ *//
        p
      }
    }' "$CONFIG" 2>/dev/null || echo "false")
    if [ "$STATUS" = "true" ]; then
      echo "Playwright MCP: ON"
    else
      echo "Playwright MCP: OFF (default)"
    fi
    echo "Toggle: bash ./scripts/enable-playwright.sh on|off"
    ;;
esac
