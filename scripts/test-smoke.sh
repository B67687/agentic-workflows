#!/bin/bash
# =============================================================================
# test-smoke.sh --- Smoke test suite for all agentic-workflows scripts
#
# Tests P0-P4 and pipeline integration scripts. Each test is fast, safe,
# self-contained, and gives a clear pass/fail signal.
#
# Usage:
#   bash ./scripts/test-smoke.sh            # run all tests
#   bash ./scripts/test-smoke.sh --list     # list available tests
#   bash ./scripts/test-smoke.sh --quick    # only fast tests (skip sandbox)
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0
SKIP=0

MODE="${1:-all}"

# === Test framework ===

test_pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
test_fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }
test_skip() { SKIP=$((SKIP + 1)); echo "  - $1 (skipped)"; }

assert_exit() {
  local name="$1" cmd="$2" expected="${3:-0}"
  if [ "$MODE" = "--quick" ] && [ "${4:-}" = "slow" ]; then
    test_skip "$name"
    return
  fi
  if eval "$cmd" > /dev/null 2>&1; then
    actual=0
  else
    actual=$?
  fi
  if [ "$actual" = "$expected" ]; then
    test_pass "$name"
  else
    test_fail "$name (expected exit $expected, got $actual)"
  fi
}

assert_output_contains() {
  local name="$1" cmd="$2" pattern="$3"
  if output=$(eval "$cmd" 2>&1); then
    if echo "$output" | grep -q "$pattern"; then
      test_pass "$name"
    else
      test_fail "$name (output missing: '$pattern')"
    fi
  else
    test_fail "$name (exit $?)"
  fi
}

assert_output_not_contains() {
  local name="$1" cmd="$2" pattern="$3"
  if output=$(eval "$cmd" 2>&1); then
    if echo "$output" | grep -qv "$pattern"; then
      test_pass "$name"
    else
      test_fail "$name (unexpected: '$pattern')"
    fi
  else
    test_fail "$name (exit $?)"
  fi
}

cleanup() {
  rm -rf .pipeline/ .agent-jobs/ .triage/ docs/decisions/ 2>/dev/null || true
}
trap cleanup EXIT
cleanup

echo "=== Smoke Tests ==="
echo ""

# ===========================================================================
echo "--- P0: Sandbox ---"

assert_output_contains "agent-sandbox.sh help text" \
  "bash scripts/agent-sandbox.sh help" \
  "Bubblewrap"

assert_output_contains "agent-sandbox.sh bwrap: echo works" \
  "bash scripts/agent-sandbox.sh bwrap 'echo hello_sandbox'" \
  "hello_sandbox"

# ===========================================================================
echo ""
echo "--- P1: Tool Registry ---"

assert_output_contains "tools.sh lists scripts" \
  "bash scripts/tools.sh" \
  "script/"

assert_output_contains "tools.sh lists commands" \
  "bash scripts/tools.sh" \
  "command/"

assert_exit "session-start.sh runs cleanly" \
  "bash scripts/hooks/session-start.sh"

# ===========================================================================
echo ""
echo "--- P2: Scripted Skills ---"

# explore.py
assert_output_contains "explore.py file-stats" \
  "python3 skills/bash-explore/core/explore.py file-stats" \
  "\.md"

assert_output_contains "explore.py dir-tree" \
  "python3 skills/bash-explore/core/explore.py dir-tree --max-depth 2" \
  "skills"

assert_output_contains "explore.py find-by-name" \
  "python3 skills/bash-explore/core/explore.py find-by-name 'SKILL.md'" \
  "SKILL.md"

assert_output_contains "explore.py largest-files" \
  "python3 skills/bash-explore/core/explore.py largest-files --ext .md --top 3" \
  "\.md"

# triage.sh
assert_output_contains "triage.sh outputs JSON" \
  "bash skills/debugging-and-error-recovery/scripts/triage.sh" \
  '"timestamp"'

assert_output_contains "triage.sh has git state" \
  "bash skills/debugging-and-error-recovery/scripts/triage.sh" \
  '"sha"'

# create-adr.sh
assert_output_contains "create-adr.sh creates ADR" \
  "bash skills/documentation-and-adrs/scripts/create-adr.sh 'Smoke test ADR'" \
  "ADR-001"
# clean up test ADR
rm -rf docs/decisions/ 2>/dev/null || true

# log-error.sh
assert_exit "log-error.sh captures error" \
  "echo 'simulated failure' | bash scripts/log-error.sh 'test command'"
assert_output_contains "log-error.sh creates error log" \
  "cat .triage/errors.log 2>/dev/null || echo 'no log'" \
  "test command"
rm -rf .triage/ 2>/dev/null || true

# ===========================================================================
echo ""
echo "--- Browser ---"

assert_output_contains "browser.sh help" \
  "bash scripts/browser.sh help" \
  "navigate"

assert_output_contains "browser.sh navigate" \
  "bash scripts/browser.sh navigate https://example.com" \
  "Example Domain"

assert_output_contains "browser.sh text" \
  "bash scripts/browser.sh text https://example.com" \
  "Example Domain"

assert_output_contains "browser.sh check (found)" \
  "bash scripts/browser.sh check https://example.com 'Example'" \
  "FOUND"

assert_output_contains "browser.sh check (not found)" \
  "bash scripts/browser.sh check https://example.com 'NonexistentTextXYZ'" \
  "NOT FOUND"

# ===========================================================================
echo ""
echo "--- P3: Async Agent Dispatch ---"

assert_output_contains "agent-dispatch.sh help" \
  "bash scripts/agent-dispatch.sh help" \
  "pi"

assert_exit "agent-dispatch.sh list (empty)" \
  "bash scripts/agent-dispatch.sh list"

assert_output_contains "agent-dispatch.sh status (no args)" \
  "bash scripts/agent-dispatch.sh status" \
  "Recent"

# _agent_runner.py with missing env vars should fail gracefully
assert_exit "_agent_runner.py fails without env vars" \
  "python3 scripts/_agent_runner.py 2>&1" \
  1

# ===========================================================================
echo ""
echo "--- P4: Session Health ---"

assert_output_contains "context-pressure.sh health report" \
  "bash scripts/context-pressure.sh" \
  "Session Health"
# Verify not CRITICAL (both HEALTHY and WARNING are acceptable)
assert_output_not_contains "context-pressure.sh health report (not critical)" \
  "bash scripts/context-pressure.sh" \
  "CRITICAL"

assert_output_contains "context-pressure.sh --json" \
  "bash scripts/context-pressure.sh --json" \
  '"status"'

assert_exit "context-pressure.sh --check (healthy)" \
  "bash scripts/context-pressure.sh --check" \
  0

# ===========================================================================
echo ""
echo "--- Pipeline Integration ---"

assert_exit "pipeline-run.sh list (empty)" \
  "bash scripts/pipeline-run.sh list"

# Create a pipeline
PIPELINE_ID=$(bash scripts/pipeline-run.sh init "Smoke test" "task alpha" "task beta" 2>&1 | grep "^pipeline-" | head -1)
if [ -n "$PIPELINE_ID" ]; then
  test_pass "pipeline-run.sh creates pipeline"
else
  test_fail "pipeline-run.sh init failed"
fi

# Check pipeline status
assert_output_contains "pipeline-run.sh shows status" \
  "bash scripts/pipeline-run.sh status $PIPELINE_ID" \
  "task alpha"

# Check update
assert_exit "pipeline-run.sh update task" \
  "bash scripts/pipeline-run.sh update $PIPELINE_ID 1 done"

# Check next (should show task 2)
assert_output_contains "pipeline-run.sh next picks next task" \
  "bash scripts/pipeline-run.sh next $PIPELINE_ID" \
  "task beta"

# ===========================================================================
echo ""
echo "=== Results ==="
echo "  Pass: $PASS"
echo "  Fail: $FAIL"
echo "  Skip: $SKIP"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "FAILURES DETECTED"
  exit 1
else
  echo "ALL TESTS PASSED"
  exit 0
fi
