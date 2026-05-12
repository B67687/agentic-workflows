#!/usr/bin/env bash
# Browser test scenario scaffold.
# Usage: bash ./scripts/browser-test.sh scenario "<name>"
set -euo pipefail
case "${1:-scenario}" in
  scenario)
    echo "# Browser Test: $2"
    echo "## Setup"
    echo "- URL:"
    echo "- Viewport:"
    echo "- Auth:"
    echo ""
    echo "## Steps"
    echo "1. Navigate to"
    echo "2. Interact with"
    echo "3. Assert"
    echo ""
    echo "## Expected"
    echo "- <visible state, console, network>"
    echo ""
    echo "## Edge Cases"
    echo "- [ ] Loading state"
    echo "- [ ] Error state"
    echo "- [ ] Empty state"
    echo "- [ ] Slow network"
    ;;
  *) echo "Usage: $0 scenario \"<name>\"" >&2; exit 1 ;;
esac
