#!/usr/bin/env bash
# =============================================================================
# daily-session.sh — Daily session overview in one command
#
# Shows goal tree status, recent changelog, current branch state, and
# recent commits in a single compact view. Run at session start to get
# oriented quickly.
#
# Usage:
#   bash scripts/daily-session.sh     # show full overview
#   bash scripts/daily-session.sh --compact  # minimal output
#   bash scripts/daily-session.sh --help
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODE="${1:-overview}"

case "$MODE" in
--help | -h)
  sed -n 's/^# //p; s/^#$//p' "$0"
  exit 0
  ;;
--compact)
  COMPACT=true
  ;;
*)
  COMPACT=false
  ;;
esac

echo "═══════════════════════════════════════"
echo "  Daily Session Overview"
echo "═══════════════════════════════════════"
echo ""

# ── Active goal ──
echo "── Goal ──"
python3 -c "
import json
try:
    with open('$REPO_ROOT/.runtime/goal-tree.json') as f:
        d = json.load(f)
    active = d.get('active', '')
    nodes = d.get('nodes', {})
    if active and active in nodes:
        n = nodes[active]
        path = []
        cur = active
        while cur:
            if cur in nodes:
                path.insert(0, nodes[cur]['title'][:70])
                cur = nodes[cur].get('parent')
            else:
                break
        print('  → '.join(path))
        # Show meso goal progress from root children
        root_id = d.get('root', '')
        if root_id and root_id in nodes:
            root_children = nodes[root_id].get('children', [])
            done_ct = sum(1 for s in root_children if s in nodes and nodes[s].get('status') == 'done')
            active_ct = sum(1 for s in root_children if s in nodes and nodes[s].get('status') == 'active')
            total = len(root_children)
            print(f'  ({done_ct}/{total} meso goals done, {active_ct} active)')
    else:
        print('  (no active goal)')
except:
    print('  (no goal tree)')
" 2>/dev/null

echo ""

# ── Git state ──
echo "── Git ──"
echo "  Branch: $(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
echo "  HEAD:   $(git -C "$REPO_ROOT" log --oneline -1 2>/dev/null || echo '?')"
modified=$(git -C "$REPO_ROOT" status --short 2>/dev/null | wc -l | tr -d ' ')
if [[ "$modified" -gt 0 ]]; then
  echo "  Dirty:  $modified file(s) modified"
fi

# Check sync status
ahead=$(git -C "$REPO_ROOT" rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
behind=$(git -C "$REPO_ROOT" rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
if [[ "$ahead" -gt 0 || "$behind" -gt 0 ]]; then
  echo "  Sync:   +$ahead/-$behind (ahead/behind origin)"
fi
echo ""

# ── Session changelog ──
echo "── Recent Changes ──"
if [[ -f "$REPO_ROOT/.runtime/session-changelog.jsonl" ]]; then
  python3 -c "
import json
entries = []
with open('$REPO_ROOT/.runtime/session-changelog.jsonl') as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try: entries.append(json.loads(line))
        except: continue

if entries:
    for i, e in enumerate(entries[-3:]):
        ts = e.get('timestamp', '?')[:10]
        fc = e.get('files_changed', 0)
        ins = e.get('insertions', 0)
        del_ = e.get('deletions', 0)
        print(f'  {ts}  {fc} files  +{ins}/-{del_}')
else:
    print('  (no changelog)')
" 2>/dev/null
else
  echo "  (no changelog yet)"
fi
echo ""

# ── Recent commits ──
echo "── Recent Commits ──"
git -C "$REPO_ROOT" log --oneline -5 2>/dev/null | sed 's/^/  /' || echo "  (none)"
echo ""

# ── Suggested next ──
echo "── Quick Commands ──"
echo "  Check goals:    bash scripts/goal-tree.sh status"
echo "  Full changelog: bash scripts/session-changelog.sh show"
echo "  Run smoke:      bash scripts/infra/test-smoke.sh"
echo "  Dashboard:      bash scripts/tools/session-dashboard.sh"
echo "═══════════════════════════════════════"
