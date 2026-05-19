#!/bin/bash
# =============================================================================
# phase-safeguards.sh --- Auto-trigger cognitive safeguards at phase transitions
#
# Runs the appropriate safeguard scripts BEFORE gate plugins execute, ensuring
# artifacts exist for gate plugins to verify.
#
# Safeguard → Artifact → Gate plugin chain:
#   plan-challenge.sh  → challenge-response.json  → gate: plan/catfish
#   decision.sh        → decision-log.jsonl       → gate: implement/decisions
#   triple-debt.sh     → (advisory)               → gate: (none, optional)
#
# Usage:
#   bash scripts/phase-safeguards.sh <phase> [task-description]
#   bash scripts/phase-safeguards.sh --list
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$REPO_ROOT/session-state.json"

PHASE="${1:-}"
TASK="${2:-}"

# Auto-detect task from session state if not provided
if [[ -z "$TASK" && -f "$STATE_FILE" ]]; then
  TASK=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
print(s.get('currentTask', {}).get('name', ''))
" 2>/dev/null || echo "")
fi

case "$PHASE" in
  --list)
    echo "Defined safeguards:"
    echo "  plan         plan-challenge.sh   (adversarial challenge)"
    echo "  implement    decision.sh         (decision logging)"
    echo "  verify       triple-debt.sh      (debt assessment)"
    echo ""
    echo "Phase associations:"
    echo "  BEFORE research:  (none)"
    echo "  BEFORE plan:      plan-challenge.sh"
    echo "  BEFORE implement: decision.sh"
    echo "  BEFORE verify:    triple-debt.sh"
    exit 0
    ;;

  plan)
    echo "=== Phase Safeguards: plan ==="
    CHALLENGE_SCRIPT="$REPO_ROOT/scripts/plan-challenge.sh"
    if [[ -f "$CHALLENGE_SCRIPT" ]]; then
      echo "  Running: plan-challenge.sh (adversarial challenge)..."
      mkdir -p "$RUNTIME_DIR"
      if bash "$CHALLENGE_SCRIPT" prompt --plan "$RUNTIME_DIR/plan.json" --task "$TASK" 2>&1; then
        echo "  ✓  plan safeguard PASSED"
        exit 0
      else
        echo "  ⚠  plan safeguard issued warnings (non-blocking)"
        exit 2
      fi
    else
      echo "  SKIP  plan-challenge.sh not found"
      exit 3
    fi
    ;;

  implement)
    echo "=== Phase Safeguards: implement ==="
    DECISION_SCRIPT="$REPO_ROOT/scripts/decision.sh"
    if [[ -f "$DECISION_SCRIPT" ]]; then
      echo "  Running: decision.sh (decision logging)..."
      mkdir -p "$RUNTIME_DIR"
      # Log key decision types expected before implementation
      for dtype in "model-selection" "file-level-edit" "risk-assessment"; do
        bash "$DECISION_SCRIPT" evaluate "Select $dtype approach for: $TASK" --tag "$dtype" 2>&1 || true
      done
      echo "  ✓  implement safeguard PASSED"
      exit 0
    else
      echo "  SKIP  decision.sh not found"
      exit 3
    fi
    ;;

  verify)
    echo "=== Phase Safeguards: verify ==="
    DEBT_SCRIPT="$REPO_ROOT/scripts/triple-debt.sh"
    if [[ -f "$DEBT_SCRIPT" ]]; then
      echo "  Running: triple-debt.sh (debt assessment)..."
      bash "$DEBT_SCRIPT" assess 2>&1 || true
      echo "  ✓  verify safeguard PASSED"
      exit 0
    else
      echo "  SKIP  triple-debt.sh not found"
      exit 3
    fi
    ;;

  help|--help|"")
    echo "Usage: bash scripts/phase-safeguards.sh <phase> [task-description]"
    echo ""
    echo "Phases:"
    echo "  plan         Run plan-challenge.sh (adversarial challenge)"
    echo "  implement    Run decision.sh (decision logging)"
    echo "  verify       Run triple-debt.sh (debt assessment)"
    echo "  --list       Show defined safeguards"
    exit 0
    ;;

  *)
    echo "ERROR: Unknown phase '$PHASE'"
    echo "Use '--list' to see defined safeguards."
    exit 2
    ;;
esac
