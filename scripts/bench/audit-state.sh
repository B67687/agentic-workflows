#!/usr/bin/env bash
# ==============================================================================
# audit-state.sh -- Deterministic health probe for session handover integrity
#
# Counts actual benchmark results from .runtime/bench-runs/ and compares
# against expected values from HANDOVER.md. Reports discrepancies.
#
# Usage:
#   bash scripts/bench/audit-state.sh
#
# Exit codes:
#   0 - State matches HANDOVER.md (or within tolerance)
#   1 - State has drifted (discrepancy found)
#   2 - Cannot determine state (missing data)
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"
HANDOVER="$REPO_ROOT/HANDOVER.md"

# Expected values from HANDOVER.md (update these when HANDOVER changes)
HANDOVER_BC_PASS=623
HANDOVER_BC_FAIL=35
HANDOVER_BC_UNKNOWN=483
HANDOVER_BC_TOTAL=1141

echo "=== Health Probe: Benchmark State Audit ==="
echo "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo ""

# --- BigCodeBench ---
echo "--- BigCodeBench ---"
if [[ ! -d "$RUNS_DIR" ]]; then
  echo "ERROR: $RUNS_DIR does not exist"
  exit 2
fi

BC_PASS=0
BC_FAIL=0
BC_UNKNOWN=0
BC_TOTAL=0

for d in "$RUNS_DIR"/bigcodebench-*; do
  if [[ -d "$d" ]]; then
    BC_TOTAL=$((BC_TOTAL + 1))
    rpath="$d/result.json"
    if [[ -f "$rpath" ]]; then
      success=$(python3 -c "import json; print(json.load(open('$rpath')).get('success', False))" 2>/dev/null || echo "false")
      if [[ "$success" == "True" ]]; then
        BC_PASS=$((BC_PASS + 1))
      else
        BC_FAIL=$((BC_FAIL + 1))
      fi
    else
      BC_UNKNOWN=$((BC_UNKNOWN + 1))
    fi
  fi
done

echo "  Actual:    $BC_PASS pass, $BC_FAIL fail, $BC_UNKNOWN unknown (total $BC_TOTAL)"
echo "  Handover:  $HANDOVER_BC_PASS pass, $HANDOVER_BC_FAIL fail, $HANDOVER_BC_UNKNOWN unknown (total $HANDOVER_BC_TOTAL)"

DRIFT=0
if [[ "$BC_PASS" -ne "$HANDOVER_BC_PASS" ]]; then
  echo "  !! DRIFT: Pass count differs by $((BC_PASS - HANDOVER_BC_PASS))"
  DRIFT=1
fi
if [[ "$BC_FAIL" -ne "$HANDOVER_BC_FAIL" ]]; then
  echo "  !! DRIFT: Fail count differs by $((BC_FAIL - HANDOVER_BC_FAIL))"
  DRIFT=1
fi
if [[ "$BC_TOTAL" -ne "$HANDOVER_BC_TOTAL" ]]; then
  echo "  !! DRIFT: Total dirs differs by $((BC_TOTAL - HANDOVER_BC_TOTAL))"
  DRIFT=1
fi

# --- Terminal-Bench Oracle ---
echo ""
echo "--- Terminal-Bench Oracle ---"
TB_DIR="$RUNS_DIR/terminal-bench-oracle-20260520"
if [[ -f "$TB_DIR/summary.json" ]]; then
  TB_MEAN=$(python3 -c "import json; print(json.load(open('$TB_DIR/summary.json')).get('mean', '?'))" 2>/dev/null)
  echo "  Oracle baseline: mean=$TB_MEAN (expected 0.955)"
else
  echo "  WARNING: Oracle summary not found at $TB_DIR/summary.json"
fi

# --- Summary ---
echo ""
if [[ "$DRIFT" -eq 1 ]]; then
  echo "RESULT: STATE DRIFT DETECTED"
  echo "Action: Do NOT proceed with backlog work. Reconcile before continuing."
  exit 1
else
  echo "RESULT: State matches handover"
  exit 0
fi
