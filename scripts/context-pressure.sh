#!/bin/bash
# =============================================================================
# context-pressure.sh — Session health monitor
#
# Measures signals that indicate context degradation or session rot:
#   - Session duration (from session-state.json)
#   - Dirty file accumulation (uncommitted changes)
#   - Commit frequency (proxy for turn count)
#   - session-state.json staleness
#
# Outputs a compact health report with actionable recommendations.
#
# Usage:
#   bash ./scripts/context-pressure.sh          # full health report
#   bash ./scripts/context-pressure.sh --check  # exit 1 if unhealthy
#   bash ./scripts/context-pressure.sh --json   # machine-readable output
#   bash ./scripts/context-pressure.sh --persist# compute + save to session-state
#   bash ./scripts/context-pressure.sh --auto   # persist + compact if critical
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$REPO_ROOT/session-state.json"

NOW=$(date +%s)
MODE="${1:-}"

# --- Session duration ---
SESSION_AGE_HOURS=0
if [ -f "$STATE_FILE" ]; then
    STATE_MTIME=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo "$NOW")
    SESSION_AGE_HOURS=$(( (NOW - STATE_MTIME) / 3600 ))
else
    STATE_MTIME=$NOW
fi

# --- Commit count today ---
TODAY=$(date -u +%Y-%m-%d)
COMMITS_TODAY=$(git log --oneline --after="$TODAY 00:00:00" 2>/dev/null | wc -l | tr -d ' ')

# --- Dirty files ---
DIRTY_COUNT=$(git status --short 2>/dev/null | wc -l | tr -d ' ')

# --- Dirty files by type ---
DIRTY_NEW=$(git status --short 2>/dev/null | grep -c "^??" || true)
DIRTY_MODIFIED=$(git status --short 2>/dev/null | grep -c "^ M\|^M " || true)

# --- contextPressure from session state ---
CONTEXT_PRESSURE="unknown"
if [ -f "$STATE_FILE" ]; then
    CONTEXT_PRESSURE=$(python3 -c "
import json
try:
    s = json.load(open('$STATE_FILE'))
    print(s.get('contextPressure', 'unknown'))
except:
    print('unknown')
" 2>/dev/null || echo "unknown")
fi

# --- Health assessment ---
SCORE=0
RECOMMENDATIONS=()

# Signal 1: Session age
if [ "$SESSION_AGE_HOURS" -gt 4 ]; then
    SCORE=$((SCORE + 2))
    RECOMMENDATIONS+=("Session is ${SESSION_AGE_HOURS}h old — consider checkpoint + fresh session")
elif [ "$SESSION_AGE_HOURS" -gt 2 ]; then
    SCORE=$((SCORE + 1))
    RECOMMENDATIONS+=("Session is ${SESSION_AGE_HOURS}h old — approaching context rot threshold")
fi

# Signal 2: Dirty files
if [ "$DIRTY_COUNT" -gt 20 ]; then
    SCORE=$((SCORE + 2))
    RECOMMENDATIONS+=("$DIRTY_COUNT uncommitted files — checkpoint before they grow stale")
elif [ "$DIRTY_COUNT" -gt 10 ]; then
    SCORE=$((SCORE + 1))
    RECOMMENDATIONS+=("$DIRTY_COUNT uncommitted files — consider checkpointing")
fi

# Signal 3: Commits (proxy for turn count — lots of commits = long session)
if [ "$COMMITS_TODAY" -gt 15 ]; then
    SCORE=$((SCORE + 1))
    RECOMMENDATIONS+=("$COMMITS_TODAY commits today — high activity, context may be fragmented")
fi

# Signal 4: Context pressure from state file
if [ "$CONTEXT_PRESSURE" = "high" ]; then
    SCORE=$((SCORE + 3))
    RECOMMENDATIONS+=("Context pressure is HIGH — compact immediately (bash ./scripts/hooks/pre-compact.sh then ask agent to compact)")
elif [ "$CONTEXT_PRESSURE" = "medium" ]; then
    SCORE=$((SCORE + 1))
    RECOMMENDATIONS+=("Context pressure is medium — prepare to compact soon")
fi

# --- Determine health status ---
if [ $SCORE -ge 4 ]; then
    STATUS="CRITICAL"
elif [ $SCORE -ge 2 ]; then
    STATUS="WARNING"
else
    STATUS="HEALTHY"
fi

# --- Persist metrics to session-state.json ---
persist_metrics() {
    python3 -c "
import json, os
state_file = '$STATE_FILE'
now = '$NOW'
metrics = {
    'status': '$STATUS',
    'score': $SCORE,
    'signals': {
        'session_age_hours': $SESSION_AGE_HOURS,
        'commits_today': $COMMITS_TODAY,
        'dirty_count': $DIRTY_COUNT,
        'dirty_new': $DIRTY_NEW,
        'dirty_modified': $DIRTY_MODIFIED,
        'context_pressure': '$CONTEXT_PRESSURE'
    },
    'timestamp': $NOW
}

if os.path.exists(state_file):
    with open(state_file) as f:
        data = json.load(f)
else:
    data = {}

# Update contextPressure
data['contextPressure'] = '$STATUS'.lower()

# Update or create metrics history
if 'contextMetrics' not in data:
    data['contextMetrics'] = {'history': []}

# Keep last 20 measurements
data['contextMetrics']['last'] = metrics
data['contextMetrics']['history'].append(metrics)
data['contextMetrics']['history'] = data['contextMetrics']['history'][-20:]

# Compute trend: is pressure increasing?
history = data['contextMetrics']['history']
if len(history) >= 3:
    recent = [h['score'] for h in history[-3:]]
    trend = 'increasing' if recent[-1] > recent[0] else ('stable' if recent[-1] == recent[0] else 'decreasing')
else:
    trend = 'insufficient_data'
data['contextMetrics']['trend'] = trend

with open(state_file, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
" 2>/dev/null || true
}

# --- Auto-action at CRITICAL pressure ---
auto_compact() {
    echo "=== Auto-Compact Triggered ==="
    echo "Context pressure score: $SCORE (CRITICAL)"
    echo ""
    
    # Run pre-compact hook
    if [ -f "$REPO_ROOT/scripts/hooks/pre-compact.sh" ]; then
        bash "$REPO_ROOT/scripts/hooks/pre-compact.sh"
    fi
    
    # Recommend action
    echo ""
    echo "RECOMMENDED ACTIONS (in order):"
    echo "  1. Commit or stash all changes:"
    echo "     bash ./scripts/checkpoint-commit.sh -m \"checkpoint before compaction\""
    echo "  2. Start a fresh session with compact context"
    echo ""
    echo "  If context is still manageable, run:"
    echo "    bash ./scripts/context-pressure.sh --check  # verify health"
}

# --- Output ---
case "$MODE" in
  --json)
    python3 -c "
import json
print(json.dumps({
    'status': '$STATUS',
    'score': $SCORE,
    'signals': {
        'session_age_hours': $SESSION_AGE_HOURS,
        'commits_today': $COMMITS_TODAY,
        'dirty_count': $DIRTY_COUNT,
        'dirty_new': $DIRTY_NEW,
        'dirty_modified': $DIRTY_MODIFIED,
        'context_pressure': '$CONTEXT_PRESSURE'
    },
    'recommendations': $(printf '%s\n' "${RECOMMENDATIONS[@]:-}" | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))" 2>/dev/null || echo '[]')
}, indent=2))
"
    ;;
  --check)
    if [ "$STATUS" = "CRITICAL" ]; then
        echo "[health] CRITICAL — context pressure needs action"
        exit 1
    fi
    echo "[health] $STATUS"
    exit 0
    ;;
  --persist)
    persist_metrics
    echo "[health] Metrics persisted to session-state.json"
    ;;
  --auto)
    persist_metrics
    if [ "$STATUS" = "CRITICAL" ]; then
        auto_compact
        exit 1
    fi
    echo "[health] $STATUS — context pressure manageable"
    exit 0
    ;;
  *)
    echo "=== Session Health: $STATUS ==="
    echo ""
    echo "Signals:"
    echo "  Session age:   ${SESSION_AGE_HOURS}h (thresholds: >2h warn, >4h critical)"
    echo "  Commits today: $COMMITS_TODAY"
    echo "  Dirty files:   $DIRTY_COUNT ($DIRTY_NEW new, $DIRTY_MODIFIED modified)"
    echo "  contextPressure: $CONTEXT_PRESSURE (from session-state.json)"
    echo ""
    if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
        echo "Recommendations:"
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo "  → $rec"
        done
        echo ""
    fi
    echo "Actions:"
    echo "  bash ./scripts/context-pressure.sh --json  # machine-readable"
    echo "  bash ./scripts/context-pressure.sh --check # exit code check"
    echo "  bash ./scripts/hooks/pre-compact.sh        # save snapshot before compacting"
    echo "  bash ./scripts/checkpoint-commit.sh -m 'msg'  # checkpoint before refresh"
    echo "========================================"
    ;;
esac
