#!/usr/bin/env bash
# =============================================================================
# phase-gate.sh - Decide whether the next phase is allowed to proceed
# =============================================================================

set -euo pipefail

PHASE=""
RESEARCH_DONE=false
PLAN_DONE=false
SCOPE_BOUNDED=false
VERIFICATION_KNOWN=false
UPSTREAM_FACING=false
CONTRIBUTION_READ=false

usage() {
  cat <<'EOF'
Usage: ./scripts/phase-gate.sh PHASE [options]

Phases:
  research
  plan
  implement
  review

Options:
  --research-done
  --plan-done
  --scope-bounded
  --verification-known
  --upstream-facing
  --contribution-read
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
