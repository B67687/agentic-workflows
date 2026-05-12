#!/usr/bin/env bash
# Companion script for product-discovery skill
# Validate ideas before building with evidence gates
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  risk <idea>      Assess the four product risks (value, usability, feasibility, viability)
  hypothesis <idea> Turn uncertainty into testable hypothesis
  experiment <type> Design experiment template (interview, fake-door, prototype, concierge, spike)
  gate <idea>      Define evidence gates (proceed/pivot/stop thresholds)
  plan <idea>      Full discovery plan template
  help             Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  risk)
    idea="${1:-}"
    echo "★ Four Product Risks ───────────────────────────"
    echo "Idea: $idea"
    echo ""
    echo "| Risk | Level | Key uncertainty |"
    echo "|------|-------|-----------------|"
    echo "| Value | L/M/H | Will customers choose to use this? |"
    echo "| Usability | L/M/H | Can users figure it out? |"
    echo "| Feasibility | L/M/H | Can we build and scale it? |"
    echo "| Viability | L/M/H | Does it work for the business? |"
    echo "─────────────────────────────────────────────────"
    ;;
  hypothesis)
    echo "★ Hypothesis Template ──────────────────────────"
    echo "We believe [specific assumption]."
    echo "We'll know we're right if [observable evidence]."
    echo "We'll know we're wrong if [observable evidence]."
    echo "─────────────────────────────────────────────────"
    ;;
  experiment)
    type="${1:-}"
    echo "★ Experiment: ${type} ──────────────────────────"
    case "$type" in
      interview)
        echo "Customer interviews (5-10 conversations)"
        echo "Best for: understanding the problem space"
        echo "Timeline: 1-2 weeks"
        ;;
      fake-door)
        echo "Fake door test"
        echo "Best for: measuring demand before building"
        echo "Method: measure click-through on a non-functional feature"
        ;;
      prototype)
        echo "Prototype test"
        echo "Best for: usability risk — can users use it?"
        echo "Method: clickable mockup tested with 5+ users"
        ;;
      concierge)
        echo "Concierge test"
        echo "Best for: validating the workflow manually"
        echo "Method: human delivers the service behind the curtain"
        ;;
      spike)
        echo "Technical spike"
        echo "Best for: feasibility risk"
        echo "Method: time-boxed exploration of hardest unknown"
        ;;
      *)
        echo "Options: interview, fake-door, prototype, concierge, spike"
        ;;
    esac
    echo "─────────────────────────────────────────────────"
    ;;
  gate)
    echo "★ Evidence Gate Template ───────────────────────"
    echo ""
    echo "### Gate: [hypothesis being tested]"
    echo "Experiment: [what you'll do]"
    echo "Timeline: [days]"
    echo "Proceed if: [specific evidence threshold]"
    echo "Pivot if: [evidence suggests different approach]"
    echo "Stop if: [evidence kills the idea]"
    echo "─────────────────────────────────────────────────"
    ;;
  plan)
    idea="${1:-}"
    cat <<EOF
★ Discovery Plan: $idea

## Problem & Desired Outcome
**Problem:** [what's broken]
**Outcome:** [measurable success]

## Risk Assessment
| Risk | Level | Key uncertainty |
|------|-------|-----------------|
| Value | L/M/H | |
| Usability | L/M/H | |
| Feasibility | L/M/H | |
| Viability | L/M/H | |

## Hypotheses
1. We believe [X]. Evidence for: [Y]. Evidence against: [Z].

## Experiments
### Experiment 1: [name]
- Tests: [which hypothesis]
- Method: [what you'll do]
- Timeline: [how long]
- Gate: Proceed if [X]. Pivot if [Y]. Stop if [Z].

## Sequence
[Which experiments to run first, parallel dependencies]

EOF
    ;;
  help|*)
    usage
    ;;
esac
