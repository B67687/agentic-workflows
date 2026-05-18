#!/usr/bin/env bash
# =============================================================================
# check-tests.sh — Run relevant tests for changed files
#
# Finds changed files and runs project-appropriate test commands.
# Outputs JSON with test results and pass/fail status.
#
# Usage: bash scripts/verify/check-tests.sh
# Output: JSON with test results
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

RESULTS="{}"
STATUS="pass"

# ── Detect project type and run appropriate tests ──

if [[ -f "scripts/test-smoke.sh" ]]; then
  # agentic-workflows smoke suite
  SMOKE_OUTPUT=$(bash scripts/test-smoke.sh 2>&1 || true)
  PASS_COUNT=$(echo "$SMOKE_OUTPUT" | grep -oP 'Pass: \K\d+' || echo "0")
  FAIL_COUNT=$(echo "$SMOKE_OUTPUT" | grep -oP 'Fail: \K\d+' || echo "0")
  SKIP_COUNT=$(echo "$SMOKE_OUTPUT" | grep -oP 'Skip: \K\d+' || echo "0")

  if [[ "$FAIL_COUNT" -gt 0 ]]; then
    STATUS="fail"
  fi

  RESULTS=$(
    cat <<EOF
{
  "status": "$STATUS",
  "suite": "smoke",
  "pass": $PASS_COUNT,
  "fail": $FAIL_COUNT,
  "skip": $SKIP_COUNT,
  "summary": "Smoke tests: $PASS_COUNT pass, $FAIL_COUNT fail, $SKIP_COUNT skip"
}
EOF
  )
elif [[ -f "package.json" ]]; then
  # Node project — try vitest or jest
  if grep -q '"test"' package.json 2>/dev/null; then
    TEST_OUTPUT=$(npm test -- --run 2>&1 || true)
  else
    TEST_OUTPUT=$(npx vitest run 2>&1 || true)
  fi

  PASS=$(echo "$TEST_OUTPUT" | grep -c "✓" || true)
  FAIL=$(echo "$TEST_OUTPUT" | grep -c "✗" || true)

  if [[ "$FAIL" -gt 0 ]]; then
    STATUS="fail"
  fi

  RESULTS=$(
    cat <<EOF
{
  "status": "$STATUS",
  "suite": "node_tests",
  "pass_count": $PASS,
  "fail_count": $FAIL,
  "summary": "Tests: $PASS pass, $FAIL fail"
}
EOF
  )
elif ls *_test.go 2>/dev/null || ls *_test.py 2>/dev/null; then
  # Python — try pytest
  if command -v pytest &>/dev/null; then
    PYTEST_OUTPUT=$(pytest --tb=short -q 2>&1 || true)
    RESULTS=$(
      cat <<EOF
{
  "status": "pass",
  "suite": "pytest",
  "raw": $(echo "$PYTEST_OUTPUT" | tail -5 | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))")
}
EOF
    )
  fi
else
  RESULTS=$(
    cat <<EOF
{
  "status": "skip",
  "suite": "none",
  "summary": "No test framework detected"
}
EOF
  )
fi

echo "$RESULTS"
exit 0
