#!/usr/bin/env bash
# =============================================================================
# Gate plugin: plan/catfish
#
# Checks whether the plan has been challenged via the CATFISH protocol.
# If a challenge-response exists, runs reconcile. If not, reports SKIP.
#
# Standard gate interface:
#   Exit 0 = PASS (plan reconciled against challenge)
#   Exit 1 = FAIL (reconcile failed --- block)
#   Exit 2 = WARN (reconcile has minor issues)
#   Exit 3 = SKIP (no challenge data available)
#
# Output: structured gate result to stdout
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"

echo "  ── Gate: plan/catfish"

PLAN_FILE="$RUNTIME_DIR/plan.json"
CHALLENGE_RESPONSE="$RUNTIME_DIR/challenge-response.json"

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "    SKIP   No plan.json found in .runtime/"
  echo "           The plan must exist before CATFISH can challenge it"
  exit 3
fi

if [[ ! -f "$CHALLENGE_RESPONSE" ]]; then
  echo "    SKIP   No challenge-response.json found"
  echo "           Run: plan-guard.sh --challenge, then dispatch subagent"
  echo "           Or:  bash scripts/plan-challenge.sh prompt --plan .runtime/plan.json"
  exit 3
fi

pc="$REPO_ROOT/scripts/plan-challenge.sh"
if [[ ! -f "$pc" ]]; then
  echo "    SKIP   plan-challenge.sh not found"
  exit 3
fi

echo "    Plan:  plan.json"
echo "    Resp:  challenge-response.json"
echo ""

output=$(bash "$pc" reconcile \
  --plan "$PLAN_FILE" \
  --response "$CHALLENGE_RESPONSE" 2>/dev/null) || true
rc=$?
echo "$output" | sed 's/^/      /'

echo ""

if [[ $rc -eq 0 ]]; then
  echo "    ✓ PASS  Plan reconciled with CATFISH challenge"
  exit 0
else
  echo "    ✗ FAIL  CATFISH reconcile failed --- revisit plan"
  exit 1
fi
