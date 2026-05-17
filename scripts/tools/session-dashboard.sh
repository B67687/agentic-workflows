#!/usr/bin/env bash
# =============================================================================
# session-dashboard.sh --- Unified session observability dashboard
#
# Aggregates state from all gate/decision/error/debt sources into a single
# compact view. Reads from:
#   - session-state.json       (phase, task, context)
#   - .runtime/decision-log.jsonl   (recent decisions)
#   - .runtime/debt-history.jsonl   (triple debt levels)
#   - .runtime/comprehension-audit.jsonl (gate status)
#   - .runtime/error-counter/         (active errors)
#   - .runtime/challenge-history.json  (CATFISH status)
#   - git status               (branch, dirty files)
#
# Usage:
#   bash ./scripts/session-dashboard.sh
#   bash ./scripts/session-dashboard.sh --json   (machine-readable output)
#   bash ./scripts/session-dashboard.sh --watch  (re-run every 10s)
# =============================================================================

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$REPO_ROOT/session-state.json"
DECISION_LOG="$RUNTIME_DIR/decision-log.jsonl"
DEBT_LOG="$RUNTIME_DIR/debt-history.jsonl"
COMPREHENSION_AUDIT="$RUNTIME_DIR/comprehension-audit.jsonl"
CHALLENGE_HISTORY="$RUNTIME_DIR/challenge-history.json"
ERROR_DIR="$RUNTIME_DIR/error-counter"
GATES_DIR="$REPO_ROOT/scripts/gates"

MODE="${1:-normal}"

usage() {
  cat <<'EOF'
Usage: ./scripts/session-dashboard.sh [--json|--watch]

  (no args)    Human-readable session dashboard
  --json       Machine-readable JSON output
  --watch      Re-run every 10 seconds (Ctrl+C to stop)
  --help       Show this help
EOF
}

case "$MODE" in
  --help|-h) usage; exit 0 ;;
  --json|--watch) ;;
  normal) ;;
  *) echo "Unknown: $MODE"; usage; exit 2 ;;
esac

# ---------------------------------------------------------------------------
# Data collection functions
# ---------------------------------------------------------------------------

collect_session_state() {
  python3 -c "
import json, sys
try:
    with open('$STATE_FILE') as f:
        s = json.load(f)
    t = s.get('currentTask', {})
    print(json.dumps({
        'session': s.get('session', '?'),
        'status': s.get('status', '?'),
        'context_pressure': s.get('contextPressure', 'unknown'),
        'task_name': t.get('name', '(none)'),
        'task_status': t.get('status', '(none)'),
    }))
except Exception as e:
    print(json.dumps({'error': str(e)}))
" 2>/dev/null || echo '{"error":"cannot read session-state.json"}'
}

collect_decisions() {
  if [[ ! -f "$DECISION_LOG" ]]; then
    echo '[]'
    return
  fi
  python3 -c "
import json, sys
entries = []
with open('$DECISION_LOG') as f:
    for line in f:
        line = line.strip()
        if line:
            try:
                entries.append(json.loads(line))
            except: pass
# Last 5
entries = entries[-5:]
for e in entries:
    # Normalize: extract type, result, timestamp
    e['_type'] = e.get('type', e.get('label', 'decision'))
    e['_result'] = e.get('selected', e.get('result', '?'))
print(json.dumps(entries))
" 2>/dev/null || echo '[]'
}

collect_debt() {
  if [[ ! -f "$DEBT_LOG" ]]; then
    echo '{}'
    return
  fi
  python3 -c "
import json
with open('$DEBT_LOG') as f:
    entries = [json.loads(l) for l in f if l.strip()]
# Find latest assessment entry (has 'technical' field)
latest = {}
for e in reversed(entries):
    if 'technical' in e:
        latest = e
        break
print(json.dumps(latest))
" 2>/dev/null || echo '{}'
}

collect_comprehension() {
  if [[ ! -f "$COMPREHENSION_AUDIT" ]]; then
    echo '{}'
    return
  fi
  python3 -c "
import json
with open('$COMPREHENSION_AUDIT') as f:
    entries = [json.loads(l) for l in f if l.strip()]
# Most recent verify result
latest = {}
for e in reversed(entries):
    if e.get('action') == 'verify':
        latest = e
        break
# Also count total
total = len(entries)
latest['_total'] = total
print(json.dumps(latest))
" 2>/dev/null || echo '{}'
}

collect_errors() {
  if [[ ! -d "$ERROR_DIR/decisions" ]]; then
    echo '[]'
    return
  fi
  python3 -c "
import json, os, re
dec_dir = '$ERROR_DIR/decisions'
errors = []
if os.path.isdir(dec_dir):
    for fname in sorted(os.listdir(dec_dir))[-5:]:
        fpath = os.path.join(dec_dir, fname)
        if not os.path.isfile(fpath): continue
        try:
            with open(fpath) as f:
                data = json.load(f)
            errors.append(data)
        except: pass
print(json.dumps(errors))
" 2>/dev/null || echo '[]'
}

collect_challenge() {
  if [[ ! -f "$CHALLENGE_HISTORY" ]]; then
    echo '{}'
    return
  fi
  python3 -c "
import json
with open('$CHALLENGE_HISTORY') as f:
    data = json.load(f)
challenges = data.get('challenges', [])
latest = challenges[-1] if challenges else {}
print(json.dumps(latest))
" 2>/dev/null || echo '{}'
}

collect_git_state() {
  local branch dirty commits
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
  dirty=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  commits=$(git log --oneline --since="$(date -u +%Y-%m-%d)T00:00:00Z" 2>/dev/null | wc -l | tr -d ' ')
  echo "{\"branch\":\"$branch\",\"dirty\":$dirty,\"commits_today\":$commits}"
}

collect_gate_plugins() {
  # Check each phase's gate plugins for recent activity
  python3 -c "
import os, json, time

gates_dir = '$GATES_DIR'
results = []
now = time.time()

if os.path.isdir(gates_dir):
    for phase in sorted(os.listdir(gates_dir)):
        phase_dir = os.path.join(gates_dir, phase)
        if not os.path.isdir(phase_dir): continue
        for plugin in sorted(os.listdir(phase_dir)):
            if not plugin.endswith('.sh'): continue
            fpath = os.path.join(phase_dir, plugin)
            mtime = os.path.getmtime(fpath)
            age_hours = (now - mtime) / 3600
            results.append({
                'phase': phase,
                'plugin': plugin.replace('.sh', ''),
                'age_hours': round(age_hours, 1),
            })
print(json.dumps(results))
" 2>/dev/null || echo '[]'
}

# ---------------------------------------------------------------------------
# Render: normal mode (human-readable)
# ---------------------------------------------------------------------------
render_normal() {
  local session_data decisions debt comprehension errors challenge git_state gate_plugins

  session_data=$(collect_session_state)
  decisions=$(collect_decisions)
  debt=$(collect_debt)
  comprehension=$(collect_comprehension)
  errors=$(collect_errors)
  challenge=$(collect_challenge)
  git_state=$(collect_git_state)
  gate_plugins=$(collect_gate_plugins)

  # Parse key fields
  local session task_name task_status context_pressure
  session=$(echo "$session_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('session','?'))" 2>/dev/null || echo "?")
  task_name=$(echo "$session_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('task_name','(none)'))" 2>/dev/null || echo "(none)")
  task_status=$(echo "$session_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('task_status','?'))" 2>/dev/null || echo "?")
  context_pressure=$(echo "$session_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('context_pressure','unknown'))" 2>/dev/null || echo "unknown")

  local branch dirty commits_today
  branch=$(echo "$git_state" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('branch','?'))" 2>/dev/null || echo "?")
  dirty=$(echo "$git_state" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('dirty',0))" 2>/dev/null || echo "0")
  commits_today=$(echo "$git_state" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('commits_today',0))" 2>/dev/null || echo "0")

  # ---- HEADER ----
  echo "=========================================="
  echo "  Session $session Dashboard"
  echo "=========================================="
  echo ""

  # ---- SESSION INFO ----
  echo "  Session"
  echo "    Task:     $task_name"
  echo "    Status:   $task_status"
  echo "    Pressure: $context_pressure"
  echo ""

  # ---- GIT STATE ----
  echo "  Git"
  echo "    Branch:  $branch"
  echo "    Dirty:   $dirty file(s)"
  echo "    Commits: $commits_today today"
  echo ""

  # ---- GATE PLUGINS ----
  echo "  Gate Plugins"
  local gate_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    gate_count=$((gate_count + 1))
    local phase plugin age
    phase=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('phase','?'))" 2>/dev/null || echo "?")
    plugin=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('plugin','?'))" 2>/dev/null || echo "?")
    age=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('age_hours','?'))" 2>/dev/null || echo "?")
    echo "    $phase/$plugin  (age: ${age}h)"
  done < <(echo "$gate_plugins" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for p in data:
    print(json.dumps(p))
" 2>/dev/null || true)
  if [[ "$gate_count" -eq 0 ]]; then
    echo "    (no gate plugins configured)"
  fi
  echo ""

  # ---- COMPREHENSION GATE ----
  echo "  Comprehension Gate"
  local comp_result comp_source comp_total
  comp_result=$(echo "$comprehension" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('result','no data'))" 2>/dev/null || echo "no data")
  comp_source=$(echo "$comprehension" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('source',''))" 2>/dev/null || echo "")
  comp_total=$(echo "$comprehension" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('_total',0))" 2>/dev/null || echo "0")
  local comp_status_icon
  case "$comp_result" in
    pass) comp_status_icon="PASS" ;;
    warn) comp_status_icon="WARN" ;;
    fail) comp_status_icon="FAIL" ;;
    *)    comp_status_icon="--" ;;
  esac
  echo "    Last verify: $comp_status_icon  (total: ${comp_total} events)"
  echo ""

  # ---- DECISIONS ----
  echo "  Recent Decisions"
  local dec_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    dec_count=$((dec_count + 1))
    local dtype dresult
    dtype=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('_type','decision'))" 2>/dev/null || echo "decision")
    dresult=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('_result','?'))" 2>/dev/null || echo "?")
    echo "    $dtype  -->  $dresult"
  done < <(echo "$decisions" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for d in data:
    print(json.dumps(d))
" 2>/dev/null || true)
  if [[ "$dec_count" -eq 0 ]]; then
    echo "    (no decisions logged)"
  fi
  echo ""

  # ---- DEBT ----
  echo "  Triple Debt"
  local tech_debt cog_debt intent_debt
  tech_debt=$(echo "$debt" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('technical','?'))" 2>/dev/null || echo "?")
  cog_debt=$(echo "$debt" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('cognitive','?'))" 2>/dev/null || echo "?")
  intent_debt=$(echo "$debt" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('intent','?'))" 2>/dev/null || echo "?")
  echo "    Technical: $tech_debt  Cognitive: $cog_debt  Intent: $intent_debt"
  echo ""

  # ---- ACTIVE ERRORS ----
  echo "  Active Errors"
  local err_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    err_count=$((err_count + 1))
    local op count threshold ts
    op=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('operation','?'))" 2>/dev/null || echo "?")
    count=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('count','?'))" 2>/dev/null || echo "?")
    threshold=$(echo "$line" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('threshold','?'))" 2>/dev/null || echo "?")
    echo "    $op  (${count}/${threshold})"
  done < <(echo "$errors" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for e in data:
    print(json.dumps(e))
" 2>/dev/null || true)
  if [[ "$err_count" -eq 0 ]]; then
    echo "    (none)"
  fi
  echo ""

  # ---- RECOMMENDATION ----
  echo "  Recommendation"
  local rec="Proceed."
  # Check for blockers
  if [[ "$comp_result" == "fail" ]]; then
    rec="Comprehension gate FAILED -- extract evidence before proceeding."
  fi
  if echo "$debt" | python3 -c "import json,sys; d=json.load(sys.stdin); print('1' if d.get('cognitive',0) and int(d.get('cognitive',0)) > 5 else '0')" 2>/dev/null | grep -q 1; then
    rec="Cognitive debt high (${cog_debt}) -- run triple-debt.sh assess and address comprehension gaps."
  fi
  if [[ "$err_count" -gt 0 ]]; then
    rec="Active errors ($err_count) -- check error-counter.sh."
  fi
  echo "    $rec"
  echo ""
  echo "=========================================="
}

# ---------------------------------------------------------------------------
# Render: JSON mode (machine-readable)
# ---------------------------------------------------------------------------
render_json() {
  local session_data=$(collect_session_state)
  local decisions=$(collect_decisions)
  local debt=$(collect_debt)
  local comprehension=$(collect_comprehension)
  local errors=$(collect_errors)
  local challenge=$(collect_challenge)
  local git_state=$(collect_git_state)
  local gate_plugins=$(collect_gate_plugins)

  python3 -c "
import json, sys

dashboard = {
    'timestamp': $(date +%s),
    'session': json.loads('''$session_data'''),
    'git': json.loads('''$git_state'''),
    'gate_plugins': json.loads('''$gate_plugins'''),
    'comprehension_gate': json.loads('''$comprehension'''),
    'decisions': json.loads('''$decisions'''),
    'debt': json.loads('''$debt'''),
    'active_errors': json.loads('''$errors'''),
    'challenge': json.loads('''$challenge'''),
}

# Compute recommendation
rec = 'Proceed.'
if dashboard['comprehension_gate'].get('result') == 'fail':
    rec = 'Comprehension gate FAILED -- extract evidence before proceeding.'
cog = dashboard['debt'].get('cognitive', 0)
if isinstance(cog, (int, float)) and cog > 5:
    rec = f'Cognitive debt high ({cog}) -- address comprehension gaps.'
if len(dashboard['active_errors']) > 0:
    rec = f'Active errors ({len(dashboard[\"active_errors\"])}) -- check error-counter.'
dashboard['recommendation'] = rec

print(json.dumps(dashboard, indent=2))
" 2>/dev/null || echo '{"error":"dashboard render failed"}'
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if [[ "$MODE" == "--json" ]]; then
  render_json
elif [[ "$MODE" == "--watch" ]]; then
  while true; do
    clear 2>/dev/null || true
    render_normal
    echo ""
    echo "  (refreshing every 10s -- Ctrl+C to stop)"
    sleep 10
  done
else
  render_normal
fi
