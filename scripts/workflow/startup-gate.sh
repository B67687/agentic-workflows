#!/usr/bin/env bash
# =============================================================================
# startup-gate.sh — Force workflow state check at session start
#
# Outputs:
#   WORKFLOW_ACTIVE=true|false  (machine-readable, sourced by agent)
#   Human-readable state block for the agent to consume.
#
# Exit codes:
#   0 — state is healthy
#   1 — corrupt state (should be reset)
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STATE_FILE="$REPO_ROOT/workflow-state.json"

# ── Read and validate state ────────────────────────────────────────────────────
if [ ! -f "$STATE_FILE" ]; then
  echo '{"workflow":null,"step":null,"context":{},"trace":[]}' >"$STATE_FILE"
elif ! python3 -c "import json,sys; json.load(open('$STATE_FILE'))" 2>/dev/null; then
  echo "!!! workflow-state.json is corrupt. Resetting."
  echo '{"workflow":null,"step":null,"context":{},"trace":[]}' >"$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")
WORKFLOW=$(echo "$STATE" | python3 -c "import json,sys; d=json.load(sys.stdin); w=d.get('workflow'); print(w if w else '')")
STEP=$(echo "$STATE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('step') or '')")
TRACE_COUNT=$(echo "$STATE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('trace', [])))")

# ── Output ────────────────────────────────────────────────────────────────────
echo ""
echo "=== Workflow State ==="

if [ -n "$WORKFLOW" ] && [ "$WORKFLOW" != "None" ]; then
  echo "  Active:   $WORKFLOW"
  echo "  Step:     $STEP"
  echo "  Trace:    $TRACE_COUNT entries"
  echo "  WORKFLOW_ACTIVE=true"
else
  echo "  Active:   none"
  echo "  WORKFLOW_ACTIVE=false"
fi

echo ""

if [ -z "$WORKFLOW" ] || [ "$WORKFLOW" = "None" ]; then
  # ── List available workflows ────────────────────────────────────────────────
  echo "  Available workflows:"
  for f in "$REPO_ROOT"/workflow.d/*.yaml; do
    name=$(basename "$f" .yaml)
    { [ "$name" = "root" ] || [ "$name" = "SCHEMA" ]; } && continue
    desc=$(grep '^description:' "$f" | sed 's/description: *//')
    [ -z "$desc" ] && desc="(no description)"
    printf "    %-15s  %s\n" "$name" "$desc"
  done
  echo ""
  echo "  Action required:"
  echo "    → Classify the user's request and run the appropriate workflow"
  echo "    → Update workflow-state.json with the workflow id and first step"
  echo "    → Begin step execution"
fi

echo "=== End Workflow State ==="
