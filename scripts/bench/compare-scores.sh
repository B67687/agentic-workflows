#!/usr/bin/env bash
# =============================================================================
# compare-scores.sh — Compare post-proposal scores against baseline
#
# Phase 3 placeholder. Full implementation deferred until run-proposal.sh
# produces the post-change scores.
#
# Current behavior:
#   - Reads baseline scores (from context.baseline or file)
#   - Reads post-change scores (from stdin, file, or context)
#   - If both available, computes delta per benchmark
#   - If not available, prints spec for future implementation
#   - Exits with status 0 (no-op for Phase 0 workflow)
#
# Future implementation (Phase 3):
#   - Parse baseline and post-change score JSON
#   - Compute delta per benchmark, per category, overall
#   - Classify change: improved (>+5%), degraded (<-5%), neutral
#   - Output structured comparison for decide step
#
# Usage:
#   bash scripts/bench/compare-scores.sh [--baseline <file>] [--post <file>]
#
# Output: JSON with fields: overall_delta, per_benchmark, classification
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Try to read baseline from context if available
BASELINE_FILE="${1:-}"
POST_FILE="${2:-}"

# If no explicit files, try runtime context
if [[ -z "$BASELINE_FILE" ]]; then
  # Check if script received piped input
  if [[ ! -t 0 ]]; then
    POST_INPUT=$(cat)
  fi
fi

# Check if baseline exists in context
RUNTIME_BASELINE="$REPO_ROOT/.runtime/baseline-scores.json"
RUNTIME_POST="$REPO_ROOT/.runtime/post-scores.json"

echo "{"
echo "  \"status\": \"placeholder\","
echo "  \"phase\": \"3\","
echo "  \"message\": \"compare-scores.sh — IMPLEMENTATION PENDING (Phase 3)\","

if [[ -f "$RUNTIME_BASELINE" && -f "$RUNTIME_POST" ]]; then
  echo "  \"baseline_found\": true,"
  echo "  \"post_found\": true,"
  echo "  \"note\": \"Both baseline and post scores found — ready for Phase 3 implementation\""
else
  echo "  \"baseline_found\": false,"
  echo "  \"post_found\": false,"
  echo "  \"note\": \"Placeholder mode — Phase 3 will implement delta computation\","
  echo "  \"pipeline\": ["
  echo "    \"1. Read baseline scores from context.baseline\","
  echo "    \"2. Read post-change scores from run-proposal.sh output\","
  echo "    \"3. Compute per-benchmark delta: post - baseline\","
  echo "    \"4. Compute per-category weighted delta\","
  echo "    \"5. Compute overall score change\","
  echo "    \"6. Classify: IMPROVED / DEGRADED / NEUTRAL\","
  echo "    \"7. Output structured comparison for decide step\""
  echo "  ]"
fi

echo "}"
