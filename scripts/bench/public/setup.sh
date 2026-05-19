#!/usr/bin/env bash
# =============================================================================
# setup.sh — Install public benchmark frameworks (BigCodeBench, HumanEval, etc.)
#
# Creates a Python virtual environment and installs the requested benchmark.
# The venv lives in .runtime/bench-env/ to avoid polluting system packages.
#
# Usage:
#   bash scripts/bench/public/setup.sh bigcodebench
#   bash scripts/bench/public/setup.sh humaneval
#   bash scripts/bench/public/setup.sh all
#
# Each benchmark is independently installable.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VENV_DIR="$REPO_ROOT/.runtime/bench-env"

BENCHMARK="${1:-help}"

usage() {
  cat <<'USAGE'
Usage: bash scripts/bench/public/setup.sh <benchmark>

Benchmarks:
  bigcodebench    Install BigCodeBench (1,140 API-heavy Python tasks)
  humaneval       Install HumanEval (164 function completion tasks)
  all             Install all supported public benchmarks
USAGE
}

setup_venv() {
  if [[ ! -d "$VENV_DIR" ]]; then
    echo "[setup] Creating Python venv at $VENV_DIR" >&2
    python3 -m venv "$VENV_DIR"
  fi
  source "$VENV_DIR/bin/activate"
}

case "$BENCHMARK" in
bigcodebench)
  setup_venv
  echo "[setup] Installing BigCodeBench..." >&2
  pip install -q bigcodebench 2>/dev/null

  # Configure HF token for faster downloads
  HF_CACHE_DIR="$HOME/.cache/huggingface"
  if [[ ! -f "$HF_CACHE_DIR/token" ]]; then
    echo "[setup] No HF token found. BigCodeBench will work but downloads may be slow." >&2
    echo "[setup] To speed up: save a HuggingFace read token to $HF_CACHE_DIR/token" >&2
    echo "[setup] Get one at: https://huggingface.co/settings/tokens" >&2
  else
    export HF_TOKEN=$(cat "$HF_CACHE_DIR/token")
    echo "[setup] HF token configured — authenticated downloads enabled" >&2
  fi
  echo "[setup] BigCodeBench ready. Usage: bash scripts/bench/public/run-bigcodebench.sh" >&2
  ;;
humaneval)
  setup_venv
  echo "[setup] Installing HumanEval..." >&2
  pip install -q human-eval 2>/dev/null
  echo "[setup] HumanEval ready." >&2
  ;;
all)
  setup_venv
  echo "[setup] Installing all public benchmarks..." >&2
  pip install -q bigcodebench human-eval 2>/dev/null
  echo "[setup] All public benchmarks ready." >&2
  ;;
help | --help | -h)
  usage
  exit 0
  ;;
*)
  echo "Unknown benchmark: $BENCHMARK" >&2
  usage
  exit 2
  ;;
esac
