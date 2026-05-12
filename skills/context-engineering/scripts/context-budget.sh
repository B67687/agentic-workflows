#!/usr/bin/env bash
# =============================================================================
# context-budget.sh — Companion script for Context Engineering
#
# Estimates token usage for files and directories, flags budget risks,
# and provides compaction recommendations.
#
# Rough estimate: ~4 chars per token for English text, ~2 chars per token
# for code/markdown (higher symbol density).
#
# Usage:
#   bash ./scripts/context-budget.sh estimate <file>
#     Estimate tokens for a single file.
#
#   bash ./scripts/context-budget.sh check [dir]
#     Check all .md files in a directory against context budget.
#
#   bash ./scripts/context-budget.sh compact "<5-line summary>"
#     Format a compact handoff summary.
# =============================================================================

set -euo pipefail

MODE="${1:-check}"
TARGET="${2:-.}"
TOKEN_LIMIT=128000  # typical context window

case "$MODE" in
  estimate)
    if [ ! -f "$TARGET" ]; then
      echo "Usage: $0 estimate <file>" >&2
      exit 1
    fi
    CHARS=$(wc -c < "$TARGET")
    LINES=$(wc -l < "$TARGET")
    # Estimate: code/markdown ~3 chars/token
    TOKENS=$((CHARS / 3))
    PCT=$((TOKENS * 100 / TOKEN_LIMIT))
    echo "  $TARGET"
    echo "  Lines:  $LINES"
    echo "  Chars:  $CHARS"
    echo "  Tokens: ~${TOKENS} (est)"
    echo "  Budget: ${PCT}% of ${TOKEN_LIMIT}"
    if [ "$PCT" -gt 50 ]; then echo "  ⚠  Over 50% of context budget"
    elif [ "$PCT" -gt 25 ]; then echo "  ⚠  Over 25% of context budget"
    else echo "  ✓  Within budget"
    fi
    ;;

  check)
    TOTAL_TOKENS=0
    TOTAL_PCT=0
    echo "=== Context Budget Check: ${TARGET} ==="
    echo ""
    while IFS= read -r f; do
        CHARS=$(wc -c < "$f")
        TOKENS=$((CHARS / 3))
        TOTAL_TOKENS=$((TOTAL_TOKENS + TOKENS))
        PCT=$((TOKENS * 100 / TOKEN_LIMIT))
        [ "$PCT" -gt 10 ] && echo "  ${PCT}%  $(basename "$f")"
    done < <(find "$TARGET" -name '*.md' -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | sort)
    TOTAL_PCT=$((TOTAL_TOKENS * 100 / TOKEN_LIMIT))
    echo ""
    echo "  Total: ~${TOTAL_TOKENS} tokens (${TOTAL_PCT}% of ${TOKEN_LIMIT})"
    if [ "$TOTAL_PCT" -gt 80 ]; then echo "  ⚠  CRITICAL: over 80% of context budget"
    elif [ "$TOTAL_PCT" -gt 50 ]; then echo "  ⚠  WARNING: over 50% of context budget"
    else echo "  ✓  Within safe budget"
    fi
    ;;

  compact)
    SUMMARY="${*:2}"
    if [ -z "$SUMMARY" ]; then
      echo "Usage: $0 compact \"<5-line summary>\"" >&2
      exit 1
    fi
    echo "# Context Handoff"
    echo "## Summary"
    echo "$SUMMARY"
    echo ""
    echo "## State"
    echo "- Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    echo "- Changes: $(git status --short 2>/dev/null | wc -l) uncommitted"
    echo "- Last commit: $(git log -1 --oneline 2>/dev/null || echo 'none')"
    echo ""
    echo "## Next"
    echo "- Task: <next action>"
    echo "- Files: <key paths>"
    ;;

  *)
    echo "Usage: $0 {estimate|check|compact}"
    echo "  estimate <file>   — Estimate tokens for a file"
    echo "  check [dir]       — Check directory context budget"
    echo "  compact \"<sum>\"   — Format compact handoff"
    exit 1
    ;;
esac
