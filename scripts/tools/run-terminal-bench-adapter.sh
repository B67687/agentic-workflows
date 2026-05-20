#!/usr/bin/env bash
# ==============================================================================
# Run the Terminal-Bench Harbor adapter to download/generate tasks
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Activate the bench-env venv (has harbor installed)
source "$REPO_ROOT/.runtime/bench-env/bin/activate"

export PYTHONPATH="$REPO_ROOT/adapters/terminal-bench/src${PYTHONPATH:+:$PYTHONPATH}"

python3 -m terminal_bench.adapter "$@"
