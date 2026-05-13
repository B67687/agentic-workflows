#!/usr/bin/env bash
# =============================================================================
# tdd-cycle.sh --- Companion script for Test-Driven Development
#
# Walks through the RED -> GREEN -> REFACTOR cycle, running tests at each step
# with clear pass/fail output and no noise.
#
# Usage:
#   bash ./scripts/tdd-cycle.sh red <test-command>
#     Run tests to confirm RED phase (expected: test fails).
#     Exits 0 if tests FAIL (RED confirmed), 1 if tests pass (not RED).
#
#   bash ./scripts/tdd-cycle.sh green <test-command>
#     Run tests after minimal implementation (expected: test passes).
#     Exits 0 if tests PASS (GREEN achieved), 1 if tests fail.
#
#   bash ./scripts/tdd-cycle.sh refactor <test-command>
#     Run full test suite after refactoring (expected: all pass).
#
#   bash ./scripts/tdd-cycle.sh prove <test-command>
#     Prove-It pattern: run the bug reproduction test.
#     Exits 0 if test FAILS (bug confirmed), 1 if test passes.
#
# Examples:
#   bash ./scripts/tdd-cycle.sh red "npm test -- --grep 'creates a task'"
#   bash ./scripts/tdd-cycle.sh green "npm test -- --grep 'creates a task'"
#   bash ./scripts/tdd-cycle.sh refactor "npm test"
#   bash ./scripts/tdd-cycle.sh prove "npm test -- --grep 'completedAt'"
#
# Output format (machine-readable):
#   TDD_CYCLE=red|green|refactor|prove
#   TDD_RESULT=pass|fail
#   TDD_DETAIL=<truncated test output>
# =============================================================================

set -euo pipefail

MODE="${1:-}"
shift 1 2>/dev/null || true
TEST_CMD="${*:-}"

if [ -z "$MODE" ] || [ -z "$TEST_CMD" ]; then
  echo "Usage: $0 {red|green|refactor|prove} <test-command>" >&2
  echo "" >&2
  echo "  red       --- Confirm RED: test MUST fail" >&2
  echo "  green     --- Confirm GREEN: test MUST pass" >&2
  echo "  refactor  --- Confirm refactor: all tests MUST pass" >&2
  echo "  prove     --- Prove-It pattern: bug reproduction test MUST fail" >&2
  exit 1
fi

# Validate mode
case "$MODE" in
  red|green|refactor|prove) ;;
  *)
    echo "ERROR: Unknown mode '$MODE'. Use red, green, refactor, or prove." >&2
    exit 1
    ;;
esac

echo "TDD_CYCLE=${MODE}"
echo "TDD_COMMAND=${TEST_CMD}"
echo ""

# Run the test, capture output and exit code
set +e
TEST_OUTPUT=$(eval "$TEST_CMD" 2>&1)
TEST_EXIT=$?
set -e

# Truncate output for TDD_DETAIL (first 30 lines)
TDD_DETAIL=$(echo "$TEST_OUTPUT" | head -30)

case "$MODE" in
  red|prove)
    # Expected: test FAILS (exit non-zero)
    if [ "$TEST_EXIT" -ne 0 ]; then
      echo "TDD_RESULT=pass"
      echo "TDD_VERDICT=✓ RED confirmed --- test failed as expected"
      echo "TDD_DETAIL=${TDD_DETAIL}"
      exit 0
    else
      echo "TDD_RESULT=fail"
      echo "TDD_VERDICT=✗ RED not confirmed --- test passed when it should fail"
      echo "TDD_DETAIL=${TDD_DETAIL}"
      exit 1
    fi
    ;;
  green|refactor)
    # Expected: test PASSES (exit zero)
    if [ "$TEST_EXIT" -eq 0 ]; then
      echo "TDD_RESULT=pass"
      echo "TDD_VERDICT=✓ GREEN achieved --- all tests passing"
      echo "TDD_DETAIL=${TDD_DETAIL}"
      exit 0
    else
      echo "TDD_RESULT=fail"
      echo "TDD_VERDICT=✗ GREEN blocked --- tests still failing"
      echo "TDD_DETAIL=${TDD_DETAIL}"
      exit 1
    fi
    ;;
esac
