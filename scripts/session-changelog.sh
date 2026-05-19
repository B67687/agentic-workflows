#!/usr/bin/env bash
# =============================================================================
# session-changelog.sh — Track what changed per session
#
# Records a compact changelog entry when a session ends (called by
# generate-handover.sh). Shows the diff summary and commit list since
# the last entry, giving cross-session change visibility.
#
# Usage:
#   bash scripts/session-changelog.sh record   # record entry (auto-called)
#   bash scripts/session-changelog.sh show     # show full changelog
#   bash scripts/session-changelog.sh recent   # show last 5 entries
#   bash scripts/session-changelog.sh [--help]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHANGELOG_FILE="$REPO_ROOT/.runtime/session-changelog.jsonl"

usage() {
  sed -n 's/^# //p; s/^#$//p' "$0"
  exit 0
}

record() {
  mkdir -p "$(dirname "$CHANGELOG_FILE")"

  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  # Find the last entry's commit to use as the diff base
  local since_ref=""
  if [[ -f "$CHANGELOG_FILE" ]]; then
    since_ref=$(tail -1 "$CHANGELOG_FILE" | python3 -c "
import json,sys
try:
    e = json.loads(sys.stdin.read())
    print(e.get('head_commit', ''))
except: pass
" 2>/dev/null || true)
  fi

  if [[ -z "$since_ref" ]]; then
    since_ref="HEAD~5" # default: last 5 commits if no prior entry
  fi

  local head_commit
  head_commit=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo "")

  # Gather diff stats since last entry
  local files_changed insertions deletions
  if [[ -n "$since_ref" ]] && git -C "$REPO_ROOT" merge-base --is-ancestor "$since_ref" HEAD 2>/dev/null; then
    files_changed=$(git -C "$REPO_ROOT" diff --stat "$since_ref"..HEAD 2>/dev/null | tail -1 | grep -oP '\d+(?= file)' || echo "0")
    insertions=$(git -C "$REPO_ROOT" diff --stat "$since_ref"..HEAD 2>/dev/null | tail -1 | grep -oP '\d+(?= insertion)' || echo "0")
    deletions=$(git -C "$REPO_ROOT" diff --stat "$since_ref"..HEAD 2>/dev/null | tail -1 | grep -oP '\d+(?= deletion)' || echo "0")

    # Get file list
    local file_list
    file_list=$(git -C "$REPO_ROOT" diff --name-only "$since_ref"..HEAD 2>/dev/null | tr '\n' ' ' | sed 's/ $//')

    # Get commit messages
    local commits
    commits=$(git -C "$REPO_ROOT" log --oneline "$since_ref"..HEAD 2>/dev/null || echo "")
  else
    files_changed=0
    insertions=0
    deletions=0
    file_list=""
    commits=""
  fi

  # Build JSON entry
  local entry
  entry=$(python3 -c "
import json
entry = {
    'timestamp': '$timestamp',
    'head_commit': '$head_commit',
    'since_ref': '$since_ref',
    'files_changed': ${files_changed:-0},
    'insertions': ${insertions:-0},
    'deletions': ${deletions:-0},
    'file_list': '''$file_list'''.split(),
    'commits': '''$commits'''.strip().split('\n') if '''$commits'''.strip() else []
}
print(json.dumps(entry))
" 2>/dev/null)

  echo "$entry" >>"$CHANGELOG_FILE"
  echo "  Session changelog: $files_changed files, +$insertions/-$deletions"
}

show() {
  if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "  No session changelog yet."
    return
  fi
  local count
  count=$(wc -l <"$CHANGELOG_FILE")
  python3 -c "
import json, sys

def load(file):
    entries = []
    with open(file) as f:
        for line in f:
            line = line.strip()
            if not line: continue
            try: entries.append(json.loads(line))
            except: continue
    return entries

entries = load('$CHANGELOG_FILE')
if not entries:
    print('  (no entries)')
    sys.exit(0)

print(f'  Session Changelog ({len(entries)} session(s)):')
print('  ───────────────────────────────────────')
for i, e in enumerate(entries):
    ts = e.get('timestamp', '?')[:10]
    fc = e.get('files_changed', 0)
    ins = e.get('insertions', 0)
    del_ = e.get('deletions', 0)
    c_count = len(e.get('commits', []))
    print(f'  {i+1:<2} {ts}  {fc} files  +{ins}/-{del_}  {c_count} commit(s)')
" 2>/dev/null
}

recent() {
  if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "  No session changelog yet."
    return
  fi
  tail -5 "$CHANGELOG_FILE" | python3 -c "
import json, sys

entries = []
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try: entries.append(json.loads(line))
    except: continue

if not entries:
    print('  (no entries)')
    sys.exit(0)

print(f'  Recent Sessions (last {len(entries)}):')
print('  ─────────────────────────────────────────────')
for e in entries:
    ts = e.get('timestamp', '?')[:10]
    fc = e.get('files_changed', 0)
    ins = e.get('insertions', 0)
    del_ = e.get('deletions', 0)
    files = e.get('file_list', [])
    print(f'  {ts}  {fc} files  +{ins}/-{del_}')
    for f in files[:5]:
        print(f'    {f}')
    if len(files) > 5:
        print(f'    ... +{len(files)-5} more')
" 2>/dev/null
}

# --- Main ---
ACTION="${1:-show}"
case "$ACTION" in
record) record ;;
show) show ;;
recent) recent ;;
--help | -h) usage ;;
*)
  echo "Unknown: $ACTION" >&2
  usage >&2
  exit 2
  ;;
esac
