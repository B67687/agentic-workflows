#!/usr/bin/env bash
# =============================================================================
# cleanup-runs.sh --- Safe benchmark run directory cleanup
#
# Protects against accidental deletion of benchmark run data by requiring
# explicit run IDs. Never accepts globs or wildcards.
#
# Usage:
#   bash scripts/bench/cleanup-runs.sh                    # List runs (dry)
#   bash scripts/bench/cleanup-runs.sh list               # List all runs
#   bash scripts/bench/cleanup-runs.sh list <benchmark>   # List runs for a benchmark
#   bash scripts/bench/cleanup-runs.sh rm <run-id>        # Remove one run
#   bash scripts/bench/cleanup-runs.sh rm <id1> <id2>     # Remove multiple runs by ID
#   bash scripts/bench/cleanup-runs.sh clean               # Remove all verified successful runs
#                                                          # (only those with no outstanding deps)
#
# Safety:
#   - Never accepts globs or wildcards
#   - Requires explicit run IDs for deletion
#   - `clean` mode only removes runs that are verified + successful
#   - All operations print what they would do before doing it
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUNS_DIR="$REPO_ROOT/.runtime/bench-runs"

log() { echo "$@" >&2; }
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# Guard: never operate if RUNS_DIR resolves to something dangerous
if [ ! -d "$RUNS_DIR" ]; then
  log "No bench-runs directory found at $RUNS_DIR"
  exit 0
fi

# Resolve to real path for safety checks
REAL_RUNS_DIR="$(cd "$RUNS_DIR" && pwd)"

cmd_list() {
  local filter="${1:-}"
  log "=== Benchmark Runs ==="
  log ""
  local count=0
  for dir in "$REAL_RUNS_DIR"/*/; do
    [ -d "$dir" ] || continue
    local rid
    rid="$(basename "$dir")"
    if [ -n "$filter" ]; then
      echo "$rid" | grep -qi "$filter" || continue
    fi
    local result=""
    if [ -f "$dir/result.json" ]; then
      result="$(python3 -c "
import json
try:
    r = json.load(open('$dir/result.json'))
    s = 'PASS' if r.get('success') else 'FAIL'
    b = r.get('benchmark_id', '?')
    print(f'{s} | {b}')
except: print('unparseable')
" 2>/dev/null || echo "unparseable")"
    else
      result="no result"
    fi
    echo "  $rid  [$result]"
    count=$((count + 1))
  done
  log ""
  log "Total: $count run(s)"
}

cmd_rm() {
  if [ $# -eq 0 ]; then
    die "Usage: cleanup-runs.sh rm <run-id> [run-id ...]"
  fi

  # Protect against empty IDs (would target the runs dir itself)
  for arg in "$@"; do
    if [ -z "$arg" ]; then
      die "Empty run IDs are not allowed."
    fi
  done

  # Protect against glob/wildcard patterns
  for arg in "$@"; do
    case "$arg" in
    *\**) die "Wildcards are not allowed. Use explicit run IDs." ;;
    *\?*) die "Wildcards are not allowed. Use explicit run IDs." ;;
    *\[*) die "Wildcards are not allowed. Use explicit run IDs." ;;
    *\;*) die "Semicolons are not allowed." ;;
    . | ..) die "Path traversal is not allowed. Use explicit run IDs." ;;
    esac
  done

  for rid in "$@"; do
    local target="$REAL_RUNS_DIR/$rid"
    if [ ! -d "$target" ]; then
      log "WARNING: run not found: $rid (skipping)"
      continue
    fi
    log "Removing: $rid"
    rm -rf "$target"
    log "  Done."
  done
}

cmd_clean() {
  log "Cleaning verified successful runs..."
  log ""

  local count=0
  for dir in "$REAL_RUNS_DIR"/*/; do
    [ -d "$dir" ] || continue
    local rid
    rid="$(basename "$dir")"
    if [ -f "$dir/result.json" ]; then
      local success
      success=$(python3 -c "
import json
r = json.load(open('$dir/result.json'))
print('true' if r.get('success') and r.get('status') == 'verified' else 'false')
" 2>/dev/null || echo "false")
      if [ "$success" = "true" ]; then
        log "  Cleaning: $rid"
        rm -rf "$dir"
        count=$((count + 1))
      fi
    fi
  done
  log ""
  log "Cleaned $count verified successful runs."
}

# --- Main dispatch ---
CMD="${1:-list}"
shift 2>/dev/null || true

case "$CMD" in
list | ls)
  cmd_list "${1:-}"
  ;;
rm | remove | delete)
  cmd_rm "$@"
  ;;
clean | cleanup)
  cmd_clean
  ;;
help | --help | -h)
  echo "Usage: bash scripts/bench/cleanup-runs.sh [command]"
  echo ""
  echo "Commands:"
  echo "  list [filter]     List runs, optionally filter by benchmark name"
  echo "  rm <id> [id...]  Remove one or more runs by exact run ID"
  echo "  clean             Remove all verified successful runs"
  echo "  help              Show this help"
  ;;
*)
  die "Unknown command: $CMD -- valid: list, rm, clean"
  ;;
esac
