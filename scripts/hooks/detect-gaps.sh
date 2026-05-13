#!/usr/bin/env bash
# =============================================================================
# detect-gaps.sh --- SessionStart lifecycle hook
# Detects common workspace hygiene gaps:
#   1. BM25 index stale or missing -> auto-heals if HEAL=1
#   2. session-state.json stale or missing
#   3. Uncommitted work that should be checkpointed
#   4. Propagation sync drift
#   5. Stale learnings file
#   6. Expired assumptions
#   7. Context pressure status
#   8. Skill completeness gaps
#   9. Archive file size thresholds
#
# Non-blocking --- reports findings, exits 0.
# Set HEAL=1 to auto-fix regeneratable artifacts (BM25 index).
#   Example: HEAL=1 bash ./scripts/hooks/detect-gaps.sh
# Compatible with: Claude Code (via hooks.json), manual invocation, AGENTS.md
# =============================================================================

set -euo pipefail

FOUND_GAP=false

report_gap() {
    local severity="$1" message="$2"
    FOUND_GAP=true
    if [ "$severity" = "WARN" ]; then
        echo "  ⚠  $message"
    else
        echo "  ℹ   $message"
    fi
}

echo "=== Gap Detection ==="

# ---- Check 1: BM25 Index Freshness (auto-heals if HEAL=1) ----
INDEX_DIR=".cache/bm25-index"
INDEX_FILE="$INDEX_DIR/index.bm25"  # bm25s creates this
if [ -d "$INDEX_DIR" ]; then
    # Find newest file in workspace to compare
    NEWEST_FILE=$(find . -path ./.git -prune -o -path ./.cache -prune -o -type f -print 2>/dev/null | head -1000 | xargs stat -c %Y 2>/dev/null | sort -rn | head -1 || echo 0)
    NEWEST_INDEX=$(find "$INDEX_DIR" -type f -exec stat -c %Y {} + 2>/dev/null | sort -rn | head -1 || echo 0)
    if [ "$NEWEST_FILE" -gt "$NEWEST_INDEX" ] 2>/dev/null; then
        if [ "${HEAL:-0}" = "1" ]; then
            echo "  ⚡  BM25 index stale --- auto-rebuilding..."
            bash ./scripts/build-index.sh 2>/dev/null && echo "  ✓  BM25 index rebuilt" || echo "  ⚠  BM25 index rebuild failed (run: bash ./scripts/build-index.sh)"
        else
            report_gap "WARN" "BM25 index is stale. Run: HEAL=1 bash ./scripts/hooks/detect-gaps.sh"
        fi
    else
        echo "  ✓  BM25 index is current"
    fi
else
    if [ "${HEAL:-0}" = "1" ]; then
        echo "  ⚡  BM25 index missing --- auto-building..."
        bash ./scripts/build-index.sh 2>/dev/null && echo "  ✓  BM25 index created" || echo "  ⚠  BM25 index build failed (run: bash ./scripts/build-index.sh)"
    else
        report_gap "WARN" "BM25 index missing. Run: HEAL=1 bash ./scripts/hooks/detect-gaps.sh"
    fi
fi

# ---- Check 2: Session State Health ----
STATE_FILE="session-state.json"
if [ -f "$STATE_FILE" ]; then
    NOW=$(date +%s)
    STATE_MTIME=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)
    AGE_HOURS=$(( (NOW - STATE_MTIME) / 3600 ))
    if [ "$AGE_HOURS" -gt 24 ]; then
        report_gap "WARN" "session-state.json is $AGE_HOURS hours old --- may be stale"
    fi
    # Check if interruptedCount suggests a crashed session
    INTERRUPTED=$(python3 -c "
import json
try:
    s = json.load(open('$STATE_FILE'))
    print(s.get('interruptedCount', 0))
except: print(0)
" 2>/dev/null || echo 0)
    if [ "$INTERRUPTED" -gt 0 ] && [ "$INTERRUPTED" -lt 3 ]; then
        report_gap "ℹ" "session-state.json has $INTERRUPTED interruption(s) --- may need attention"
    fi
else
    report_gap "WARN" "session-state.json not found"
fi

# ---- Check 3: Uncommitted Work ----
DIRTY=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
if [ "$DIRTY" -gt 10 ]; then
    report_gap "WARN" "Large dirty worktree ($DIRTY changes, $UNTRACKED untracked). Consider checkpointing."
elif [ "$DIRTY" -gt 0 ]; then
    echo "  ℹ   $DIRTY uncommitted change(s), $UNTRACKED untracked"
fi

# ---- Check 4: Propagation Sync ----
PROP_CONTRACT="scripts/propagation-contract.sh"
if [ -f "$PROP_CONTRACT" ]; then
    # Quick check: do propagated repos have recent sync?
    PROP_DIRS=$(find propagation -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    if [ "$PROP_DIRS" -gt 0 ]; then
        echo "  ℹ   $PROP_DIRS propagation target(s) configured"
        # Check most recent sync across all targets
        LATEST_PROP=$(find propagation -name ".sync-timestamp" -exec cat {} + 2>/dev/null | sort -rn | head -1 || echo "never")
        if [ "$LATEST_PROP" = "never" ]; then
            report_gap "ℹ" "No propagation sync timestamps found. Run: bash ./scripts/propagate-to-all.sh"
        fi
    fi
fi

# ---- Check 5: Learnings freshness ----
LEARNINGS=".learnings.jsonl"
if [ -f "$LEARNINGS" ]; then
    NOW=$(date +%s)
    LEARN_MTIME=$(stat -c %Y "$LEARNINGS" 2>/dev/null || echo 0)
    LEARN_AGE_DAYS=$(( (NOW - LEARN_MTIME) / 86400 ))
    if [ "$LEARN_AGE_DAYS" -gt 14 ]; then
        report_gap "ℹ" ".learnings.jsonl not updated in $LEARN_AGE_DAYS days"
    fi
fi

# ---- Check 6: Assumption Expiry ----
if [ -f "session-state.json" ]; then
    OVERDUE=$(python3 -c "
import json
from datetime import datetime, timezone
now = datetime.now(timezone.utc)
with open('session-state.json') as f:
    data = json.load(f)
overdue = 0
for a in data.get('assumptions', []):
    if a.get('status') == 'dismissed':
        continue
    expires = a.get('expiresAt', None)
    if not expires:
        overdue += 1
        continue
    try:
        exp = datetime.fromisoformat(expires.replace('Z', '+00:00'))
        if (exp - now).days <= 0:
            overdue += 1
    except:
        overdue += 1
print(overdue)
" 2>/dev/null || echo 0)
    if [ "$OVERDUE" -gt 0 ]; then
        report_gap "WARN" "$OVERDUE assumption(s) expired. Run: bash ./scripts/assumption-expiry.sh check"
    else
        echo "  ℹ   Assumption expiry check --- all current"
    fi
fi

# ---- Check 7: Context Pressure Monitoring ----
if [ -f "session-state.json" ]; then
    PRESS_STATUS=$(python3 -c "
import json
with open('session-state.json') as f:
    data = json.load(f)
cm = data.get('contextMetrics', {})
s = cm.get('last', {}).get('status', 'unknown')
t = cm.get('trend', 'unknown')
h = len(cm.get('history', []))
print(f'{s}|{t}|{h}')
" 2>/dev/null || echo "unknown|unknown|0")
    
    PRESS_STATUS_VAL=$(echo "$PRESS_STATUS" | cut -d'|' -f1)
    PRESS_TREND=$(echo "$PRESS_STATUS" | cut -d'|' -f2)
    PRESS_COUNT=$(echo "$PRESS_STATUS" | cut -d'|' -f3)
    
    if [ "$PRESS_STATUS_VAL" = "critical" ]; then
        report_gap "WARN" "Context pressure CRITICAL --- run: bash ./scripts/context-pressure.sh --auto"
    elif [ "$PRESS_STATUS_VAL" = "warning" ]; then
        echo "  ℹ   Context pressure: WARNING (trend: $PRESS_TREND, $PRESS_COUNT measurements)"
    else
        echo "  ℹ   Context pressure: healthy ($PRESS_COUNT measurements tracked)"
    fi
fi

# ---- Check 8: Skill Completeness ----
SKILL_MISSING=$(python3 -c "
import os
d = [s for s in os.listdir('skills') 
     if os.path.isdir(os.path.join('skills', s)) 
     and not any(f != 'SKILL.md' and f != 'manifest.json' 
                 for f in os.listdir(os.path.join('skills', s)))
     and os.path.exists(os.path.join('skills', s, 'SKILL.md'))]
for s in d:
    print(s)
" 2>/dev/null)
SKILL_COUNT=$(echo "$SKILL_MISSING" | grep -c . 2>/dev/null) || SKILL_COUNT=0
if [ "$SKILL_COUNT" -gt 0 ]; then
    echo "  ℹ   $SKILL_COUNT skill(s) missing companion scripts:"
    echo "$SKILL_MISSING" | head -5 | while read -r s; do echo "       $s"; done
    if [ "$SKILL_COUNT" -gt 5 ]; then
        echo "       ... and $(($SKILL_COUNT - 5)) more"
    fi
fi

# ---- Check 9: Hot-path File Size Budget ----
# Archive files are intentionally cold storage --- excluded.
# Only hot-path files (read on every session) need a budget.
HOTPATH_THRESHOLD_KB=300
for f in AGENTS.md docs/workflow.md session-state.json; do
    if [ -f "$f" ]; then
        SIZE_KB=$(du -k "$f" | cut -f1)
        if [ "$SIZE_KB" -gt "$HOTPATH_THRESHOLD_KB" ] 2>/dev/null; then
            report_gap "WARN" "$f is ${SIZE_KB}KB (budget: ${HOTPATH_THRESHOLD_KB}KB). Consider compacting."
        fi
    fi
done

# ---- Check 10: Inbox Classification ----
INBOX_FILES=$(find inbox -type f -not -name '.gitkeep' 2>/dev/null)
if [ -n "$INBOX_FILES" ]; then
    COUNT=$(echo "$INBOX_FILES" | wc -l)
    report_gap "WARN" "$COUNT file(s) in inbox/ need classification. See docs/structural-governance.md"
    echo "$INBOX_FILES" | while read -r f; do
        echo "       $f"
    done
else
    echo "  ✓  inbox/ is empty"
fi

# ---- Check 11: Error Handling Regressions ----
# Scans active scripts for missing error handling patterns (non-blocking).
# Excludes propagation templates and raw/sources (intentionally exempt).
ERROR_HANDLING_ISSUES=0
while IFS= read -r f; do
    issues=0
    grep -qE '^\s*set\s+-[a-z]*e' "$f" 2>/dev/null || issues=$((issues + 1))
    grep -qE '^\s*set\s+-[a-z]*u' "$f" 2>/dev/null || issues=$((issues + 1))
    grep -qE 'pipefail' "$f" 2>/dev/null || issues=$((issues + 1))
    if [ "$issues" -gt 0 ]; then
        ERROR_HANDLING_ISSUES=$((ERROR_HANDLING_ISSUES + 1))
        [ "$ERROR_HANDLING_ISSUES" -le 5 ] && report_gap "WARN" "$f is missing error handling components"
    fi
done < <(find . -name '*.sh' -not -path './.git/*' -not -path './propagation/*' -not -path './raw/*' -not -path './.bench-runs/*' -not -path './.opencode/*' 2>/dev/null)

if [ "$ERROR_HANDLING_ISSUES" -gt 0 ]; then
    if [ "$ERROR_HANDLING_ISSUES" -gt 5 ]; then
        report_gap "WARN" "plus $(($ERROR_HANDLING_ISSUES - 5)) more script(s) with missing error handling"
    fi
    echo "       Run: bash ./scripts/hooks/quality-gate.sh (pre-commit check)"
else
    echo "  ✓  Error handling patterns: all active scripts comply"
fi

# ---- Summary ----
echo ""
if [ "$FOUND_GAP" = true ]; then
    echo "Gaps detected --- address as needed. None are blocking."
else
    echo "✓  No gaps detected --- workspace is healthy."
fi
echo "=== End Gap Detection ==="
