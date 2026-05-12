#!/usr/bin/env bash
# =============================================================================
# grill-session.sh — Companion script for Grill Me
#
# Structures the decision-tree walkthrough: setup framing, question format,
# and closure summary. Complements the structured-questioning skill.
#
# Usage:
#   bash ./scripts/grill-session.sh start "<topic>"
#     Output the initial framing for a grill session.
#
#   bash ./scripts/grill-session.sh question "<q>" "<recommended>"
#     Format a question with recommended answer + branch indicators.
#
#   bash ./scripts/grill-session.sh close
#     Output the closure summary template.
# =============================================================================

set -euo pipefail

MODE="${1:-start}"

case "$MODE" in
  start)
    TOPIC="${2:-}"
    if [ -z "$TOPIC" ]; then
      echo "Usage: $0 start \"<topic>\"" >&2
      exit 1
    fi
    
    cat << FRAME
# Grill Session: ${TOPIC}

## Framing
I'm going to interview you about this until we reach shared understanding on
every branch of the decision tree. I'll go one question at a time.

For each question:
- I'll include my recommended answer
- You can say "yes" (agree), offer an alternative, or ask me to explore the codebase
- We don't advance until the current branch is resolved

## Ground Rules
- One question at a time
- I recommend; you decide
- Pending questions are tracked until answered
- When all branches are resolved: plan → implement

## Decision Tree
Start: ${TOPIC}
Depth: <tracked as we go>

Let's begin.
FRAME
    ;;

  question)
    QUESTION="${2:-}"
    RECOMMENDED="${3:-}"
    
    if [ -z "$QUESTION" ]; then
      echo "Usage: $0 question \"<question>\" \"<recommended answer>\"" >&2
      exit 1
    fi
    
    cat << Q
---
**Q:** ${QUESTION}
${RECOMMENDED:+**Recommended:** ${RECOMMENDED}}

**Answer:** <user response>
**Result:** [ ] Resolved  [ ] Branching  [ ] Needs exploration
**Next:** <next question or phase>

---
Q
    ;;

  close)
    cat << CLOSE
# Grill Session — Closure Summary

## Decisions Made
| Decision | Choice | Rationale |
|----------|--------|-----------|
|          |        |           |

## Remaining Branches
<!-- Any questions deferred or left unresolved -->
- [ ] <item>

## Next Phase
Based on the resolved decision tree:
- [ ] Plan the implementation
- [ ] Break into tasks
- [ ] Start implementation

## Session Notes
<!-- Anything the griller learned that should inform future work -->
-
CLOSE
    ;;

  *)
    echo "Usage: $0 {start|question|close}"
    echo ""
    echo "  start \"<topic>\"       — Begin a grill session"
    echo "  question \"<q>\" \"<r>\"  — Format a question"
    echo "  close                 — Output closure summary"
    exit 1
    ;;
esac
