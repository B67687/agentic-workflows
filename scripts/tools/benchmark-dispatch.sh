#!/usr/bin/env bash
# =============================================================================
# benchmark-dispatch.sh --- Batch benchmark dispatch orchestrator
#
# Prepares, dispatches, and verifies benchmark runs in batches.
# Designed to work with the worker-dispatch.sh step-budget system.
#
# Usage:
#   bash scripts/tools/benchmark-dispatch.sh list [--category <cat>]
#   bash scripts/tools/benchmark-dispatch.sh prepare --category <cat> --passes <N>
#   bash scripts/tools/benchmark-dispatch.sh prepare --benchmark <file> --passes <N>
#   bash scripts/tools/benchmark-dispatch.sh prepare --bigcodebench --subset <N> --passes <N>
#   bash scripts/tools/benchmark-dispatch.sh manifest [--status <filter>]
#   bash scripts/tools/benchmark-dispatch.sh verify --all
#   bash scripts/tools/benchmark-dispatch.sh verify --run <dir>
#   bash scripts/tools/benchmark-dispatch.sh verify --manifest
#
# Lifecycle:
#   1. prepare   → creates run dirs with step-budgeted prompts + verify scripts
#   2. [agent dispatches workers to fill each run dir's output.md]
#   3. verify    → batch-checks all completed runs, writes result.json
#   4. aggregate → delegate to scripts/bench/aggregate.sh for score summary
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
BENCHMARKS_DIR="$REPO_ROOT/benchmarks"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"
MANIFEST_FILE="$REPO_ROOT/.runtime/dispatch-manifest.json"
SKILL_BENCH="$SCRIPTS_DIR/tools/skill-bench.sh"
WORKER_DISPATCH="$SCRIPTS_DIR/tools/worker-dispatch.sh"

# ── Helpers ──────────────────────────────────────────────────────────────────

log() { echo "$@" >&2; }

# Parse YAML frontmatter from a markdown file and extract a field value
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

# Write dispatch manifest
write_manifest() {
  local category="$1" passes="$2"
  shift 2
  local runs_json="["
  local first=true
  for run_id in "$@"; do
    local run_dir="$RUNS_DIR/$run_id"
    local meta_file="$run_dir/meta.json"
    local bench_id=""
    local bench_name=""
    local bench_file=""
    if [ -f "$meta_file" ]; then
      bench_id=$(python3 -c "import json; print(json.load(open('$meta_file')).get('benchmark_id',''))" 2>/dev/null || echo "")
      bench_name=$(python3 -c "import json; print(json.load(open('$meta_file')).get('benchmark_name',''))" 2>/dev/null || echo "")
      bench_file=$(python3 -c "import json; print(json.load(open('$meta_file')).get('benchmark_file',''))" 2>/dev/null || echo "")
    fi
    # Determine status
    local status="prepared"
    if [ -f "$run_dir/output.md" ]; then
      if [ -f "$run_dir/result.json" ]; then
        status="verified"
      else
        status="completed"
      fi
    fi
    $first || runs_json+=","
    first=false
    runs_json+="{\"run_id\":\"$run_id\",\"benchmark_id\":\"$bench_id\",\"benchmark_name\":\"$bench_name\",\"benchmark_file\":\"$bench_file\",\"run_dir\":\"$run_dir\",\"status\":\"$status\"}"
  done
  runs_json+="]"

  cat >"$MANIFEST_FILE" <<MANIFEST
{
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "category": "$category",
  "passes": $passes,
  "total_runs": $#,
  "runs": $runs_json
}
MANIFEST
}

# Read a field from the manifest
read_manifest_field() {
  local field="$1"
  python3 -c "
import json, sys
try:
    with open('$MANIFEST_FILE') as f:
        m = json.load(f)
    print(m.get('$field', ''))
except: sys.exit(1)
" 2>/dev/null || true
}

# ── Usage ─────────────────────────────────────────────────────────────────────

usage() {
  cat <<'USAGE'
Usage: bash scripts/tools/benchmark-dispatch.sh <command> [options]

Commands:
  list [--category <cat>]                List available benchmarks, optionally by category
  prepare --category <cat> --passes <N>  Prepare runs for all benchmarks in category
  prepare --benchmark <file> --passes <N> Prepare runs for a single benchmark
  prepare --bigcodebench --subset <N> --passes <N>  Prepare BigCodeBench runs
  prepare --help                         Show prepare-specific options
  manifest [--status <filter>]           Show dispatch manifest (prepared|completed|verified|all)
  verify --all                           Verify all prepared runs with output.md
  verify --run <dir>                     Verify a single run directory
  verify --manifest                      Verify all runs in the dispatch manifest

Options for prepare:
  --category <name>   Benchmark category (harness, generic, public)
  --benchmark <file>  Single benchmark file (overrides --category)
  --bigcodebench      Use BigCodeBench dataset
  --subset <N>        For BigCodeBench: subset size (default: all)
  --passes <N>        Number of passes per benchmark (default: 3)
  --steps <N>         Max tool calls per worker (default: 8)
  --model <name>      Worker model: minimax|flash|pro (default: flash)
  --out <dir>         Output directory (default: .runtime/bench-runs/)
  --dry-run           Show what would be done without creating anything

Examples:
  bash scripts/tools/benchmark-dispatch.sh list --category generic
  bash scripts/tools/benchmark-dispatch.sh prepare --category generic --passes 3
  bash scripts/tools/benchmark-dispatch.sh prepare --benchmark benchmarks/generic/count-files.md --passes 3
  bash scripts/tools/benchmark-dispatch.sh manifest
  bash scripts/tools/benchmark-dispatch.sh verify --all
  bash scripts/tools/benchmark-dispatch.sh verify --manifest
USAGE
}

# ── List benchmarks ───────────────────────────────────────────────────────────

cmd_list() {
  local category_filter=""
  while [ $# -gt 0 ]; do
    case "$1" in
    --category)
      category_filter="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      log "Unknown: $1"
      usage
      exit 1
      ;;
    esac
  done

  echo "Available benchmarks:"
  echo ""

  local found=0
  while IFS= read -r -d '' bm; do
    local rel="${bm#$BENCHMARKS_DIR/}"
    local name=$(parse_frontmatter "$bm" "name")
    local btype=$(parse_frontmatter "$bm" "type")
    local diff=$(parse_frontmatter "$bm" "difficulty")
    local time=$(parse_frontmatter "$bm" "estimated_time")

    if [ -n "$category_filter" ]; then
      # Match by directory (benchmarks/<category>/...) or by type field
      local bm_cat=$(echo "$rel" | cut -d/ -f1)
      if [ "$bm_cat" != "$category_filter" ] && [ "$btype" != "$category_filter" ]; then
        continue
      fi
    fi

    echo "  $rel"
    [ -n "$name" ] && echo "    name:        $name"
    [ -n "$btype" ] && echo "    type:        $btype"
    [ -n "$diff" ] && echo "    difficulty:  $diff"
    [ -n "$time" ] && echo "    estimated:   $time"
    echo ""
    found=$((found + 1))
  done < <(find "$BENCHMARKS_DIR" -name '*.md' -type f -print0 2>/dev/null)

  if [ "$found" -eq 0 ]; then
    if [ -n "$category_filter" ]; then
      echo "  (no benchmarks found for category: $category_filter)"
    else
      echo "  (no benchmarks found)"
    fi
  fi
  echo "Total: $found benchmark(s)"
}

# ── Prepare runs ──────────────────────────────────────────────────────────────

cmd_prepare() {
  local category=""
  local benchmark_file=""
  local bigcodebench=false
  local subset=""
  local passes=3
  local steps=8
  local model="flash"
  local custom_out=""
  local dry_run=false

  while [ $# -gt 0 ]; do
    case "$1" in
    --category)
      category="$2"
      shift 2
      ;;
    --benchmark)
      benchmark_file="$2"
      shift 2
      ;;
    --bigcodebench)
      bigcodebench=true
      shift
      ;;
    --subset)
      subset="$2"
      shift 2
      ;;
    --passes)
      passes="$2"
      shift 2
      ;;
    --steps)
      steps="$2"
      shift 2
      ;;
    --model)
      model="$2"
      shift 2
      ;;
    --out)
      custom_out="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      log "Unknown: $1"
      usage
      exit 1
      ;;
    esac
  done

  # ── Validate ──
  if [ "$bigcodebench" = true ]; then
    if [ -z "$subset" ]; then
      log "[dispatch] Preparing all BigCodeBench problems..."
    else
      log "[dispatch] Preparing $subset BigCodeBench problems..."
    fi
    # BigCodeBench uses its own runner
    log "[dispatch] BigCodeBench dispatch is handled by scripts/bench/public/run-bigcodebench.sh"
    log "[dispatch] Run that separately, then use 'verify --all' here."
    log ""
    log "  bash scripts/bench/public/run-bigcodebench.sh${subset:+ --subset $subset}"
    exit 0
  fi

  # Collect benchmark files
  local bench_files=()
  if [ -n "$benchmark_file" ]; then
    if [ ! -f "$benchmark_file" ]; then
      log "ERROR: benchmark not found: $benchmark_file"
      exit 1
    fi
    bench_files+=("$benchmark_file")
  elif [ -n "$category" ]; then
    local cat_dir="$BENCHMARKS_DIR/$category"
    if [ ! -d "$cat_dir" ]; then
      log "ERROR: category directory not found: $cat_dir"
      log "  Available categories:"
      for d in "$BENCHMARKS_DIR"/*/; do
        log "    - $(basename "$d")"
      done
      exit 1
    fi
    while IFS= read -r -d '' f; do
      bench_files+=("$f")
    done < <(find "$cat_dir" -name '*.md' -type f -print0 2>/dev/null)
  else
    log "ERROR: specify --category, --benchmark, or --bigcodebench"
    usage
    exit 1
  fi

  if [ ${#bench_files[@]} -eq 0 ]; then
    log "ERROR: no benchmark files found"
    exit 1
  fi

  log "[dispatch] Preparing ${#bench_files[@]} benchmark(s) × $passes pass(es) = $((${#bench_files[@]} * passes)) runs"
  log "[dispatch] Step budget: $steps calls per worker | Model: $model"
  log ""

  # Validate passes
  if ! [[ "$passes" =~ ^[0-9]+$ ]] || [ "$passes" -lt 1 ]; then
    log "ERROR: --passes must be a positive integer, got: $passes"
    exit 1
  fi

  # ── Prepare each benchmark × pass ──
  local all_run_ids=()
  local total=$((${#bench_files[@]} * passes))
  local current=0
  local has_errors=false

  for bm in "${bench_files[@]}"; do
    local bm_name=$(parse_frontmatter "$bm" "name")
    local bm_id=$(parse_frontmatter "$bm" "id")
    [ -z "$bm_name" ] && bm_name="$(basename "$bm" .md)"

    for pass_n in $(seq 1 "$passes"); do
      current=$((current + 1))
      log "[$current/$total] Preparing: $bm_name (pass $pass_n/$passes)"

      if [ "$dry_run" = true ]; then
        local run_id="standalone-$(basename "$bm" .md)-$(date -u +%Y%m%d%H%M%S)-pass${pass_n}"
        all_run_ids+=("$run_id (DRY RUN)")
        log "       Run ID: $run_id"
        continue
      fi

      # Step 1: Create run dir using skill-bench.sh prepare
      local run_id_raw
      if ! run_id_raw=$(bash "$SKILL_BENCH" prepare --benchmark "$bm" 2>/dev/null); then
        log "       ERROR: skill-bench.sh prepare failed"
        has_errors=true
        continue
      fi
      run_id_raw=$(echo "$run_id_raw" | tail -1)
      local run_dir="$RUNS_DIR/$run_id_raw"

      # Ensure directory was created
      if [ ! -d "$run_dir" ]; then
        log "       ERROR: run directory not created at $run_dir"
        has_errors=true
        continue
      fi

      # Ensure unique run_id by renaming with pass suffix (skill-bench.sh has 1s granularity)
      local unique_id="${run_id_raw}-pass${pass_n}"
      local unique_dir="$RUNS_DIR/$unique_id"
      if [ "$run_dir" != "$unique_dir" ]; then
        if [ -d "$unique_dir" ]; then
          log "       WARN: removing existing directory at $unique_dir"
          rm -rf "$unique_dir"
        fi
        mv "$run_dir" "$unique_dir"
        run_dir="$unique_dir"
        run_id_raw="$unique_id"
        # Update meta.json with new run_id
        local meta_file="$run_dir/meta.json"
        if [ -f "$meta_file" ]; then
          python3 -c "
import json
with open('$meta_file') as f:
    meta = json.load(f)
meta['run_id'] = '$unique_id'
with open('$meta_file', 'w') as f:
    json.dump(meta, f, indent=2)
" 2>/dev/null || true
        fi
        # Fix verify.sh RUN_DIR path (baked with old directory name)
        local verify_file="$run_dir/verify.sh"
        if [ -f "$verify_file" ]; then
          sed -i "s|$RUNS_DIR/$run_id_raw|$RUNS_DIR/$unique_id|g" "$verify_file"
        fi
      fi

      # Step 2: Overwrite prompt.md with step-budgeted version using worker-dispatch.sh style
      # Read benchmark body (strip frontmatter)
      local bench_body
      bench_body=$(python3 -c "
with open('$bm') as f:
    content = f.read()
parts = content.split('---', 2)
if len(parts) >= 3:
    print(parts[2].strip())
else:
    print(content.strip())
" 2>/dev/null)

      cat >"$run_dir/prompt.md" <<PROMPT_EOF
You are a dispatch worker (model profile: $model).

## Step Budget

You have at most **${steps} tool calls** to complete this task.
After you use ${steps} calls, you MUST stop and write your partial result.
Do not loop or retry indefinitely. If stuck, write what you have.

## Task

${bench_body}

## Output

Write your output to: \`${run_dir}/output.md\`

After writing the output, report with exactly these lines:
- \`BENCH_SUCCESS: true\` or \`BENCH_SUCCESS: false\`
- \`BENCH_STEPS: <number of calls used>\`
- \`BENCH_TIME_SEC: <approximate wall-clock seconds>\`
- \`BENCH_ERROR: <if failed, brief error description>\`

## Success Criteria

- The output file exists at \`${run_dir}/output.md\`
- The output follows the format specified in the task
- Verification passes (after you finish, verify.sh in the run dir will check)

## Fallback Contract

If you cannot complete the task within the step budget:
1. Write whatever partial output you have to \`${run_dir}/output.md\`
2. Set \`BENCH_SUCCESS: false\`
3. Report \`BENCH_ERROR: <what went wrong>\`
4. The parent orchestrator will pick up where you left off

Do not modify any files outside of \`${run_dir}\`.
PROMPT_EOF

      # Step 3: Update meta.json with pass number
      local meta_file="$run_dir/meta.json"
      if [ -f "$meta_file" ]; then
        python3 -c "
import json
with open('$meta_file') as f:
    meta = json.load(f)
meta['pass'] = $pass_n
meta['total_passes'] = $passes
meta['steps_budget'] = $steps
meta['model'] = '$model'
with open('$meta_file', 'w') as f:
    json.dump(meta, f, indent=2)
" 2>/dev/null || true
      fi

      all_run_ids+=("$run_id_raw")
      log "       Run dir: $run_dir"
    done
  done

  # ── Write manifest ──
  if [ "$dry_run" != true ] && [ ${#all_run_ids[@]} -gt 0 ]; then
    write_manifest "${category:-single}" "$passes" "${all_run_ids[@]}"
    log ""
    log "[dispatch] Manifest written to $MANIFEST_FILE"
  fi

  # Summary
  local prepared_count=${#all_run_ids[@]}
  log ""
  log "============================================"
  log "  Prepared: $prepared_count / $total runs"
  if [ "$has_errors" = true ]; then
    log "  Errors:   YES (some runs failed to prepare)"
  fi
  log "  Category: ${category:-single}"
  log "  Passes:   $passes"
  log "  Steps:    $steps max per worker"
  log "  Model:    $model"
  log "============================================"
  log ""
  log "Next: dispatch workers for each run, then:"
  log "  bash scripts/tools/benchmark-dispatch.sh verify --all"
  log ""
  log "Or verify a specific run:"
  log "  bash scripts/tools/benchmark-dispatch.sh verify --run <dir>"

  # Output machine-readable summary on stdout
  echo "{"
  echo "  \"prepared\": $prepared_count,"
  echo "  \"total\": $total,"
  echo "  \"errors\": $has_errors,"
  echo "  \"category\": \"${category:-single}\","
  echo "  \"passes\": $passes,"
  echo "  \"manifest\": \"$MANIFEST_FILE\""
  echo "}"

  if [ "$has_errors" = true ]; then
    exit 1
  fi
  exit 0
}

# ── Show manifest ─────────────────────────────────────────────────────────────

cmd_manifest() {
  local status_filter=""
  while [ $# -gt 0 ]; do
    case "$1" in
    --status)
      status_filter="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      log "Unknown: $1"
      usage
      exit 1
      ;;
    esac
  done

  if [ ! -f "$MANIFEST_FILE" ]; then
    log "No dispatch manifest found at $MANIFEST_FILE"
    log "Run 'prepare' first to create one."
    exit 1
  fi

  local total=$(read_manifest_field "total_runs")
  local category=$(read_manifest_field "category")
  local passes=$(read_manifest_field "passes")

  echo "=== Dispatch Manifest ==="
  echo "  Category: $category"
  echo "  Passes:   $passes"
  echo "  Total:    $total runs"
  echo ""

  python3 -c "
import json, os

def get_realtime_status(run_dir):
    result_f = os.path.join(run_dir, 'result.json')
    output_f = os.path.join(run_dir, 'output.md')
    if os.path.isfile(result_f):
        return 'verified'
    if os.path.isfile(output_f):
        return 'completed'
    return 'prepared'

with open('$MANIFEST_FILE') as f:
    m = json.load(f)
runs = m.get('runs', [])

# Update statuses from filesystem for each run
for r in runs:
    rd = r.get('run_dir', '')
    r['status'] = get_realtime_status(rd)

status_filter = '$status_filter'

# Count by status
statuses = {}
for r in runs:
    s = r.get('status', 'unknown')
    statuses[s] = statuses.get(s, 0) + 1

print('  Status breakdown (real-time):')
for s in ['prepared', 'completed', 'verified']:
    c = statuses.get(s, 0)
    print(f'    {s}: {c}')
for s, c in sorted(statuses.items()):
    if s not in ['prepared', 'completed', 'verified']:
        print(f'    {s}: {c}')
print()

# Filter
if status_filter and status_filter != 'all':
    runs = [r for r in runs if r.get('status') == status_filter]

if not runs:
    print('  No runs match filter.')
else:
    print(f'  Runs ({len(runs)}):')
    for r in runs:
        bid = r.get('benchmark_name', r.get('benchmark_id', '?'))
        status = r.get('status', '?')
        rid = r.get('run_id', '?')
        print(f'    [{status}] {bid:<40s} {rid}')
" 2>/dev/null
}

# ── Verify runs ───────────────────────────────────────────────────────────────

cmd_verify() {
  local mode=""
  local target_run=""

  while [ $# -gt 0 ]; do
    case "$1" in
    --all)
      mode="all"
      shift
      ;;
    --run)
      mode="single"
      target_run="$2"
      shift 2
      ;;
    --manifest)
      mode="manifest"
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      log "Unknown: $1"
      usage
      exit 1
      ;;
    esac
  done

  if [ -z "$mode" ]; then
    log "ERROR: specify --all, --run <dir>, or --manifest"
    usage
    exit 1
  fi

  local run_dirs=()
  case "$mode" in
  all)
    # Scan all run dirs for output.md without result.json
    log "[verify] Scanning all run directories..."
    for d in "$RUNS_DIR"/*/; do
      [ -d "$d" ] || continue
      local output_file="$d/output.md"
      local result_file="$d/result.json"
      if [ -f "$output_file" ] && [ ! -f "$result_file" ]; then
        run_dirs+=("$d")
      fi
    done
    ;;
  single)
    if [ ! -d "$target_run" ]; then
      log "ERROR: run directory not found: $target_run"
      exit 1
    fi
    run_dirs+=("$target_run")
    ;;
  manifest)
    if [ ! -f "$MANIFEST_FILE" ]; then
      log "ERROR: no manifest at $MANIFEST_FILE"
      exit 1
    fi
    while IFS= read -r d; do
      [ -n "$d" ] && run_dirs+=("$d")
    done < <(python3 -c "
import json
with open('$MANIFEST_FILE') as f:
    m = json.load(f)
for r in m.get('runs', []):
    rd = r.get('run_dir', '')
    out_f = rd + '/output.md'
    res_f = rd + '/result.json'
    import os
    if os.path.isfile(out_f) and not os.path.isfile(res_f):
        print(rd)
" 2>/dev/null)
    ;;
  esac

  if [ ${#run_dirs[@]} -eq 0 ]; then
    log "[verify] No runs to verify (all have result.json or no output.md)"
    exit 0
  fi

  log "[verify] Verifying ${#run_dirs[@]} run(s)..."
  echo ""

  local passed=0
  local failed=0
  local errors=0

  for d in "${run_dirs[@]}"; do
    local run_name=$(basename "$d")
    log "  [$((passed + failed + errors + 1))/${#run_dirs[@]}] $run_name"

    if bash "$SKILL_BENCH" verify --run "$d" 2>&1; then
      # Check result
      local result_file="$d/result.json"
      if [ -f "$result_file" ]; then
        local success
        success=$(python3 -c "import json; print(json.load(open('$result_file')).get('success', False))" 2>/dev/null || echo "false")
        if [ "$success" = "True" ] || [ "$success" = "true" ]; then
          passed=$((passed + 1))
          log "    ✓ PASS"
        else
          failed=$((failed + 1))
          log "    ✗ FAIL"
        fi
      fi
    else
      errors=$((errors + 1))
      log "    ✗ VERIFY ERROR"
    fi
    echo ""
  done

  # Summary on stdout (machine-readable)
  echo "{"
  echo "  \"verified\": $((passed + failed)),"
  echo "  \"passed\": $passed,"
  echo "  \"failed\": $failed,"
  echo "  \"errors\": $errors"
  echo "}"

  log "============================================"
  log "  Verify complete"
  log "  Total:  $((passed + failed + errors))"
  log "  Passed: $passed"
  log "  Failed: $failed"
  log "  Errors: $errors"
  log "============================================"
  log ""
  log "To see aggregate scores:"
  log "  bash scripts/bench/aggregate.sh summary"
}

# ── Main dispatch ─────────────────────────────────────────────────────────────

CMD="${1:-help}"
if [ $# -gt 0 ]; then shift; fi

case "$CMD" in
list)
  cmd_list "$@"
  ;;
prepare)
  cmd_prepare "$@"
  ;;
manifest)
  cmd_manifest "$@"
  ;;
verify)
  cmd_verify "$@"
  ;;
help | --help | -h)
  usage
  ;;
*)
  log "Unknown command: $CMD"
  usage
  exit 1
  ;;
esac
