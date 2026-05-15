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
# Quality checks (--check-quality or --all-checks)
# ---------------------------------------------------------------------------
if [[ "$CHECK_QUALITY" != true ]] && [[ "$ALL_CHECKS" != true ]]; then
  exit 0
fi

echo ""
echo "--- Phase Quality Checks ---"

case "$PHASE" in
  plan)
    # Research -> Plan: check research sufficiency
    echo "  Phase: research -> plan"
    echo "  Quality checks: research sufficiency"

    # Find most recent .md in .runtime/ or repo root that looks like a research note
    research_note=""
    for candidate in "$REPO_ROOT"/research/*.md; do
      if [[ -f "$candidate" ]]; then
        research_note="$candidate"
      fi
    done

    rs="$SCRIPT_DIR/research-sufficiency.sh"
    if [[ -n "$research_note" ]] && [[ -f "$rs" ]]; then
      echo ""
      bash "$rs" note "$research_note" 2>/dev/null || true
    else
      echo "  SKIP   research-sufficiency.sh not available or no research note found"
      echo "  Run:   bash scripts/research-sufficiency.sh assess --research-note <file>"
    fi
    ;;

  implement)
    # Plan -> Implement: check comprehension + CATFISH reconcile + decision
    echo "  Phase: plan -> implement"
    echo "  Quality checks: comprehension evidence, CATFISH reconcile, decision log"
    echo ""

    # Comprehension evidence
    cg="$SCRIPT_DIR/comprehension-gate.sh"
    if [[ -f "$cg" ]] && [[ -f "$RUNTIME_DIR/comprehension-evidence.md" ]]; then
      bash "$cg" verify "$RUNTIME_DIR/comprehension-evidence.md" 2>/dev/null || true
    else
      echo "  SKIP   comprehension evidence --- run: comprehension-gate.sh extract <instruction-file>"
    fi

    echo ""

    # CATFISH reconcile
    pc="$SCRIPT_DIR/plan-challenge.sh"
    if [[ -f "$RUNTIME_DIR/challenge-response.json" ]]; then
      echo "  CATFISH reconcile:"
      if [[ -f "$pc" ]]; then
        bash "$pc" reconcile \
          --plan "$RUNTIME_DIR/plan.json" \
          --response "$RUNTIME_DIR/challenge-response.json" 2>/dev/null || true
      fi
    else
      echo "  SKIP   CATFISH reconcile --- run: plan-guard.sh --challenge then dispatch subagent"
    fi

    echo ""

    # Decision log check
    if [[ -f "$RUNTIME_DIR/decision-log.jsonl" ]]; then
      pending
      pending=$(grep -c 'PENDING_\|status.*pending' "$RUNTIME_DIR/decision-log.jsonl" 2>/dev/null || echo 0)
      if [[ "$pending" -gt 0 ]]; then
        echo "  WARN   $pending unresolved decision(s) --- run: decision.sh audit --failed"
      else
        echo "  OK     No pending decisions"
      fi
    fi
    ;;

  review)
    # Implement -> Review: check quality-speed gate
    echo "  Phase: implement -> review"
    echo "  Quality checks: verification depth recommendation"
    echo ""

    qsg="$SCRIPT_DIR/quality-speed-gate.sh"
    if [[ -f "$qsg" ]]; then
      echo "  Recommended verification depth:"
      bash "$qsg" quick 2>/dev/null || true
    else
      echo "  Run:   quality-speed-gate.sh assess --changed-lines N --files N"
    fi
    ;;

  research)
    # No quality checks needed entering research
    echo "  Phase: (any) -> research"
    echo "  Quality checks: none --- research is always the safe entry lane"
    echo "  Remember to produce a structured research note with:"
    echo "    - Source URLs and confidence levels"
    echo "    - Gaps and uncertainty section"
    echo "    - Pre-research expectation vs actual findings"
    ;;
esac
