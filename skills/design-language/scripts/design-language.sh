#!/usr/bin/env bash
# Design language capture and review template.
# Usage: bash ./scripts/design-language.sh capture "<product>"
set -euo pipefail
case "${1:-capture}" in
  capture)
    echo "# Design Language: $2"
    echo "## Principles"
    echo "- Principle 1:"
    echo "- Principle 2:"
    echo ""
    echo "## Visual Patterns"
    echo "| Element | Pattern | Source |"
    echo "|---------|---------|--------|"
    echo "| Color   |         |        |"
    echo "| Typography |      |        |"
    echo "| Spacing |         |        |"
    echo "| Motion  |         |        |"
    ;;
  review)
    echo "# Design Review: $2"
    echo "| Pattern | Expected | Actual | Issue |"
    echo "|---------|----------|--------|-------|"
    echo "|         |          |        |       |"
    ;;
  *) echo "Usage: $0 {capture|review}" >&2; exit 1 ;;
esac
