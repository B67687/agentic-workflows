#!/usr/bin/env bash
# =============================================================================
# ideate.sh — Companion script for Divergent Ideation
#
# Generates structured ideation prompts and captures output.
#
# Usage:
#   bash ./scripts/ideate.sh prompt "<topic>"
#     Generate a divergent ideation prompt.
#
#   bash ./scripts/ideate.html capture "<idea>"
#     Format and capture a single idea.
# =============================================================================

set -euo pipefail

MODE="${1:-prompt}"
TOPIC="${2:-}"

case "$MODE" in
  prompt)
    if [ -z "$TOPIC" ]; then
      echo "Usage: $0 prompt \"<topic>\"" >&2
      exit 1
    fi
    cat << PROMPT
# Divergent Ideation: ${TOPIC}

Generate 10+ distinct approaches. Do NOT filter, rank, or evaluate.
Quantity over quality. Wild ideas welcome.

## Constraints
- One sentence per idea
- No judgment during generation
- Build on others' ideas (yes, and...)

## Output
1. 
2. 
3. 
4. 
5. 
6. 
7. 
8. 
9. 
10.

After generation, use the capture command to save promising ideas.
PROMPT
    ;;

  capture)
    IDEA="${*:2}"
    if [ -z "$IDEA" ]; then
      echo "Usage: $0 capture \"<idea>\"" >&2
      exit 1
    fi
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "- [$TIMESTAMP] ${IDEA}" >> /dev/stdout
    echo "Captured: ${IDEA:0:60}..."
    ;;

  *)
    echo "Usage: $0 {prompt|capture}"
    exit 1
    ;;
esac
