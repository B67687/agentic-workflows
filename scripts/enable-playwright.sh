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
    # Replace 'false' with 'true' on the enabled line within the playwright block
    sed -i '/"playwright":/,/^    }/s/"enabled": false/"enabled": true/' "$CONFIG"
    echo "Playwright MCP enabled. Restart OpenCode session for changes to take effect."
    ;;
  off)
    sed -i '/"playwright":/,/^    }/s/"enabled": true/"enabled": false/' "$CONFIG"
    echo "Playwright MCP disabled."
    ;;
  status)
    # Check the enabled line within the playwright block
    STATUS=$(sed -n '/"playwright":/,/^    }/p' "$CONFIG" | grep '"enabled"' | grep -q true && echo "true" || echo "false")
    if [ "$STATUS" = "true" ]; then
      echo "Playwright MCP: ON"
    else
      echo "Playwright MCP: OFF (default)"
    fi
    echo "Toggle: bash ./scripts/enable-playwright.sh on|off"
    ;;
esac
