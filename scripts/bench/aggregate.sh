#!/usr/bin/env bash
# =============================================================================
# aggregate.sh — Benchmark score aggregator
#
# Scans completed benchmark runs and computes aggregate scores by benchmark,
# category, and overall. Provides direction signal for harness effectiveness.
#
# Usage:
#   bash scripts/bench/aggregate.sh summary              Overall aggregate scores
#   bash scripts/bench/aggregate.sh by-benchmark          Per-benchmark breakdown
#   bash scripts/bench/aggregate.sh by-category           Per-category breakdown
#   bash scripts/bench/aggregate.sh by-skill              Per-skill breakdown
#   bash scripts/bench/aggregate.sh detail                Full detail with all runs
#   bash scripts/bench/aggregate.sh export                JSON export for external tools
#
# Data sources:
#   - .runtime/bench-runs/*/result.json    (benchmark run results)
#   - benchmarks/registry.json             (benchmark metadata registry)
#
# Exit codes:
#   0 = success
#   1 = error
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"
REGISTRY_FILE="$REPO_ROOT/benchmarks/registry.json"

# ── Colors ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/aggregate.sh <command>

Commands:
  summary               Overall aggregate scores (default)
  by-benchmark          Per-benchmark breakdown
  by-category           Per-category breakdown
  by-skill              Per-skill breakdown
  detail                Full detail with all runs
  export                JSON export for external tools
USAGE
}

# ── Data loading ──

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

load_runs() {
  if [[ ! -d "$RUNS_DIR" ]]; then
    echo '[]'
    return
  fi

  python3 -c "
import json, os, glob

runs_dir = '$RUNS_DIR'
results = []
for d in sorted(glob.glob(os.path.join(runs_dir, '*', 'result.json'))):
    try:
        with open(d) as f:
            r = json.load(f)
        results.append(r)
    except (json.JSONDecodeError, IOError):
        pass
print(json.dumps(results))
" 2>/dev/null || echo '[]'
}

# ── Analysis ──

compute_scores() {
  local runs_json="$1"
  local registry_json="$2"

  python3 -c "
import json, sys
from collections import defaultdict

runs = json.loads('''$runs_json''')
registry = json.loads('''$registry_json''')
benchmarks = registry.get('benchmarks', {})
categories = registry.get('categories', {})

# Aggregate by benchmark
by_benchmark = defaultdict(lambda: {'pass': 0, 'fail': 0, 'total': 0, 'times': []})
by_category = defaultdict(lambda: {'pass': 0, 'fail': 0, 'total': 0, 'weighted_score': 0.0})
by_skill = defaultdict(lambda: {'pass': 0, 'fail': 0, 'total': 0})
overall = {'pass': 0, 'fail': 0, 'total': 0}

for r in runs:
    bid = r.get('benchmark_id', 'unknown')
    success = r.get('success', False)
    steps = r.get('steps')
    time_s = r.get('time_seconds')

    bm = benchmarks.get(bid, {})
    cat = bm.get('category') or r.get('category', 'uncategorized')
    cat_weight = categories.get(cat, {}).get('weight', 1.0)
    skills = bm.get('skills', [])

    # Per benchmark
    bb = by_benchmark[bid]
    bb['total'] += 1
    if success:
        bb['pass'] += 1
    else:
        bb['fail'] += 1
    if time_s is not None:
        bb['times'].append(time_s)

    # Per category (weighted)
    bc = by_category[cat]
    bc['total'] += 1
    if success:
        bc['pass'] += 1
        bc['weighted_score'] += 1.0 * cat_weight
    else:
        bc['fail'] += 1

    # Per skill
    for skill in skills:
        bs = by_skill[skill]
        bs['total'] += 1
        if success:
            bs['pass'] += 1
        else:
            bs['fail'] += 1

    # Overall
    overall['total'] += 1
    if success:
        overall['pass'] += 1
    else:
        overall['fail'] += 1

# Compute rates
for bid, data in by_benchmark.items():
    data['pass_rate'] = round(data['pass'] / data['total'], 3) if data['total'] > 0 else 0.0
    data['avg_time'] = round(sum(data['times']) / len(data['times']), 1) if data['times'] else None

for cat, data in by_category.items():
    data['pass_rate'] = round(data['pass'] / data['total'], 3) if data['total'] > 0 else 0.0
    cw = categories.get(cat, {}).get('weight', 1.0)
    data['avg_weighted_score'] = round(data['weighted_score'] / data['total'], 3) if data['total'] > 0 else 0.0

for skill, data in by_skill.items():
    data['pass_rate'] = round(data['pass'] / data['total'], 3) if data['total'] > 0 else 0.0

overall['pass_rate'] = round(overall['pass'] / overall['total'], 3) if overall['total'] > 0 else 0.0

# Sort by pass rate ascending (problems first)
sorted_benchmarks = sorted(by_benchmark.items(), key=lambda x: x[1]['pass_rate'])
sorted_categories = sorted(by_category.items(), key=lambda x: x[1]['pass_rate'])
sorted_skills = sorted(by_skill.items(), key=lambda x: x[1]['pass_rate'])

result = {
    'overall': overall,
    'by_benchmark': {k: dict(v) for k, v in sorted_benchmarks},
    'by_category': {k: dict(v) for k, v in sorted_categories},
    'by_skill': {k: dict(v) for k, v in sorted_skills},
    'benchmark_count': len(by_benchmark),
    'run_count': len(runs)
}

print(json.dumps(result, indent=2))
" 2>/dev/null
}

# ── Output formatting ──

cmd_summary() {
  local scores="$1"
  echo ""
  echo -e "${BOLD}═══ Benchmark Score Summary${NC}"
  echo ""

  local overall
  overall=$(echo "$scores" | python3 -c "
import json, sys
s = json.load(sys.stdin)
o = s['overall']
print(f\"Runs: {o['total']}  Pass: {o['pass']}  Fail: {o['fail']}  Rate: {o['pass_rate']*100:.1f}%\")
print(f\"Benchmarks: {s['benchmark_count']}\")
" 2>/dev/null)

  echo "  $overall"
  echo ""

  # Show per-category breakdown
  echo -e "${BOLD}  By Category:${NC}"
  echo "$scores" | python3 -c "
import json, sys
s = json.load(sys.stdin)
cats = s['by_category']
for cat, data in sorted(cats.items()):
    rate = data['pass_rate'] * 100
    print(f\"    {cat}: {data['pass']}/{data['total']} ({rate:.0f}%)\")
" 2>/dev/null

  echo ""
  echo -e "${BOLD}  Lowest-Rated Benchmarks:${NC}"
  echo "$scores" | python3 -c "
import json, sys
s = json.load(sys.stdin)
bms = sorted(s['by_benchmark'].items(), key=lambda x: x[1]['pass_rate'])
for bid, data in bms[:3]:
    rate = data['pass_rate'] * 100
    print(f\"    {bid}: {data['pass']}/{data['total']} ({rate:.0f}%)\")
" 2>/dev/null

  echo ""
}

cmd_by_benchmark() {
  local scores="$1"
  echo ""
  echo -e "${BOLD}═══ Per-Benchmark Breakdown${NC}"
  echo ""

  echo "$scores" | python3 -c "
import json, sys
s = json.load(sys.stdin)
bms = s['by_benchmark']
for bid, data in sorted(bms.items(), key=lambda x: x[1]['pass_rate']):
    rate = data['pass_rate'] * 100
    time_str = f\" avg={data['avg_time']}s\" if data['avg_time'] else ''
    bar_len = 20
    filled = int(data['pass_rate'] * bar_len) if data['total'] > 0 else 0
    bar = '#' * filled + '-' * (bar_len - filled)
    print(f\"  [{bar}] {data['pass']:>2}/{data['total']:<2} ({rate:>5.1f}%){time_str}  {bid}\")
" 2>/dev/null
  echo ""
}

cmd_by_category() {
  local scores="$1"
  echo ""
  echo -e "${BOLD}═══ Per-Category Breakdown${NC}"
  echo ""

  echo "$scores" | python3 -c "
import json, sys
s = json.load(sys.stdin)
cats = s['by_category']
for cat, data in sorted(cats.items(), key=lambda x: x[1]['pass_rate']):
    rate = data['pass_rate'] * 100
    weighted = data['avg_weighted_score']
    bar_len = 20
    filled = int(data['pass_rate'] * bar_len) if data['total'] > 0 else 0
    bar = '#' * filled + '-' * (bar_len - filled)
    print(f\"  [{bar}] {data['pass']:>2}/{data['total']:<2} ({rate:>5.1f}%) w={weighted:.2f}  {cat}\")
" 2>/dev/null
  echo ""
}

cmd_by_skill() {
  local scores="$1"
  echo ""
  echo -e "${BOLD}═══ Per-Skill Breakdown${NC}"
  echo ""

  echo "$scores" | python3 -c "
import json, sys
s = json.load(sys.stdin)
skills = s['by_skill']
for skill, data in sorted(skills.items(), key=lambda x: x[1]['pass_rate']):
    rate = data['pass_rate'] * 100
    bar_len = 20
    filled = int(data['pass_rate'] * bar_len) if data['total'] > 0 else 0
    bar = '#' * filled + '-' * (bar_len - filled)
    print(f\"  [{bar}] {data['pass']:>2}/{data['total']:<2} ({rate:>5.1f}%)  {skill}\")
" 2>/dev/null
  echo ""
}

cmd_detail() {
  cmd_summary "$1"
  cmd_by_benchmark "$1"
  cmd_by_category "$1"
  cmd_by_skill "$1"

  # List individual runs
  local runs_json="$2"
  echo -e "${BOLD}  Recent Runs:${NC}"
  echo "$runs_json" | python3 -c "
import json, sys
runs = json.load(sys.stdin)
if not runs:
    print('    (no runs yet)')
else:
    for r in runs[-10:]:
        rid = r.get('run_id', '?')[:40]
        bid = r.get('benchmark_id', '?')
        status = 'PASS' if r.get('success') else 'FAIL'
        print(f\"    [{status}] {rid}  ({bid})\")
" 2>/dev/null
  echo ""
}

cmd_export() {
  local scores="$1"
  echo "$scores"
}

# ── Main ──

main() {
  local cmd="${1:-summary}"

  local runs_json
  runs_json=$(load_runs)
  local registry_json
  registry_json=$(load_registry)
  local scores
  scores=$(compute_scores "$runs_json" "$registry_json")

  # Check if we have any runs
  local run_count
  run_count=$(echo "$scores" | python3 -c "import json,sys; print(json.load(sys.stdin)['run_count'])" 2>/dev/null || echo 0)

  if [[ "$run_count" -eq 0 ]]; then
    echo ""
    echo -e "${YELLOW}No benchmark runs found.${NC}"
    echo "  Run benchmarks first with: bash scripts/tools/skill-bench.sh prepare ..."
    echo "  Then verify: bash scripts/tools/skill-bench.sh verify --run <dir>"
    echo ""
    exit 0
  fi

  case "$cmd" in
  summary)
    cmd_summary "$scores"
    ;;
  by-benchmark)
    cmd_by_benchmark "$scores"
    ;;
  by-category)
    cmd_by_category "$scores"
    ;;
  by-skill)
    cmd_by_skill "$scores"
    ;;
  detail)
    cmd_detail "$scores" "$runs_json"
    ;;
  export)
    cmd_export "$scores"
    ;;
  *)
    usage
    exit 2
    ;;
  esac
}

main "$@"
