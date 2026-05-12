#!/usr/bin/env bash
# Companion script for product-primitives skill
# Break complex systems into fundamental primitives
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  analyze <system>   Decompose a system into primitives
  check <primitive>  Check primitive quality (deep? encapsulating? composable?)
  redflag <text>     Check for decomposition red flags
  lens <type>        Apply a decomposition lens (knowledge, io-function-state)
  template           Output format template
  help               Show this help
EOF
}

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  analyze)
    system="${1:-}"
    cat <<EOF
★ System: $system

## Primitives

### 1. [Primitive Name]
**Purpose**: What it does
**Encapsulates**: What knowledge/decisions it hides
**Interface**: Inputs → Outputs

### 2. [Next Primitive]
...

## How They Fit Together

[ASCII diagram showing relationships]

## Composition Examples

[Show 2-3 user workflows composed from these primitives]
EOF
    ;;
  check)
    primitive="${1:-}"
    echo "★ Primitive Quality Check ──────────────────────"
    echo "Primitive: $primitive"
    echo ""
    echo "□ Deep — simple interface, powerful functionality behind it?"
    echo "□ Encapsulating — hides a design decision; internals can change?"
    echo "□ Composable — combines through simple interfaces?"
    echo "□ Transferable — useful in multiple workflows?"
    echo "─────────────────────────────────────────────────"
    ;;
  redflag)
    text="${1:-}"
    echo "★ Red Flag Check ───────────────────────────────"
    echo "Pattern: $text"
    echo ""
    echo "Red flags:"
    echo "- Shallow: interface as complex as implementation?"
    echo "- Information leakage: same knowledge in multiple primitives?"
    echo "- Temporal decomposition: boundaries mirror execution order?"
    echo "- Pass-through: forwards to another with similar interface?"
    echo "- Conjoined: can't understand one without the other?"
    echo "─────────────────────────────────────────────────"
    ;;
  lens)
    case "${1:-}" in
      knowledge)
        echo "★ Split by Knowledge Lens ─────────────────────"
        echo "Ask: what distinct pieces of knowledge does this system need?"
        echo "Each piece of knowledge = one primitive."
        echo "Merge: when two pieces share info, are always used together."
        echo "Split: when pieces are truly independent."
        echo "TEST: will devs need to read both to understand either?"
        echo "─────────────────────────────────────────────────"
        ;;
      iofs|io-function-state)
        echo "★ I/O / Function / State Lens ─────────────────"
        echo "Each primitive belongs to one layer:"
        echo "  I/O: Boundary (network, files, time, webhooks)"
        echo "  Function: Logic (pure computation, decisions, orchestration)"
        echo "  State: Persistence (DB, caches, durable queues)"
        echo "A primitive mixing layers = decomposition smell. Split it."
        echo "─────────────────────────────────────────────────"
        ;;
      *)
        echo "Lenses: knowledge, iofs"
        ;;
    esac
    ;;
  template)
    echo "Use: bash ./scripts/decompose-primitives.sh analyze \"system name\""
    ;;
  help|*)
    usage
    ;;
esac
