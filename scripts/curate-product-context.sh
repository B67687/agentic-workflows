#!/usr/bin/env bash
# Companion script for curate-product-context skill
# Curate and maintain .tap/product.md — product vision, focus, bets, non-goals
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  check-state       Check if .tap/product.md exists and its age
  mode              Auto-detect mode (interview/review/refresh)
  read-inputs       Read existing inputs (CLAUDE.md, README, etc.)
  interview         Run interview mode (walk all 5 sections)
  review            Run review mode (prune then add)
  refresh           Run refresh mode (capture shifts, then review)
  template          Product context format template
  help              Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  check-state)
    echo "★ Checking Product Context ──────────────────────"
    if [[ -f .tap/product.md ]]; then
      mtime=$(stat -c %Y .tap/product.md 2>/dev/null || stat -f %m .tap/product.md)
      now=$(date +%s)
      days_old=$(( (now - mtime) / 86400 ))
      echo "Found: .tap/product.md (${days_old} days old)"
    else
      echo "Not found: .tap/product.md"
    fi
    echo "─────────────────────────────────────────────────"
    ;;
  mode)
    echo "★ Mode Detection ────────────────────────────────"
    if [[ ! -f .tap/product.md ]]; then
      echo "Mode: INTERVIEW — no file exists, walk all 5 sections"
    else
      mtime=$(stat -c %Y .tap/product.md 2>/dev/null || stat -f %m .tap/product.md)
      now=$(date +%s)
      days_old=$(( (now - mtime) / 86400 ))
      if (( days_old < 90 )); then
        echo "Mode: REVIEW — file exists, ${days_old} days old, prune-first protocol"
      else
        echo "Mode: REFRESH — file is ${days_old} days old, capture shifts then review"
      fi
    fi
    echo "─────────────────────────────────────────────────"
    ;;
  read-inputs)
    echo "★ Reading Inputs ────────────────────────────────"
    for f in "CLAUDE.md" "README.md" ".tap/tap-audit.md" ".tap/system-health.md" ".tap/architecture.md"; do
      if [[ -f "$f" ]]; then
        echo "  ✓ $f"
      else
        echo "  ✗ $f (not found)"
      fi
    done
    echo "─────────────────────────────────────────────────"
    ;;
  interview)
    echo "★ Interview Mode ────────────────────────────────"
    echo ""
    echo "Walk 5 sections:"
    echo ""
    echo "1. What we build — 1-3 sentences: the product + who it's for"
    echo "2. Audience & pain — users + what hurts"
    echo "   PRINCIPLE: the belief about audience that shapes every decision"
    echo "3. Current focus — problem solving this quarter + success signal"
    echo "4. Bets — 2-4 bets: what you're trying + why it'll work"
    echo "5. Non-goals — what you're NOT doing + why"
    echo "   PRINCIPLE: why this boundary matters right now"
    echo "─────────────────────────────────────────────────"
    ;;
  review)
    echo "★ Review Mode ───────────────────────────────────"
    echo "Prune-first protocol for each section:"
    echo "1. Show current content"
    echo "2. Ask: Still true? Anything stale or wrong?"
    echo "3. Only after pruning: Anything new to add?"
    echo "─────────────────────────────────────────────────"
    ;;
  refresh)
    days="${1:-}"
    echo "★ Refresh Mode ──────────────────────────────────"
    echo "File is ${days} days old."
    echo ""
    echo "1. Capture top-line shifts since last write"
    echo "2. Run Review protocol (prune-first)"
    echo "─────────────────────────────────────────────────"
    ;;
  template)
    cat <<TEMPLATE
# Product Context

## What we build
[1-3 sentences: the product + who it's specifically for]

## Audience & pain
**Users:** [who, concretely]
**Pain:** [what hurts most]
**Principle:** [belief about audience that shapes every decision]

## Current focus
**Problem:** [what you're solving this quarter]
**Insight:** [data/customers/tech that showed you this]
**Success signal:** [the one measurable thing]

## Bets
- [bet 1]: [what you're trying + why it'll work]
- [bet 2]: [what you're trying + why it'll work]

## Non-goals
[what you're NOT doing right now, even though people ask]
**Principle:** [why this boundary matters]
TEMPLATE
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
