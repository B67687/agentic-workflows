#!/usr/bin/env bash
# =============================================================================
# simplify-check.sh — Companion script for Code Simplification
#
# Analyzes code complexity and suggests simplification targets.
# Uses line count, nesting depth, and structural heuristics.
#
# Usage:
#   bash ./scripts/simplify-check.sh check <file>
#     Analyze a file for complexity issues.
#     Example: bash ./scripts/simplify-check.sh check src/index.ts
#
#   bash ./scripts/simplify-check.sh compare <file-a> <file-b>
#     Compare two versions for complexity changes.
#
#   bash ./scripts/simplify-check.sh principles
#     Output the five principles reference.
# =============================================================================

set -euo pipefail

MODE="${1:-principles}"

case "$MODE" in
  check)
    TARGET="${2:-}"
    if [ -z "$TARGET" ] || [ ! -f "$TARGET" ]; then
      echo "Usage: $0 check <file>" >&2
      exit 1
    fi
    
    TOTAL_LINES=$(wc -l < "$TARGET")
    CODE_LINES=$(grep -c '^\s*[^$\s]' "$TARGET" 2>/dev/null || echo "$TOTAL_LINES")
    
    echo "=== Simplify Check: ${TARGET} ==="
    echo "Total lines:  ${TOTAL_LINES}"
    echo "Code lines:   ${CODE_LINES}"
    echo ""
    
    # Check 1: Line length
    LONG_LINES=$(awk 'length > 100 {count++} END {print count}' "$TARGET")
    echo "--- Line length ---"
    if [ "$LONG_LINES" -gt 0 ]; then
      echo "  ⚠  $LONG_LINES line(s) over 100 chars — consider breaking up"
    else
      echo "  ✓  No lines over 100 chars"
    fi
    
    # Check 2: Function/class size (heuristic — count blocks between braces)
    LARGE_BLOCKS=$(grep -c '^\s*\(function\|class\|def\b\)' "$TARGET" 2>/dev/null || echo 0)
    echo "--- Structure ---"
    echo "  $LARGE_BLOCKS function/class definitions found"
    
    # Check 3: Nesting depth
    MAX_DEPTH=0
    CURRENT=0
    while IFS= read -r line; do
      # Count opening braces, brackets, parens
      OPEN=$(echo "$line" | grep -o '{' | wc -l || true)
      CLOSE=$(echo "$line" | grep -o '}' | wc -l || true)
      CURRENT=$((CURRENT + OPEN - CLOSE))
      if [ "$CURRENT" -gt "$MAX_DEPTH" ]; then MAX_DEPTH=$CURRENT; fi
    done < "$TARGET"
    
    echo ""
    echo "--- Nesting depth ---"
    if [ "$MAX_DEPTH" -gt 5 ]; then
      echo "  ⚠  Max nesting depth: $MAX_DEPTH (target: ≤5)"
      echo "  Suggestion: Extract nested blocks into named functions"
    else
      echo "  ✓  Max nesting depth: $MAX_DEPTH"
    fi
    
    # Check 4: TODO/FIXME markers
    TODOS=$(grep -c 'TODO\|FIXME\|HACK\|XXX' "$TARGET" 2>/dev/null || echo 0)
    echo ""
    echo "--- Markers ---"
    if [ "$TODOS" -gt 0 ]; then
      echo "  ⚠  $TODOS TODO/FIXME/HACK marker(s) found"
      grep -n 'TODO\|FIXME\|HACK\|XXX' "$TARGET" | head -5
    else
      echo "  ✓  No TODO/FIXME/HACK markers"
    fi
    
    # Complexity rating
    echo ""
    echo "--- Summary ---"
    if [ "$TOTAL_LINES" -gt 300 ] || [ "$MAX_DEPTH" -gt 8 ] || [ "$LONG_LINES" -gt 10 ]; then
      echo "  COMPLEXITY: High — consider refactoring"
      echo "  Recommended: review with code-simplification skill"
    elif [ "$TOTAL_LINES" -gt 100 ] || [ "$MAX_DEPTH" -gt 5 ] || [ "$LONG_LINES" -gt 3 ]; then
      echo "  COMPLEXITY: Moderate — could benefit from simplification"
    else
      echo "  COMPLEXITY: Low — file looks manageable"
    fi
    ;;

  compare)
    FILE_A="${2:-}"
    FILE_B="${3:-}"
    if [ -z "$FILE_A" ] || [ -z "$FILE_B" ]; then
      echo "Usage: $0 compare <original-file> <simplified-file>" >&2
      exit 1
    fi
    
    if [ ! -f "$FILE_A" ] || [ ! -f "$FILE_B" ]; then
      echo "Both files must exist." >&2
      exit 1
    fi
    
    LA=$(wc -l < "$FILE_A")
    LB=$(wc -l < "$FILE_B")
    DA=$(awk 'length > 100 {count++} END {print count}' "$FILE_A")
    DB=$(awk 'length > 100 {count++} END {print count}' "$FILE_B")
    
    echo "=== Simplification Comparison ==="
    echo "              Original  Simplified  Change"
    echo "Lines:        $(printf '%5d' $LA)   $(printf '%5d' $LB)   $(printf '%+5d' $((LB - LA)))"
    echo "Long lines:   $(printf '%5d' $DA)   $(printf '%5d' $DB)   $(printf '%+5d' $((DB - DA)))"
    echo ""
    
    if [ "$LB" -lt "$LA" ] && [ "$DB" -le "$DA" ]; then
      echo "  ✓ Simplification reduced size and complexity."
    elif [ "$LB" -le "$LA" ]; then
      echo "  ⚠  Size reduced but long lines unchanged."
    else
      echo "  ⚠  File grew. Verify behavior preservation before accepting."
    fi
    echo ""
    echo "  Remember (Principle 1): behavior must be identical."
    echo "  Run tests to verify."
    ;;

  principles)
    cat << "PRIN"
=== The Five Principles of Code Simplification ===

1. Preserve Behavior Exactly
   Don't change what the code does — only how it expresses it.
   All inputs, outputs, side effects, error behavior, and edge cases
   must remain identical.

2. Reduce Nesting, Not Lines
   Deeply nested code is hard to follow. Extract conditions into
   named functions, use early returns, flatten if-else chains.
   Goal: max nesting ≤ 3 levels.

3. Name Things Once, Name Things Well
   A name that needs a comment to explain is a bad name.
   Magic numbers → named constants.
   Boolean flags → enums or separate functions.

4. One Thing Per Function
   If a function does more than one thing at the same level of
   abstraction, split it. If you can't name it in 3 words,
   it does too much.

5. Remove What's Not Used
   Dead code, unused parameters, commented-out blocks,
   unnecessary generics/abstractions, unused exports.
   If it's not tested, it's not needed.
PRIN
    ;;

  *)
    echo "Usage: $0 {check|compare|principles}"
    echo ""
    echo "  check <file>              — Analyze file complexity"
    echo "  compare <a> <b>           — Compare complexity changes"
    echo "  principles                — Five principles reference"
    exit 1
    ;;
esac
