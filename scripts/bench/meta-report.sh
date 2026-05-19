#!/usr/bin/env bash
# =============================================================================
# meta-report.sh — Phase 4: Meta-loop — instrument the improvement cycle
#
# Analyzes the self-improving framework's own performance:
#   - Gap resolution trend (detected → addressed)
#   - Proposal pipeline (created → tested → kept/discarded)
#   - Benchmark coverage trend over time
#   - Score direction trend (are we improving?)
#
# Usage:
#   bash scripts/bench/meta-report.sh
#   bash scripts/bench/meta-report.sh --save
#
# Data sources:
#   - .runtime/comparison-result.json   (latest comparison)
#   - .runtime/comparison-history/*.json (historical comparisons)
#   - .runtime/proposals/*.json         (proposal history, when available)
#   - .runtime/bench-runs/*/result.json (benchmark run history)
#
# Output: JSON with meta-metrics
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
RUNS_DIR="$RUNTIME_DIR/bench-runs"
COMPARISON_FILE="$RUNTIME_DIR/comparison-result.json"
COMPARISON_HISTORY_DIR="$RUNTIME_DIR/comparison-history"
PROPOSALS_DIR="$RUNTIME_DIR/proposals"

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/meta-report.sh [options]

Options:
  --save    Save report to .runtime/meta-report.json
  --help    Show this help
USAGE
}

SAVE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --save)
    SAVE=true
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

# ── Collect data into temp files ──

TMP_RUNS=$(mktemp)
TMP_COMPS=$(mktemp)
trap "rm -f $TMP_RUNS $TMP_COMPS" EXIT

# Benchmark run stats
python3 -c "
import json, os, glob

runs_dir = '$RUNS_DIR'
results = []
if os.path.isdir(runs_dir):
    for d in sorted(glob.glob(os.path.join(runs_dir, '*', 'result.json'))):
        try:
            with open(d) as f:
                results.append(json.load(f))
        except: pass

run_count = len(results)
pass_count = sum(1 for r in results if r.get('success', False))
benchmark_ids = set(r.get('benchmark_id', '') for r in results if r.get('benchmark_id'))

output = {
    'run_count': run_count,
    'pass_count': pass_count,
    'fail_count': run_count - pass_count,
    'pass_rate': round(pass_count / run_count, 3) if run_count > 0 else 0.0,
    'benchmarks_with_runs': len(benchmark_ids),
    'benchmark_ids': sorted(benchmark_ids)
}
print(json.dumps(output))
" >"$TMP_RUNS" 2>/dev/null

# Comparison history stats
python3 -c "
import json, os, glob

hist_dir = '$COMPARISON_HISTORY_DIR'
comparisons = []
if os.path.isdir(hist_dir):
    for f in sorted(glob.glob(os.path.join(hist_dir, '*.json'))):
        try:
            with open(f) as cf:
                comparisons.append(json.load(cf))
        except: pass

# Also check the latest comparison file
latest_file = '$COMPARISON_FILE'
if os.path.isfile(latest_file):
    try:
        with open(latest_file) as lf:
            latest = json.load(lf)
            if latest not in comparisons:
                comparisons.append(latest)
    except: pass

total = len(comparisons)
improved = sum(1 for c in comparisons if c.get('classification') == 'IMPROVED')
degraded = sum(1 for c in comparisons if c.get('classification') == 'DEGRADED')
neutral = sum(1 for c in comparisons if c.get('classification') == 'NEUTRAL')

output = {
    'comparison_count': total,
    'improved': improved,
    'degraded': degraded,
    'neutral': neutral,
    'improvement_rate': round(improved / total, 3) if total > 0 else 0.0
}
print(json.dumps(output))
" >"$TMP_COMPS" 2>/dev/null

# Latest comparison
LATEST_COMP='null'
if [[ -f "$COMPARISON_FILE" ]]; then
  LATEST_COMP=$(cat "$COMPARISON_FILE")
fi

# Proposal count
PROPOSAL_COUNT=0
if [[ -d "$PROPOSALS_DIR" ]]; then
  PROPOSAL_COUNT=$(find "$PROPOSALS_DIR" -name '*.json' 2>/dev/null | wc -l)
fi

# Registry benchmark count
REGISTRY_COUNT=$(python3 -c "
import json
with open('$REPO_ROOT/benchmarks/registry.json') as f:
    reg = json.load(f)
print(len(reg.get('benchmarks', [])))
" 2>/dev/null || echo 0)

# ── Build report ──

python3 -c "
import json

with open('$TMP_RUNS') as f:
    run_stats = json.load(f)
with open('$TMP_COMPS') as f:
    comp_stats = json.load(f)
latest = json.loads('''$LATEST_COMP''')

registry_count = $REGISTRY_COUNT
proposal_count = $PROPOSAL_COUNT

# Coverage rate
covered = run_stats.get('benchmarks_with_runs', 0)
coverage_rate = round(covered / registry_count, 3) if registry_count > 0 else 0.0

# Latest classification
latest_class = None
if latest and latest != 'null' and isinstance(latest, dict):
    latest_class = latest.get('classification')

report = {
    'generated_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    'improvement_cycle': {
        'benchmark_runs': run_stats.get('run_count', 0),
        'benchmark_pass_rate': run_stats.get('pass_rate', 0.0),
        'benchmarks_in_registry': registry_count,
        'benchmarks_with_runs': covered,
        'benchmark_coverage_rate': coverage_rate,
        'proposals_created': proposal_count,
        'comparisons_performed': comp_stats.get('comparison_count', 0),
        'comparisons_improved': comp_stats.get('improved', 0),
        'comparisons_degraded': comp_stats.get('degraded', 0),
        'comparisons_neutral': comp_stats.get('neutral', 0),
        'improvement_rate': comp_stats.get('improvement_rate', 0.0),
        'latest_classification': latest_class
    },
    'recommendation': None
}

# Generate recommendation
if coverage_rate < 0.5:
    report['recommendation'] = 'Low benchmark coverage — run more benchmarks first'
elif proposal_count == 0:
    report['recommendation'] = 'No proposals created yet — review gap detection output and create a first proposal'
elif comp_stats.get('comparison_count', 0) == 0:
    report['recommendation'] = 'Proposals exist but none tested — run the improvement cycle'
elif report['improvement_cycle']['improvement_rate'] < 0.3:
    report['recommendation'] = 'Low improvement rate — review proposal quality and first-principles methodology'
elif report['improvement_cycle']['improvement_rate'] > 0.7:
    report['recommendation'] = 'Strong improvement rate — cycle is working well'
else:
    report['recommendation'] = 'Cycle operating normally'

print(json.dumps(report, indent=2))
" 2>/dev/null

# ── Save if requested ──
if $SAVE; then
  mkdir -p "$RUNTIME_DIR"
  bash "$0" >"$RUNTIME_DIR/meta-report.json" 2>/dev/null
  echo "[meta-report] Saved to $RUNTIME_DIR/meta-report.json" >&2
fi

exit 0
