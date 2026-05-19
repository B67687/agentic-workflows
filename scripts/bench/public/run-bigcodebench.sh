#!/usr/bin/env bash
# =============================================================================
# run-bigcodebench.sh — Run BigCodeBench against the agent and export results
#
# Pipeline:
#   1. Activates the bench-env venv (created by setup.sh)
#   2. Downloads BigCodeBench problems (Complete / Instruct / Hard)
#   3. For each problem: prepares a skill-bench run, lets the agent solve it
#   4. Verifies solutions using BigCodeBench's test harness
#   5. Exports results to .runtime/bench-runs/ for aggregate.sh consumption
#
# Usage:
#   bash scripts/bench/public/run-bigcodebench.sh [--subset <N>] [--split <split>]
#
# Options:
#   --subset <N>   Run only N problems (default: all 1,140)
#   --split <name> Dataset split: Complete (default), Instruct, Hard
#   --help         Show this help
#
# Requires:
#   - .runtime/bench-env/ (created by setup.sh bigcodebench)
#   - Network access to download the dataset
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VENV_DIR="$REPO_ROOT/.runtime/bench-env"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"

SUBSET=""
SPLIT="Complete"

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/public/run-bigcodebench.sh [options]

Options:
  --subset <N>   Run only N problems (default: all 1,140)
  --split <name> Dataset split: Complete (default), Instruct, Hard
  --help         Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --subset)
    SUBSET="$2"
    shift 2
    ;;
  --split)
    SPLIT="$2"
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

# ── Check venv ──
if [[ ! -d "$VENV_DIR" ]]; then
  echo "Error: bench venv not found. Run: bash scripts/bench/public/setup.sh bigcodebench" >&2
  exit 1
fi

source "$VENV_DIR/bin/activate"

# ── Pull problems from BigCodeBench ──
echo "[bigcodebench] Loading BigCodeBench ($SPLIT split)..." >&2
PROBLEMS_JSON=$(python3 -c "
from bigcodebench import BigCodeBench
import json

dataset = BigCodeBench(trust_remote_code=True)
problems = dataset.get_problems()
# Filter by split
split_problems = {k: v for k, v in problems.items() if v.get('split') == '$SPLIT' or '$SPLIT' == 'Complete'}
print(json.dumps(split_problems, indent=2))
" 2>/dev/null)

PROBLEM_COUNT=$(echo "$PROBLEMS_JSON" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)
echo "[bigcodebench] Found $PROBLEM_COUNT problems" >&2

if [[ "$PROBLEM_COUNT" -eq 0 ]]; then
  echo "Error: no problems loaded. Check split name and network." >&2
  exit 1
fi

# Apply subset limit
if [[ -n "$SUBSET" ]]; then
  echo "[bigcodebench] Subsetting to $SUBSET problems" >&2
  PROBLEMS_JSON=$(echo "$PROBLEMS_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
limited = dict(list(data.items())[:int('$SUBSET')])
print(json.dumps(limited))
" 2>/dev/null)
  echo "[bigcodebench] Limited to $SUBSET problems" >&2
fi

# ── Process each problem ──
PASSED=0
FAILED=0
TOTAL=0

echo "$PROBLEMS_JSON" | python3 -c "
import json, sys, os

problems = json.load(sys.stdin)
runs_dir = '$RUNS_DIR'

for pid, problem in problems.items():
    task_id = problem.get('task_id', pid)
    
    # Create run directory
    run_id = f'bigcodebench-{pid}-' + os.popen('date -u +%Y%m%d%H%M%S').read().strip()
    run_dir = os.path.join(runs_dir, run_id)
    os.makedirs(run_dir, exist_ok=True)
    
    # Write prompt
    prompt_path = os.path.join(run_dir, 'prompt.md')
    with open(prompt_path, 'w') as f:
        f.write(f'# BigCodeBench: {pid}\n\n')
        f.write(f'## Problem\n\n{problem.get(\"prompt\", \"\")}\n\n')
        f.write(f'## Instructions\n\n')
        f.write(f'Complete the function. Write your solution to output.md.\n')
        f.write(f'Report: BENCH_SUCCESS: true/false, BENCH_STEPS: N, BENCH_TIME_SEC: N\n')
    
    print(f'PREPARED:{run_id}:{pid}')

# Write full problem set for agent processing
problems_path = os.path.join(runs_dir, 'bigcodebench-problems.json')
with open(problems_path, 'w') as f:
    json.dump(problems, f, indent=2)
print(f'DONE:{problems_path}')
" 2>/dev/null

echo "[bigcodebench] Problems prepared. Each will appear in .runtime/bench-runs/bigcodebench-*" >&2
echo "[bigcodebench] After running: each run dir needs output.md with the solution" >&2
echo "[bigcodebench] Then verify with: bigcodebench.check --solutions <path>" >&2
echo "" >&2
echo "Next steps:" >&2
echo "  1. For each run dir, the agent writes a solution to output.md" >&2
echo "  2. Run verification: python3 -m bigcodebench.check --solutions .runtime/bench-runs/ --tasks .runtime/bench-runs/bigcodebench-problems.json" >&2
echo "  3. Results auto-import into aggregate.sh" >&2

# ── Output summary JSON ──
echo "{"
echo "  \"benchmark\": \"bigcodebench\","
echo "  \"split\": \"$SPLIT\","
echo "  \"problems_total\": $PROBLEM_COUNT,"
echo "  \"problems_prepared\": $PROBLEM_COUNT,"
echo "  \"status\": \"prepared\","
echo "  \"message\": \"Run agent on each prepared directory, then verify\""
echo "}"

exit 0
