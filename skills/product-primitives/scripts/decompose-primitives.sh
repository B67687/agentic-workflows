#!/usr/bin/env bash
# =============================================================================
# decompose-primitives.sh — Product Primitives companion
#
# Decompose complex systems into fundamental building blocks.
# Supports multiple analytical lenses.
#
# Usage:
#   bash ./scripts/decompose-primitives.sh analyze "<system>"   # decompose
#   bash ./scripts/decompose-primitives.sh check "<primitive>"   # quality check
#   bash ./scripts/decompose-primitives.sh redflag "<text>"      # red flag check
#   bash ./scripts/decompose-primitives.sh lens <type>            # apply a lens
# =============================================================================

set -euo pipefail

MODE="${1:-analyze}"
INPUT="${2:-}"

case "$MODE" in
  analyze)
    echo "# Primitives Analysis: $INPUT"
    echo "## System"
    echo "$INPUT"
    echo ""
    echo "## Proposed Primitives"
    echo ""
    echo "### 1. <primitive name>"
    echo "**Purpose:**"
    echo "**Encapsulates:**"
    echo "**Interface:**"
    echo ""
    echo "### 2. <primitive name>"
    echo "**Purpose:**"
    echo "**Encapsulates:**"
    echo "**Interface:**"
    ;;
  check)
    echo "# Primitive Quality Check: $INPUT"
    echo "| Criterion | Status | Notes |"
    echo "|-----------|--------|-------|"
    echo "| Deep (simple interface) | | |"
    echo "| Encapsulates a decision | | |"
    echo "| Composable | | |"
    echo "| Transferable | | |"
    ;;
  redflag)
    echo "# Red Flag Check"
    echo "| Flag | Present? | Fix |"
    echo "|------|----------|-----|"
    echo "| Shallow interface | | |"
    echo "| Information leakage | | |"
    echo "| Temporal decomposition | | |"
    echo "| Pass-through | | |"
    echo "| Conjoined primitives | | |"
    ;;
  lens)
    case "$INPUT" in
      io|boundary)   echo "I/O lens: focus on network, files, time, webhooks boundaries" ;;
      function|logic) echo "Function lens: focus on decisions, computations, orchestration" ;;
      state|persist)  echo "State lens: focus on DB, caches, durable queues" ;;
      *) echo "Lenses available: io, function, state" ;;
    esac
    ;;
  *)
    echo "Usage: $0 {analyze|check|redflag|lens}"
    exit 1
    ;;
esac
