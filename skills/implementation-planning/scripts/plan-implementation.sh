#!/usr/bin/env bash
# =============================================================================
# plan-implementation.sh — Companion script for Implementation Planning
#
# Structures implementation plans with phases, file changes, and verification.
# Complements the planning-and-task-breakdown skill (task→level decomposition).
#
# Usage:
#   bash ./scripts/plan-implementation.sh plan "<title>"
#     Generate an implementation plan template.
#   bash ./scripts/plan-implementation.sh phase "<name>"
#     Generate a single-phase template.
# =============================================================================

set -euo pipefail

MODE="${1:-plan}"
TITLE="${2:-}"

case "$MODE" in
  plan)
    [ -z "$TITLE" ] && echo "Usage: $0 plan \"<title>\"" >&2 && exit 1
    cat << PLAN
# Implementation Plan: ${TITLE}

## Research
- [ ] Read relevant codebase sections
- [ ] Identify existing patterns
- [ ] Map dependencies

## Phases

### Phase 1: <name>
**Files:**
**Changes:**
**Verification:**
- [ ] <test or check>

### Phase 2: <name>
**Files:**
**Changes:**
**Verification:**
- [ ] <test or check>

### Phase 3: <name>
**Files:**
**Changes:**
**Verification:**
- [ ] <test or check>

## Risks
- <risk>
PLAN
    ;;

  phase)
    [ -z "$TITLE" ] && echo "Usage: $0 phase \"<name>\"" >&2 && exit 1
    cat << PHASE
### Phase: ${TITLE}

**Goal:**
**Files:** <paths>
**Changes:**
\`\`\`

\`\`\`

**Dependencies:**
**Verification:** <how to confirm this phase works>
**Estimated size:** <small/medium/large>
PHASE
    ;;

  *)
    echo "Usage: $0 {plan|phase}"
    exit 1
    ;;
esac
