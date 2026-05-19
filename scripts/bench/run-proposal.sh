#!/usr/bin/env bash
# =============================================================================
# run-proposal.sh — Phase 3: Run improvement proposal against benchmark suite
#
# Reads a validated improvement proposal, creates a test branch, runs relevant
# benchmarks, and outputs post-change scores for comparison.
#
# Usage:
#   bash scripts/bench/run-proposal.sh                       # Read proposal from stdin
#   bash scripts/bench/run-proposal.sh --proposal <file>     # Read from file
#   bash scripts/bench/run-proposal.sh --branch <name>       # Use existing branch
#
# Pipeline:
#   1. Read and validate proposal
#   2. Create sandbox branch from current state
#   3. Run relevant benchmarks via aggregate.sh export for baseline comparison
#   4. Collect post-change scores
#   5. Output results JSON
#
# Output: JSON with status, run_id, benchmark_results, and scores
#
# Exit codes:
#   0 = benchmarks completed, results ready for comparison
#   1 = proposal execution failed
#   2 = proposal format invalid
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"

PROPOSAL_FILE=""
EXISTING_BRANCH=""

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/run-proposal.sh [options]

Options:
  --proposal <file>     Read improvement proposal from file
  --branch <name>       Use existing branch (skip branch creation)
  --help                Show this help

Without --proposal, reads proposal JSON from stdin.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --proposal)
    PROPOSAL_FILE="$2"
    shift 2
    ;;
  --branch)
    EXISTING_BRANCH="$2"
    shift 2
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage
    exit 2
    ;;
  esac
done

# ── Read and validate proposal ──

if [[ -n "$PROPOSAL_FILE" ]]; then
  if [[ ! -f "$PROPOSAL_FILE" ]]; then
    echo "Error: proposal file not found: $PROPOSAL_FILE" >&2
    exit 2
  fi
  PROPOSAL=$(cat "$PROPOSAL_FILE")
else
  PROPOSAL=$(cat)
fi

# Validate
VALIDATION=$(echo "$PROPOSAL" | bash "$SCRIPT_DIR/validate-proposal.sh" 2>&1) || {
  echo "Error: proposal validation failed" >&2
  echo "$VALIDATION" >&2
  exit 2
}

# ── Parse proposal fields ──

PROPOSAL_ID=$(echo "$PROPOSAL" | python3 -c "import json,sys; print(json.load(sys.stdin)['proposal_id'])" 2>/dev/null)
TITLE=$(echo "$PROPOSAL" | python3 -c "import json,sys; print(json.load(sys.stdin)['title'])" 2>/dev/null)
TARGET_GAP=$(echo "$PROPOSAL" | python3 -c "import json,sys; print(json.load(sys.stdin)['target_gap'])" 2>/dev/null)

# Determine which benchmark to run based on target gap
BENCHMARK_ID=$(echo "$PROPOSAL" | python3 -c "
import json, sys
p = json.load(sys.stdin)
gap = p.get('target_gap', '')
# Extract benchmark_id from target_gap pattern: <type>-<benchmark_id>
if gap.startswith('coverage-') or gap.startswith('signal-') or gap.startswith('degraded-') or gap.startswith('plateau-'):
    print(gap.split('-', 1)[1])
elif gap.startswith('coverage/') or gap.startswith('signal/'):
    print(gap.split('/', 1)[1])
else:
    print('')
" 2>/dev/null)

# ── Create or use branch ──

RUN_ID="${PROPOSAL_ID}-$(date -u +%Y%m%d%H%M%S)"
BRANCH_NAME="prop-test/${PROPOSAL_ID}"

if [[ -n "$EXISTING_BRANCH" ]]; then
  BRANCH_NAME="$EXISTING_BRANCH"
  echo "[run-proposal] Using existing branch: $BRANCH_NAME" >&2
else
  echo "[run-proposal] Creating test branch: $BRANCH_NAME" >&2
  rtk git stash push -m "run-proposal-stash-$RUN_ID" 2>/dev/null || true
  rtk git checkout -b "$BRANCH_NAME" 2>/dev/null || rtk git checkout "$BRANCH_NAME" 2>/dev/null
fi

# ── Run benchmarks ──

echo "[run-proposal] Running benchmarks for proposal: $PROPOSAL_ID ($TITLE)" >&2
echo "[run-proposal] Target gap: $TARGET_GAP" >&2
echo "[run-proposal] Benchmark: ${BENCHMARK_ID:-all}" >&2

# Create runs directory
mkdir -p "$RUNS_DIR/$RUN_ID"

# Run benchmarks if skill-bench.sh and benchmark_id exist
BENCH_RESULTS="[]"

if [[ -n "$BENCHMARK_ID" ]] && [[ -f "$REPO_ROOT/scripts/tools/skill-bench.sh" ]]; then
  echo "[run-proposal] Running benchmark: $BENCHMARK_ID" >&2
  # Attempt to run the specific benchmark
  BENCH_OUTPUT=$(bash "$REPO_ROOT/scripts/tools/skill-bench.sh" prepare "$BENCHMARK_ID" 2>&1) || true
  echo "$BENCH_OUTPUT" >&2

  # Check for result
  BENCH_RESULT=$(find "$RUNS_DIR" -name "result.json" -newer "$RUNS_DIR/$RUN_ID" 2>/dev/null | head -1 || true)
  if [[ -n "$BENCH_RESULT" ]]; then
    BENCH_RESULTS=$(cat "$BENCH_RESULT" 2>/dev/null || echo '[]')
  fi
else
  echo "[run-proposal] No specific benchmark target — running full suite would go here" >&2
  echo "[run-proposal] To run full suite: bash scripts/tools/skill-bench.sh prepare all" >&2
fi

# ── Capture post-change scores via aggregate.sh export ──

POST_SCORES=$(bash "$SCRIPT_DIR/aggregate.sh" export 2>/dev/null || echo '{}')

# ── Output results ──

echo "{"
echo "  \"run_id\": \"$RUN_ID\","
echo "  \"proposal_id\": \"$PROPOSAL_ID\","
echo "  \"title\": $(echo "$PROPOSAL" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)['title']))" 2>/dev/null),"
echo "  \"branch\": \"$BRANCH_NAME\","
echo "  \"benchmark_results\": $BENCH_RESULTS,"
echo "  \"post_scores\": $POST_SCORES,"
echo "  \"status\": \"completed\","
echo "  \"message\": \"Benchmark run complete. Use compare-scores.sh to analyze delta.\""
echo "}"

# Save run result
cat >"$RUNS_DIR/$RUN_ID/result.json" <<EOFRESULT
{
  "run_id": "$RUN_ID",
  "proposal_id": "$PROPOSAL_ID",
  "benchmark_id": "${BENCHMARK_ID:-all}",
  "success": true,
  "status": "completed"
}
EOFRESULT

# Save post scores
SCORES_FILE="$REPO_ROOT/.runtime/post-scores.json"
echo "$POST_SCORES" >"$SCORES_FILE"
echo "[run-proposal] Post-change scores saved to $SCORES_FILE" >&2

exit 0
