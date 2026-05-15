#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/decisions
#
# Checks that all required decisions have been made before implementation.
# Scans decision-log.jsonl for pending decisions.
#
# Standard gate interface:
#   Exit 0 = PASS (all decisions logged)
#   Exit 1 = FAIL (blocking decisions pending)
#   Exit 2 = WARN (minor decisions pending)
#   Exit 3 = SKIP (no decision log found)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DECISION_LOG="$RUNTIME_DIR/decision-log.jsonl"

echo "  ── Gate: implement/decisions"

if [[ ! -f "$DECISION_LOG" ]]; then
  echo "    SKIP   No decision-log.jsonl found"
  echo "           Run: bash scripts/decision.sh evaluate \"<question>\""
  exit 3
fi

# Check for PENDING_ markers or status=pending in the log
pending_count=$(grep -c 'PENDING_\|"status":"pending"' "$DECISION_LOG" 2>/dev/null || echo 0)
total_count=$(wc -l < "$DECISION_LOG" 2>/dev/null || echo 0)

echo "    Decision log: $total_count entries ($pending_count pending)"

# Check for the key decision types expected before implementation
has_model_decision=false
has_file_decision=false
has_autonomy_decision=false

if grep -q 'model.Select\|model-select\|model_selection' "$DECISION_LOG" 2>/dev/null; then
  has_model_decision=true
fi
if grep -q 'file.decision\|file_decision\|edit\|create\|split' "$DECISION_LOG" 2>/dev/null; then
  has_file_decision=true
fi
if grep -q 'autonomy\|FULL\|SUPERVISED\|RESTRICTED' "$DECISION_LOG" 2>/dev/null; then
  has_autonomy_decision=true
fi

echo "      model decision:    $($has_model_decision && echo '✓' || echo '---')"
echo "      file decision:     $($has_file_decision && echo '✓' || echo '---')"
echo "      autonomy decision: $($has_autonomy_decision && echo '✓' || echo '---')"

echo ""

if [[ "$pending_count" -gt 0 ]]; then
  echo "    ⚠ WARN  $pending_count pending decision(s)"
  echo "           Run: bash scripts/decision.sh audit --failed"
  exit 2
fi

if ! $has_model_decision || ! $has_file_decision || ! $has_autonomy_decision; then
  echo "    ⚠ WARN  Some decisions not yet logged (see above)"
  echo "           Run: bash scripts/decision.sh evaluate \"...\" --options ..."
  exit 2
fi

echo "    ✓ PASS  All decisions logged, none pending"
exit 0
