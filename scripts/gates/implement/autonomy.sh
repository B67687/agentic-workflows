#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/autonomy
#
# Assesses the current autonomy level with dynamic cascade.
# First invocation: autonomy-gate.sh start (creates state)
# Subsequent:       autonomy-gate.sh adjust (dynamic signal-driven adjustment)
#
# Standard gate interface:
#   Exit 0 = PASS (autonomy level determined)
#   Exit 1 = FAIL (cannot assess - block)
#   Exit 2 = WARN (autonomy limited)
#   Exit 3 = SKIP (autonomy-gate not available)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$RUNTIME_DIR/autonomy-state.json"

echo "  -- Gate: implement/autonomy"

ag="$REPO_ROOT/scripts/autonomy-gate.sh"
if [[ ! -f "$ag" ]]; then
  echo "    SKIP   autonomy-gate.sh not found"
  exit 3
fi

echo ""

# First invocation: start (creates state). Subsequent: adjust (dynamic).
if [[ -f "$STATE_FILE" ]]; then
  output=$(bash "$ag" adjust 2>/dev/null) || true
  rc=$?
  echo "$output" | sed 's/^/      /'
  echo ""
  if [[ $rc -eq 0 ]]; then
    echo "    ✓ PASS  Autonomy: FULL (stable or raised)"
    exit 0
  elif [[ $rc -eq 1 ]]; then
    level=$(echo "$output" | grep 'New:\|stable:' | sed 's/.*New:\s*//;s/.*stable:\s*//' | head -1 || echo "SUPERVISED")
    echo "    ✓ PASS  Autonomy: $level (dynamic)"
    exit 0
  elif [[ $rc -eq 3 ]]; then
    # State was invalid, re-start
    output=$(bash "$ag" start 2>/dev/null) || true
    rc=$?
    echo "$output" | sed 's/^/      /'
    echo ""
    echo "    ✓ PASS  Autonomy re-initialized"
    exit 0
  else
    echo "    ⚠ WARN  Autonomy: RESTRICTED (signal cascade triggered)"
    exit 2
  fi
else
  output=$(bash "$ag" start 2>/dev/null) || true
  rc=$?
  echo "$output" | sed 's/^/      /'
  echo ""
  level=$(echo "$output" | grep 'Autonomy:' | sed 's/.*Autonomy:\s*//' || echo "SUPERVISED")
  echo "    ✓ PASS  Autonomy initialized: $level"
  if [[ $rc -eq 0 ]]; then
    exit 0
  elif [[ $rc -eq 1 ]]; then
    exit 0  # SUPERVISED is pass, just limited
  else
    exit 2  # RESTRICTED is warn
  fi
fi
