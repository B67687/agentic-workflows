#!/usr/bin/env bash
# =============================================================================
# export-samples.sh -- Export benchmark solutions to BigCodeBench .jsonl format
#
# Converts solutions from .runtime/bench-runs/bigcodebench-* into the
# .jsonl format required by bigcodebench.evaluate() (Gradle or local mode).
#
# The .jsonl format:
#   {"task_id": "BigCodeBench/0", "solution": "def func():\n  ..."}
#
# Usage:
#   bash scripts/bench/public/export-samples.sh [--run-dir <dir>] [--output <file>]
#     Default: scans .runtime/bench-runs for bigcodebench-* dirs with output.md
#     Default output: .runtime/bench-runs/bigcodebench-samples.jsonl
#
#   bash scripts/bench/public/export-samples.sh --evaluate
#     Export samples then run bigcodebench.evaluate with Gradio execution
#
#   bash scripts/bench/public/export-samples.sh --evaluate --execution local
#     Export samples then evaluate locally (requires bigcodebench venv)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"
DEFAULT_OUTPUT="$RUNS_DIR/bigcodebench-samples.jsonl"
VENV_DIR="$REPO_ROOT/.runtime/bench-env"

RUN_DIR="$RUNS_DIR"
OUTPUT_FILE="$DEFAULT_OUTPUT"
DO_EVALUATE=false
EXECUTION="gradio"
SUBSET=""
SPLIT="Complete"

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/public/export-samples.sh [options]

Options:
  --run-dir <dir>    Scan a specific run directory (default: .runtime/bench-runs)
  --output <file>    Output .jsonl path (default: .runtime/bench-runs/bigcodebench-samples.jsonl)
  --evaluate         After export, run bigcodebench.evaluate with the samples
  --execution <mode> Evaluation mode: gradio (default), local, e2b
  --subset <N>       Only include first N problems (for testing)
  --split <name>     Dataset split: Complete (default), Instruct, Hard
  --help             Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --run-dir)
    RUN_DIR="$2"
    shift 2
    ;;
  --output)
    OUTPUT_FILE="$2"
    shift 2
    ;;
  --evaluate)
    DO_EVALUATE=true
    shift
    ;;
  --execution)
    EXECUTION="$2"
    shift 2
    ;;
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

# ── Collect solutions from run directories ──

echo "[export] Scanning $RUN_DIR for bigcodebench run directories..." >&2

python3 -c "
import json, os, glob, re

runs_dir = '$RUN_DIR'
output_file = '$OUTPUT_FILE'
subset = '$SUBSET'
samples = []

# Find all bigcodebench run directories with output.md
# Pattern: bigcodebench-*/output.md or standalone-*/output.md containing BigCodeBench
for output_path in glob.glob(os.path.join(runs_dir, '*', 'output.md')):
    run_dir = os.path.dirname(output_path)
    run_name = os.path.basename(run_dir)
    
    # Check if this is a BigCodeBench run (directory name or content)
    is_bigcodebench = False
    task_id = None
    
    # Check meta.json
    meta_path = os.path.join(run_dir, 'meta.json')
    if os.path.isfile(meta_path):
        try:
            with open(meta_path) as f:
                meta = json.load(f)
            bid = meta.get('benchmark_id', '')
            if 'bigcodebench' in bid.lower():
                is_bigcodebench = True
                task_id = bid
        except:
            pass
    
    # Check result.json
    if not is_bigcodebench:
        result_path = os.path.join(run_dir, 'result.json')
        if os.path.isfile(result_path):
            try:
                with open(result_path) as f:
                    result = json.load(f)
                bid = result.get('benchmark_id', '')
                if 'bigcodebench' in bid.lower():
                    is_bigcodebench = True
                    task_id = bid
            except:
                pass
    
    if not is_bigcodebench:
        continue
    
    # Read the solution from output.md
    with open(output_path) as f:
        solution = f.read()
    
    # Convert normalized ID back to BigCodeBench format if needed
    # e.g., bigcodebench-0 -> BigCodeBench/0
    if task_id and '/' not in task_id:
        # Extract the number
        m = re.search(r'bigcodebench[-/](\d+)', task_id, re.IGNORECASE)
        if m:
            task_id = f'BigCodeBench/{m.group(1)}'
    
    if not task_id:
        # Fall back to extracting from directory name
        m = re.search(r'bigcodebench[-/](\d+)', run_name, re.IGNORECASE)
        if m:
            task_id = f'BigCodeBench/{m.group(1)}'
        else:
            continue
    
    samples.append({
        'task_id': task_id,
        'solution': solution,
        '_source': run_dir
    })

if not samples:
    err_msg = 'ERROR: No BigCodeBench solutions found'
    print(err_msg)
    sys.exit(1)

# Remove duplicates (keep last)
seen = {}
for s in samples:
    seen[s['task_id']] = s
samples = list(seen.values())

# Apply subset
if subset:
    try:
        n = int(subset)
        samples = samples[:n]
    except ValueError:
        pass

# Sort by task_id
samples.sort(key=lambda s: s['task_id'])

# Write .jsonl
with open(output_file, 'w') as f:
    for s in samples:
        line = json.dumps({'task_id': s['task_id'], 'solution': s['solution']})
        f.write(line + '\n')

print(f'Exported {len(samples)} samples to {output_file}')
print(f'Task IDs: {[s[\"task_id\"] for s in samples]}')
" 2>&1

# ── Optionally evaluate ──

if $DO_EVALUATE; then
  echo "[export] Running bigcodebench.evaluate with $OUTPUT_FILE..." >&2

  if [[ ! -d "$VENV_DIR" ]]; then
    echo "Error: bench venv not found. Run: bash scripts/bench/public/setup.sh bigcodebench" >&2
    exit 1
  fi

  source "$VENV_DIR/bin/activate"

  python3 -m bigcodebench.evaluate \
    --split "$SPLIT" \
    --samples "$OUTPUT_FILE" \
    --execution "$EXECUTION" 2>&1

  echo "[export] Evaluation complete." >&2
fi
