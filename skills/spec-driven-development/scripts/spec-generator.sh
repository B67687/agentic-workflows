#!/usr/bin/env bash
# =============================================================================
# spec-generator.sh --- Companion script for Spec-Driven Development
#
# Scaffolds structured specification documents. Follows the gated workflow:
# SPECIFY -> PLAN -> TASKS -> IMPLEMENT (with human review between phases).
#
# Usage:
#   bash ./scripts/spec-generator.sh spec "<name>" "<description>"
#     Generate a full spec document from name and description.
#
#   bash ./scripts/spec-generator.sh assumptions "<claim>"
#     Output a structured assumptions table entry for the spec.
#
#   bash ./scripts/spec-generator.sh checklist
#     Output the Spec-Driven Development gate review checklist.
# =============================================================================

set -euo pipefail

MODE="${1:-checklist}"

case "$MODE" in
  spec)
    NAME="${2:-}"
    DESC="${3:-}"
    TODAY=$(date -u +%Y-%m-%d)
    
    if [ -z "$NAME" ] || [ -z "$DESC" ]; then
      echo "Usage: $0 spec \"<name>\" \"<description>\"" >&2
      exit 1
    fi
    
    cat << SPEC
# Specification: ${NAME}

**Date:** ${TODAY}
**Status:** Draft

## Overview
${DESC}

---

## Phase 1: Requirements

### What problem are we solving?
<!-- What user need, pain point, or opportunity does this address? -->

### Who is this for?
<!-- Which users, roles, or systems does this affect? -->

### What is explicitly out of scope?
<!-- What are we NOT building? This is as important as what we are building. -->

### Success Criteria
<!-- How will we know this is done? Measurable, verifiable conditions. -->
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Phase 2: Design

### Approach
<!-- High-level approach, key decisions, trade-offs -->

### Architecture / Data Flow
<!-- Diagrams, data flow, module boundaries -->
\`\`\`
[Describe or reference architecture]
\`\`\`

### Interfaces
<!-- API endpoints, function signatures, component props -->
- Input:
- Output:
- Error modes:

### Dependencies
<!-- What existing systems, libraries, or data does this depend on? -->
- Internal:
- External:

---

## Phase 3: Verification

### How to Test
<!-- Test strategy, key scenarios -->
\`\`\`
# Test scenarios
1. Scenario A: expected -> result
2. Scenario B: expected -> result
\`\`\`

### Edge Cases
- [ ] Empty/null input
- [ ] Large/boundary input
- [ ] Concurrent access
- [ ] Error recovery

---

## Phase 4: Risks

| Risk | Likelihood | Impact | Mitigation |
|------|:----------:|:------:|------------|
|      |            |        |            |
|      |            |        |            |

---

*Template: Spec-Driven Development skill*
SPEC
    ;;

  assumptions)
    CLAIM="${2:-}"
    if [ -z "$CLAIM" ]; then
      echo "Usage: $0 assumptions \"<claim>\"" >&2
      echo "Example: $0 assumptions \"The API returns 200 OK for all valid requests\"" >&2
      exit 1
    fi
    
    cat << ASSUMPTION
| Assumption | Source | Confidence | Needs Validation? |
|------------|--------|:----------:|:-----------------:|
| ${CLAIM} | Current session | Medium | [ ] Verify before proceeding |
ASSUMPTION
    ;;

  checklist)
    cat << "CHECKLIST"
=== Spec-Driven Development: Gate Review Checklist ===

## Phase 1 -> Phase 2 Gate (SPECIFY -> PLAN)
Ask the human:
- [ ] Does the spec match what you want?
- [ ] Is anything missing from scope?
- [ ] Are the success criteria correct?

## Phase 2 -> Phase 3 Gate (PLAN -> TASKS)
Before task breakdown:
- [ ] Architecture decisions documented?
- [ ] Trade-offs acknowledged?
- [ ] Dependencies identified?

## Phase 3 -> Phase 4 Gate (TASKS -> IMPLEMENT)
Before writing code:
- [ ] Tasks ordered by dependency?
- [ ] Each task independently verifiable?
- [ ] Edge cases identified?

## General
- [ ] Surface assumptions immediately (before writing spec)
- [ ] Out of scope explicitly documented
- [ ] Risks flagged up front
CHECKLIST
    ;;

  *)
    echo "Usage: $0 {spec|assumptions|checklist}"
    echo ""
    echo "  spec \"<name>\" \"<desc>\"   --- Generate full spec document"
    echo "  assumptions \"<claim>\"     --- Format assumption for spec"
    echo "  checklist                  --- Gate review checklist"
    exit 1
    ;;
esac
