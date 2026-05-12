#!/usr/bin/env bash
# Companion script for strategic-thinker skill
# Cross-domain strategic reasoning, approach selection, systems thinking
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  question <type>    Route question type (enumerate, zoom, stress, decompose)
  enumerate          Enumerate & Evaluate framework template
  zoom               Zoom Stack framework (30K/10K/ground)
  stress <plan>      Stress Test framework
  decompose <prob>   First Principles decomposition
  lens <name>        Systems thinking lens (feedback, stocks, leverage, emergence)
  help               Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  question)
    type="${1:-}"
    echo "★ Question Routing ─────────────────────────────"
    case "$type" in
      enumerate|approach)
        echo "\"What's the right approach?\" → Enumerate & Evaluate"
        echo "Multiple paths exist. List viable approaches, assess each, recommend."
        ;;
      zoom|blind-spots)
        echo "\"What am I not seeing?\" → Zoom Stack"
        echo "Direction exists but blind spots suspected. Shift altitudes."
        ;;
      stress|sanity)
        echo "\"Sanity check this\" → Stress Test"
        echo "Plan exists. Poke holes before committing."
        ;;
      decompose|first-principles)
        echo "\"How should we think about X?\" → First Principles"
        echo "Unfamiliar or complex. Reframe the problem."
        ;;
      *)
        echo "Unknown type. Options: enumerate, zoom, stress, decompose"
        ;;
    esac
    echo "─────────────────────────────────────────────────"
    ;;
  enumerate)
    echo "★ Enumerate & Evaluate ─────────────────────────"
    echo "1. List viable approaches (2-4)"
    echo "2. For each, evaluate:"
    echo "   - Feasibility — can we do this?"
    echo "   - Reversibility — how hard to undo?"
    echo "   - Second-order effects — what feedback loops?"
    echo "   - Org fit — matches how team works?"
    echo "   - Time horizon — good for now vs 6mo vs 2yr?"
    echo "3. Recommend one + what would change your mind"
    echo "─────────────────────────────────────────────────"
    ;;
  zoom)
    echo "★ Zoom Stack ───────────────────────────────────"
    echo "30,000ft — Context: Why does this exist? What forces?"
    echo "10,000ft — Structure: How do parts connect? Feedback loops?"
    echo "Ground — Constraints: What's concretely true right now?"
    echo ""
    echo "Synthesize: What does each altitude reveal the others miss?"
    echo "─────────────────────────────────────────────────"
    ;;
  stress)
    plan="${1:-}"
    echo "★ Stress Test ──────────────────────────────────"
    echo "Plan: $plan"
    echo "1. Assumptions — what's assumed that might be wrong?"
    echo "2. Failure modes — what breaks first? Under what conditions?"
    echo "3. Missing feedback — how will you know it's working?"
    echo "4. Load/scale — holds under 10x?"
    echo "5. Dependencies — what externals could invalidate?"
    echo ""
    echo "Verdict: Sound / Sound with caveats / Rethink"
    echo "─────────────────────────────────────────────────"
    ;;
  decompose)
    problem="${1:-}"
    echo "★ First Principles Decomposition ───────────────"
    echo "Problem: $problem"
    echo "1. State the problem as seen"
    echo "2. Strip away inherited assumptions"
    echo "3. Identify real constraints (physics, not policy)"
    echo "4. Rebuild from what's true"
    echo "5. Bridge: pragmatic path from here to there"
    echo "─────────────────────────────────────────────────"
    ;;
  lens)
    name="${1:-}"
    echo "★ Systems Thinking Lens: ${name} ────────────────"
    case "$name" in
      feedback)
        echo "Reinforcing loops (growth/collapse) and balancing loops (stability)."
        echo "When you change X, what loop does it amplify or dampen?"
        ;;
      stocks)
        echo "Stocks (accumulate: tech debt, trust, knowledge) change slowly."
        echo "Flows (requests, deployments, decisions) change fast."
        echo "Don't optimize a flow when the stock is the bottleneck."
        ;;
      leverage)
        echo "Where does a small change produce a large effect?"
        echo "Usually at rules, information flows, or goals — not parameters."
        ;;
      emergence)
        echo "The system behaves in ways no single component intends."
        echo "What emerges from the interaction of parts?"
        ;;
      iofs|io-function-state)
        echo "I/O / Function / State lens for placement decisions."
        echo "I/O: boundaries (network, files, time, webhooks)"
        echo "Function: logic (pure computation, decisions, orchestration)"
        echo "State: persistence (DB, caches, durable queues)"
        echo "A primitive mixing layers is a decomposition smell."
        ;;
      *)
        echo "Available lenses: feedback, stocks, leverage, emergence, iofs"
        ;;
    esac
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
