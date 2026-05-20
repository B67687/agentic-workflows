#!/bin/bash
# =============================================================================
# test-benchmark-tools.sh --- Tests for benchmark/dispatch harness tooling
#
# Tests:
#   - worker-dispatch.sh: prompt generation
#   - reverify-bigcodebench.py: argument parsing, help text
#   - audit-state.sh: runs without crashing, detects known state
#   - run-terminal-bench-adapter.sh: help/usage
#   - tools registry consistency: all registered scripts exist on disk
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0
SKIP=0

test_pass() {
  PASS=$((PASS + 1))
  echo "  ✓ $1"
}
test_fail() {
  FAIL=$((FAIL + 1))
  echo "  ✗ $1"
}
test_skip() {
  SKIP=$((SKIP + 1))
  echo "  - $1 (skipped)"
}

assert_exit() {
  local name="$1" cmd="$2" expected="${3:-0}"
  if eval "$cmd" >/dev/null 2>&1; then actual=0; else actual=$?; fi
  if [ "$actual" = "$expected" ]; then
    test_pass "$name"
  else test_fail "$name (expected exit $expected, got $actual)"; fi
}

assert_output_contains() {
  local name="$1" cmd="$2" pattern="$3"
  if output=$(eval "$cmd" 2>&1); then
    if echo "$output" | grep -q "$pattern"; then
      test_pass "$name"
    else test_fail "$name (output missing: '$pattern')"; fi
  else test_fail "$name (exit $?)"; fi
}

echo "=== Benchmark Harness Tool Tests ==="
echo ""

# ===========================================================================
echo "--- Worker Dispatch ---"

assert_output_contains "worker-dispatch.sh --help shows usage" \
  "bash scripts/tools/worker-dispatch.sh --help" \
  "Usage"

assert_output_contains "worker-dispatch.sh with task arg generates prompt" \
  "bash scripts/tools/worker-dispatch.sh --task 'test task' --run-dir /tmp/test-wd" \
  "Steps:"

assert_exit "worker-dispatch.sh missing --run-dir fails" \
  "bash scripts/tools/worker-dispatch.sh --task 'test' 2>&1" 1

assert_exit "worker-dispatch.sh missing --task fails" \
  "bash scripts/tools/worker-dispatch.sh --run-dir /tmp/test 2>&1" 1

assert_output_contains "worker-dispatch.sh --verify-only mode" \
  "bash scripts/tools/worker-dispatch.sh --verify-only --run-dir /tmp/test-wd 2>&1" \
  "verify"

echo ""
# ===========================================================================
echo "--- Benchmark Dispatch ---"

# Check that benchmark-dispatch.sh exists and is well-formed
if [ -f scripts/tools/benchmark-dispatch.sh ]; then
  assert_exit "benchmark-dispatch.sh help exit 0" \
    "bash scripts/tools/benchmark-dispatch.sh --help 2>&1" 0

  assert_output_contains "benchmark-dispatch.sh help text" \
    "bash scripts/tools/benchmark-dispatch.sh --help 2>&1" \
    "Usage"
else
  test_skip "benchmark-dispatch.sh (not yet created)"
fi

echo ""
# ===========================================================================
echo "--- reverify-bigcodebench.py ---"

PY_SCRIPT="scripts/bench/public/reverify-bigcodebench.py"

assert_exit "reverify-bigcodebench.py --help exits 0" \
  "source .runtime/bench-env/bin/activate && python3 $PY_SCRIPT --help" 0

assert_output_contains "reverify-bigcodebench.py help text" \
  "source .runtime/bench-env/bin/activate && python3 $PY_SCRIPT --help" \
  "Re-verify"

assert_output_contains "reverify-bigcodebench.py lists --unknown-only" \
  "source .runtime/bench-env/bin/activate && python3 $PY_SCRIPT --help" \
  "unknown-only"

echo ""
# ===========================================================================
echo "--- audit-state.sh ---"

if [ -d .runtime/bench-runs ]; then
  assert_exit "audit-state.sh runs cleanly" \
    "timeout 30 bash scripts/bench/audit-state.sh" 0

  assert_output_contains "audit-state.sh shows BigCodeBench state" \
    "timeout 30 bash scripts/bench/audit-state.sh" \
    "BigCodeBench"
else
  test_skip "audit-state.sh (no bench-runs directory)"
fi

echo ""
# ===========================================================================
echo "--- Terminal-Bench Adapter ---"

TB_SCRIPT="scripts/tools/run-terminal-bench-adapter.sh"
if [ -f "$TB_SCRIPT" ]; then
  assert_exit "run-terminal-bench-adapter.sh --help" \
    "bash $TB_SCRIPT --help 2>&1" 0

  assert_output_contains "run-terminal-bench-adapter.sh help text" \
    "bash $TB_SCRIPT --help 2>&1" \
    "Terminal-Bench"
else
  test_skip "run-terminal-bench-adapter.sh (not yet created)"
fi

echo ""
# ===========================================================================
echo "--- Tools Registry Consistency ---"

# Verify every script in tools.json actually exists on disk
TOOLS_JSON=$(bash scripts/tools.sh --json 2>/dev/null || true)
if [ -n "$TOOLS_JSON" ]; then
  MISSING=0
  while IFS='|' read -r name script_path; do
    if [ -n "$script_path" ] && [ ! -f "$REPO_ROOT/$script_path" ] && [ ! -f "$script_path" ]; then
      echo "  ! MISSING: $name -> $script_path"
      MISSING=$((MISSING + 1))
    fi
  done < <(echo "$TOOLS_JSON" | python3 -c "
import json, sys
d = json.load(sys.stdin)
for t in d.get('tools', []):
    name = t.get('name', '?')
    script = t.get('script', '') or ''
    print(f'{name}|{script}')
" 2>/dev/null || true)

  if [ "$MISSING" -eq 0 ]; then
    test_pass "All registered tool scripts exist on disk"
  else
    echo "  ✗ $MISSING registered scripts missing from disk"
  fi
else
  test_skip "tools registry JSON (not available)"
fi

echo ""
# ===========================================================================
echo "--- Benchmark Script Syntax Checks ---"

for script in scripts/bench/audit-state.sh \
  scripts/bench/public/reverify-bigcodebench.py \
  scripts/bench/public/solve-bigcodebench.py \
  scripts/bench/public/verify-bigcodebench.py \
  scripts/tools/worker-dispatch.sh \
  scripts/tools/run-terminal-bench-adapter.sh; do
  if [ -f "$script" ]; then
    case "$script" in
    *.sh) assert_exit "$(basename $script) syntax" "bash -n $script" ;;
    *.py) assert_exit "$(basename $script) syntax" \
      "source .runtime/bench-env/bin/activate && python3 -c 'import ast; ast.parse(open(\"$script\").read())'" ;;
    esac
  else
    test_skip "$(basename $script) syntax (not found)"
  fi
done

echo ""
# ===========================================================================
echo "--- Bench Run Data Guardrails ---"

# Test that cleanup-runs.sh rejects dangerous patterns
if [ -f scripts/bench/cleanup-runs.sh ]; then
  assert_output_contains "cleanup-runs: rejects empty RID" \
    "bash scripts/bench/cleanup-runs.sh rm '' 2>&1; true" \
    "not allowed"

  assert_output_contains "cleanup-runs: rejects glob pattern" \
    "bash scripts/bench/cleanup-runs.sh rm 'bigcodebench-*' 2>&1; true" \
    "not allowed"

  assert_output_contains "cleanup-runs: list works" \
    "timeout 10 bash scripts/bench/cleanup-runs.sh list 2>&1 || true" \
    "=== Benchmark Runs"
else
  test_skip "cleanup-runs.sh (not found)"
fi

echo ""
# ===========================================================================
echo "--- Result: $PASS pass, $FAIL fail, $SKIP skip ---"
if [ "$FAIL" -gt 0 ]; then
  echo "FAILURES DETECTED"
  exit 1
else
  echo "ALL TESTS PASSED"
  exit 0
fi
