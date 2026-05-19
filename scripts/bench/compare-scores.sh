#!/usr/bin/env bash
# =============================================================================
# compare-scores.sh — Phase 3: Compare post-proposal scores against baseline
#
# Computes deltas between baseline and post-change benchmark scores and
# classifies the change as IMPROVED, DEGRADED, or NEUTRAL.
#
# Usage:
#   bash scripts/bench/compare-scores.sh
#     Uses .runtime/baseline-scores.json and .runtime/post-scores.json
#
#   bash scripts/bench/compare-scores.sh --baseline <file> --post <file>
#     Explicit baseline and post-change score files
#
# Output: JSON with overall_delta, per_benchmark deltas, and classification
#
# Classification thresholds:
#   IMPROVED: overall pass_rate delta > +0.05
#   DEGRADED: overall pass_rate delta < -0.05
#   NEUTRAL:  delta between -0.05 and +0.05
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"

BASELINE_FILE="$RUNTIME_DIR/baseline-scores.json"
POST_FILE="$RUNTIME_DIR/post-scores.json"

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/compare-scores.sh [options]

Options:
  --baseline <file>     Baseline scores file (default: .runtime/baseline-scores.json)
  --post <file>         Post-change scores file (default: .runtime/post-scores.json)
  --save                Save result to .runtime/comparison-result.json
  --help                Show this help

Without options, uses .runtime/baseline-scores.json and .runtime/post-scores.json.
USAGE
}

SAVE_RESULT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --baseline)
    BASELINE_FILE="$2"
    shift 2
    ;;
  --post)
    POST_FILE="$2"
    shift 2
    ;;
  --save)
    SAVE_RESULT=true
    shift
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

# ── Validate inputs ──

if [[ ! -f "$BASELINE_FILE" ]]; then
  echo "Error: baseline file not found: $BASELINE_FILE" >&2
  echo "Run 'bash scripts/bench/aggregate.sh export > .runtime/baseline-scores.json' first" >&2
  exit 1
fi

if [[ ! -f "$POST_FILE" ]]; then
  echo "Error: post-change scores file not found: $POST_FILE" >&2
  echo "Run run-proposal.sh first to generate post-change scores" >&2
  exit 1
fi

# ── Compute comparison ──

python3 -c "
import json, sys

with open('$BASELINE_FILE') as f:
    baseline = json.load(f)

with open('$POST_FILE') as f:
    post = json.load(f)

baseline_bms = baseline.get('by_benchmark', {})
post_bms = post.get('by_benchmark', {})
baseline_cats = baseline.get('by_category', {})
post_cats = post.get('by_category', {})

baseline_overall = baseline.get('overall', {})
post_overall = post.get('overall', {})

# ── Overall delta ──
base_rate = baseline_overall.get('pass_rate', 0.0)
post_rate = post_overall.get('pass_rate', 0.0)
overall_delta = round(post_rate - base_rate, 3)

# ── Per-benchmark deltas ──
all_benchmark_ids = sorted(set(list(baseline_bms.keys()) + list(post_bms.keys())))
per_benchmark = {}

for bid in all_benchmark_ids:
    base = baseline_bms.get(bid, {})
    pst = post_bms.get(bid, {})
    base_rate_b = base.get('pass_rate', 0.0)
    post_rate_b = pst.get('pass_rate', 0.0)
    base_runs = base.get('total', 0)
    post_runs = pst.get('total', 0)
    delta = round(post_rate_b - base_rate_b, 3)
    per_benchmark[bid] = {
        'baseline_pass_rate': base_rate_b,
        'post_pass_rate': post_rate_b,
        'delta': delta,
        'baseline_runs': base_runs,
        'post_runs': post_runs,
        'classification': 'IMPROVED' if delta > 0.05 else ('DEGRADED' if delta < -0.05 else 'NEUTRAL')
    }

# ── Per-category deltas ──
all_cat_ids = sorted(set(list(baseline_cats.keys()) + list(post_cats.keys())))
per_category = {}

for cid in all_cat_ids:
    base = baseline_cats.get(cid, {})
    pst = post_cats.get(cid, {})
    base_rate_c = base.get('pass_rate', 0.0)
    post_rate_c = pst.get('pass_rate', 0.0)
    delta = round(post_rate_c - base_rate_c, 3)
    per_category[cid] = {
        'baseline_pass_rate': base_rate_c,
        'post_pass_rate': post_rate_c,
        'baseline_weighted': base.get('avg_weighted_score', 0.0),
        'post_weighted': pst.get('avg_weighted_score', 0.0),
        'delta': delta,
        'classification': 'IMPROVED' if delta > 0.05 else ('DEGRADED' if delta < -0.05 else 'NEUTRAL')
    }

# ── Overall classification ──
if overall_delta > 0.05:
    classification = 'IMPROVED'
elif overall_delta < -0.05:
    classification = 'DEGRADED'
else:
    classification = 'NEUTRAL'

# ── Summary counts ──
improved = sum(1 for b in per_benchmark.values() if b['classification'] == 'IMPROVED')
degraded = sum(1 for b in per_benchmark.values() if b['classification'] == 'DEGRADED')
neutral = sum(1 for b in per_benchmark.values() if b['classification'] == 'NEUTRAL')

result = {
    'comparison_id': 'compare-$(date -u +%Y%m%d%H%M%S)',
    'compared_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    'classification': classification,
    'overall_delta': overall_delta,
    'baseline_pass_rate': base_rate,
    'post_pass_rate': post_rate,
    'baseline_run_count': baseline_overall.get('total', 0),
    'post_run_count': post_overall.get('total', 0),
    'summary': {
        'improved': improved,
        'degraded': degraded,
        'neutral': neutral,
        'total_benchmarks': len(per_benchmark)
    },
    'per_benchmark': per_benchmark,
    'per_category': per_category
}

print(json.dumps(result, indent=2))
" 2>/dev/null

exit 0
