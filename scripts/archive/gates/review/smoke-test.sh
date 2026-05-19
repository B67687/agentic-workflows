#!/usr/bin/env bash
# =============================================================================
# Gate plugin: review/smoke-test
#
# Runs core smoke checks during review phase transitions.
# Tests only fast, local, deterministic checks (no MCP/network).
# Use the full suite for thorough verification: bash scripts/infra/test-smoke.sh
#
# Standard gate interface:
#   Exit 0 = PASS (core checks pass)
#   Exit 1 = FAIL (core checks fail — blocking)
#   Exit 3 = SKIP (prerequisites not available)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "  ── Gate: review/smoke-test"

checks=0
failures=0

# Check 1: Git state is sane
if git -C "$REPO_ROOT" rev-parse HEAD >/dev/null 2>&1; then
  checks=$((checks + 1))
  echo "    ✓  Git HEAD is reachable"
else
  checks=$((checks + 1))
  failures=$((failures + 1))
  echo "    ✗  Git HEAD not found"
fi

# Check 2: Script syntax (bash -n) on key infrastructure scripts
for script in scripts/infra/checkpoint-commit.sh scripts/infra/checkpoint-review.sh scripts/hooks/quality-gate.sh; do
  if [[ -f "$REPO_ROOT/$script" ]]; then
    checks=$((checks + 1))
    if bash -n "$REPO_ROOT/$script" 2>/dev/null; then
      echo "    ✓  Syntax: $script"
    else
      failures=$((failures + 1))
      echo "    ✗  Syntax: $script"
    fi
  fi
done

# Check 3: Goal tree is valid JSON
if [[ -f "$REPO_ROOT/.runtime/goal-tree.json" ]]; then
  checks=$((checks + 1))
  if python3 -c "import json; json.load(open('$REPO_ROOT/.runtime/goal-tree.json'))" 2>/dev/null; then
    echo "    ✓  Goal tree: valid JSON"
  else
    failures=$((failures + 1))
    echo "    ✗  Goal tree: invalid JSON"
  fi
fi

# Check 4: Workflow state is valid JSON
if [[ -f "$REPO_ROOT/workflow-state.json" ]]; then
  checks=$((checks + 1))
  if python3 -c "import json; json.load(open('$REPO_ROOT/workflow-state.json'))" 2>/dev/null; then
    echo "    ✓  Workflow state: valid JSON"
  else
    failures=$((failures + 1))
    echo "    ✗  Workflow state: invalid JSON"
  fi
fi

echo ""

if [[ "$failures" -eq 0 ]]; then
  echo "    ✓ PASS  $checks core check(s) passed"
  echo "    For full suite: bash scripts/infra/test-smoke.sh"
  exit 0
else
  echo "    ✗ FAIL  $failures/$checks check(s) failed"
  echo "    Next: Review failures above"
  exit 1
fi
