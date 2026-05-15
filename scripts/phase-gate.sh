#!/usr/bin/env bash
# =============================================================================
# phase-gate.sh - Decide whether the next phase is allowed to proceed
#
# Two layers of checking:
#   1. STATE: boolean prerequisites (research-done, plan-done, etc.)
#   2. QUALITY: comprehension + sufficiency + decision checks
#       (activated by --check-quality or --all-checks)
#
# Usage: ./scripts/phase-gate.sh PHASE [options]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"

PHASE=""
RESEARCH_DONE=false
PLAN_DONE=false
SCOPE_BOUNDED=false
VERIFICATION_KNOWN=false
UPSTREAM_FACING=false
CONTRIBUTION_READ=false
CHECK_QUALITY=false
ALL_CHECKS=false

usage() {
  cat <<'EOF'
Usage: ./scripts/phase-gate.sh PHASE [options]

Phases:
  research     -> always allowed (safe entry lane)
  plan         -> block if research not done
  implement    -> block if research/plan/scope/verification not done
  review       -> block if verification target unknown

State options:
  --research-done       Research phase completed
  --plan-done            Plan phase completed
  --scope-bounded        Scope explicitly bounded
  --verification-known   Verification target defined
  --upstream-facing      Work may go upstream
  --contribution-read    Contribution guide read

Quality options:
  --check-quality       Run quality checks for this phase transition
                        (research sufficiency, CATFISH reconcile,
                         comprehension evidence, etc.)
  --all-checks          Run ALL checks comprehensively (slower)

When --check-quality is set, the gate delegates to:
  research-sufficiency.sh (research -> plan)
  comprehension-gate.sh   (plan -> implement)
  plan-challenge.sh       (plan -> implement)
  quality-speed-gate.sh   (implement -> review)
EOF
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

PHASE="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --research-done)
      RESEARCH_DONE=true
      ;;
    --plan-done)
      PLAN_DONE=true
      ;;
    --scope-bounded)
      SCOPE_BOUNDED=true
      ;;
    --verification-known)
      VERIFICATION_KNOWN=true
      ;;
    --upstream-facing)
      UPSTREAM_FACING=true
      ;;
    --contribution-read)
      CONTRIBUTION_READ=true
      ;;
    --check-quality)
      CHECK_QUALITY=true
      ;;
    --all-checks)
      ALL_CHECKS=true
      CHECK_QUALITY=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

decision="allow"
reason="phase prerequisites satisfied"
next="proceed"

case "$PHASE" in
  research)
    decision="allow"
    reason="research is always the safe entry lane"
    next="understand the system before changing files"
    ;;
  plan)
    if [[ "$RESEARCH_DONE" != true ]]; then
      decision="block"
      reason="planning without enough research creates bad implementation assumptions"
      next="finish research first"
    fi
    ;;
  implement)
    if [[ "$RESEARCH_DONE" != true ]]; then
      decision="block"
      reason="implementation is not allowed before research"
      next="go back to research"
    elif [[ "$PLAN_DONE" != true ]]; then
      decision="block"
      reason="implementation is not allowed before a clear plan"
      next="go back to planning"
    elif [[ "$SCOPE_BOUNDED" != true ]]; then
      decision="block"
      reason="scope is still loose or mixed"
      next="tighten the plan scope before editing"
    elif [[ "$VERIFICATION_KNOWN" != true ]]; then
      decision="block"
      reason="verification path is still unclear"
      next="define the test or review path before editing"
    elif [[ "$UPSTREAM_FACING" == true && "$CONTRIBUTION_READ" != true ]]; then
      decision="block"
      reason="upstream-facing work requires contribution guidance first"
      next="read CONTRIBUTING.md or the closest equivalent guidance"
    fi
    ;;
  review)
    if [[ "$VERIFICATION_KNOWN" != true ]]; then
      decision="block"
      reason="review without a known verification standard is too weak"
      next="define the review or verification target first"
    fi
    ;;
  *)
    echo "Unknown phase: $PHASE" >&2
    usage >&2
    exit 2
    ;;
esac

echo "Decision: $decision"
echo "Phase: $PHASE"
echo "Reason: $reason"
echo "Next: $next"

# ---------------------------------------------------------------------------
# Quality checks via plugin discovery (--check-quality or --all-checks)
# ---------------------------------------------------------------------------
if [[ "$CHECK_QUALITY" != true ]] && [[ "$ALL_CHECKS" != true ]]; then
  exit 0
fi

echo ""
echo "--- Phase Quality Checks ---"
echo "  Phase: $PHASE"
echo ""

# Discover gate plugins for this phase
GATE_DIR="$REPO_ROOT/scripts/gates/$PHASE"
OVERALL_RESULT=0
PLUGIN_COUNT=0
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

if [[ -d "$GATE_DIR" ]]; then
  for plugin in "$GATE_DIR"/*.sh; do
    [[ ! -f "$plugin" ]] && continue
    PLUGIN_COUNT=$((PLUGIN_COUNT + 1))

    # Run the plugin, capture its exit code
    set +e
    bash "$plugin" 2>/dev/null
    rc=$?
    set -e

    case $rc in
      0) PASS_COUNT=$((PASS_COUNT + 1)) ;;
      1) FAIL_COUNT=$((FAIL_COUNT + 1)); OVERALL_RESULT=1 ;;
      2) WARN_COUNT=$((WARN_COUNT + 1)); [[ "$OVERALL_RESULT" -eq 0 ]] && OVERALL_RESULT=2 ;;
      3) SKIP_COUNT=$((SKIP_COUNT + 1)) ;;
      *) echo "    ? UNKNOWN (exit $rc)"; SKIP_COUNT=$((SKIP_COUNT + 1)) ;;
    esac
    echo ""
  done
fi

if [[ "$PLUGIN_COUNT" -eq 0 ]]; then
  echo "  No gate plugins found for phase '$PHASE'"
  echo "  Create scripts/gates/$PHASE/<name>.sh to add checks"
  echo "  (This is not an error --- the phase has no gates defined)"
fi

# Summary line
echo "  ───────────────────────────────────────────"
echo "  Gates: $PLUGIN_COUNT total"
echo "    ✓ Pass: $PASS_COUNT"
echo "    ⚠ Warn: $WARN_COUNT"
echo "    ✗ Fail: $FAIL_COUNT"
echo "    -- Skip: $SKIP_COUNT"

exit "$OVERALL_RESULT"
