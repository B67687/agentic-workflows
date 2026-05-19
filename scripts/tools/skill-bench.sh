#!/usr/bin/env bash
# =============================================================================
# skill-bench.sh --- Benchmark runner for agent skills
#
# Prepares and verifies benchmark runs for skill optimization experiments.
# Inspired by karpathy/autoresearch: fixed-budget experiments with a single
# metric, keep/discard loop, and untracked result logging.
#
# Usage:
#   bash ./scripts/skill-bench.sh list [--skill <name>]
#   bash ./scripts/skill-bench.sh prepare --skill <name> --benchmark <path> [--out <dir>]
#   bash ./scripts/skill-bench.sh verify --run <dir>
#
# Lifecycle:
#   1. list       --- see which benchmarks apply to a skill
#   2. prepare    --- creates a run directory with worker prompt + verify script
#   3. [agent executes the task using the skill, writes output to run dir]
#   4. verify     --- runs verification checks, writes result.json
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BENCHMARKS_DIR="$REPO_ROOT/benchmarks"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"
SKILLS_DIR="$REPO_ROOT/skills"

# ── Helpers ──────────────────────────────────────────────────────────────────

# Print a message to stderr (for status output that won't interfere with stdout)
log() { echo "$@" >&2; }

# Parse YAML frontmatter from a markdown file and extract a field value
# Usage: parse_frontmatter <file> <field>
# Returns the field value with surrounding whitespace trimmed
parse_frontmatter() {
  local file="$1" field="$2"
  python3 -c "
import yaml, sys
with open('$file') as f:
    content = f.read()
parts = content.split('---', 2)
if len(parts) >= 3:
    meta = yaml.safe_load(parts[1])
    val = meta.get('$field', '')
    if isinstance(val, list):
        print('\n'.join(str(v) for v in val))
    else:
        print(val)
" 2>/dev/null || echo ""
}

# Generate a unique run ID
gen_run_id() {
  local skill="$1" benchmark="$2"
  local bench_name
  bench_name="$(basename "$benchmark" .md)"
  echo "${skill}-${bench_name}-$(date -u +%Y%m%d%H%M%S)"
}

# ── Commands ─────────────────────────────────────────────────────────────────

CMD="${1:-help}"
if [ $# -gt 0 ]; then shift; fi

case "$CMD" in
list)
  SKILL_FILTER=""
  if [ "${1:-}" = "--skill" ] && [ -n "${2:-}" ]; then
    SKILL_FILTER="$2"
  fi

  echo "Available benchmarks:"
  echo ""

  FOUND=0
  while IFS= read -r -d '' bm; do
    rel="${bm#$BENCHMARKS_DIR/}"
    name="$(parse_frontmatter "$bm" "name")"
    btype="$(parse_frontmatter "$bm" "type")"
    diff="$(parse_frontmatter "$bm" "difficulty")"
    time="$(parse_frontmatter "$bm" "estimated_time")"
    skills_line="$(parse_frontmatter "$bm" "skills")"

    if [ -n "$SKILL_FILTER" ]; then
      # Only show benchmarks that list this skill
      echo "$skills_line" | grep -qx "$SKILL_FILTER" || continue
    fi

    echo "  $rel"
    [ -n "$name" ] && echo "    name:        $name"
    [ -n "$btype" ] && echo "    type:        $btype"
    [ -n "$diff" ] && echo "    difficulty:  $diff"
    [ -n "$time" ] && echo "    estimated:   $time"
    if [ -n "$skills_line" ]; then
      echo "    skills:      $(echo "$skills_line" | tr '\n' ' ')"
    fi
    echo ""
    FOUND=$((FOUND + 1))
  done < <(find "$BENCHMARKS_DIR" -name '*.md' -type f -print0)

  if [ "$FOUND" -eq 0 ]; then
    if [ -n "$SKILL_FILTER" ]; then
      echo "  (no benchmarks found for skill: $SKILL_FILTER)"
    else
      echo "  (no benchmarks found)"
    fi
  fi

  echo "Total: $FOUND benchmark(s)"
  ;;

prepare)
  SKILL_NAME=""
  BENCHMARK_FILE=""
  RUN_DIR=""

  # Parse flags
  while [ $# -gt 0 ]; do
    case "$1" in
    --skill)
      SKILL_NAME="$2"
      shift 2
      ;;
    --benchmark)
      BENCHMARK_FILE="$2"
      shift 2
      ;;
    --out)
      RUN_DIR="$2"
      shift 2
      ;;
    *)
      log "Unknown option: $1"
      exit 1
      ;;
    esac
  done

  # Validate
  if [ -z "$BENCHMARK_FILE" ]; then
    log "ERROR: --benchmark is required"
    exit 1
  fi

  if [ -n "$SKILL_NAME" ]; then
    SKILL_FILE="$SKILLS_DIR/$SKILL_NAME/SKILL.md"
    if [ ! -f "$SKILL_FILE" ]; then
      log "ERROR: skill not found at $SKILL_FILE"
      exit 1
    fi
  fi

  if [ ! -f "$BENCHMARK_FILE" ]; then
    log "ERROR: benchmark not found at $BENCHMARK_FILE"
    exit 1
  fi

  if [ -z "$RUN_DIR" ]; then
    if [ -n "$SKILL_NAME" ]; then
      RUN_ID="$(gen_run_id "$SKILL_NAME" "$BENCHMARK_FILE")"
    else
      BENCH_NAME="$(basename "$BENCHMARK_FILE" .md)"
      RUN_ID="standalone-${BENCH_NAME}-$(date -u +%Y%m%d%H%M%S)"
    fi
    RUN_DIR="$RUNS_DIR/$RUN_ID"
  fi

  mkdir -p "$RUN_DIR"

  # Read benchmark content (strip frontmatter)
  BENCHMARK_BODY="$(python3 -c "
with open('$BENCHMARK_FILE') as f:
    content = f.read()
parts = content.split('---', 2)
if len(parts) >= 3:
    print(parts[2].strip())
else:
    print(content.strip())
")"

  # Read skill content (or use default)
  if [ -n "$SKILL_NAME" ]; then
    SKILL_CONTENT="$(cat "$SKILL_FILE")"
  else
    SKILL_CONTENT="You are running a standalone benchmark. Read the task below carefully, follow the specified output format, and write your solution to the output file. No specialized skill guidance is needed -- use general best practices."
  fi

  # Extract verification script from benchmark frontmatter
  VERIFY_SCRIPT="$(parse_frontmatter "$BENCHMARK_FILE" "verification")"

  # Get benchmark name
  BENCH_NAME="$(parse_frontmatter "$BENCHMARK_FILE" "name")"
  BENCH_ID="$(parse_frontmatter "$BENCHMARK_FILE" "id")"

  # Write metadata
  cat >"$RUN_DIR/meta.json" <<MEOF
{
  "run_id": "$(basename "$RUN_DIR")",
  "skill": "${SKILL_NAME:-standalone}",
  "benchmark_id": "$BENCH_ID",
  "benchmark_name": "$BENCH_NAME",
  "benchmark_file": "$BENCHMARK_FILE",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "prepared"
}
MEOF

  # Write verification script (bakes RUN_DIR so it can check the agent's output)
  if [ -n "$VERIFY_SCRIPT" ]; then
    cat >"$RUN_DIR/verify.sh" <<VEOF
#!/usr/bin/env bash
# Auto-generated verification script for benchmark: $BENCH_ID
# Checks the agent's output in RUN_DIR against expected criteria.
set -euo pipefail
RUN_DIR="$RUN_DIR"
cd "$REPO_ROOT" || { echo "ERROR: cannot cd to $REPO_ROOT"; exit 1; }
$VERIFY_SCRIPT
VEOF
    chmod +x "$RUN_DIR/verify.sh"
  fi

  # Write the worker prompt
  cat >"$RUN_DIR/prompt.md" <<PROMPT
You are running a benchmark${SKILL_NAME:+ for the **${SKILL_NAME}** skill}.

## ${SKILL_NAME:+Skill }Instructions

\`\`\`
${SKILL_CONTENT}
\`\`\`

## Task

${BENCHMARK_BODY}

## Instructions

1. Follow the skill instructions to complete the task.
2. Write your output to the file: \`${RUN_DIR}/output.md\`.
3. After finishing, report:
   - \`BENCH_SUCCESS: true\` or \`BENCH_SUCCESS: false\`
   - \`BENCH_STEPS: <number of steps taken>\`
   - \`BENCH_TIME_SEC: <approximate wall-clock seconds>\`

Do not modify any files outside of \`${RUN_DIR}\`. Focus on completing the task correctly.
PROMPT

  echo "$(basename "$RUN_DIR")"
  log "Prepared benchmark run:"
  if [ -n "$SKILL_NAME" ]; then
    log "  Skill:     $SKILL_NAME"
  else
    log "  Skill:     (standalone -- no skill required)"
  fi
  log "  Benchmark: $BENCH_NAME ($BENCH_ID)"
  log "  Run dir:   $RUN_DIR"
  log "  Prompt:    $RUN_DIR/prompt.md"
  log ""
  log "Next: spawn a worker with the prompt, then run:"
  log "  bash ./scripts/skill-bench.sh verify --run $RUN_DIR"
  ;;

verify)
  TARGET_RUN=""

  while [ $# -gt 0 ]; do
    case "$1" in
    --run)
      TARGET_RUN="$2"
      shift 2
      ;;
    *)
      log "Unknown option: $1"
      exit 1
      ;;
    esac
  done

  if [ -z "$TARGET_RUN" ]; then
    log "ERROR: --run is required"
    exit 1
  fi

  if [ ! -d "$TARGET_RUN" ]; then
    log "ERROR: run directory not found: $TARGET_RUN"
    exit 1
  fi

  META_FILE="$TARGET_RUN/meta.json"
  OUTPUT_FILE="$TARGET_RUN/output.md"
  VERIFY_FILE="$TARGET_RUN/verify.sh"

  if [ ! -f "$META_FILE" ]; then
    log "ERROR: meta.json not found in $TARGET_RUN (was prepare run?)"
    exit 1
  fi

  log "Verifying benchmark run: $(basename "$TARGET_RUN")"

  # Check if output exists
  SUCCESS=false
  if [ ! -f "$OUTPUT_FILE" ]; then
    log "  WARN: output.md not found --- task may not have completed"
    OUTPUT_EXISTS=false
  else
    OUTPUT_EXISTS=true
    OUTPUT_SIZE=$(wc -c <"$OUTPUT_FILE" | tr -d ' ')
    log "  Output: $OUTPUT_FILE ($OUTPUT_SIZE bytes)"
  fi

  # Run verification checks
  VERIFY_PASSED=false
  VERIFY_OUTPUT=""
  if [ -f "$VERIFY_FILE" ]; then
    log "  Running verification..."
    if VERIFY_OUTPUT=$(bash "$VERIFY_FILE" 2>&1); then
      VERIFY_PASSED=true
      log "  Verification: PASS"
    else
      VERIFY_PASSED=false
      log "  Verification: FAIL"
    fi
  else
    log "  WARN: no verify.sh in run directory --- using output existence as signal"
    VERIFY_PASSED="$OUTPUT_EXISTS"
  fi

  # Extract benchmark metrics from output (if it has BENCH_ markers)
  BENCH_STEPS=""
  BENCH_TIME=""
  if [ "$OUTPUT_EXISTS" = true ]; then
    BENCH_STEPS=$(grep -E "^BENCH_STEPS:" "$OUTPUT_FILE" 2>/dev/null | head -1 | sed 's/^BENCH_STEPS:[[:space:]]*//' || echo "")
    BENCH_TIME=$(grep -E "^BENCH_TIME_SEC:" "$OUTPUT_FILE" 2>/dev/null | head -1 | sed 's/^BENCH_TIME_SEC:[[:space:]]*//' || echo "")
  fi

  # Compute result
  RESULT_SUCCESS=false
  if [ "$VERIFY_PASSED" = true ]; then
    RESULT_SUCCESS=true
  fi

  # Read run metadata
  SKILL_NAME="$(python3 -c "import json; print(json.load(open('$META_FILE')).get('skill',''))" 2>/dev/null || echo "")"
  BENCH_ID="$(python3 -c "import json; print(json.load(open('$META_FILE')).get('benchmark_id',''))" 2>/dev/null || echo "")"

  # Write result (sanitize verify_output to avoid breaking JSON with newlines)
  RESULT_FILE="$TARGET_RUN/result.json"
  SAFE_VERIFY_OUTPUT="${VERIFY_OUTPUT//$'\n'/ }"      # newlines -> spaces
  SAFE_VERIFY_OUTPUT="${SAFE_VERIFY_OUTPUT//\"/\\\"}" # double quotes -> escaped
  cat >"$RESULT_FILE" <<REOF
{
  "run_id": "$(basename "$TARGET_RUN")",
  "skill": "$SKILL_NAME",
  "benchmark_id": "$BENCH_ID",
  "success": $RESULT_SUCCESS,
  "steps": ${BENCH_STEPS:-null},
  "time_seconds": ${BENCH_TIME:-null},
  "output_exists": $OUTPUT_EXISTS,
  "verify_output": "${SAFE_VERIFY_OUTPUT:-}",
  "verified_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "verified"
}
REOF

  # Summary line on stdout (for piping/aggregation)
  echo "RESULT: $SKILL_NAME / $BENCH_ID = success=$RESULT_SUCCESS steps=${BENCH_STEPS:-?} time=${BENCH_TIME:-?}"

  log "  Result: success=$RESULT_SUCCESS"
  log "  Result file: $RESULT_FILE"
  ;;

eval-report | report)
  # Generate a standardized evaluation report comparing multiple runs.
  # Format: promptfoo-compatible JSON for cross-run comparison.
  # Source pattern: https://github.com/promptfoo/promptfoo (evaluation format)
  MODE="${1:-list}"
  REPORT_DIR="$RUNS_DIR"

  case "$MODE" in
  list)
    # List available benchmark runs
    echo "=== Benchmark Runs ==="
    echo ""
    if [ ! -d "$REPORT_DIR" ]; then
      echo "  No runs found."
      exit 0
    fi
    for dir in "$REPORT_DIR"/*/; do
      [ -d "$dir" ] || continue
      RESULT_FILE="$dir/result.json"
      if [ -f "$RESULT_FILE" ]; then
        python3 -c "
import json
with open('$RESULT_FILE') as f:
    r = json.load(f)
print(f'  {r.get(\"run_id\", \"?\")}')
print(f'    skill:  {r.get(\"skill\", \"?\")}')
print(f'    bench:  {r.get(\"benchmark_id\", \"?\")}')
print(f'    result: {\"PASS\" if r.get(\"success\") else \"FAIL\"} steps={r.get(\"steps\", \"?\")} time={r.get(\"time_seconds\", \"?\")}s')
print()
" 2>/dev/null || echo "  $(basename "$dir"): no result"
      fi
    done
    ;;

  compare)
    # Compare two or more runs, sorted by score
    shift
    if [ $# -eq 0 ]; then
      echo "Usage: skill-bench.sh eval-report compare <run-id-1> [run-id-2 ...]"
      exit 1
    fi
    echo "=== Comparison Report ==="
    echo ""
    python3 -c "
import json, glob, os, sys

report_dir = '$REPORT_DIR'
run_ids = sys.argv[1:]

entries = []
for rid in run_ids:
    f = os.path.join(report_dir, rid, 'result.json')
    if os.path.exists(f):
        with open(f) as fp:
            entries.append(json.load(fp))
    else:
        for gf in glob.glob(os.path.join(report_dir, rid, 'result.json')):
            with open(gf) as fp:
                entries.append(json.load(fp))

if not entries:
    print('  No matching runs found.')
else:
    entries.sort(key=lambda x: (not x.get('success', False), x.get('time_seconds', 9999)))
    print(f'  Runs: {len(entries)}')
    print(f'  Pass: {sum(1 for e in entries if e.get(\"success\"))}')
    print(f'  Fail: {sum(1 for e in entries if not e.get(\"success\"))}')
    print()
    for i, e in enumerate(entries):
        status = 'PASS' if e.get('success') else 'FAIL'
        print(f'  [{i+1}] {e.get(\"run_id\", \"?\")}')
        print(f'       skill={e.get(\"skill\", \"?\")} bench={e.get(\"benchmark_id\", \"?\")}')
        print(f'       result={status} steps={e.get(\"steps\", \"?\")} time={e.get(\"time_seconds\", \"?\")}s')
        print()
" "$@" 2>/dev/null
    ;;

  export)
    # Export all results as promptfoo-compatible JSON
    echo "["
    FIRST=true
    for dir in "$REPORT_DIR"/*/; do
      [ -d "$dir" ] || continue
      RESULT_FILE="$dir/result.json"
      if [ -f "$RESULT_FILE" ]; then
        $FIRST || echo ","
        FIRST=false
        python3 -c "
import json
with open('$RESULT_FILE') as f:
    r = json.load(f)
pf = {
    'prompt': {'raw': 'see run ' + r.get('run_id', '')},
    'response': {'raw': 'verified=' + str(r.get('success', False))},
    'success': r.get('success', False),
    'score': 1.0 if r.get('success', False) else 0.0,
    'latency_ms': (r.get('time_seconds') or 0) * 1000,
    'testCase': {
        'description': r.get('benchmark_id', '') + ' / ' + r.get('skill', ''),
        'assert': []
    }
}
print(json.dumps(pf, indent=2))
" 2>/dev/null
      fi
    done
    echo "]"
    ;;

  *)
    echo "Usage:"
    echo "  eval-report list                        List all benchmark runs"
    echo "  eval-report compare <id> [id...]       Compare runs side by side"
    echo "  eval-report export                     Export as promptfoo JSON"
    echo ""
    echo "Source: promptfoo evaluation format"
    echo "(https://github.com/promptfoo/promptfoo)"
    ;;
  esac
  ;;

score)
  # Delegate to the benchmark aggregator for score summaries
  AGGREGATOR="$REPO_ROOT/scripts/bench/aggregate.sh"
  if [ -f "$AGGREGATOR" ]; then
    MODE="${1:-summary}"
    bash "$AGGREGATOR" "$MODE"
  else
    log "ERROR: aggregator not found at $AGGREGATOR"
    log "Run: bash ./scripts/bench/aggregate.sh"
    exit 1
  fi
  ;;

help | --help | -h | *)
  echo "Skill Benchmark Runner"
  echo ""
  echo "Usage:"
  echo "  bash ./scripts/skill-bench.sh list [--skill <name>]"
  echo "    List available benchmarks, optionally filtered by skill."
  echo ""
  echo "  bash ./scripts/skill-bench.sh prepare [--skill <name>] --benchmark <path> [--out <dir>]"
  echo "    Prepare a benchmark run. Creates prompt.md + verify.sh in the run dir."
  echo "    --skill is optional. When omitted, a standalone benchmark with default instructions is created."
  echo "    Outputs the run ID on stdout."
  echo ""
  echo "  bash ./scripts/skill-bench.sh verify --run <dir>"
  echo "    Verify a completed benchmark run. Runs verification checks, writes result.json."
  echo ""
  echo "  bash ./scripts/skill-bench.sh eval-report list"
  echo "    List all benchmark runs with results."
  echo ""
  echo "  bash ./scripts/skill-bench.sh eval-report compare <id> [id...]"
  echo "    Compare runs side by side, sorted by score."
  echo ""
  echo "  bash ./scripts/skill-bench.sh eval-report export"
  echo "    Export all results as promptfoo-compatible JSON."
  echo ""
  echo "  bash ./scripts/skill-bench.sh score [summary|by-benchmark|by-category|by-skill|detail|export]"
  echo "    Aggregate score summary and breakdowns (delegates to scripts/bench/aggregate.sh)."
  echo ""
  echo "Lifecycle:"
  echo "  1. list     -> pick a benchmark for your skill"
  echo "  2. prepare  -> creates run directory with worker prompt"
  echo "  3. [spawn a worker agent with the prompt, let it execute]"
  echo "  4. verify   -> runs checks, produces result.json"
  echo ""
  echo "Examples:"
  echo "  bash ./scripts/skill-bench.sh list --skill bash-explore"
  echo "  bash ./scripts/skill-bench.sh prepare --skill bash-explore --benchmark benchmarks/generic/search-todo.md"
  echo "  bash ./scripts/skill-bench.sh verify --run .runtime/bench-runs/bash-explore-search-todo-20260513-120000"
  echo "  bash ./scripts/skill-bench.sh score summary"
  ;;
esac
