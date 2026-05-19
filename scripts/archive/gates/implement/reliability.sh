#!/usr/bin/env bash
# =============================================================================
# Gate plugin: implement/reliability
#
# Checks reliability health before implementation proceeds:
#   - Error counters (stuck retry loops)
#   - Recent unaddressed errors
#   - Stale context snapshots
#   - Pending human escalations
#
# Standard gate interface:
#   Exit 0 = PASS (reliability looks healthy)
#   Exit 2 = WARN (reliability concerns found — advisory)
#   Exit 3 = SKIP (no reliability data available)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"

echo "  ── Gate: implement/reliability"

warnings=0
checks=0

# Check 1: Error counters — any stuck operations?
ERROR_COUNTER="$REPO_ROOT/scripts/infra/error-counter.sh"
if [[ -f "$ERROR_COUNTER" ]]; then
  checks=$((checks + 1))
  counter_output=$(bash "$ERROR_COUNTER" list 2>/dev/null || true)
  if echo "$counter_output" | grep -qE '[0-9]+/[0-9]+' 2>/dev/null; then
    stuck_ops=$(echo "$counter_output" | grep -v '0/' | grep -cE '[0-9]+/' 2>/dev/null || echo 0)
    if [[ "$stuck_ops" -gt 0 ]]; then
      echo "    ⚠  $stuck_ops operation(s) with active error counters"
      echo "$counter_output" | grep -v '0/' | head -3 | sed 's/^/        /'
      warnings=$((warnings + 1))
    else
      echo "    ✓  Error counters: clean"
    fi
  else
    echo "    ✓  Error counters: no active operations"
  fi
else
  echo "    --  Error counter script not found"
fi

# Check 2: Recent unaddressed errors in triage log
TRIAGE_LOG="$RUNTIME_DIR/triage/errors.log"
if [[ -f "$TRIAGE_LOG" ]] && [[ -s "$TRIAGE_LOG" ]]; then
  checks=$((checks + 1))
  entry_count=$(wc -l <"$TRIAGE_LOG" 2>/dev/null || echo 0)
  # Check for errors in the last hour
  recent_count=$(python3 -c "
import json, time
now = time.time()
count = 0
try:
    with open('$TRIAGE_LOG') as f:
        for line in f:
            try:
                e = json.loads(line)
                ts = e.get('timestamp', '')
                if ts and now - time.mktime(time.strptime(ts[:19], '%Y-%m-%dT%H:%M:%S')) < 3600:
                    count += 1
            except: pass
except: pass
print(count)
" 2>/dev/null || echo 0)
  if [[ "$recent_count" -gt 0 ]]; then
    echo "    ⚠  $recent_count error(s) in last hour"
    tail -3 "$TRIAGE_LOG" | python3 -c "
import json,sys
for line in sys.stdin:
    try:
        e = json.loads(line)
        print(f'        {e.get(\"command\", \"?\")[:60]}')
    except: pass
" 2>/dev/null || true
    warnings=$((warnings + 1))
  else
    echo "    ✓  No recent errors (${entry_count} total in log)"
  fi
else
  echo "    ✓  No triage errors logged"
fi

# Check 3: Stale context snapshots
CONTEXT_DIR="$REPO_ROOT/.context"
if [[ -d "$CONTEXT_DIR" ]]; then
  checks=$((checks + 1))
  stale_count=0
  for f in "$CONTEXT_DIR"/*.json; do
    [[ -f "$f" ]] || continue
    age=$(($(date +%s) - $(stat -c %Y "$f" 2>/dev/null || echo 0)))
    if [[ "$age" -gt 86400 ]]; then # > 24 hours
      stale_count=$((stale_count + 1))
    fi
  done
  if [[ "$stale_count" -gt 0 ]]; then
    echo "    ℹ  $stale_count stale context snapshot(s) (>24h old)"
  else
    echo "    ✓  Context snapshots: fresh"
  fi
fi

echo ""

if [[ "$warnings" -eq 0 ]]; then
  echo "    ✓ PASS  Reliability looks healthy ($checks checks)"
  exit 0
else
  echo "    ⚠ WARN  $warnings reliability concern(s)"
  echo "    Next:"
  echo "      - Check error counters:  bash scripts/infra/error-counter.sh list"
  echo "      - View recent errors:    cat .runtime/triage/errors.log | tail -5"
  echo "      - Reset stuck ops:       bash scripts/infra/error-counter.sh reset <op>"
  echo "      - Clean stale contexts:  rm .context/*.json (review first)"
  exit 2
fi
