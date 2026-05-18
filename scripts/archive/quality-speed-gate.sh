#!/usr/bin/env bash
# =============================================================================
# quality-speed-gate.sh --- Decision: full suite or just smoke tests?
#
# Simple heuristic engine: given change size, blast radius, and risk level,
# recommends the appropriate verification depth.
#
# Usage:
#   assess [--changed-lines N] [--files N] [--cross-module true|false]
#          [--risk low|medium|high]
#          Recommends: full-suite, smoke-only, or targeted
# =============================================================================

set -euo pipefail

CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  assess [--changed-lines N] [--files N] [--cross-module true|false]
         [--risk low|medium|high]
         Recommends verification depth based on change profile.

  quick                     Quick assessment from git diff --stat
EOF
}

# ---------------------------------------------------------------------------
# Heuristic assessment
# ---------------------------------------------------------------------------
assess() {
  local changed_lines=0
  local files=0
  local cross_module="false"
  local risk="low"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --changed-lines) changed_lines="$2"; shift 2 ;;
      --files) files="$2"; shift 2 ;;
      --cross-module) cross_module="$2"; shift 2 ;;
      --risk) risk="$2"; shift 2 ;;
      *) echo "Unknown: $1" >&2; usage; exit 2 ;;
    esac
  done

  echo "=========================================="
  echo "  Quality vs Speed Assessment"
  echo "=========================================="
  echo ""

  # Score (0-10): higher = more verification needed
  local score=0

  # Size factor
  if [[ "$changed_lines" -gt 200 ]]; then
    score=$((score + 3))
    echo "  +3  large change ($changed_lines lines)"
  elif [[ "$changed_lines" -gt 50 ]]; then
    score=$((score + 1))
    echo "  +1  medium change ($changed_lines lines)"
  fi

  # File count factor
  if [[ "$files" -gt 5 ]]; then
    score=$((score + 2))
    echo "  +2  touches many files ($files files)"
  elif [[ "$files" -gt 2 ]]; then
    score=$((score + 1))
    echo "  +1  multiple files ($files files)"
  fi

  # Cross-module factor
  if [[ "$cross_module" == "true" ]]; then
    score=$((score + 3))
    echo "  +3  cross-module change"
  fi

  # Risk factor
  case "$risk" in
    high) score=$((score + 3)); echo "  +3  high risk" ;;
    medium) score=$((score + 1)); echo "  +1  medium risk" ;;
  esac

  echo ""
  echo "  Score: $score / 10"

  local recommendation=""
  local reason=""

  if [[ "$score" -ge 7 ]]; then
    recommendation="full-suite"
    reason="high impact change --- run full test suite and integration tests"
  elif [[ "$score" -ge 4 ]]; then
    recommendation="targeted"
    reason="moderate impact --- run affected test modules and smoke suite"
  else
    recommendation="smoke-only"
    reason="low impact --- smoke tests sufficient"
  fi

  echo "  Recommendation: $recommendation"
  echo "  Reason: $reason"
  echo ""
  echo "  Suggested commands:"
  case "$recommendation" in
    full-suite)
      echo "    bash ./scripts/test-smoke.sh   # smoke suite"
      echo "    npm test                        # or full project tests"
      echo "    # integration tests as applicable"
      ;;
    targeted)
      echo "    bash ./scripts/test-smoke.sh   # smoke suite"
      echo "    # test the affected modules specifically"
      ;;
    smoke-only)
      echo "    bash ./scripts/test-smoke.sh   # smoke tests"
      ;;
  esac

  # Exit code signals recommendation
  case "$recommendation" in
    full-suite) exit 0 ;;
    targeted) exit 1 ;;
    smoke-only) exit 2 ;;
  esac
}

# ---------------------------------------------------------------------------
# Quick assessment from git diff
# ---------------------------------------------------------------------------
quick_assess() {
  local changed_lines files cross_module risk

  changed_lines=$(git diff --cached --stat 2>/dev/null | tail -1 | grep -oP '\d+(?= insertion)' || echo 0)
  files=$(git diff --cached --name-only 2>/dev/null | wc -l || echo 0)

  # Detect cross-module: files span multiple top-level dirs
  local top_dirs
  top_dirs=$(git diff --cached --name-only 2>/dev/null | grep -oP '^[^/]+' | sort -u | wc -l || echo 1)
  if [[ "$top_dirs" -gt 1 ]]; then
    cross_module="true"
  else
    cross_module="false"
  fi

  # Detect risk from changed file paths
  risk="low"
  if git diff --cached --name-only 2>/dev/null | grep -qE 'scripts/hooks/|safety|auth|security|production'; then
    risk="high"
  elif git diff --cached --name-only 2>/dev/null | grep -qE 'scripts/|core/|config|api'; then
    risk="medium"
  fi

  assess --changed-lines "$changed_lines" --files "$files" \
    --cross-module "$cross_module" --risk "$risk"
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
