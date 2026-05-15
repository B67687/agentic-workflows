#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/preflight
#
# Runs the implementation preflight checks before editing.
# Calls implement-preflight.sh under the hood.
#
# Standard gate interface:
#   Exit 0 = PASS (preflight ok)
#   Exit 1 = FAIL (preflight blocks)
#   Exit 2 = WARN (preflight warnings)
#   Exit 3 = SKIP (no task detected)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$REPO_ROOT/session-state.json"

echo "  ── Gate: implement/preflight"

# Extract task name from session state
task_name=""
if [[ -f "$STATE_FILE" ]]; then
  task_name=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
print(s.get('currentTask', {}).get('name', ''))
" 2>/dev/null || true)
fi

if [[ -z "$task_name" ]]; then
  echo "    SKIP   No active task in session state"
  exit 3
fi

pf="$REPO_ROOT/scripts/implement-preflight.sh"
if [[ ! -f "$pf" ]]; then
  echo "    SKIP   implement-preflight.sh not found"
  exit 3
fi

echo "    Task:  $task_name"
echo ""

output=$(bash "$pf" "$task_name" --research-done --plan-done 2>/dev/null) || true
rc=$?
echo "$output" | sed 's/^/      /'

echo ""

if [[ $rc -eq 0 ]]; then
  echo "    ✓ PASS  Preflight checks passed"
  exit 0
else
  echo "    ✗ FAIL  Preflight checks failed --- resolve issues above"
  exit 1
fi
