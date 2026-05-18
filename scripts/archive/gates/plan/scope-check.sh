#!/usr/bin/env bash
# =============================================================================
# Gate plugin: plan/scope-check
#
# Checks that the task scope is properly bounded before implementation.
# Looks for scope markers in plans, task descriptions, and session state.
# This is a NEW check that was previously unmplemented.
#
# Standard gate interface:
#   Exit 0 = PASS (scope clearly bounded)
#   Exit 1 = FAIL (scope unbounded)
#   Exit 2 = WARN (scope loosely defined)
#   Exit 3 = SKIP (no scope data to check)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$REPO_ROOT/session-state.json"

echo "  ── Gate: plan/scope-check"

# Check 1: plan.json has bounded scope
plan_file="$RUNTIME_DIR/plan.json"
plan_has_scope=false
if [[ -f "$plan_file" ]]; then
  if python3 -c "
import json, sys
with open('$plan_file') as f:
    p = json.load(f)
# Check for scope-related fields
scope_ok = bool(p.get('scope')) or bool(p.get('boundary')) or bool(p.get('verification'))
sys.exit(0 if scope_ok else 1)
" 2>/dev/null; then
    plan_has_scope=true
  fi
fi

# Check 2: session-state.json has a currentTask with scope info
state_has_scope=false
state_has_files=false
if [[ -f "$STATE_FILE" ]]; then
  if python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    s = json.load(f)
task = s.get('currentTask', {})
files = s.get('filesTouched', [])
goal = task.get('goal', '')
status = task.get('status', '')
ok = bool(goal) and bool(status) and len(files) > 0
sys.exit(0 if ok else 1)
" 2>/dev/null; then
    state_has_scope=true
    state_has_files=true
  fi
fi

# Check 3: Task intake determined a size
size_known=false
intake_log="$RUNTIME_DIR/task-intake.json"
if [[ -f "$intake_log" ]]; then
  size_known=true
fi

# Score: 2 checks needed for pass
pass_count=0
warn_count=0
$plan_has_scope && pass_count=$((pass_count + 1)) || warn_count=$((warn_count + 1))
$state_has_scope && pass_count=$((pass_count + 1)) || warn_count=$((warn_count + 1))
$size_known && pass_count=$((pass_count + 1)) || true

echo "    Scope signals:"
echo "      plan.json scope:      $($plan_has_scope && echo '✓ found' || echo '--- missing')"
echo "      session task + files: $($state_has_scope && echo '✓ found' || echo '--- missing')"
echo "      task intake record:   $($size_known && echo '✓ found' || echo '--- not found')"

if [[ "$pass_count" -ge 2 ]]; then
  echo ""
  echo "    ✓ PASS  Scope adequately bounded"
  exit 0
elif [[ "$pass_count" -ge 1 ]]; then
  echo ""
  echo "    ⚠ WARN  Scope partially defined --- tighten before implementing"
  exit 2
else
  echo ""
  echo "    ⚠ WARN  No scope bounding detected"
  echo "           Run: bash scripts/task-intake.sh \"<task>\" --size light|medium|heavy"
  exit 2
fi
