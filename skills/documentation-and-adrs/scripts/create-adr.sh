#!/bin/bash
# =============================================================================
# create-adr.sh --- Create a new Architecture Decision Record.
#
# Companion script for the documentation-and-adrs skill.
# Creates a sequentially-numbered ADR in docs/decisions/ using the
# lightweight format from the skill. Handles numbering, date, and basic
# template filling.
#
# Usage:
#   bash ./scripts/create-adr.sh "Title of the decision"
#   bash ./scripts/create-adr.sh --status "Accepted" "Title"
#   bash ./scripts/create-adr.sh --dir docs/adrs "Title"
#
# Examples:
#   bash ./scripts/create-adr.sh "Use PostgreSQL for primary database"
#   bash ./scripts/create-adr.sh --status "Proposed" "API versioning strategy"
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

# Defaults
STATUS="Accepted"
ADRS_DIR="$REPO_ROOT/docs/decisions"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --status)
      STATUS="$2"
      shift 2
      ;;
    --dir)
      ADRS_DIR="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: bash ./scripts/create-adr.sh [--status STATUS] [--dir PATH] \"Title\""
      echo ""
      echo "Creates a new ADR in \$ADRS_DIR (default: docs/decisions/)"
      echo "with sequential numbering."
      exit 0
      ;;
    *)
      TITLE="$*"
      break
      ;;
  esac
done

if [ -z "${TITLE:-}" ]; then
  echo "Error: ADR title is required"
  echo "Usage: bash ./scripts/create-adr.sh \"Title of the decision\""
  exit 1
fi

# Ensure ADR directory exists
mkdir -p "$ADRS_DIR"

# Find next sequence number
LAST_NUM=$(find "$ADRS_DIR" -maxdepth 1 -name 'ADR-*.md' 2>/dev/null | \
  sed 's/.*ADR-0*\([0-9]*\).*/\1/' | \
  sort -n | tail -1)
LAST_NUM=${LAST_NUM:-0}
NEXT_NUM=$((LAST_NUM + 1))
PADDED_NUM=$(printf "%03d" "$NEXT_NUM")

# Derive filename from title
SLUG=$(echo "$TITLE" | \
  tr '[:upper:]' '[:lower:]' | \
  sed 's/[^a-z0-9][^a-z0-9]*/-/g' | \
  sed 's/^-//;s/-$//')
FILENAME="ADR-${PADDED_NUM}-${SLUG}.md"
FILEPATH="$ADRS_DIR/$FILENAME"

# Create the ADR
cat > "$FILEPATH" << ADR
# ADR-${PADDED_NUM}: ${TITLE}

## Status
${STATUS}

## Date
$(date -u +%Y-%m-%d)

## Context
<!-- What led to this decision? What constraints, requirements, or
     problems are we addressing? -->

## Decision
<!-- What did we decide? Be specific. -->

## Alternatives Considered
<!-- What else did we evaluate, and why did we choose this approach?
     List at least one alternative with pros/cons. -->

### Alternative 1: (name)
- Pros:
- Cons:

### Alternative 2: (name)
- Pros:
- Cons:

## Consequences
<!-- What are the trade-offs, follow-ups, or required changes? -->

## References
<!-- Links to relevant issues, PRs, docs, or discussions. -->
ADR

echo "Created: $FILEPATH"
echo "Number: $PADDED_NUM"
echo "Status: $STATUS"
