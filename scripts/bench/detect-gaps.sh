#!/usr/bin/env bash
# =============================================================================
# detect-gaps.sh — Phase 1: Detection mechanism for self-improving framework
#
# Analyzes benchmark scores for four gap types:
#   COVERAGE   — benchmarks in registry with zero runs
#   SIGNAL     — benchmarks with too few runs for confidence (<3)
#   DEGRADED   — scores that dropped compared to previous baseline (if provided)
#   PLATEAU    — scores unchanged across multiple measurement cycles (if history)
#
# Usage:
#   bash scripts/bench/detect-gaps.sh
#     Reads current scores via aggregate.sh export, detects coverage + signal gaps
#
#   bash scripts/bench/detect-gaps.sh --baseline <file>
#     Compares current scores against a previous baseline export for degradation
#
#   bash scripts/bench/detect-gaps.sh --history <dir>
#     Analyzes score history directory for plateau detection
#
# Output: JSON with gaps array, each gap has:
#   id, type, severity (high/medium/low), benchmark_id (or null),
#   current_value, expected_value, evidence, suggestion
#
# Exit codes:
#   0 = success (gaps may or may not exist)
#   1 = error
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REGISTRY_FILE="$REPO_ROOT/benchmarks/registry.json"

BASELINE_FILE=""
HISTORY_DIR=""

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/detect-gaps.sh [options]

Options:
  --baseline <file>    Previous baseline export for degradation detection
  --history <dir>      Score history directory for plateau detection
  --help               Show this help

Without options, detects coverage gaps and signal gaps from current scores.
USAGE
}

# ── Parse arguments ──

while [[ $# -gt 0 ]]; do
  case "$1" in
  --baseline)
    BASELINE_FILE="$2"
    shift 2
    ;;
  --history)
    HISTORY_DIR="$2"
    shift 2
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    usage
    exit 2
    ;;
  esac
done

# ── Load data ──

load_registry() {
  if [[ -f "$REGISTRY_FILE" ]]; then
    python3 -c "
import json, sys
with open('$REGISTRY_FILE') as f:
    reg = json.load(f)
benchmarks = {b['id']: b for b in reg.get('benchmarks', [])}
categories = reg.get('categories', {})
print(json.dumps({'benchmarks': benchmarks, 'categories': categories}))
" 2>/dev/null || echo '{"benchmarks":{},"categories":{}}'
  else
    echo '{"benchmarks":{},"categories":{}}'
  fi
}

# Get current scores
CURRENT_SCORES=$(bash "$SCRIPT_DIR/aggregate.sh" export 2>/dev/null || echo '{}')

# ── Gap detection functions ──

detect_coverage_gaps() {
  local registry_json="$1"
  local current_json="$2"

  python3 -c "
import json, sys

registry = json.loads('''$registry_json''')
current = json.loads('''$current_json''')

reg_benchmarks = registry.get('benchmarks', {})
current_bms = current.get('by_benchmark', {})

gaps = []
for bid, bm in reg_benchmarks.items():
    runs = current_bms.get(bid, {})
    total = runs.get('total', 0)
    if total == 0:
        gaps.append({
            'id': f'coverage-{bid}',
            'type': 'COVERAGE',
            'severity': 'high',
            'benchmark_id': bid,
            'benchmark_name': bm.get('name', bid),
            'category': bm.get('category', 'unknown'),
            'difficulty': bm.get('difficulty', 'unknown'),
            'skills': bm.get('skills', []),
            'current_value': 0,
            'expected_value': 1,
            'evidence': f'Benchmark \"{bm.get(\"name\", bid)}\" has 0 runs — no measurement data available',
            'suggestion': f'Run benchmark: bash scripts/tools/skill-bench.sh prepare {bid}'
        })

# Sort: high severity first, then by benchmark_id
gaps.sort(key=lambda g: (0 if g['severity'] == 'high' else 1 if g['severity'] == 'medium' else 2, g['benchmark_id']))
print(json.dumps(gaps, indent=2))
" 2>/dev/null || echo '[]'
}

detect_signal_gaps() {
  local current_json="$1"

  python3 -c "
import json, sys

current = json.loads('''$current_json''')
current_bms = current.get('by_benchmark', {})

gaps = []
for bid, data in current_bms.items():
    total = data.get('total', 0)
    if total < 3:
        severity = 'high' if total == 0 else 'medium'
        gaps.append({
            'id': f'signal-{bid}',
            'type': 'SIGNAL',
            'severity': severity,
            'benchmark_id': bid,
            'current_value': total,
            'expected_value': 3,
            'evidence': f'Benchmark \"{bid}\" has only {total} run(s) — minimum 3 needed for statistical confidence',
            'suggestion': f'Run {3 - total} more time(s): bash scripts/tools/skill-bench.sh prepare {bid}'
        })

gaps.sort(key=lambda g: (0 if g['severity'] == 'high' else 1, g['benchmark_id']))
print(json.dumps(gaps, indent=2))
" 2>/dev/null || echo '[]'
}

detect_degradation() {
  local baseline_file="$1"
  local current_json="$2"

  if [[ ! -f "$baseline_file" ]]; then
    echo '[]'
    return
  fi

  python3 -c "
import json, sys

try:
    with open('$baseline_file') as f:
        baseline = json.load(f)
except (json.JSONDecodeError, IOError):
    print('[]')
    sys.exit(0)

current = json.loads('''$current_json''')

baseline_bms = baseline.get('by_benchmark', {})
current_bms = current.get('by_benchmark', {})

gaps = []
for bid, cur_data in current_bms.items():
    base_data = baseline_bms.get(bid)
    if base_data is None:
        continue

    cur_rate = cur_data.get('pass_rate', 1.0)
    base_rate = base_data.get('pass_rate', 1.0)
    delta = cur_rate - base_rate

    if delta < -0.05:  # More than 5% drop
        gaps.append({
            'id': f'degraded-{bid}',
            'type': 'DEGRADED',
            'severity': 'high' if delta < -0.1 else 'medium',
            'benchmark_id': bid,
            'current_value': round(cur_rate, 3),
            'previous_value': round(base_rate, 3),
            'delta': round(delta, 3),
            'evidence': f'Benchmark \"{bid}\" dropped from {base_rate:.1%} to {cur_rate:.1%} (Δ{delta:.1%})',
            'suggestion': 'Review recent changes affecting this area and consider reverting or fixing'
        })

    elif delta > 0.05:
        # Improvement — not a gap but note it
        pass

gaps.sort(key=lambda g: (0 if g['severity'] == 'high' else 1, g['benchmark_id']))
print(json.dumps(gaps, indent=2))
" 2>/dev/null || echo '[]'
}

detect_plateaus() {
  local history_dir="$1"
  local current_json="$2"

  if [[ ! -d "$history_dir" ]]; then
    echo '[]'
    return
  fi

  python3 -c "
import json, sys, os, glob

current = json.loads('''$current_json''')
current_bms = current.get('by_benchmark', {})

# Collect history files
history_files = sorted(glob.glob(os.path.join('$history_dir', 'scores-*.json')))
if len(history_files) < 3:
    print('[]')
    sys.exit(0)

# Build history per benchmark
history = {}  # bid -> [pass_rates]
for hf in history_files:
    try:
        with open(hf) as f:
            data = json.load(f)
        for bid, bm_data in data.get('by_benchmark', {}).items():
            rate = bm_data.get('pass_rate', 0.0)
            if bid not in history:
                history[bid] = []
            history[bid].append(rate)
    except (json.JSONDecodeError, IOError):
        pass

gaps = []
for bid, rates in history.items():
    if len(rates) < 3:
        continue

    # Check if rate hasn't changed across last 3 measurements
    last_3 = rates[-3:]
    if len(set(last_3)) == 1:
        current_rate = current_bms.get(bid, {}).get('pass_rate', 0.0)
        gaps.append({
            'id': f'plateau-{bid}',
            'type': 'PLATEAU',
            'severity': 'medium',
            'benchmark_id': bid,
            'current_value': current_rate,
            'measurements': len(rates),
            'evidence': f'Benchmark \"{bid}\" pass rate unchanged across {len(rates)} measurements at {current_rate:.0%}',
            'suggestion': 'Investigate whether the benchmark is still discriminating or if the metric needs recalibration'
        })

print(json.dumps(gaps, indent=2))
" 2>/dev/null || echo '[]'
}

# ── Main: single python3 process for all assembly ──

main() {
  local registry_json
  registry_json=$(load_registry)

  local baseline_json='null'
  if [[ -n "$BASELINE_FILE" && -f "$BASELINE_FILE" ]]; then
    baseline_json=$(cat "$BASELINE_FILE")
  fi

  local history_files_json='[]'
  if [[ -n "$HISTORY_DIR" && -d "$HISTORY_DIR" ]]; then
    history_files_json=$(python3 -c "
import json, glob, sys, os
files = sorted(glob.glob(os.path.join('$HISTORY_DIR', 'scores-*.json')))
data = []
for f in files:
    try:
        with open(f) as hf:
            data.append(json.load(hf))
    except: pass
print(json.dumps(data))
" 2>/dev/null)
  fi

  # Run all detection in a single python process
  python3 -c "
import json, sys
from collections import defaultdict

registry = json.loads('''$registry_json''')
current = json.loads('''$CURRENT_SCORES''')
baseline = json.loads('''$baseline_json''')
history = json.loads('''$history_files_json''')

reg_benchmarks = registry.get('benchmarks', {})
current_bms = current.get('by_benchmark', {})
gaps = []

# ── Coverage gaps ──
for bid, bm in reg_benchmarks.items():
    runs = current_bms.get(bid, {})
    total = runs.get('total', 0)
    if total == 0:
        gaps.append({
            'id': f'coverage-{bid}',
            'type': 'COVERAGE',
            'severity': 'high',
            'benchmark_id': bid,
            'benchmark_name': bm.get('name', bid),
            'category': bm.get('category', 'unknown'),
            'difficulty': bm.get('difficulty', 'unknown'),
            'skills': bm.get('skills', []),
            'current_value': 0,
            'expected_value': 1,
            'evidence': f'Benchmark \"{bm.get(\"name\", bid)}\" has 0 runs — no measurement data available',
            'suggestion': f'Run benchmark: bash scripts/tools/skill-bench.sh prepare {bid}'
        })

# ── Signal gaps ──
for bid, data in current_bms.items():
    total = data.get('total', 0)
    if 0 < total < 3:
        severity = 'high' if total == 0 else 'medium'
        gaps.append({
            'id': f'signal-{bid}',
            'type': 'SIGNAL',
            'severity': severity,
            'benchmark_id': bid,
            'current_value': total,
            'expected_value': 3,
            'evidence': f'Benchmark \"{bid}\" has only {total} run(s) — minimum 3 needed for statistical confidence',
            'suggestion': f'Run {3 - total} more time(s): bash scripts/tools/skill-bench.sh prepare {bid}'
        })

# ── Degradation (if baseline provided) ──
if baseline is not None and 'by_benchmark' in baseline:
    baseline_bms = baseline.get('by_benchmark', {})
    for bid, cur_data in current_bms.items():
        base_data = baseline_bms.get(bid)
        if base_data is None:
            continue
        cur_rate = cur_data.get('pass_rate', 1.0)
        base_rate = base_data.get('pass_rate', 1.0)
        delta = cur_rate - base_rate
        if delta < -0.05:
            gaps.append({
                'id': f'degraded-{bid}',
                'type': 'DEGRADED',
                'severity': 'high' if delta < -0.1 else 'medium',
                'benchmark_id': bid,
                'current_value': round(cur_rate, 3),
                'previous_value': round(base_rate, 3),
                'delta': round(delta, 3),
                'evidence': f'Benchmark \"{bid}\" dropped from {base_rate:.1%} to {cur_rate:.1%} (delta {delta:.1%})',
                'suggestion': 'Review recent changes affecting this area and consider reverting or fixing'
            })

# ── Plateaus (if history provided) ──
if len(history) >= 3:
    hist_by_bm = defaultdict(list)
    for h in history:
        for bid, bm_data in h.get('by_benchmark', {}).items():
            hist_by_bm[bid].append(bm_data.get('pass_rate', 0.0))
    for bid, rates in hist_by_bm.items():
        if len(rates) >= 3:
            last_3 = rates[-3:]
            if len(set(last_3)) == 1:
                current_rate = current_bms.get(bid, {}).get('pass_rate', 0.0)
                gaps.append({
                    'id': f'plateau-{bid}',
                    'type': 'PLATEAU',
                    'severity': 'medium',
                    'benchmark_id': bid,
                    'current_value': current_rate,
                    'measurements': len(rates),
                    'evidence': f'Benchmark \"{bid}\" pass rate unchanged across {len(rates)} measurements at {current_rate:.0%}',
                    'suggestion': 'Investigate whether the benchmark is still discriminating or if the metric needs recalibration'
                })

# Sort: high severity first, then type, then benchmark_id
sev_order = {'high': 0, 'medium': 1, 'low': 2}
type_order = {'COVERAGE': 0, 'DEGRADED': 1, 'SIGNAL': 2, 'PLATEAU': 3}
gaps.sort(key=lambda g: (
    sev_order.get(g['severity'], 9),
    type_order.get(g['type'], 9),
    g.get('benchmark_id', '')
))

result = {
    'detected_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    'gap_count': len(gaps),
    'gaps': gaps,
    'summary': {
        'baseline_used': baseline is not None,
        'history_used': len(history) > 0
    }
}
print(json.dumps(result, indent=2))
" 2>/dev/null

  exit 0
}

main
