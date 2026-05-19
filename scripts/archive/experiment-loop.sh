#!/usr/bin/env bash
# =============================================================================
# experiment-loop.sh --- Experiment state manager for skill optimization
#
# Manages state, baselines, and logging for autonomous skill experiments.
# Part of the experiment loop system (pattern from karpathy/autoresearch).
# The loop itself is driven by the agent (human + LLM); this script provides
# the supporting infrastructure.
#
# Usage:
#   bash ./scripts/experiment-loop.sh init --skill <name> [--benchmarks <dir>]
#   bash ./scripts/experiment-loop.sh baseline --skill <name>
#   bash ./scripts/experiment-loop.sh log --skill <name> --status <keep|discard> --description "<text>"
#   bash ./scripts/experiment-loop.sh status [--skill <name>]
#   bash ./scripts/experiment-loop.sh list
# =============================================================================

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXPERIMENTS_DIR="$REPO_ROOT/.runtime/experiments"
TSV_FILE="$REPO_ROOT/experiments.tsv"
BENCH_RUNNER="$REPO_ROOT/scripts/skill-bench.sh"

# ── Helpers ──────────────────────────────────────────────────────────────────

log() { echo "$@" >&2; }

experiment_dir() {
  local skill="$1"
  echo "$EXPERIMENTS_DIR/$skill"
}

# Run a single benchmark and return the result as JSON
# Returns the path to the result.json
run_single_benchmark() {
  local skill="$1" bench_file="$2" run_id="$3"
  local run_dir="$REPO_ROOT/.runtime/bench-runs/$run_id"

  bash "$BENCH_RUNNER" prepare --skill "$skill" --benchmark "$bench_file" --out "$run_dir" > /dev/null 2>&1

  echo "$run_dir"
}

# Aggregate results from multiple benchmark runs
# Computes: success rate, total steps (if available)
aggregate_results() {
  local results_dir="$1" skill="$2" suite_name="$3"
  shift 3
  local result_dirs=("$@")

  local total=0 passed=0 total_steps=0 steps_counted=0

  log "  Aggregating results from ${#result_dirs[@]} benchmark(s)..."

  for rd in "${result_dirs[@]}"; do
    local rf="$rd/result.json"
    if [ -f "$rf" ]; then
      local success steps
      success=$(python3 -c "import json; print(json.load(open('$rf')).get('success', False))" 2>/dev/null || echo "false")
      steps=$(python3 -c "import json; s=json.load(open('$rf')).get('steps'); print(s if s is not None else '')" 2>/dev/null || echo "")

      total=$((total + 1))
      if [ "$success" = "True" ]; then
        passed=$((passed + 1))
      fi
      if [ -n "$steps" ]; then
        total_steps=$((total_steps + steps))
        steps_counted=$((steps_counted + 1))
      fi

      local bench_id
      bench_id=$(python3 -c "import json; print(json.load(open('$rf')).get('benchmark_id','?'))" 2>/dev/null || echo "?")
      log "    $bench_id: success=$success"
    fi
  done

  local success_rate=0
  if [ "$total" -gt 0 ]; then
    success_rate=$(python3 -c "print(round($passed / $total, 4))" 2>/dev/null || echo "0")
  fi

  local avg_steps=null
  if [ "$steps_counted" -gt 0 ]; then
    avg_steps=$(python3 -c "print(round($total_steps / $steps_counted, 1))" 2>/dev/null || echo "null")
  fi

  # Write aggregate result
  local agg_file="$results_dir/aggregate.json"
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  cat > "$agg_file" << AEOF
{
  "skill": "$skill",
  "suite": "$suite_name",
  "timestamp": "$timestamp",
  "total_benchmarks": $total,
  "passed": $passed,
  "success_rate": $success_rate,
  "avg_steps": $avg_steps,
  "git_hash": "$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")"
}
AEOF

  echo "$agg_file"
}

# ── Commands ─────────────────────────────────────────────────────────────────

CMD="${1:-help}"
if [ $# -gt 0 ]; then shift; fi

case "$CMD" in
  list)
    echo "Experiment sessions:"
    echo ""
    if [ -d "$EXPERIMENTS_DIR" ]; then
      FOUND=0
      for d in "$EXPERIMENTS_DIR"/*/; do
        [ -d "$d" ] || continue
        skill="$(basename "$d")"
        state_file="$d/state.json"
        if [ -f "$state_file" ]; then
          suite=$(python3 -c "import json; print(json.load(open('$state_file')).get('benchmarks_dir','?'))" 2>/dev/null || echo "?")
          echo "  $skill"
          echo "    benchmarks: $suite"
          echo "    state:     $(cat "$d/state.json" 2>/dev/null | python3 -c "import json,sys; s=json.load(sys.stdin); print(s.get('status','?'))" 2>/dev/null || echo "?")"
        else
          echo "  $skill (no state)"
        fi
        FOUND=$((FOUND + 1))
      done
      [ "$FOUND" -eq 0 ] && echo "  (no experiments initialized)"
    else
      echo "  (no experiments initialized)"
    fi
    ;;

  init)
    SKILL_NAME=""
    BENCHMARKS_DIR=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --skill) SKILL_NAME="$2"; shift 2 ;;
        --benchmarks) BENCHMARKS_DIR="$2"; shift 2 ;;
        *) log "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [ -z "$SKILL_NAME" ]; then
      log "ERROR: --skill is required"
      log "Usage: bash ./scripts/experiment-loop.sh init --skill <name> [--benchmarks <dir>]"
      exit 1
    fi

    SKILL_FILE="$REPO_ROOT/skills/$SKILL_NAME/SKILL.md"
    if [ ! -f "$SKILL_FILE" ]; then
      log "ERROR: skill not found at $SKILL_FILE"
      exit 1
    fi

    if [ -z "$BENCHMARKS_DIR" ]; then
      BENCHMARKS_DIR="$REPO_ROOT/benchmarks/generic"
    fi

    EXP_DIR="$(experiment_dir "$SKILL_NAME")"
    if [ -d "$EXP_DIR" ]; then
      log "WARN: experiment already exists for '$SKILL_NAME'"
      log "  Delete $EXP_DIR to re-initialize"
      exit 1
    fi

    mkdir -p "$EXP_DIR"

    # Discover applicable benchmarks
    BENCH_LIST=()
    while IFS= read -r -d '' bm; do
      if bash "$BENCH_RUNNER" list --skill "$SKILL_NAME" 2>/dev/null | grep -q "$(basename "$bm")"; then
        BENCH_LIST+=("$bm")
      fi
    done < <(find "$BENCHMARKS_DIR" -name '*.md' -type f -print0)

    # Also include benchmarks that don't declare skills (all generic)
    if [ ${#BENCH_LIST[@]} -eq 0 ]; then
      while IFS= read -r -d '' bm; do
        BENCH_LIST+=("$bm")
      done < <(find "$BENCHMARKS_DIR" -name '*.md' -type f -print0)
    fi

    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    cat > "$EXP_DIR/state.json" << SEOF
{
  "skill": "$SKILL_NAME",
  "benchmarks_dir": "$BENCHMARKS_DIR",
  "status": "initialized",
  "created": "$timestamp",
  "experiments": [],
  "baseline": null
}
SEOF

    # Create benchmarks list
    printf '%s\n' "${BENCH_LIST[@]}" > "$EXP_DIR/benchmarks.txt"

    # Ensure TSV header
    if [ ! -f "$TSV_FILE" ]; then
      echo -e "timestamp\tskill\tgit_hash\tsuccess_rate\tstatus\tdescription" > "$TSV_FILE"
      log "Created $TSV_FILE"
    fi

    log "Initialized experiment session for skill: $SKILL_NAME"
    log "  State:  $EXP_DIR"
    log "  Benchmarks: ${#BENCH_LIST[@]}"
    log ""
    log "Next, establish a baseline:"
    log "  bash ./scripts/experiment-loop.sh baseline --skill $SKILL_NAME"
    ;;

  baseline)
    SKILL_NAME=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --skill) SKILL_NAME="$2"; shift 2 ;;
        *) log "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [ -z "$SKILL_NAME" ]; then
      log "ERROR: --skill is required"
      exit 1
    fi

    EXP_DIR="$(experiment_dir "$SKILL_NAME")"
    if [ ! -f "$EXP_DIR/state.json" ]; then
      log "ERROR: experiment not initialized for '$SKILL_NAME'"
      log "  Run: bash ./scripts/experiment-loop.sh init --skill $SKILL_NAME"
      exit 1
    fi

    BENCHMARKS_FILE="$EXP_DIR/benchmarks.txt"
    if [ ! -f "$BENCHMARKS_FILE" ]; then
      log "ERROR: no benchmarks list at $BENCHMARKS_FILE"
      exit 1
    fi

    # Read benchmarks
    mapfile -t BENCH_FILES < "$BENCHMARKS_FILE"

    log "Establishing baseline for skill: $SKILL_NAME"
    log "  Benchmarks: ${#BENCH_FILES[@]}"
    git_hash=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    log "  Git hash: $git_hash"
    log ""

    # Verify git is clean
    if ! git -C "$REPO_ROOT" diff --quiet 2>/dev/null; then
      log "WARN: git working tree is dirty. Baseline should be from a clean state."
      log "  Stash or commit before proceeding."
    fi

    # Create baseline run directory
    BASELINE_RUN="$EXP_DIR/baseline"
    mkdir -p "$BASELINE_RUN"
    BASELINE_ID="baseline-${SKILL_NAME}-$(date -u +%Y%m%d%H%M%S)"

    # Prepare all benchmarks
    RESULT_DIRS=()
    for bm in "${BENCH_FILES[@]}"; do
      [ -f "$bm" ] || continue
      bench_name="$(basename "$bm" .md)"
      run_id="${BASELINE_ID}-${bench_name}"
      log "  Preparing: $(basename "$bm")..."
      run_dir=$(run_single_benchmark "$SKILL_NAME" "$bm" "$run_id")
      RESULT_DIRS+=("$run_dir")
    done

    log ""
    log "All benchmarks prepared. ${#RESULT_DIRS[@]} run(s) ready."
    log ""
    log "NEXT: For each run directory, spawn a worker agent with the prompt file."
    log "      After workers complete, re-run this command to verify and record."
    log ""

    # Save prepared run info
    printf '%s\n' "${RESULT_DIRS[@]}" > "$EXP_DIR/.baseline-runs.txt"
    log "Run dirs saved to $EXP_DIR/.baseline-runs.txt"
    log ""
    log "To complete the baseline (after running workers):"
    log "  bash ./scripts/experiment-loop.sh collect --skill $SKILL_NAME"
    ;;

  collect)
    SKILL_NAME=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --skill) SKILL_NAME="$2"; shift 2 ;;
        *) log "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [ -z "$SKILL_NAME" ]; then
      log "ERROR: --skill is required"
      log "Usage: bash ./scripts/experiment-loop.sh collect --skill <name>"
      exit 1
    fi

    EXP_DIR="$(experiment_dir "$SKILL_NAME")"
    RUNS_FILE="$EXP_DIR/.baseline-runs.txt"

    if [ ! -f "$RUNS_FILE" ]; then
      log "ERROR: no pending runs found. Run 'baseline --skill $SKILL_NAME' first."
      exit 1
    fi

    mapfile -t RESULT_DIRS < "$RUNS_FILE"

    log "Collecting results for ${#RESULT_DIRS[@]} baseline run(s)..."

    VERIFIED_DIRS=()
    for rd in "${RESULT_DIRS[@]}"; do
      [ -d "$rd" ] || continue
      log "  Verifying: $(basename "$rd")..."
      bash "$BENCH_RUNNER" verify --run "$rd" > /dev/null 2>&1
      VERIFIED_DIRS+=("$rd")
    done

    # Aggregate
    agg_file=$(aggregate_results "$EXP_DIR" "$SKILL_NAME" "baseline" "${VERIFIED_DIRS[@]}")

    # Read aggregate metrics
    success_rate=$(python3 -c "import json; print(json.load(open('$agg_file')).get('success_rate', 0))" 2>/dev/null || echo "0")
    total=$(python3 -c "import json; print(json.load(open('$agg_file')).get('total_benchmarks', 0))" 2>/dev/null || echo "0")

    log ""
    log "Baseline established:"
    log "  Success rate: $success_rate ($(python3 -c "print(round($success_rate * 100))" 2>/dev/null || echo "?")%)"
    log "  Benchmarks:  $total"
    log "  Aggregated:  $agg_file"

    # Update state with baseline
    BASELINE_DATA=$(python3 -c "
import json
with open('$agg_file') as f:
    d = json.load(f)
print(json.dumps(d))
" 2>/dev/null || echo "{}")

    python3 -c "
import json
with open('$EXP_DIR/state.json') as f:
    s = json.load(f)
s['baseline'] = json.loads('''$BASELINE_DATA''')
s['status'] = 'baseline-ready'
with open('$EXP_DIR/state.json', 'w') as f:
    json.dump(s, f, indent=2)
" 2>/dev/null

    # Clean up runs file
    rm -f "$RUNS_FILE"

    log ""
    log "Ready for experiments."
    log "  Next: propose a change to '$SKILL_NAME', apply it, run benchmarks, then log."
    log "  bash ./scripts/skill-bench.sh prepare --skill $SKILL_NAME --benchmark <path>"
    log "  bash ./scripts/skill-bench.sh verify --run <dir>"
    log "  bash ./scripts/experiment-loop.sh log --skill $SKILL_NAME --status keep --description \"...\""
    ;;

  log)
    SKILL_NAME=""
    STATUS=""
    DESCRIPTION=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --skill) SKILL_NAME="$2"; shift 2 ;;
        --status) STATUS="$2"; shift 2 ;;
        --description) DESCRIPTION="$2"; shift 2 ;;
        *) log "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [ -z "$SKILL_NAME" ] || [ -z "$STATUS" ] || [ -z "$DESCRIPTION" ]; then
      log "ERROR: --skill, --status, and --description are required"
      exit 1
    fi

    if [ "$STATUS" != "keep" ] && [ "$STATUS" != "discard" ]; then
      log "ERROR: --status must be 'keep' or 'discard'"
      exit 1
    fi

    EXP_DIR="$(experiment_dir "$SKILL_NAME")"
    if [ ! -f "$EXP_DIR/state.json" ]; then
      log "ERROR: experiment not initialized for '$SKILL_NAME'"
      exit 1
    fi

    # Get git hash
    git_hash=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")

    # Get latest aggregate if available
    success_rate=""
    latest_agg=$(ls -t "$EXP_DIR"/aggregate.json 2>/dev/null | head -1)
    if [ -n "$latest_agg" ]; then
      success_rate=$(python3 -c "import json; print(json.load(open('$latest_agg')).get('success_rate', ''))" 2>/dev/null || echo "")
    fi

    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Append to TSV
    echo -e "${timestamp}\t${SKILL_NAME}\t${git_hash}\t${success_rate:-?}\t${STATUS}\t${DESCRIPTION}" >> "$TSV_FILE"

    log "Logged experiment:"
    log "  Skill:       $SKILL_NAME"
    log "  Status:      $STATUS"
    log "  Success rate: ${success_rate:-?}"
    log "  Description: $DESCRIPTION"
    log "  TSV:         $TSV_FILE"

    # Update state
    python3 -c "
import json
with open('$EXP_DIR/state.json') as f:
    s = json.load(f)
s['experiments'].append({
    'timestamp': '$timestamp',
    'git_hash': '$git_hash',
    'status': '$STATUS',
    'success_rate': '${success_rate:-}',
    'description': '$(echo "$DESCRIPTION" | sed "s/'/'\\\\''/g")'
})
s['status'] = 'active'
with open('$EXP_DIR/state.json', 'w') as f:
    json.dump(s, f, indent=2)
" 2>/dev/null

    if [ "$STATUS" = "keep" ]; then
      log ""
      log "  Change KEPT. The branch has advanced. Propose the next experiment."
    else
      log ""
      log "  Change DISCARDED. Git has been reset. Propose a different approach."
    fi
    ;;

  status)
    SKILL_NAME=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --skill) SKILL_NAME="$2"; shift 2 ;;
        *) log "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [ -z "$SKILL_NAME" ]; then
      # Show all
      bash "$0" list
      exit 0
    fi

    EXP_DIR="$(experiment_dir "$SKILL_NAME")"
    if [ ! -f "$EXP_DIR/state.json" ]; then
      log "Experiment not initialized for: $SKILL_NAME"
      log "  Run: bash ./scripts/experiment-loop.sh init --skill $SKILL_NAME"
      exit 1
    fi

    python3 -c "
import json
with open('$EXP_DIR/state.json') as f:
    s = json.load(f)

print(f'Skill:       {s.get(\"skill\", \"?\")}')
print(f'Status:      {s.get(\"status\", \"?\")}')
print(f'Benchmarks:  {s.get(\"benchmarks_dir\", \"?\")}')

bl = s.get('baseline')
if bl:
    print(f'Baseline:    success_rate={bl.get(\"success_rate\", \"?\")}  ({bl.get(\"total_benchmarks\", 0)} benchmarks)')
    print(f'             git_hash={bl.get(\"git_hash\", \"?\")}')
else:
    print(f'Baseline:    not established')

exps = s.get('experiments', [])
print(f'Experiments: {len(exps)}')
for i, exp in enumerate(exps[-5:], 1):
    print(f'  {i}. [{exp.get(\"status\", \"?\")}] {exp.get(\"description\", \"?\")}  (rate: {exp.get(\"success_rate\", \"?\")})')
" 2>/dev/null

    # Show recent TSV entries
    if [ -f "$TSV_FILE" ]; then
      echo ""
      echo "Recent experiments.tsv entries:"
      grep "$SKILL_NAME" "$TSV_FILE" 2>/dev/null | tail -5 | while IFS= read -r line; do
        echo "  $line" | awk -F'\t' '{printf "  [%s] %s | rate=%s | %s\n", $5, $2, $4, $6}'
      done
    fi
    ;;

  help|--help|-h|*)
    echo "Experiment State Manager"
    echo ""
    echo "Usage:"
    echo "  init     --skill <name> [--benchmarks <dir>]"
    echo "           Initialize an experiment session for a skill."
    echo ""
    echo "  baseline --skill <name>"
    echo "           Establish a baseline by running all registered benchmarks."
    echo ""
    echo "  collect  --skill <name>"
    echo "           Collect and verify baseline/experiment results."
    echo ""
    echo "  log      --skill <name> --status <keep|discard> --description \"<text>\""
    echo "           Log an experiment result to experiments.tsv."
    echo ""
    echo "  status   [--skill <name>]"
    echo "           Show experiment state. Omitting --skill lists all."
    echo ""
    echo "  list"
    echo "           List all active experiment sessions."
    echo ""
    echo "Lifecycle:"
    echo "  1. init       -> creates experiment state"
    echo "  2. baseline   -> establishes baseline metrics"
    echo "  3. propose    -> (you) generate a change proposal"
    echo "  4. apply      -> (you) modify the skill"
    echo "  5. benchmark  -> skill-bench.sh prepare + verify"
    echo "  6. log        -> record result (keep/discard)"
    echo "  7. repeat 3-6"
    echo ""
    echo "Examples:"
    echo "  bash ./scripts/experiment-loop.sh init --skill bash-explore"
    echo "  bash ./scripts/experiment-loop.sh baseline --skill bash-explore"
    echo "  bash ./scripts/experiment-loop.sh log --skill bash-explore --status keep --description \"added depth param\""
    ;;
esac
