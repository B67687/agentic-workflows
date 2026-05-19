#!/usr/bin/env bash
# =============================================================================
# generate-handover.sh — Auto-generate HANDOVER.md from live state
#
# Reads workflow-state.json + goal-tree.json + git log to produce a compact
# (≤200 line) handover document. Uses section markers so permanent content
# (north star, key links) survives regeneration.
#
# Usage:
#   bash scripts/generate-handover.sh [--output PATH] [--target repo]
#
# Options:
#   --output PATH     Write to PATH (default: auto-detect)
#   --target repo     pi-star or agentic-workflows
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$REPO_ROOT/workflow-state.json"
GOAL_TREE_FILE="$RUNTIME_DIR/goal-tree.json"

# ── Detect target ──
TARGET=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --output)
    OUTPUT="$2"
    shift 2
    ;;
  --target)
    TARGET="$2"
    shift 2
    ;;
  *)
    echo "Unknown: $1"
    exit 2
    ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  if [[ -d "$REPO_ROOT/../pi-star" ]]; then
    TARGET="pi-star"
  else
    TARGET="agentic-workflows"
  fi
fi

if [[ -z "$OUTPUT" ]]; then
  if [[ "$TARGET" == "pi-star" ]]; then
    OUTPUT="$REPO_ROOT/../pi-star/HANDOVER.md"
  else
    OUTPUT="$REPO_ROOT/HANDOVER.md"
  fi
fi

# ── Section markers ──
MARKER_START="<!-- session-data:start -->"
MARKER_END="<!-- session-data:end -->"

# ── Collect dynamic data ──

# Goal tree
GOAL_TREE_TEXT=$(python3 -c "
import json
try:
    with open('$GOAL_TREE_FILE') as f:
        d = json.load(f)
except:
    print('  (no goal tree)'); exit(0)

root_id = d.get('root')
active_id = d.get('active')
lines = []
if root_id and root_id in d.get('nodes', {}):
    def print_node(nid, indent=0):
        if nid not in d['nodes']: return
        n = d['nodes'][nid]
        icon = {'active': '○', 'done': '✓', 'cancelled': '✗'}.get(n['status'], '?')
        ss = f' ({n[\"status\"]})' if n['status'] != 'active' else ''
        marker = '→' if nid == active_id else ' '
        depth_tag = f' [d:{n[\"depth\"]}]' if n['depth'] > 0 else ''
        lines.append(f\"{marker} {icon} {'  '*indent}{n['title']}{ss}{depth_tag}\")
        for c in n.get('children', []): print_node(c, indent+1)
    print_node(root_id)
if active_id and active_id in d.get('nodes', {}):
    path = []; cur = active_id
    while cur:
        if cur in d['nodes']: path.append(d['nodes'][cur]['title'][:60]); cur = d['nodes'][cur].get('parent')
        else: break
    path.reverse()
    lines.append(''); lines.append('  Path: ' + ' → '.join(path))
print('\n'.join(lines))
" 2>/dev/null) || GOAL_TREE_TEXT="  (no goal tree)"

# Workflow state
WORKFLOW_TEXT=$(python3 -c "
import json
try:
    with open('$STATE_FILE') as f: s = json.load(f)
    print(f'  Workflow: {s.get(\"workflow\") or \"none\"}  Step: {s.get(\"step\") or \"none\"}  Trace: {len(s.get(\"trace\", []))} entries')
except:
    print('  (no workflow state)')
" 2>/dev/null) || WORKFLOW_TEXT="  (no workflow state)"

# Commits and state
COMMITS=$(git log --oneline -5 2>/dev/null | sed 's/^/  /' || echo "  (no commits)")
UNCOMMITTED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "none")

# Pi-Star state
PI_STAR_DIR="$REPO_ROOT/../pi-star"
PS_BRANCH=""
PS_LAST=""
if [[ -d "$PI_STAR_DIR" ]]; then
  PS_BRANCH=$(cd "$PI_STAR_DIR" && git rev-parse --abbrev-ref HEAD 2>/dev/null) || PS_BRANCH=""
  PS_LAST=$(cd "$PI_STAR_DIR" && git log --oneline -1 2>/dev/null) || PS_LAST=""
fi

# Trace summary
TRACE_SUMMARY=$(python3 -c "
import json
try:
    with open('$STATE_FILE') as f: s = json.load(f)
    trace = s.get('trace', [])
    if trace:
        lines = [f\"- {t.get('step', t.get('action', 'step'))}: {t.get('result', str(t.get('summary', '')))[:100]}\" for t in trace[-5:]]
        print('\n'.join(lines))
    else:
        print('(no trace entries)')
except:
    print('(no trace)')
" 2>/dev/null)

# Active goal
ACTIVE_GOAL=$(python3 -c "
import json
try:
    with open('$GOAL_TREE_FILE') as f: d = json.load(f)
    active = d.get('active')
    if active and active in d.get('nodes', {}):
        n = d['nodes'][active]
        path = []; cur = active
        while cur:
            if cur in d['nodes']: path.insert(0, d['nodes'][cur]['title'][:50]); cur = d['nodes'][cur].get('parent')
            else: break
        print(' → '.join(path))
    else:
        print('(no active node — start a new branch)')
except:
    print('(no goal tree)')
" 2>/dev/null) || ACTIVE_GOAL="(no goal tree)"

# Entry prompt summary line
ENTRY_SUMMARY=$(python3 -c "
import json
with open('$GOAL_TREE_FILE') as f: d = json.load(f)
active = d.get('active')
if active and active in d.get('nodes', {}):
    n = d['nodes'][active]
    done_ct = sum(1 for nd in d['nodes'].values() if nd.get('status') == 'done' and nd.get('parent') is not None)
    active_ct = sum(1 for nd in d['nodes'].values() if nd.get('status') == 'active' and nd.get('depth', 0) <= 1)
    print(f'{done_ct} meso goals done, {active_ct} active. Active: {n[\"title\"]}')
else:
    print('All goals complete — start a new branch')
" 2>/dev/null) || ENTRY_SUMMARY="See goal tree below"

# ── Record changelog entry for this session ──
CHANGELOG_SCRIPT="$REPO_ROOT/scripts/session-changelog.sh"
if [[ -f "$CHANGELOG_SCRIPT" ]]; then
  bash "$CHANGELOG_SCRIPT" record 2>/dev/null || true
fi

# ── Build dynamic section ──
DYNAMIC=$(
  cat <<DYNAMICEOF
## Current State

| Repo | Branch | Last Commit |
|------|--------|-------------|
| agentic-workflows | $BRANCH | $LAST_COMMIT |
$([[ -n "$PS_BRANCH" ]] && echo "| pi-star | $PS_BRANCH | $PS_LAST |")

Changes: $UNCOMMITTED modified, $UNTRACKED untracked

$WORKFLOW_TEXT

## Goal Tree

\`\`\`
$GOAL_TREE_TEXT
\`\`\`

## Last Session Summary

$TRACE_SUMMARY

## Session Changes

$([[ -f "$REPO_ROOT/.runtime/session-changelog.jsonl" ]] && bash "$REPO_ROOT/scripts/session-changelog.sh" show 2>/dev/null || echo "  (no changelog)")

## Next

$ACTIVE_GOAL

\`\`\`bash
# Quick start
bash scripts/goal-tree.sh current   # see where you are
bash scripts/goal-tree.sh status    # full tree
bash scripts/goal-tree.sh branch <parent> "<title>"  # start new work
\`\`\`

## Recent Commits

\`\`\`
$COMMITS
\`\`\`

## Entry Prompt

Copy this block to the top of the next session:

\`\`\`
Read HANDOVER.md for complete context before responding.

Current state: $ENTRY_SUMMARY

All pushed to origin/main.

The next session follows the research→plan→implement→verify cycle.
Browse the goal tree and branch into the next item:

  bash scripts/goal-tree.sh current   # active path
  bash scripts/goal-tree.sh status    # full tree
  bash scripts/goal-tree.sh branch <parent> \"<title>\"  # start new work
  bash scripts/workflow-check.sh      # validate state
\`\`\`
DYNAMICEOF
)

# ── Merge: keep permanent content, replace dynamic section ──

if [[ -f "$OUTPUT" ]] && grep -q "$MARKER_START" "$OUTPUT" 2>/dev/null; then
  # Replace between markers — permanent content survives
  python3 -c "
import sys
with open('$OUTPUT') as f:
    content = f.read()
start_marker = '$MARKER_START'
end_marker = '$MARKER_END'
dynamic = '''$DYNAMIC'''

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx >= 0 and end_idx > start_idx:
    before = content[:start_idx + len(start_marker)]
    after = content[end_idx:]
    result = before + '\n' + dynamic + '\n' + after
    with open('$OUTPUT', 'w') as f:
        f.write(result)
    print('  Replaced dynamic section between markers')
else:
    print('  ERROR: markers not found in existing file')
    sys.exit(1)
" 2>/dev/null
else
  # No existing file or no markers — create full file with markers
  cat >"$OUTPUT" <<HEADEREOF
# Session Handover — $(date +%Y-%m-%d)

## North Star

> Build the best agent harness based on research — studying existing tools as
> data points, letting evidence dictate architecture. Governed by phase-discipline
$([[ "$TARGET" == "pi-star" ]] && echo "> methodology. Cheap enough to self-iterate. Used to build the next version." || echo "> methodology.")

**Strategy**: OpenCode (agentic-workflows) is the development harness. Design
and harden concepts there first, then port patterns to Pi-Star's extension
architecture. Goal: strengthen both until Pi-Star can self-iterate, then shift.

$MARKER_START
$DYNAMIC
$MARKER_END

## Key Links

| Doc | Location |
|-----|----------|
| Goal tree | \`.runtime/goal-tree.json\` |
| Workflow state | \`workflow-state.json\` |
| Architecture | \`ARCHITECTURE.md\` (pi-star) |
| Determinism framework | \`docs/determinism-framework.md\` |
HEADEREOF
  echo "  Created new file with section markers"
fi

echo "✅ Generated: $OUTPUT ($(wc -l <"$OUTPUT") lines)"
