#!/usr/bin/env bash
# =============================================================================
# pre-push.sh --- Pre-push quality gate
# Runs before git push to catch integration issues:
#   - P16 smoke suite
#   - 5-task Terminal-Bench smoke (infrastructure health check)
#   - Propagation drift check
#   - Quality gate (reuses pre-commit checks)
# =============================================================================
#
# Install: ln -sf ../../scripts/git/pre-push.sh .git/hooks/pre-push
# Run directly: bash scripts/git/pre-push.sh
# Skip: SKIP_PRE_PUSH=1 git push

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FAILED=false

log_info() { echo -e "${CYAN}[PRE-PUSH]${NC} $1"; }
log_ok() { echo -e "${GREEN}[PRE-PUSH]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[PRE-PUSH]${NC} $1"; }
log_err() { echo -e "${RED}[PRE-PUSH]${NC} $1"; }

# Allow skip via env
if [[ "${SKIP_PRE_PUSH:-}" == "1" ]]; then
  echo "[PRE-PUSH] SKIPPED (SKIP_PRE_PUSH=1)"
  exit 0
fi

echo ""
echo "=========================================="
echo "  Pre-Push Quality Gate"
echo "=========================================="
echo ""

# ---- Check 1: Quality gate ----
log_info "Running quality gate..."
if bash "$REPO_ROOT/scripts/hooks/quality-gate.sh"; then
  log_ok "Quality gate passed"
else
  log_err "Quality gate failed"
  FAILED=true
fi
echo ""

# ---- Check 2: P16 smoke suite ----
log_info "Running P16 smoke suite..."
SMOKE_SCRIPT="$REPO_ROOT/scripts/test-smoke.sh"
if [[ -f "$SMOKE_SCRIPT" ]]; then
  if bash "$SMOKE_SCRIPT" 2>&1 | tail -5; then
    log_ok "Smoke suite passed"
  else
    log_err "Smoke suite failed"
    FAILED=true
  fi
else
  log_warn "Smoke suite not found at $SMOKE_SCRIPT, skipping"
fi
echo ""

# ---- Check 3: Propagation drift ----
log_info "Checking propagation drift..."
PROP_SCRIPT="$REPO_ROOT/scripts/propagate-to-all.sh"
if [[ -f "$PROP_SCRIPT" ]]; then
  DRIFT_OUTPUT=$(bash "$PROP_SCRIPT" --preview 2>&1 || true)
  if echo "$DRIFT_OUTPUT" | grep -q "WOULD REFRESH"; then
    COUNT=$(echo "$DRIFT_OUTPUT" | grep -c "WOULD REFRESH" 2>/dev/null || echo 0)
    log_warn "$COUNT propagated file(s) have drifted"
    echo "$DRIFT_OUTPUT" | grep "WOULD REFRESH" | head -10
    echo ""
    log_info "Fix: bash scripts/propagate-to-all.sh --apply"
    FAILED=true
  else
    log_ok "Propagation is clean"
  fi
else
  log_warn "propagate-to-all.sh not found, skipping"
fi
echo ""

# ---- Check 4: 5-task Terminal-Bench smoke (if Harbor is available) ----
HARBOR="$REPO_ROOT/.runtime/bench-env/bin/harbor"
SMOKE_CONFIG="$REPO_ROOT/adapters/terminal-bench/run_5task-smoke.yaml"
if [[ -f "$HARBOR" ]] && [[ -f "$SMOKE_CONFIG" ]]; then
  log_info "Running 5-task Terminal-Bench smoke..."
  log_info "  (this takes ~3 minutes)"
  if bash -c "source '$REPO_ROOT/.runtime/bench-env/bin/activate' && harbor run -c '$SMOKE_CONFIG' -a opencode -m openai/ds/deepseek-v4-flash 2>&1" | tail -5; then
    log_ok "Benchmark smoke passed"
  else
    log_err "Benchmark smoke failed — infrastructure issue"
    FAILED=true
  fi
else
  log_warn "Harbor or smoke config not available, skipping benchmark check"
fi
echo ""

# ---- Summary ----
echo "=========================================="
if [[ "$FAILED" == true ]]; then
  echo -e "${RED}✗ Pre-push gate FAILED — fix issues before pushing.${NC}"
  echo "  To skip (not recommended): SKIP_PRE_PUSH=1 git push"
  exit 1
else
  echo -e "${GREEN}✓ Pre-push gate PASSED${NC}"
  exit 0
fi
