#!/usr/bin/env bash
# Companion script for product-thinker skill
# Product decisions, UX evaluation, build-vs-buy, competitive analysis
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  explore <url>        Product context exploration (sub-agent prompt)
  analyze <question>   Multi-angle product analysis structure
  build-vs-buy <item>  Build-vs-buy decision framework
  ux-review <url>      UX flow review structure
  framework <name>     Load a product framework (jtbd, rice, first-principles, emotions)
  template <type>      Output template (feature-design, strategy, prioritization)
  help                 Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  explore)
    url="${1:-}"
    echo "★ Product Context Exploration ─────────────────"
    echo "Target: ${url:-"(codebase)"}"
    echo ""
    echo "Exploring to understand the PRODUCT (not technical implementation):"
    echo "1. README / CLAUDE.md — what does this product do? Who is it for?"
    echo "2. Routes / pages — what are the main user-facing features?"
    echo "3. Data models — what are the key domain concepts?"
    echo "4. User types, onboarding, billing, integrations"
    echo "─────────────────────────────────────────────────"
    ;;
  analyze)
    question="${1:-}"
    echo "★ Multi-Angle Analysis ──────────────────────"
    echo "Question: $question"
    echo ""
    echo "Lenses:"
    echo "  User:       What do they need? Where's the friction?"
    echo "  Business:   What's the impact? ROI? Metric impact?"
    echo "  Technical:  Feasibility given the codebase?"
    echo "  Competitive: How do others solve this?"
    echo "  Risk:       What could go wrong? Reversible?"
    echo "─────────────────────────────────────────────────"
    ;;
  build-vs-buy)
    item="${1:-}"
    echo "★ Build vs Buy: ${item} ─────────────────────"
    echo ""
    echo "1. What do we actually need? (not vendor's feature list)"
    echo "2. Internal capability + maintenance burden"
    echo "3. Total cost comparison (build + ongoing vs license + integration)"
    echo "4. Lock-in, data ownership, customization needs"
    echo "5. Recommendation with reasoning"
    echo "─────────────────────────────────────────────────"
    ;;
  ux-review)
    url="${1:-}"
    echo "★ UX Flow Review ────────────────────────────"
    echo "Target: ${url}"
    echo ""
    echo "1. Walk through the flow in browser"
    echo "2. Identify friction points and emotional gaps"
    echo "3. Compare to best practices / competitors"
    echo "4. Propose before/after improvements"
    echo "─────────────────────────────────────────────────"
    ;;
  framework)
    name="${1:-}"
    case "$name" in
      jtbd|jobs-to-be-done)
        echo "★ Jobs To Be Done ────────────────────────────"
        echo "Functional job: What task does the user hire this product for?"
        echo "Emotional job:  How does the user want to feel?"
        echo "Social job:     How does this make them look to others?"
        ;;
      rice|rice-scoring)
        echo "★ RICE Scoring ───────────────────────────────"
        echo "Reach:    How many users per time period?"
        echo "Impact:   How much impact per user? (massive/high/medium/low)"
        echo "Confidence: How sure are we? (high/medium/low)"
        echo "Effort:   Total engineering time"
        ;;
      first-principles)
        echo "★ First Principles ───────────────────────────"
        echo "1. State the problem as given"
        echo "2. Strip away inherited assumptions"
        echo "3. Identify real constraints (physics, not policy)"
        echo "4. Rebuild from what's true"
        echo "5. Bridge back to reality"
        ;;
      emotions|emotional-journey)
        echo "★ Emotions to Evoke ──────────────────────────"
        echo "Map the emotional before → during → after:"
        echo "  Before landing: [current negative emotion]"
        echo "  During onboarding: [feeling of progress]"
        echo "  After completion: [desired emotional state]"
        echo "  On return: [habit/trust feeling]"
        ;;
      *)
        echo "Unknown framework: $name"
        echo "Available: jtbd, rice, first-principles, emotions"
        ;;
    esac
    echo "─────────────────────────────────────────────────"
    ;;
  template)
    type="${1:-}"
    case "$type" in
      feature-design)
        echo "★ Feature Design Template ────────────────────"
        echo ""
        echo "## Problem & Job-to-be-Done"
        echo "- Functional job:"
        echo "- Emotional job:"
        echo ""
        echo "## Current State"
        echo ""
        echo "## Proposed Solution"
        echo ""
        echo "## Edge Cases & Risks"
        echo ""
        echo "## Success Metrics"
        ;;
      strategy)
        echo "★ Product Strategy Template ──────────────────"
        echo ""
        echo "## Current Position"
        echo ""
        echo "## Opportunities & Threats"
        echo ""
        echo "## Recommended Focus Areas"
        echo ""
        echo "## Measurable Outcomes"
        ;;
      prioritization)
        echo "★ Prioritization Template ────────────────────"
        echo ""
        echo "| Item | Impact | Effort | Confidence | Priority |"
        echo "|------|--------|--------|------------|----------|"
        echo "|      |        |        |            |          |"
        ;;
      *)
        echo "Unknown template: $type"
        echo "Available: feature-design, strategy, prioritization"
        ;;
    esac
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
