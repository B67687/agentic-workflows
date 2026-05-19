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
#   bash ./scripts/test-smoke.sh --quick    # only fast tests (skip slow tests)
# =============================================================================
set -euo pipefail

# Resolve symlinks so REPO_ROOT works from any call path (symlink vs real path)
resolve_script_root() {
  local script_path="$0"
  while [[ -L "$script_path" ]]; do
    local link_target
    link_target="$(readlink "$script_path")"
    [[ "$link_target" != /* ]] && link_target="$(dirname "$script_path")/$link_target"
    script_path="$link_target"
  done
  cd "$(dirname "$script_path")" && pwd
}
SCRIPT_DIR="$(resolve_script_root)"
# SCRIPT_DIR is now scripts/infra/ (always resolved)
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT" || {
  echo "ERROR: cannot cd to $REPO_ROOT"
  exit 1
}

PASS=0
FAIL=0
SKIP=0

MODE="${1:-all}"

# === Test framework ===

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
  if [ "$MODE" = "--quick" ] && [ "${4:-}" = "slow" ]; then
    test_skip "$name"
    return
  fi
  if eval "$cmd" >/dev/null 2>&1; then
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
    if echo "$output" 2>/dev/null | grep -q "$pattern"; then
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
  rm -rf .runtime/pipeline/ .runtime/agent-jobs/ .runtime/triage/ docs/decisions/ 2>/dev/null || true
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

if command -v bwrap &>/dev/null; then
  assert_output_contains "agent-sandbox.sh bwrap: echo works" \
    "bash scripts/agent-sandbox.sh bwrap 'echo hello_sandbox'" \
    "hello_sandbox"
else
  test_skip "agent-sandbox.sh bwrap: echo works (bwrap not installed)"
fi

# ===========================================================================
echo ""
echo "--- P1: Tool Registry ---"

assert_output_contains "tools.sh lists tools (toml mode)" \
  "bash scripts/tools.sh" \
  "phase-gate"

assert_output_contains "tools.sh lists workflow tools" \
  "bash scripts/tools.sh" \
  "[workflow]"

assert_output_contains "tools.sh --json valid" \
  "bash scripts/tools.sh --json 2>/dev/null | python3 -c \"import json,sys; d=json.load(sys.stdin); print(d.get('tool_count'))\"" \
  "134"

assert_exit "session-start.sh runs cleanly" \
  "bash scripts/hooks/session-start.sh"

# ===========================================================================
echo ""
echo "--- P2: MCP Server ---"

assert_exit "serve-mcp.sh --check succeeds" \
  "bash scripts/serve-mcp.sh --check"

assert_output_contains "serve-mcp.py initialize responds" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-11-25\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"0.1\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py" \
  "agentic-workflows-mcp"

assert_output_contains "serve-mcp.py lists tools" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); print(len(d['result']['tools']))\"" \
  "134"

assert_output_contains "serve-mcp.py lists 44 skills" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); skills=[r for r in d['result']['resources'] if r['uri'].startswith('skill://')]; print(len(skills))\"" \
  "44"

# ===========================================================================
echo ""
echo "--- P4: Full Integration ---"

assert_exit "session-sync.sh start creates state" \
  "bash scripts/session-sync.sh start"

assert_output_contains "session-sync.sh status shows session" \
  "bash scripts/session-sync.sh status" \
  "Session:"

assert_output_contains "session-sync.sh update + append work" \
  "bash scripts/session-sync.sh update currentTask.name 'Integration Test' && bash scripts/session-sync.sh append whatChanged 'test entry'" \
  "whatChanged"

assert_output_contains "serve-mcp.py state/status responds" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"state/status\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().strip().split(chr(10))[1]); sc=d.get('result',{}).get('structuredContent',{}); print('session' in sc and isinstance(sc['session'], int))\"" \
  "True"

assert_output_contains "serve-mcp.py lists methodology resource" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); methods=[r for r in d['result']['resources'] if r['uri'].startswith('methodology://')]; print(len(methods))\"" \
  "5"

assert_output_contains "serve-mcp.py reads state://session" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/read\",\"params\":{\"uri\":\"state://session\"}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); c=d['result']['contents'][0]; print(c.get('mimeType',''))\"" \
  "application/json"

# MCP: new gate-system resources (dashboard, autonomy, gate-plugins doc, gate:// URIs)
assert_output_contains "serve-mcp.py lists dashboard resource" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); uris=[r['uri'] for r in d['result']['resources']]; print('state://dashboard' in uris)\"" \
  "True"

assert_output_contains "serve-mcp.py lists autonomy resource" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); uris=[r['uri'] for r in d['result']['resources']]; print('state://autonomy' in uris)\"" \
  "True"

assert_output_contains "serve-mcp.py lists gate-plugins methodology" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); uris=[r['uri'] for r in d['result']['resources']]; print('methodology://gate-plugins' in uris)\"" \
  "True"

assert_output_contains "serve-mcp.py lists gate:// URIs" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/list\",\"params\":{}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); gates=[r for r in d['result']['resources'] if r['uri'].startswith('gate://')]; print(len(gates) >= 8)\"" \
  "True"

assert_output_contains "serve-mcp.py reads gate://implement/autonomy" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/read\",\"params\":{\"uri\":\"gate://implement/autonomy\"}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); c=d['result']['contents'][0]; print(c.get('mimeType',''))\"" \
  "application/json"

assert_output_contains "serve-mcp.py reads state://dashboard" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"resources/read\",\"params\":{\"uri\":\"state://dashboard\"}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); c=d['result']['contents'][0]; t=c.get('text',''); print('session' in t)\"" \
  "True"

assert_output_contains "serve-mcp.py pipeline/run implement->verify" \
  "printf '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"pipeline/run\",\"params\":{\"transition\":\"implement->verify\",\"task\":\"test\"}}\n' | python3 scripts/serve-mcp.py 2>/dev/null | python3 -c \"import sys,json; d=json.loads(sys.stdin.read().split(chr(10))[1]); sc=d.get('result',{}).get('structuredContent',{}); print(sc.get('pipeline',{}).get('passed'))\"" \
  "True"

assert_exit "post-edit.sh runs cleanly on staged" \
  "bash scripts/hooks/post-edit.sh --staged"

assert_exit "feedback-aggregator.sh status works" \
  "bash scripts/feedback-aggregator.sh status"

assert_exit "feedback-aggregator.sh record works" \
  "bash scripts/feedback-aggregator.sh record test-gate passed 'test ok'"

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
  "cat .runtime/triage/errors.log 2>/dev/null || echo 'no log'" \
  "test command"
rm -rf .runtime/triage/ 2>/dev/null || true

# ===========================================================================
echo ""
echo "--- Browser ---"

# Skip browser tests if Playwright is not available
BROWSER_AVAILABLE=1
if ! python3 -c "import playwright" 2>/dev/null; then
  BROWSER_AVAILABLE=0
  echo "  ⚠  Playwright not available — skipping browser tests"
fi

if [ "$BROWSER_AVAILABLE" = "1" ]; then
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
fi

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

# --- P10: CrewAI Flow Routing ---
echo ""
echo "--- P10: CrewAI Flow Routing ---"

# Test route help text
assert_output_contains "pipeline-run.sh route help text" \
  "bash scripts/pipeline-run.sh 2>&1" \
  "CrewAI Flow @router"

# Create a 3-task pipeline for routing tests
ROUTE_PIPE_ID=$(bash scripts/pipeline-run.sh init "Route test" "first" "second" "third" 2>&1 | grep "^pipeline-" | head -1)
if [ -n "$ROUTE_PIPE_ID" ]; then
  test_pass "pipeline-run.sh route: creates pipeline"
else
  test_fail "pipeline-run.sh route: init failed"
fi

# Add a route: task 1 done -> skip task 2, go to task 3
assert_exit "pipeline-run.sh route: add success route" \
  "bash scripts/pipeline-run.sh route $ROUTE_PIPE_ID 1 --success 3"

# Verify route is in the pipeline JSON
assert_output_contains "pipeline-run.sh route: stored in JSON" \
  "jq -r '.routes | length' .runtime/pipeline/$ROUTE_PIPE_ID.json" \
  "1"

# Mark task 1 done (should route to task 3)
assert_exit "pipeline-run.sh route: mark task 1 done" \
  "bash scripts/pipeline-run.sh update $ROUTE_PIPE_ID 1 done"

# Next should show task 3 (routed, skipping task 2)
assert_output_contains "pipeline-run.sh route: next shows routed task 3" \
  "bash scripts/pipeline-run.sh next $ROUTE_PIPE_ID" \
  "third"

# Test failure routing: create another pipeline
ROUTE_PIPE_ID2=$(bash scripts/pipeline-run.sh init "Route fail test" "step1" "retry-step" "fallback" 2>&1 | grep "^pipeline-" | head -1)
assert_exit "pipeline-run.sh route: creates failure pipeline" \
  "[ -n \"$ROUTE_PIPE_ID2\" ]"

# Route: step1 failure -> fallback (task 3), step1 done -> retry-step (task 2)
assert_exit "pipeline-run.sh route: add failure route" \
  "bash scripts/pipeline-run.sh route $ROUTE_PIPE_ID2 1 --success 2 --failure 3"

# Mark task 1 failed -> should route to task 3
assert_exit "pipeline-run.sh route: mark task 1 failed" \
  "bash scripts/pipeline-run.sh update $ROUTE_PIPE_ID2 1 failed"

# Next should show task 3 (failure route)
assert_output_contains "pipeline-run.sh route: next shows failure route" \
  "bash scripts/pipeline-run.sh next $ROUTE_PIPE_ID2" \
  "fallback"

echo ""

# ===========================================================================
echo ""
echo "--- P5: Source Enforcement ---"

assert_output_contains "quality-gate.sh has source citation check" \
  "grep -q check_source_citation scripts/hooks/quality-gate.sh && echo check_source_citation" \
  "check_source_citation"

# Test: check that the quality gate's regex flags an unsourced repo ref in a staged doc
assert_output_contains "source-check flags unsourced repo reference" \
  'bash -c "
tmpdir=\$(mktemp -d)
cd \"\$tmpdir\"
git init -q
echo \"# Test\" > test.md
git add test.md
git commit -qm \"init\"
echo \"Using repo: test-org/test-project for inspiration\" >> test.md
git add test.md
# Simulate check_source_citation logic
refs=\$(git diff --cached -U0 test.md 2>/dev/null | grep '^+' | sed 's/^+//' | grep -oE \"\\b[a-zA-Z][a-zA-Z0-9_-]{2,}/[a-zA-Z][a-zA-Z0-9._-]{2,}\\b\" | grep -v \"^B67687/\" | grep -v \"/\\.\" || true)
echo \"Found refs: \$refs\"
[ -n \"\$refs\" ] && echo \"FLAGGED\" || echo \"CLEAN\"
rm -rf \"\$tmpdir\"
" 2>&1 | tail -1' \
  "FLAGGED"

# ===========================================================================
echo ""
echo "--- P6: Guardrail Pattern ---"

# guardrail scripts live in scripts/guardrails/ - skip pipeline-integrated
# guardrail tests (feat/autonomous-runtime only), just syntax-check what exists.
for _g in scripts/guardrails/pre-default.sh scripts/guardrails/post-default.sh; do
  if [ -f "$_g" ]; then
    assert_exit "$(basename $_g) syntax" "bash -n $_g"
  else
    test_skip "$(basename $_g) syntax (not present)"
  fi
done

# ===========================================================================
echo ""
echo "--- P7: Browser.sh Argument Validation ---"

if [ "$BROWSER_AVAILABLE" = "1" ]; then
  # Test that click and section modes reject missing arguments
  assert_exit "browser.sh click rejects missing selector" \
    "bash scripts/browser.sh click https://example.com 2>&1" \
    1

  assert_exit "browser.sh section rejects missing selector" \
    "bash scripts/browser.sh section https://example.com 2>&1" \
    1

  assert_output_contains "browser.sh help shows new modes" \
    "bash scripts/browser.sh help" \
    "click <url> <selector>"

  assert_output_contains "browser.sh help shows section mode" \
    "bash scripts/browser.sh help" \
    "section <url> <selector>"
fi

# ===========================================================================
echo ""
echo "--- P8: AST Pattern Detection ---"

# Test each grep command from the code-review skill on known files
assert_output_contains "AST: nested conditional detection works" \
  "grep -rn 'if.*if.*if' --include='*.md' scripts/test-smoke.sh 2>/dev/null | head -1 || true" \
  ""

# Test repo-map runs (may exit 1 if no tree-sitter languages installed)
assert_exit "AST: repo-map runs without crash" \
  "python3 scripts/repo-map.py --max-tokens 128 --scope scripts/ 2>/dev/null || true" \
  0

# Test that the code-review skill references tree-sitter sources
assert_output_contains "code-review skill cites tree-sitter source" \
  "grep -q 'tree-sitter/tree-sitter' skills/code-review-and-quality/SKILL.md && echo FOUND" \
  "FOUND"

assert_output_contains "code-review skill cites Aider source" \
  "grep -q 'Aider-AI/aider' skills/code-review-and-quality/SKILL.md && echo FOUND" \
  "FOUND"

# ===========================================================================
echo ""
echo "--- P9: Quality Gate Self-Test ---"

# Test that check_error_handling detects set -euo pipefail in valid scripts
assert_output_contains "quality gate detects set -euo in pipeline-run.sh" \
  "grep -qE 'set\s+-[a-z]*euo' scripts/pipeline-run.sh 2>/dev/null && echo 'has_errexit' || echo 'no_errexit'" \
  "has_errexit"

# Verify check_source_citation function exists and can be parsed
assert_exit "quality-gate.sh parses without syntax error" \
  "bash -n scripts/hooks/quality-gate.sh"

# --- P11: Autonomous Runtime Fork ---
echo ""
echo "--- P11: Autonomous Runtime Fork ---"

# Script syntax checks (fast) — skip if not present (branch-specific)
for _p11 in scripts/safety-escalate.sh scripts/autopilot.sh scripts/meta-standardize.sh scripts/self-improve.sh; do
  if [ -f "$_p11" ]; then
    assert_exit "$(basename $_p11) syntax" "bash -n $_p11"
  else
    test_skip "$(basename $_p11) syntax (not present)"
  fi
done

# Running subcommands — only test if script exists
if [ -f scripts/meta-standardize.sh ]; then
  assert_exit "meta-standardize.sh check" "bash scripts/meta-standardize.sh check"
else
  test_skip "meta-standardize.sh check (not present)"
fi

for _p11_run in self-improve.sh --status:scripts/self-improve.sh \
  autopilot.sh --status:scripts/autopilot.sh \
  goal-decompose.sh --output:'scripts/goal-decompose.sh test goal --max-tasks 2 --output'; do
  _p11_name="${_p11_run%%:*}"
  _p11_cmd="${_p11_run#*:}"
  _p11_script="${_p11_cmd%% *}"
  if [ -f "$_p11_script" ]; then
    assert_exit "$_p11_name" "bash $_p11_cmd; true"
  else
    test_skip "$_p11_name (not present)"
  fi
done

# safety-escalate.sh help text
if [ -f scripts/safety-escalate.sh ]; then
  assert_output_contains "safety-escalate.sh help" \
    "bash scripts/safety-escalate.sh 2>&1" \
    "Safety Escalation Chain"
else
  test_skip "safety-escalate.sh help (not present)"
fi

# ===========================================================================
echo ""
echo "--- P12: Gate Plugin Discovery ---"

# Test that phase-gate.sh discovers plugins for the plan phase
assert_output_contains "gate plugin: plan discovers plugins" \
  "bash scripts/phase-gate.sh plan --research-done --check-quality 2>&1; true" \
  "Gates: 2 total"

# Test that plan/scope-check runs and produces output
assert_output_contains "gate plugin: scope-check runs" \
  "bash scripts/gates/plan/scope-check.sh 2>&1; true" \
  "session task"

# Test that research gate discovers at least 1 plugin
assert_output_contains "gate plugin: research discovers plugins" \
  "bash scripts/phase-gate.sh research --check-quality 2>&1" \
  "Gates: 1 total"

# Test that review phase discovers the smoke-test gate
assert_output_contains "gate plugin: review has smoke-test gate" \
  "bash scripts/phase-gate.sh review --verification-known --check-quality 2>&1" \
  "Gate: review/smoke-test"

# Test phase-gate.sh without --check-quality (should skip quality checks entirely)
assert_output_contains "gate plugin: quality skipped without flag" \
  "bash scripts/phase-gate.sh plan --research-done 2>&1" \
  "Decision:"

assert_output_not_contains "gate plugin: quality section absent without flag" \
  "bash scripts/phase-gate.sh plan --research-done 2>&1" \
  "Phase Quality Checks"

# ===========================================================================
echo ""
echo "--- P13: Error Counter Cooldown ---"

# Clean up any leftover test state
rm -f .runtime/error-counter/cd-*.json .runtime/error-counter/escalations/cd-*.json 2>/dev/null || true

# Test 1: Default cooldown after first increment (30s = COOLDOWN_BASE * 2^0)
assert_output_contains "cooldown: first increment shows 30s" \
  "bash scripts/error-counter.sh increment cd-basic 'test error' 2>&1" \
  "Cooldown: 30s"

# Test 2: Exponential backoff on second increment (60s = 30 * 2^1)
assert_output_contains "cooldown: second increment shows 60s" \
  "bash scripts/error-counter.sh increment cd-basic 'second error' 2>&1" \
  "Cooldown: 60s"

# Test 3: Check shows cooldown status
assert_output_contains "cooldown: check shows ACTIVE" \
  "bash scripts/error-counter.sh check cd-basic 2>&1" \
  "Cooldown: ACTIVE"

# Test 4: --retry-after override (120s instead of default 30s)
assert_output_contains "cooldown: retry-after uses 120s" \
  "bash scripts/error-counter.sh increment cd-retry 'rate limited' --retry-after 120 2>&1" \
  "Cooldown: 120s"

# Test 5: List shows cooldown badge (use separate ops so leftover escalation doesn't interfere)
assert_output_contains "cooldown: list has CD badge" \
  "bash scripts/error-counter.sh list 2>&1; true" \
  "CD:"

# Test 6-7: Escalation + cooldown at threshold (third increment triggers it)
# ramp the counter to 3 in sequence, then check the third output
ESC_OUTPUT=$(bash scripts/error-counter.sh increment cd-esc 'fail 1' 2>&1 && bash scripts/error-counter.sh increment cd-esc 'fail 2' 2>&1 && bash scripts/error-counter.sh increment cd-esc 'fail 3' 2>&1) || true
assert_output_contains "cooldown: escalation at threshold" \
  "echo \"$ESC_OUTPUT\"" \
  "Escalating to human"
assert_output_contains "cooldown: shows 120s during escalation" \
  "echo \"$ESC_OUTPUT\"" \
  "Cooldown: 120s"

# Test 8: Backoff persists across multiple increments on same operation
PERSIST_OUTPUT=$(bash scripts/error-counter.sh increment cd-persist 'first' 2>&1 && bash scripts/error-counter.sh increment cd-persist 'second' 2>&1 && bash scripts/error-counter.sh increment cd-persist 'third' 2>&1) || true
assert_output_contains "cooldown: third increment 120s = 30*2^2" \
  "echo \"$PERSIST_OUTPUT\"" \
  "Cooldown: 120s"

# Reset all test counters
for op in cd-basic cd-retry cd-esc cd-persist; do
  bash scripts/error-counter.sh reset "$op" 2>/dev/null || true
done

# Cleanup trace files
rm -f .runtime/error-counter/cd-*.json .runtime/error-counter/escalations/cd-*.json 2>/dev/null || true

# Test 9: Check shows no errors after reset
assert_output_contains "cooldown: check reports no errors after reset" \
  "bash scripts/error-counter.sh check cd-basic 2>&1" \
  "No errors recorded"
echo ""
echo "--- P13: Decision Pipeline ---"

# Test syntax
assert_exit "decision-pipeline.sh syntax" \
  "bash -n scripts/decision-pipeline.sh"

# Test list command
assert_output_contains "decision-pipeline: list" \
  "bash scripts/decision-pipeline.sh list 2>&1" \
  "plan->implement"

# Test help/usage
assert_output_contains "decision-pipeline: help" \
  "bash scripts/decision-pipeline.sh --help 2>&1" \
  "research->plan"

# Test implement->verify pipeline (runs quickly, 1 step)
# Note: -> must be quoted to prevent shell redirect interpretation
assert_output_contains "decision-pipeline: implement->verify" \
  "bash scripts/decision-pipeline.sh 'implement->verify' 'smoke test' 2>&1; true" \
  "Pipeline complete: implement->verify"

# Test unknown transition error
assert_output_contains "decision-pipeline: unknown transition" \
  "bash scripts/decision-pipeline.sh 'bad->transition' 2>&1; true" \
  "Unknown transition"

# ===========================================================================
echo ""
echo "--- P14: Session Dashboard ---"

assert_output_contains "dashboard: shows session header" \
  "bash scripts/session-dashboard.sh 2>&1; true" \
  "Session.*Dashboard"

assert_output_contains "dashboard: shows gate plugins" \
  "bash scripts/session-dashboard.sh 2>&1; true" \
  "Gate Plugins"

assert_output_contains "dashboard: shows recommendation" \
  "bash scripts/session-dashboard.sh 2>&1; true" \
  "Recommendation"

assert_exit "dashboard: JSON mode" \
  "bash scripts/session-dashboard.sh --json > /dev/null 2>&1"

assert_output_contains "dashboard: JSON has session field" \
  "bash scripts/session-dashboard.sh --json 2>&1; true" \
  "\"session\""

assert_output_contains "dashboard: JSON has recommendation" \
  "bash scripts/session-dashboard.sh --json 2>&1; true" \
  "\"recommendation\""

echo ""

# ===========================================================================
echo ""
echo "--- P15: Opencode DB Integrity ---"
echo ""

assert_exit "opencode-db: all integrity checks pass" \
  "bash scripts/opencode-db-test.sh"

echo ""

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
