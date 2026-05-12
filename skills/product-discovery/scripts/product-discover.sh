#!/usr/bin/env bash
# Product discovery hypothesis template.
# Usage: bash ./scripts/product-discover.sh hypothesis "<idea>"
set -euo pipefail
case "${1:-hypothesis}" in
  hypothesis)
    echo "# Discovery Hypothesis"
    echo "## Hypothesis"
    echo "We believe that **$2**"
    echo ""
    echo "## Evidence gates"
    echo "- [ ] Gate 1: <cheapest test to validate>"
    echo "- [ ] Gate 2: <next level of evidence>"
    echo "- [ ] Gate 3: <strongest evidence before build>"
    echo ""
    echo "## Success criteria"
    echo "- Metric:"
    echo "- Threshold:"
    echo "- Timeframe:"
    echo ""
    echo "## Riskiest assumption"
    echo "- <What must be true for this to work?>"
    ;;
  *) echo "Usage: $0 hypothesis \"<idea>\"" >&2; exit 1 ;;
esac
