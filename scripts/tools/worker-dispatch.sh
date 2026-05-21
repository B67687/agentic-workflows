#!/usr/bin/env bash
# =============================================================================
# worker-dispatch.sh --- Structured worker dispatch with timeout and fallback
#
# Generates a worker prompt with step budget and fallback contract.
# Run this before dispatching a @worker to prevent runaway workers.
#
# Usage:
#   bash scripts/tools/worker-dispatch.sh --task <task description> \
#     --run-dir <path> [--steps 8] [--model minimax|flash|pro]
#
# The script outputs a structured prompt for the orchestrator to use
# when dispatching a @worker subagent. It includes:
#   - Step budget (max tool calls before writing partial result)
#   - Clear success criteria
#   - Error reporting format
#   - Fallback contract (parent handles on failure)
#
# Exit codes:
#   0 - prompt generated
#   1 - missing arguments
# =============================================================================
set -euo pipefail

usage() {
  cat <<EOF
Usage: bash scripts/tools/worker-dispatch.sh --task <desc> --run-dir <path> [options]

Required:
  --task TEXT       Task description for the worker
  --run-dir PATH    Path to the run directory (output.md goes here)

Options:
  --steps N         Max tool calls before partial result (default: 8)
  --model MODEL     Worker model hint (minimax|flash|pro, default: flash)
  --benchmark PATH  Benchmark file path (for verify.sh instructions)
  --verify-only     Only run verification (skip dispatch)
  --help            Show this help

Examples:
  bash scripts/tools/worker-dispatch.sh \\
    --task "Find the largest file in scripts/ and benchmarks/" \\
    --run-dir .runtime/bench-runs/my-run \\
    --steps 6

  # After worker returns, verify:
  bash scripts/tools/worker-dispatch.sh --verify-only \\
    --run-dir .runtime/bench-runs/my-run
EOF
}

TASK=""
RUN_DIR=""
STEPS=8
MODEL="flash"
BENCHMARK=""
VERIFY_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --task)
    TASK="$2"
    shift 2
    ;;
  --run-dir)
    RUN_DIR="$2"
    shift 2
    ;;
  --steps)
    STEPS="$2"
    shift 2
    ;;
  --model)
    MODEL="$2"
    shift 2
    ;;
  --benchmark)
    BENCHMARK="$2"
    shift 2
    ;;
  --verify-only)
    VERIFY_ONLY=true
    shift
    ;;
  --help | -h)
    usage
    exit 0
    ;;
  *)
    echo "ERROR: Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

if [[ "$VERIFY_ONLY" == true ]]; then
  if [[ -z "$RUN_DIR" ]]; then
    echo "ERROR: --run-dir is required with --verify-only" >&2
    exit 1
  fi
  if [[ ! -d "$RUN_DIR" ]]; then
    echo "ERROR: Run directory not found: $RUN_DIR" >&2
    exit 1
  fi
  if [[ -f "$RUN_DIR/verify.sh" ]]; then
    echo ":: Running verification for $RUN_DIR..."
    if bash "$RUN_DIR/verify.sh" 2>&1; then
      echo "VERIFY: PASS"
      exit 0
    else
      echo "VERIFY: FAIL"
      exit 1
    fi
  else
    echo "WARN: No verify.sh found in $RUN_DIR" >&2
    exit 0
  fi
fi

if [[ -z "$TASK" || -z "$RUN_DIR" ]]; then
  echo "ERROR: --task and --run-dir are required" >&2
  usage >&2
  exit 1
fi

# Validate steps is a positive integer
if ! [[ "$STEPS" =~ ^[0-9]+$ ]] || [[ "$STEPS" -lt 1 ]]; then
  echo "ERROR: --steps must be a positive integer, got: $STEPS" >&2
  exit 1
fi

# Ensure run dir exists
mkdir -p "$RUN_DIR"

# Model selection
case "$MODEL" in
minimax)
  MODEL_NAME="opencode/minimax-m2.5-free"
  MODEL_NOTE="free tier, slower but capable"
  ;;
flash)
  MODEL_NAME="opencode-go/deepseek-v4-flash"
  MODEL_NOTE="fast volume lane, same as orchestrator"
  ;;
pro)
  MODEL_NAME="opencode-go/deepseek-v4-pro"
  MODEL_NOTE="maximum quality, higher quota cost"
  ;;
*)
  echo "ERROR: Unknown model: $MODEL (valid: minimax, flash, pro)" >&2
  exit 1
  ;;
esac

# Detect existing files in run dir
HAS_PROMPT=""
if [[ -f "$RUN_DIR/prompt.md" ]]; then
  HAS_PROMPT="(prompt.md exists — will be overwritten)"
fi

# =============================================================================
# Generate prompt
# =============================================================================

cat >"$RUN_DIR/prompt.md" <<PROMPTEOF
You are a dispatch worker (model: $MODEL_NAME — $MODEL_NOTE).

## Task

$TASK

## Step Budget

You have at most **${STEPS} tool calls** to complete this task.
After you use ${STEPS} calls, you MUST stop and write your partial result.
Do not loop or retry indefinitely. If stuck, write what you have.

## Output

Write your output to: \`${RUN_DIR}/output.md\`

After writing the output, report with exactly these lines:
- \`BENCH_SUCCESS: true\` or \`BENCH_SUCCESS: false\`
- \`BENCH_STEPS: <number of calls used>\`
- \`BENCH_TIME_SEC: <approximate wall-clock seconds>\`
- \`BENCH_ERROR: <if failed, brief error description>\`

## Success Criteria

- The output file exists at \`${RUN_DIR}/output.md\`
- The output follows the format specified in the task
- Verification passes (after you finish, the parent will verify)

## Fallback Contract

If you cannot complete the task within the step budget:
1. Write whatever partial output you have to \`${RUN_DIR}/output.md\`
2. Set \`BENCH_SUCCESS: false\`
3. Report \`BENCH_ERROR: <what went wrong>\`
4. The parent orchestrator will pick up where you left off

Do not modify any files outside of \`${RUN_DIR}\`.
PROMPTEOF

echo "WORKER_DISPATCH: ready"
echo "  Task: $TASK"
echo "  Run:  $RUN_DIR"
echo "  Steps: ${STEPS} max"
echo "  Model: $MODEL_NAME"
echo ""
echo "Next: dispatch a @worker with the prompt at:"
echo "  $RUN_DIR/prompt.md"
echo ""
echo "Fallback: if worker fails, handle task directly from main session."
