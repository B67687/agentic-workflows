#!/usr/bin/env bash
# =============================================================================
# quality-snapshot.sh — Record and view quality trend snapshots
#
# Records the current folder quality audit result as a timestamped snapshot
# and shows the trend over time. Called automatically by the quality-check
# gate plugin, or manually to view history.
#
# Usage:
#   bash scripts/quality-snapshot.sh            # record + show trend
#   bash scripts/quality-snapshot.sh record     # record snapshot only
#   bash scripts/quality-snapshot.sh trend      # show trend only
#   bash scripts/quality-snapshot.sh --help     # show this help
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SNAPSHOT_FILE="$REPO_ROOT/.runtime/quality-snapshots.jsonl"
AUDIT_SCRIPT="$REPO_ROOT/scripts/audit-folder-quality.sh"

usage() {
  sed -n 's/^# //p; s/^#$//p' "$0"
  exit 0
}

record_snapshot() {
  if [[ ! -f "$AUDIT_SCRIPT" ]]; then
    echo "ERROR: audit-folder-quality.sh not found" >&2
    exit 1
  fi

  # Run audit and count issues
  local output
  output=$(bash "$AUDIT_SCRIPT" 2>&1) || true

  local warn_count error_count total_issues
  warn_count=$(echo "$output" | grep -c '\[WARN\]' 2>/dev/null || true)
  error_count=$(echo "$output" | grep -c '\[ERROR\]' 2>/dev/null || true)
  total_issues=$((warn_count + error_count))

  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  # Ensure .runtime dir exists
  mkdir -p "$(dirname "$SNAPSHOT_FILE")"

  echo "{\"timestamp\":\"$timestamp\",\"issues\":$total_issues,\"warns\":$warn_count,\"errors\":$error_count}" >>"$SNAPSHOT_FILE"
  echo "  Recorded snapshot: $total_issues issues ($timestamp)"
}

show_trend() {
  if [[ ! -f "$SNAPSHOT_FILE" ]]; then
    echo "  No quality snapshots yet. Run: bash scripts/quality-snapshot.sh record"
    return
  fi

  local count
  count=$(wc -l <"$SNAPSHOT_FILE" 2>/dev/null || echo 0)

  if [[ "$count" -eq 0 ]]; then
    echo "  No quality snapshots yet."
    return
  fi

  echo "  Quality Trend (last ${count} snapshot(s)):"
  echo "  ─────────────────────────────────────────"
  echo "  #  Date                Issues  Δ"
  echo "  ─────────────────────────────────────────"

  # Show last entries with delta
  python3 -c "
import json, sys

def load(file):
    entries = []
    with open(file) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return entries

entries = load('$SNAPSHOT_FILE')
if not entries:
    print('  (no valid entries)')
    sys.exit(0)

for i, e in enumerate(entries):
    ts = e.get('timestamp', '?')[:10]
    issues = e.get('issues', '?')
    if i == 0:
        delta = '   (baseline)'
    else:
        prev = entries[i-1].get('issues', 0)
        diff = issues - prev
        if diff == 0:
            delta = '    0'
        elif diff > 0:
            delta = f'   +{diff}'
        else:
            delta = f'   {diff}'
    print(f'  {i+1:<2} {ts}  {issues:<5} {delta}')

print()
last = entries[-1].get('issues', 0)
first = entries[0].get('issues', 0) if len(entries) > 1 else last
overall = last - first
dir_icon = '↑' if overall > 0 else ('↓' if overall < 0 else '→')
print(f'  Overall: {dir_icon} {abs(overall)} issue(s) over {len(entries)} snapshot(s)')
" 2>/dev/null || echo "  (error parsing snapshots)"
}

# --- Main ---

ACTION="${1:-both}"

case "$ACTION" in
record)
  record_snapshot
  ;;
trend)
  show_trend
  ;;
both | --record)
  record_snapshot
  echo ""
  show_trend
  ;;
--help | -h)
  usage
  ;;
*)
  echo "Unknown action: $ACTION" >&2
  usage >&2
  exit 2
  ;;
esac
