#!/usr/bin/env bash
# =============================================================================
# import-results.sh — Import public benchmark results into aggregate.sh format
#
# Converts results from external benchmarks (BigCodeBench, HumanEval, etc.)
# into .runtime/bench-runs/result.json files that aggregate.sh can read.
#
# Usage:
#   bash scripts/bench/public/import-results.sh bigcodebench --results <results.json>
#   bash scripts/bench/public/import-results.sh humaneval --results <results.json>
#
# Output: Creates result.json files in .runtime/bench-runs/ for each task
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"

BENCHMARK=""
RESULTS_FILE=""

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/public/import-results.sh <benchmark> --results <file>

Benchmarks:
  bigcodebench    Import BigCodeBench results
  humaneval       Import HumanEval results
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

BENCHMARK="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
  --results)
    RESULTS_FILE="$2"
    shift 2
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown: $1" >&2
    usage
    exit 2
    ;;
  esac
done

if [[ -z "$RESULTS_FILE" || ! -f "$RESULTS_FILE" ]]; then
  echo "Error: --results <file> required" >&2
  exit 2
fi

case "$BENCHMARK" in
bigcodebench)
  echo "[import] Importing BigCodeBench results from $RESULTS_FILE" >&2
  python3 -c "
import json, os, sys
from datetime import datetime

runs_dir = '$RUNS_DIR'

with open('$RESULTS_FILE') as f:
    results = json.load(f)

# results format: dict of task_id -> {passed, status, etc.}
for task_id, result in results.items():
    passed = result.get('passed', False)
    run_id = f'bigcodebench-{task_id}-imported'
    run_dir = os.path.join(runs_dir, run_id)
    os.makedirs(run_dir, exist_ok=True)
    
    result_data = {
        'run_id': run_id,
        'benchmark': 'bigcodebench',
        'benchmark_id': f'bigcodebench-{task_id}',
        'success': passed,
        'status': 'verified',
        'verified_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    }
    
    with open(os.path.join(run_dir, 'result.json'), 'w') as f:
        json.dump(result_data, f, indent=2)

print(f'Imported {len(results)} results')
" 2>/dev/null
  ;;

humaneval)
  echo "[import] Importing HumanEval results from $RESULTS_FILE" >&2
  python3 -c "
import json, os, sys
from datetime import datetime

runs_dir = '$RUNS_DIR'

with open('$RESULTS_FILE') as f:
    results = json.load(f)

for item in results:
    task_id = item.get('task_id', 'unknown')
    passed = item.get('passed', False)
    run_id = f'humaneval-{task_id}-imported'
    run_dir = os.path.join(runs_dir, run_id)
    os.makedirs(run_dir, exist_ok=True)
    
    result_data = {
        'run_id': run_id,
        'benchmark': 'humaneval',
        'benchmark_id': f'humaneval-{task_id}',
        'success': passed,
        'status': 'verified',
        'verified_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    }
    
    with open(os.path.join(run_dir, 'result.json'), 'w') as f:
        json.dump(result_data, f, indent=2)

print(f'Imported {len(results)} results')
" 2>/dev/null
  ;;

*)
  echo "Unknown benchmark: $BENCHMARK" >&2
  exit 2
  ;;
esac

# Re-run aggregate to show updated scores
echo "[import] Running updated aggregate..." >&2
bash "$REPO_ROOT/scripts/bench/aggregate.sh" summary

exit 0
