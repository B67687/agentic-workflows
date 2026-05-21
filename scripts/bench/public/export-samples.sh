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
SPLIT="complete"

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

python3 "$SCRIPT_DIR/export-samples.py" \
  --run-dir "$RUN_DIR" \
  --output "$OUTPUT_FILE" \
  ${SUBSET:+--subset "$SUBSET"}

# ── Optionally evaluate ──

if $DO_EVALUATE; then
  echo "[export] Running bigcodebench.evaluate with $OUTPUT_FILE..." >&2

  if [[ ! -d "$VENV_DIR" ]]; then
    echo "Error: bench venv not found. Run: bash scripts/bench/public/setup.sh bigcodebench" >&2
    exit 1
  fi

  source "$VENV_DIR/bin/activate"

  # Use Python API directly (CLI has Fire parsing issues with selective_evaluate)
  python3 -c "
from bigcodebench.evaluate import evaluate

# Determine selective_evaluate from the samples file
import json
samples_path = '$OUTPUT_FILE'
task_ids = []
with open(samples_path) as f:
    for line in f:
        if line.strip():
            sample = json.loads(line)
            tid = sample['task_id']
            # Extract numeric ID: BigCodeBench/0 -> 0
            task_ids.append(tid.split('/')[-1])

selective = ','.join(task_ids) if task_ids else ''

evaluate(
    split='$SPLIT',
    subset='full',
    samples=samples_path,
    execution='$EXECUTION',
    selective_evaluate=selective,
    check_gt_only=False,
    no_gt=True,
)
" 2>&1

  # Suppress interactive prompt by piping yes
  echo "[export] Evaluation complete." >&2
fi
