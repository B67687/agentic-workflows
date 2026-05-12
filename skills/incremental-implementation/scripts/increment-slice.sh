#!/usr/bin/env bash
# =============================================================================
# increment-slice.sh — Companion script for Incremental Implementation
#
# Validates change size, suggests slice decomposition, and runs the
# implement → test → verify → commit cycle for one slice.
#
# Usage:
#   bash ./scripts/increment-slice.sh check
#     Check if current uncommitted changes are small enough for one slice.
#
#   bash ./scripts/increment-slice.sh suggest "<task-description>"
#     Suggest how to slice a task into thin vertical slices.
#
#   bash ./scripts/increment-slice.sh cycle <test-command>
#     Run one increment cycle: test → verify → report.
#     Exits 0 if slice passes verification.
# =============================================================================

set -euo pipefail

MODE="${1:-check}"

case "$MODE" in
  check)
    echo "=== Slice Size Check ==="
    
    # Count lines changed in working tree
    CHANGED_FILES=$(git diff --stat 2>/dev/null | tail -1 | grep -oP '\d+ file' | grep -oP '\d+' || echo 0)
    INSERTIONS=$(git diff --stat 2>/dev/null | tail -1 | grep -oP '\d+ insertion' | grep -oP '\d+' || echo 0)
    DELETIONS=$(git diff --stat 2>/dev/null | tail -1 | grep -oP '\d+ deletion' | grep -oP '\d+' || echo 0)
    TOTAL=$((INSERTIONS + DELETIONS))
    
    echo "  Files changed: $CHANGED_FILES"
    echo "  Lines changed: $TOTAL (+$INSERTIONS/-$DELETIONS)"
    echo ""
    
    if [ "$CHANGED_FILES" -eq 0 ] 2>/dev/null; then
      echo "  ✓ No uncommitted changes — workspace is clean."
      echo "  Next: implement one slice, then run 'check' again."
    elif [ "$TOTAL" -le 100 ] 2>/dev/null; then
      echo "  ✓ Small slice (${TOTAL} lines) — good for one cycle."
    elif [ "$TOTAL" -le 300 ] 2>/dev/null; then
      echo "  ⚠  Medium slice (${TOTAL} lines) — acceptable but consider splitting."
      echo "     Recommendation: break into 2 slices by logical concern."
    else
      echo "  ✗ Large slice (${TOTAL} lines) — must decompose."
      echo "     Max 100 lines per slice for reliable review."
      echo "     Recommendation: $0 suggest \"current task\""
    fi
    ;;

  suggest)
    TASK="${2:-}"
    if [ -z "$TASK" ]; then
      echo "Usage: $0 suggest \"<task description>\"" >&2
      exit 1
    fi
    
    cat << SUGGEST
# Suggested Slice Decomposition
Task: ${TASK}

## Slice 1: Data & Contracts
- Define types, interfaces, schemas
- No logic yet — just structure
- ~20-40 lines

## Slice 2: Core Logic
- Implement the main algorithm/transform
- Wire up types from Slice 1
- ~30-60 lines

## Slice 3: Integration
- Connect to existing systems (API, DB, UI)
- Handle errors and edge cases
- ~20-40 lines

## Slice 4: Tests
- Unit tests for core logic
- Integration tests for boundaries
- ~30-60 lines

## Slice N: Cleanup
- Documentation, dead code removal
- Final review pass
- ~10-20 lines

## Ordering
${TASK} → Slice 1 → Slice 2 → Slice 3 → ... → done

Each slice must leave the system in a working state.
Test after every slice.
Commit after every verified slice.
SUGGEST
    ;;

  cycle)
    TEST_CMD="${*:2}"
    if [ -z "$TEST_CMD" ]; then
      echo "Usage: $0 cycle \"<test command>\"" >&2
      echo "Example: $0 cycle \"npm test\"" >&2
      exit 1
    fi
    
    echo "=== Increment Cycle ==="
    echo "Phase: Test → Verify"
    echo "Command: ${TEST_CMD}"
    echo ""
    
    # Run the test
    set +e
    TEST_OUTPUT=$(eval "$TEST_CMD" 2>&1)
    TEST_EXIT=$?
    set -e
    
    # Check files changed
    FILES=$(git diff --name-only 2>/dev/null | wc -l)
    LINES=$(git diff --stat 2>/dev/null | tail -1 | grep -oP '\d+' | head -1 || echo 0)
    
    echo "--- Results ---"
    echo "  Files changed: $FILES"
    echo "  Lines changed: ${LINES:-0}"
    
    if [ "$TEST_EXIT" -eq 0 ]; then
      echo "  Tests: PASS"
      echo ""
      echo "INCREMENT_STATUS=pass"
      echo "INCREMENT_MESSAGE=Slice verified — ready to commit"
      echo ""
      echo "Next step: bash ./scripts/checkpoint-commit.sh -m \"<describe this slice>\""
      exit 0
    else
      echo "  Tests: FAIL (exit $TEST_EXIT)"
      echo "$TEST_OUTPUT" | head -10
      echo ""
      echo "INCREMENT_STATUS=fail"
      echo "INCREMENT_MESSAGE=Slice not verified — fix before committing"
      exit 1
    fi
    ;;

  *)
    echo "Usage: $0 {check|suggest|cycle}"
    echo ""
    echo "  check               — Validate current change size"
    echo "  suggest \"<task>\"    — Suggest slice decomposition"
    echo "  cycle \"<test-cmd>\"  — Run one increment cycle"
    exit 1
    ;;
esac
