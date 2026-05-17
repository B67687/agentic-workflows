#!/usr/bin/env bash
# =============================================================================
# session-state-populate.sh --- Populate empty session-state fields from runtime data
#
# Reads the current session-state.json and fills in empty fields from
# available runtime sources:
#   - whatChanged        ← git diff + recent commit messages
#   - verification       ← comprehension audit + test results
#   - keyLearnings       ← decision log recent entries + agentmemory
#   - immediateNextSteps ← current phase + gate pipeline state
#
# Usage:
#   bash ./scripts/session-state-populate.sh              # populate all fields
#   bash ./scripts/session-state-populate.sh --dry-run     # show what would be written
#   bash ./scripts/session-state-populate.sh --check       # exit 1 if any field is empty
#   bash ./scripts/session-state-populate.sh --phase <name>  # set current phase
# =============================================================================

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$REPO_ROOT/session-state.json"
RUNTIME_DIR="$REPO_ROOT/.runtime"
DECISION_LOG="$RUNTIME_DIR/decision-log.jsonl"
COMPREHENSION_AUDIT="$RUNTIME_DIR/comprehension-audit.jsonl"
LEARNINGS_FILE="$REPO_ROOT/.learnings.jsonl"
GATES_DIR="$REPO_ROOT/scripts/gates"

MODE="${1:-populate}"
PHASE="${2:-}"

# Parse --phase flag from args
for arg in "$@"; do
  case "$arg" in
  --phase=*) PHASE="${arg#--phase=}" ;;
  --dry-run) MODE="dry-run" ;;
  --check) MODE="check" ;;
  esac
done

# ── Helpers ──

json_read() {
  python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    d = json.load(f)
print(json.dumps(d, indent=2))
" 2>/dev/null || echo "{}"
}

json_write() {
  local tmp
  tmp=$(mktemp /tmp/session-state-XXXXXX.json)
  cat >"$tmp"
  cp "$tmp" "$STATE_FILE"
  rm -f "$tmp"
  echo "  wrote: $STATE_FILE"
}

collect_what_changed() {
  # From git: staged + unstaged changes, recent commit messages
  local result="[]"
  result=$(python3 -c "
import json, subprocess, os

changes = []

# Recent commit messages (last 3)
try:
    log = subprocess.run(
        ['git', 'log', '--oneline', '-3'],
        capture_output=True, text=True, cwd='$REPO_ROOT'
    )
    for line in log.stdout.strip().split('\n'):
        if line:
            changes.append({'source': 'commit', 'value': line.strip()})
except: pass

# Modified files (staged + unstaged)
try:
    status = subprocess.run(
        ['git', 'status', '--short'],
        capture_output=True, text=True, cwd='$REPO_ROOT'
    )
    for line in status.stdout.strip().split('\n')[:10]:
        if line.strip():
            changes.append({'source': 'modified', 'value': line.strip()})
except: pass

# Dirty file count
try:
    dirty = subprocess.run(
        ['git', 'status', '--porcelain'],
        capture_output=True, text=True, cwd='$REPO_ROOT'
    )
    count = len([l for l in dirty.stdout.strip().split('\n') if l.strip()])
    if count > 0:
        changes.append({'source': 'summary', 'value': f'{count} dirty file(s)'})
except: pass

print(json.dumps(changes))
" 2>/dev/null || echo '[]')
  echo "$result"
}

collect_verification() {
  local result="[]"
  result=$(python3 -c "
import json, os

results = []

# Comprehension audit logs (last 3 verify events)
audit_file = '$COMPREHENSION_AUDIT'
if os.path.exists(audit_file):
    try:
        with open(audit_file) as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        entry = json.loads(line)
                        if entry.get('action') == 'verify':
                            results.append({
                                'source': 'comprehension_gate',
                                'result': entry.get('result', 'unknown'),
                                'detail': entry.get('detail', ''),
                            })
                    except: pass
        results = results[-3:]  # Keep last 3
    except: pass

# Check test results
smoke_file = '$RUNTIME_DIR/smoke-test-results.json'
if os.path.exists(smoke_file):
    try:
        with open(smoke_file) as f:
            data = json.load(f)
        results.append({
            'source': 'smoke_tests',
            'result': 'pass' if data.get('pass', 0) > 0 else 'unknown',
            'detail': f\"{data.get('pass', 0)} pass, {data.get('fail', 0)} fail\"
        })
    except: pass

if not results:
    results.append({'source': 'none', 'result': 'pending', 'detail': 'no verification data yet'})

print(json.dumps(results))
" 2>/dev/null || echo '[]')
  echo "$result"
}

collect_key_learnings() {
  local result="[]"
  result=$(python3 -c "
import json, os

learnings = []

# From decision log (last 5 entries)
dlog = '$DECISION_LOG'
if os.path.exists(dlog):
    try:
        with open(dlog) as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        entry = json.loads(line)
                        if entry.get('type') in ('decision_pipeline', 'gate_result'):
                            learnings.append({
                                'source': 'decision_log',
                                'transition': entry.get('transition', entry.get('phase', '?')),
                                'status': entry.get('status', entry.get('result', '?')),
                                'id': entry.get('id', ''),
                            })
                    except: pass
        learnings = learnings[-5:]
    except: pass

# From .learnings.jsonl (last 3)
lfile = '$LEARNINGS_FILE'
if os.path.exists(lfile):
    try:
        with open(lfile) as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        entry = json.loads(line)
                        learnings.append({
                            'source': 'learnings',
                            'content': entry.get('content', '')[:120],
                        })
                    except: pass
        learnings = learnings[-3:]
    except: pass

if not learnings:
    learnings.append({'source': 'none', 'content': 'no learnings recorded yet'})

print(json.dumps(learnings))
" 2>/dev/null || echo '[]')
  echo "$result"
}

collect_next_steps() {
  local result="[]"

  # Read current session state for the task name and status
  local task_name task_status
  task_name=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    d = json.load(f)
print(d.get('currentTask', {}).get('name', ''))
" 2>/dev/null || echo "")
  task_status=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    d = json.load(f)
print(d.get('currentTask', {}).get('status', ''))
" 2>/dev/null || echo "")

  result=$(python3 -c "
import json, os

steps = []

# Infer from task status
task_name = '''$task_name'''
task_status = '''$task_status'''
if task_name and task_status == 'started':
    steps.append({'type': 'continue', 'value': f'Continue task: {task_name}'})

# Check decision pipeline state for blocked transitions
gates_dir = '$GATES_DIR'
if os.path.isdir(gates_dir):
    for phase in sorted(os.listdir(gates_dir)):
        if phase.startswith('.'): continue
        steps.append({'type': 'gate_phase', 'value': f'Run {phase} gate pipeline'})

# Check for active error state
error_dir = '$RUNTIME_DIR/error-counter/decisions'
if os.path.isdir(error_dir):
    errors = [f for f in os.listdir(error_dir) if os.path.isfile(os.path.join(error_dir, f))]
    if errors:
        steps.insert(0, {'type': 'errors', 'value': f'Resolve {len(errors)} active error(s) before proceeding'})

# Default fallback
if not steps:
    steps.append({'type': 'next', 'value': 'Define next task or close current session'})

print(json.dumps(steps))
" 2>/dev/null || echo '[]')
  echo "$result"
}

# ── Main ──

main() {
  # Read existing state
  local state
  state=$(json_read)

  # Collect all data
  local changed verification learnings steps phase
  changed=$(collect_what_changed)
  verification=$(collect_verification)
  learnings=$(collect_key_learnings)
  steps=$(collect_next_steps)

  # Detect phase from gates directory or use passed value
  if [[ -z "$PHASE" ]]; then
    PHASE="unknown"
    # Try to infer from comprehension audit for the most recent phase context
    if [[ -f "$COMPREHENSION_AUDIT" ]]; then
      PHASE=$(python3 -c "
import json
with open('$COMPREHENSION_AUDIT') as f:
    for line in f:
        line = line.strip()
        if line:
            try:
                d = json.loads(line)
                if 'phase' in d: print(d['phase'])
            except: pass
" 2>/dev/null | tail -1 || echo "unknown")
    fi
  fi

  # Handle --check mode
  if [[ "$MODE" == "check" ]]; then
    local empty=0
    if [[ "$changed" == "[]" ]] || [[ "$changed" == '[{"source": "none"]]' ]]; then
      echo "  EMPTY: whatChanged"
      empty=1
    fi
    if [[ "$verification" == '[{"source": "none"]]' ]]; then
      echo "  EMPTY: verification"
      empty=1
    fi
    if [[ "$learnings" == '[{"source": "none"]]' ]]; then
      echo "  EMPTY: keyLearnings"
      empty=1
    fi
    if [[ "$steps" == '[{"type": "next", "value": "Define next task or close current session"}]' ]]; then
      echo "  EMPTY: immediateNextSteps"
      empty=1
    fi
    return "$empty"
  fi

  # Build updated state
  local updated
  updated=$(python3 -c "
import json, sys

with open('$STATE_FILE') as f:
    state = json.load(f)

# Read collected data from environment
what_changed = json.loads('''$changed''')
verification = json.loads('''$verification''')
learnings = json.loads('''$learnings''')
next_steps = json.loads('''$steps''')

# Update fields (only if they would have content)
if what_changed:
    state['whatChanged'] = [c['value'] for c in what_changed if 'value' in c]
if verification:
    v = []
    for entry in verification:
        d = entry.get('detail', '')
        r = entry.get('result', '')
        if d:
            v.append(f\"{entry.get('source', '?')}: {r} — {d}\")
        else:
            v.append(f\"{entry.get('source', '?')}: {r}\")
    state['verification'] = v
if learnings:
    state['keyLearnings'] = learnings
if next_steps:
    state['immediateNextSteps'] = [s['value'] for s in next_steps if 'value' in s]

# Update status
state['status'] = '$PHASE'

print(json.dumps(state, indent=2))
" 2>/dev/null || echo "$state")

  if [[ "$MODE" == "dry-run" ]]; then
    echo "=== DRY RUN: session-state.json would be updated ==="
    echo "$updated"
    return 0
  fi

  # Write
  echo "$updated" >"$STATE_FILE"
  echo ""

  # Count what was populated
  local wc vc lc sc
  wc=$(echo "$updated" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('whatChanged',[])))" 2>/dev/null || echo 0)
  vc=$(echo "$updated" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('verification',[])))" 2>/dev/null || echo 0)
  lc=$(echo "$updated" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('keyLearnings',[])))" 2>/dev/null || echo 0)
  sc=$(echo "$updated" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d.get('immediateNextSteps',[])))" 2>/dev/null || echo 0)

  echo "  Session state populated:"
  echo "    whatChanged:      $wc entries"
  echo "    verification:     $vc entries"
  echo "    keyLearnings:     $lc entries"
  echo "    immediateNext:    $sc entries"
  echo "    status:           $PHASE"
}

main "$@"
