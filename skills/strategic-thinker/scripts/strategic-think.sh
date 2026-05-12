#!/usr/bin/env bash
# Strategic analysis template.
# Usage: bash ./scripts/strategic-think.sh analyze "<question>"
set -euo pipefail
case "${1:-analyze}" in
  analyze)
    echo "# Strategic Analysis"
    echo "## Framing"
    echo "- What level does this operate at? (product/architecture/org)"
    echo "- Who is the decision-maker?"
    echo "- What is the time horizon?"
    echo ""
    echo "## Tradeoffs"
    echo "| Approach | Pros | Cons | Risiko |"
    echo "|----------|------|------|-------|"
    echo "|          |      |      |       |"
    echo ""
    echo "## Recommendation"
    echo "- Preferred approach:"
    echo "- Key assumptions:"
    ;;
  *) echo "Usage: $0 analyze \"<question>\"" >&2; exit 1 ;;
esac
