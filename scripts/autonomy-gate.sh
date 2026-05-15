#!/usr/bin/env bash
# =============================================================================
# autonomy-gate.sh --- Risk-adjusted agent autonomy levels
#
# Maps task risk + blast radius + context score to an autonomy level.
# Integrates with task-intake.sh (RISK), safety-guard.sh (blast radius),
# comprehension-gate.sh (context score), and a2h-contact.sh (human gates).
#
# Autonomy levels:
#   FULL       --- agent implements, tests, commits without human check
#   SUPERVISED --- agent implements, runs verification, presents diff for review
#   RESTRICTED --- agent proposes plan, waits for approval before implementing
#
# Usage:
#   assess [--risk low|medium|high] [--files N] [--cross-module true|false]
#          [--context-score high|low]
#   quick     --- quick assessment from current git + safety state
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
RUNTIME_DIR="$REPO_ROOT/.runtime"

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  assess [--risk low|medium|high] [--files N] [--cross-module true|false]
         [--context-score high|low]
         Outputs autonomy level and allowed actions.

  quick  Quick assessment from current git state + existing evidence files.

Autonomy levels:
  FULL        --- implement, test, commit without human check
  SUPERVISED  --- verify then show diff for review before commit
  RESTRICTED  --- propose plan, wait for approval before implementing

  Context score: high if comprehension evidence exists and is recent
  Blast radius: inferred from staged files count and top-level directory spread
EOF
}

# ---------------------------------------------------------------------------
# Assess autonomy level
# ---------------------------------------------------------------------------
assess() {
  local risk="medium"
  local files=0
  local cross_module="false"
  local context_score="medium"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --risk) risk="$2"; shift 2 ;;
      --files) files="$2"; shift 2 ;;
      --cross-module) cross_module="$2"; shift 2 ;;
      --context-score) context_score="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  local blast_radius="small"
  if [[ "$files" -gt 5 ]] || [[ "$cross_module" == "true" ]]; then
    blast_radius="large"
  elif [[ "$files" -gt 2 ]]; then
    blast_radius="medium"
  fi

  local autonomy=""
  local reason=""
  local human_gate=false
  local verify_before_commit=false

  # Decision matrix: risk x blast radius x context score
  if [[ "$risk" == "high" ]]; then
    autonomy="RESTRICTED"
    reason="high risk --- human approval required before any edit"
    human_gate=true
  elif [[ "$risk" == "medium" && "$blast_radius" == "large" ]]; then
    autonomy="RESTRICTED"
    reason="medium risk with large blast radius --- human approval required"
    human_gate=true
  elif [[ "$risk" == "medium" ]]; then
    autonomy="SUPERVISED"
    reason="medium risk --- implement then present diff for review"
    verify_before_commit=true
  elif [[ "$blast_radius" == "large" ]]; then
    autonomy="SUPERVISED"
    reason="small risk but large blast radius --- verify before commit"
    verify_before_commit=true
  elif [[ "$context_score" == "low" ]]; then
    autonomy="SUPERVISED"
    reason="low context confidence --- verify before commit"
    verify_before_commit=true
  else
    autonomy="FULL"
    reason="low risk, small blast radius, good context --- full autonomy"
  fi

  echo "=========================================="
  echo "  Autonomy Gate"
  echo "=========================================="
  echo ""
  echo "  Risk:         $risk"
  echo "  Blast radius: $blast_radius ($files files, cross-module: $cross_module)"
  echo "  Context:      $context_score"
  echo ""
  echo "  Autonomy:     $autonomy"
  echo "  Reason:       $reason"
  echo ""
  echo "  --- Agent May ---"
  case "$autonomy" in
    FULL)
      echo "  ✓ Implement changes"
      echo "  ✓ Run tests"
      echo "  ✓ Commit and push"
      echo "  No human gates required"
      ;;
    SUPERVISED)
      echo "  ✓ Implement changes"
      echo "  ✓ Run tests"
      echo "  ✗ Commit --- must present diff for review first"
      echo "  After review: commit with checkpoint-commit.sh"
      if [[ "$human_gate" == true ]]; then
        echo ""
        echo "  Human approval may be required for specific operations"
      fi
      ;;
    RESTRICTED)
      echo "  ✓ Propose implementation plan"
      echo "  ✗ Edit any file --- human approval required"
      echo "  After approval: autonomy upgrades to SUPERVISED for execution"
      echo ""
      echo "  To request approval:"
      echo "    bash $SCRIPT_DIR/a2h-contact.sh approve \"implement: <task>\""
      ;;
  esac
  echo ""

  # Exit code signals autonomy level
  case "$autonomy" in
    FULL) exit 0 ;;
    SUPERVISED) exit 1 ;;
    RESTRICTED) exit 2 ;;
  esac
}

# ---------------------------------------------------------------------------
# Quick assessment from current state
# ---------------------------------------------------------------------------
quick_assess() {
  local risk="low"
  local files=0
  local cross_module="false"
  local context_score="medium"

  # Detect risk from staged/in-progress file paths
  local changed_files
  changed_files=$(git diff --name-only 2>/dev/null || true)
  if [[ -z "$changed_files" ]]; then
    changed_files=$(git diff --cached --name-only 2>/dev/null || true)
  fi

  if echo "$changed_files" | grep -qE 'scripts/hooks/|auth|security|production|secret|credential'; then
    risk="high"
  elif echo "$changed_files" | grep -qE 'scripts/|core/|config|api|database|migration'; then
    risk="medium"
  elif [[ -z "$changed_files" ]]; then
    # No changes yet --- infer from last task risk in session-state
    risk="low"
  fi

  # Count files and detect cross-module
  files=$(echo "$changed_files" | grep -c . 2>/dev/null || echo 0)
  if [[ "$files" -gt 0 ]]; then
    local top_dirs
    top_dirs=$(echo "$changed_files" | grep -oP '^[^/]+' | sort -u | wc -l || echo 1)
    if [[ "$top_dirs" -gt 1 ]]; then
      cross_module="true"
    fi
  fi

  # Context score from comprehension evidence freshness
  if [[ -f "$RUNTIME_DIR/comprehension-evidence.md" ]]; then
    local evidence_age
    evidence_age=$((($(date +%s) - $(stat -c%Y "$RUNTIME_DIR/comprehension-evidence.md" 2>/dev/null || echo 0)) / 3600 ))
    if [[ "$evidence_age" -gt 4 ]]; then
      context_score="low"
    fi
  else
    context_score="low"
  fi

  # If there's a CATFISH challenge that failed reconcile, context is definitely low
  if [[ -f "$RUNTIME_DIR/challenge-response.json" ]]; then
    local reconcile_status
    reconcile_status=$(grep -c '"status":"addressed"' "$RUNTIME_DIR/challenge-response.json" 2>/dev/null || echo 0)
    if [[ "$reconcile_status" -eq 0 ]]; then
      context_score="low"
    fi
  fi

  assess --risk "$risk" --files "$files" --cross-module "$cross_module" --context-score "$context_score"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "$CMD" in
  assess)
    assess "$@"
    ;;
  quick)
    quick_assess
    ;;
  help|--help|-h|*)
    usage
    exit 0
    ;;
esac
