#!/usr/bin/env bash
# Tighten loop --- harvest course-corrections into durable changes.
# Usage: bash ./scripts/tighten-loop.sh harvest "<insight>"
set -euo pipefail
case "${1:-harvest}" in
  harvest)
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "# Loop Tightening: Harvest"
    echo "## What went wrong"
    echo "- $2"
    echo ""
    echo "## Root cause"
    echo "- <why did this happen>"
    echo ""
    echo "## Fix"
    echo "- [ ] <one thing to update so this doesn't repeat>"
    echo ""
    echo "## Files to change"
    echo "- <paths>"
    echo ""
    echo "Applied: ${TIMESTAMP}"
    ;;
  *) echo "Usage: $0 harvest \"<insight>\"" >&2; exit 1 ;;
esac
