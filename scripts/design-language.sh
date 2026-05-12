#!/usr/bin/env bash
# Companion script for design-language skill
# Capture and enforce visual design language
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  capture <source>  Capture design from (figma URL, screenshot, live URL)
  review <file>     Review component against docs/design.md
  bootstrap         Create initial docs/design.md from template
  check <criterion> Check an observation against design principles
  help              Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  capture)
    source="${1:-}"
    echo "★ Design Capture ───────────────────────────────"
    echo "Source: $source"
    echo ""
    echo "Observations:"
    echo "1. [Heuristic section] — [specific observation]"
    echo "2. [Heuristic section] — [specific observation]"
    echo ""
    echo "Proposed diff to docs/design.md:"
    echo "- Consolidate into existing: [principle N]"
    echo "- New entry (justified): [name]"
    echo "- Divergences: [what contradicts current doc]"
    echo "─────────────────────────────────────────────────"
    ;;
  review)
    file="${1:-}"
    echo "★ Design Review ────────────────────────────────"
    echo "Component: $file"
    echo ""
    echo "Findings:"
    echo "1. [principle/heuristic] — [observation] — [fix]"
    echo "2. [principle/heuristic] — [observation] — [fix]"
    echo ""
    echo "Summary: [pass / findings / significant drift]"
    echo "─────────────────────────────────────────────────"
    ;;
  bootstrap)
    echo "★ Bootstrap docs/design.md ──────────────────────"
    cat <<TEMPLATE
# Design Language

## Principles

### [N]. [describes/prescribes] — [name]
Statement: [one sentence]
Why: [reasoning]
Cite: [source]

## Anti-principles

### [N]. We deliberately don't...
Statement: [what we don't do]
Why: [what happens when we do]

## Functional Patterns

### [name]
**When:** [when to use this pattern]
**Composition:** [how it's built]
**Behavior:** [states, transitions, edge cases]

## Perceptual Patterns

### [name]
**Quality:** [what feeling or character this creates]
**Elements:** [colors, spacing, type, motion that produce it]
TEMPLATE
    echo "─────────────────────────────────────────────────"
    ;;
  check)
    criterion="${1:-}"
    echo "★ Observation Quality Check ─────────────────────"
    echo "Criterion: $criterion"
    echo ""
    echo "□ Cites a named principle or heuristic?"
    echo "□ Specific (code path, element, observation)?"
    echo "□ Quantified (if from code/Figma, not screenshot)?"
    echo "□ Novel (not generic design truth)?"
    echo "─────────────────────────────────────────────────"
    ;;
  help|*)
    usage
    ;;
esac
