#!/usr/bin/env bash
# =============================================================================
# product-think.sh --- Product Thinker companion
#
# Structured product decision framework. Covers build-vs-buy, UX analysis,
# and competitive research.
#
# Usage: bash ./scripts/product-think.sh evaluate "<question>"
#        bash ./scripts/product-think.sh competitive "<product>"
# =============================================================================
set -euo pipefail
MODE="${1:-evaluate}"; shift 2>/dev/null || true
case "$MODE" in
  evaluate)
    echo "# Product Evaluation: $*"
    echo "## Problem"
    echo "- Who is affected?"
    echo "- What is the pain point?"
    echo "- How do we know this is real?"
    echo ""
    echo "## Options"
    echo "| Option | Effort | Impact | Risk |"
    echo "|--------|--------|--------|------|"
    echo "| Build  |        |        |      |"
    echo "| Buy    |        |        |      |"
    echo "| Skip   |        |        |      |"
    echo ""
    echo "## Recommendation"
    echo "- Decision:"
    echo "- Rationale:"
    ;;
  competitive)
    echo "# Competitive Analysis: $*"
    echo "| Dimension | Us | Competitor |"
    echo "|-----------|----|------------|"
    echo "| UX        |    |            |"
    echo "| Features  |    |            |"
    echo "| Pricing   |    |            |"
    echo "| Speed     |    |            |"
    echo "| Trust     |    |            |"
    ;;
  *) echo "Usage: $0 {evaluate|competitive}" >&2; exit 1 ;;
esac
