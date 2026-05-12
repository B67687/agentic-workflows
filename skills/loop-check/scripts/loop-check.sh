#!/usr/bin/env bash
# Feedback loop assessment template.
# Usage: bash ./scripts/loop-check.sh assess
set -euo pipefail
case "${1:-assess}" in
  assess)
    echo "# Feedback Loop Assessment"
    echo "## Current Loops"
    echo "| Loop | Type | Duration | Manual? | Tooling |"
    echo "|------|------|----------|---------|--------|"
    echo "| Test | verify |        |         |        |"
    echo "| Lint | verify |        |         |        |"
    echo "| Deploy | deliver |      |         |        |"
    echo ""
    echo "## Gaps"
    echo "- <what's manual that should be automated>"
    echo ""
    echo "## Leverage Points"
    echo "- <one fix with highest impact>"
    ;;
  *) echo "Usage: $0 assess" >&2; exit 1 ;;
esac
