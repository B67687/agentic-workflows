#!/usr/bin/env bash
# =============================================================================
# goal-tree.sh — Persistent hierarchical goal tracking
#
# Manages a tree of goals/sub-goals that persists across sessions. Every
# session reads the tree to know where we are and what the big picture is.
# When a sub-goal is done, we close it and return to the parent — never
# lose context of the macro goal.
#
# Usage:
#   bash scripts/goal-tree.sh init <title>
#   bash scripts/goal-tree.sh branch <parent-id> <title>
#   bash scripts/goal-tree.sh close [node-id]
#   bash scripts/goal-tree.sh status
#   bash scripts/goal-tree.sh current
#   bash scripts/goal-tree.h cancel [node-id]
#
# Depth limit: 8 levels maximum. Warns at depth > 4.
#
# State file: .runtime/goal-tree.json
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/.runtime"
STATE_FILE="$RUNTIME_DIR/goal-tree.json"

MAX_DEPTH=8
WARN_DEPTH=4

# ── Colors ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

usage() {
  cat <<'USAGE'
Usage: bash scripts/goal-tree.sh <command> [args]

Commands:
  init <title>               Create root goal tree
  branch <parent> <title>    Add child goal under parent
  close [node-id]            Mark goal as done, go to parent
  cancel [node-id]           Mark goal as cancelled, go to parent
  status                     Show full tree
  current                    Show active node path to root

Depth limit: 8 levels. Warn at 4+.
State: .runtime/goal-tree.json
USAGE
}

# ── Helpers ──

ensure_runtime() {
  mkdir -p "$RUNTIME_DIR"
}

load_tree() {
  if [[ -f "$STATE_FILE" ]]; then
    python3 -c "
import json
try:
    with open('$STATE_FILE') as f:
        print(json.dumps(json.load(f)))
except:
    print('{\"nodes\":{},\"root\":null,\"active\":null}')
" 2>/dev/null
  else
    echo '{"nodes":{},"root":null,"active":null}'
  fi
}

save_tree() {
  cat >"$STATE_FILE"
}

id_of_title() {
  echo "$1" | python3 -c "
import sys, re
t = sys.stdin.read().strip().lower()
t = re.sub(r'[^a-z0-9]+', '-', t)
t = re.sub(r'^-|-\$', '', t)
print(t[:60])
"
}

# ── Commands ──

cmd_init() {
  local title="$1"
  shift
  ensure_runtime

  local tree
  tree=$(load_tree)
  local root
  root=$(echo "$tree" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('root') or '')" 2>/dev/null)

  if [[ -n "$root" ]]; then
    echo -e "  ${YELLOW}Tree already exists with root: ${root}${NC}"
    echo "  Use branch to add children, or close/cancel to finish nodes."
    exit 2
  fi

  local node_id
  node_id=$(echo "$title" | python3 -c "
import sys, json, re
t = sys.stdin.read().strip().lower()
t = re.sub(r'[^a-z0-9]+', '-', t)
t = re.sub(r'^-|-\$', '', t)
print(t[:60])
")

  local ts
  ts=$(date +%s)

  local new_tree
  new_tree=$(python3 -c "
import json
d = {'nodes': {}, 'root': None, 'active': None}
node = {
    'id': '$node_id',
    'parent': None,
    'title': '$title',
    'status': 'active',
    'phase': 'none',
    'depth': 0,
    'children': [],
    'created_at': $ts,
    'closed_at': None
}
d['nodes']['$node_id'] = node
d['root'] = '$node_id'
d['active'] = '$node_id'
print(json.dumps(d, indent=2))
" 2>/dev/null)

  echo "$new_tree" | save_tree
  echo -e "  ${GREEN}✓ Root goal created: ${title}${NC}"
}

cmd_branch() {
  local parent_id="$1"
  local title="$2"
  ensure_runtime

  local tree
  tree=$(load_tree)

  # Check parent exists
  local parent_exists
  parent_exists=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print('yes' if d['nodes'].get('$parent_id') else 'no')
" 2>/dev/null)

  if [[ "$parent_exists" != "yes" ]]; then
    echo -e "  ${RED}✗ Parent node '${parent_id}' not found${NC}"
    echo "  Use 'status' to see available nodes."
    exit 1
  fi

  # Check parent depth
  local parent_depth active_status
  parent_depth=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d['nodes']['$parent_id']['depth'])
" 2>/dev/null)

  active_status=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d['nodes']['$parent_id']['status'])
" 2>/dev/null)

  if [[ "$active_status" == "done" || "$active_status" == "cancelled" ]]; then
    echo -e "  ${RED}✗ Parent '${parent_id}' is already ${active_status} — cannot add children${NC}"
    exit 1
  fi

  local child_depth=$((parent_depth + 1))

  if [[ "$child_depth" -gt "$MAX_DEPTH" ]]; then
    echo -e "  ${RED}✗ Max depth (${MAX_DEPTH}) exceeded — cannot add child${NC}"
    exit 1
  fi

  if [[ "$child_depth" -ge "$WARN_DEPTH" ]]; then
    echo -e "  ${YELLOW}⚠ Note: depth ${child_depth} exceeds recommended limit (${WARN_DEPTH}). Consider closing ancestors first.${NC}"
  fi

  local child_id
  child_id=$(echo "$title" | python3 -c "
import sys, json, re
t = sys.stdin.read().strip().lower()
t = re.sub(r'[^a-z0-9]+', '-', t)
t = re.sub(r'^-|-\$', '', t)
print(t[:60])
")

  # Ensure unique ID
  local exists
  exists=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print('yes' if d['nodes'].get('$child_id') else 'no')
" 2>/dev/null)

  if [[ "$exists" == "yes" ]]; then
    child_id="${child_id}-$(date +%s)"
  fi

  local ts
  ts=$(date +%s)

  local new_tree
  new_tree=$(python3 -c "
import json
d = json.loads('''$(echo "$tree" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)))")''')
node = {
    'id': '$child_id',
    'parent': '$parent_id',
    'title': '$title',
    'status': 'active',
    'phase': 'none',
    'depth': $child_depth,
    'children': [],
    'created_at': $ts,
    'closed_at': None
}
d['nodes']['$child_id'] = node
d['nodes']['$parent_id']['children'].append('$child_id')
d['active'] = '$child_id'
print(json.dumps(d, indent=2))
" 2>/dev/null)

  echo "$new_tree" | save_tree
  echo -e "  ${GREEN}✓ Branch created: ${title}${NC}"
  echo -e "    ${DIM}id: ${child_id} | depth: ${child_depth}/${MAX_DEPTH}${NC}"
}

cmd_close() {
  local node_id="${1:-}"

  local tree
  tree=$(load_tree)

  if [[ -z "$node_id" ]]; then
    node_id=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d.get('active') or '')
" 2>/dev/null)

    if [[ -z "$node_id" ]]; then
      echo -e "  ${RED}✗ No active node and no node-id provided${NC}"
      exit 1
    fi
  fi

  # Check node exists
  local exists
  exists=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print('yes' if d['nodes'].get('$node_id') else 'no')
" 2>/dev/null)

  if [[ "$exists" != "yes" ]]; then
    echo -e "  ${RED}✗ Node '${node_id}' not found${NC}"
    exit 1
  fi

  local ts
  ts=$(date +%s)

  local new_tree
  new_tree=$(python3 -c "
import json
d = json.loads('''$(echo "$tree" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)))")''')
node = d['nodes']['$node_id']
node['status'] = 'done'
node['closed_at'] = $ts
# Activate parent
parent_id = node.get('parent')
if parent_id:
    d['active'] = parent_id
else:
    d['active'] = None
print(json.dumps(d, indent=2))
" 2>/dev/null)

  # Get title for display
  local title
  title=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d['nodes']['$node_id']['title'])
" 2>/dev/null)

  echo "$new_tree" | save_tree

  local parent_title="(no parent — tree complete)"
  local parent_id
  parent_id=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d['nodes']['$node_id'].get('parent') or '')
" 2>/dev/null)
  if [[ -n "$parent_id" ]]; then
    parent_title=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d['nodes']['$parent_id']['title'])
" 2>/dev/null)
  fi

  echo -e "  ${GREEN}✓ Closed: ${title}${NC}"
  echo -e "    ${DIM}Returned to: ${parent_title}${NC}"
}

cmd_cancel() {
  local node_id="${1:-}"
  local tree
  tree=$(load_tree)

  if [[ -z "$node_id" ]]; then
    node_id=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d.get('active') or '')
" 2>/dev/null)
  fi

  local ts
  ts=$(date +%s)

  local new_tree
  new_tree=$(python3 -c "
import json
d = json.loads('''$(echo "$tree" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)))")''')
if '$node_id' not in d['nodes']:
    print('NOT_FOUND')
else:
    node = d['nodes']['$node_id']
    node['status'] = 'cancelled'
    node['closed_at'] = $ts
    parent_id = node.get('parent')
    if parent_id:
        d['active'] = parent_id
    else:
        d['active'] = None
    print(json.dumps(d, indent=2))
" 2>/dev/null)

  if [[ "$new_tree" == "NOT_FOUND" ]]; then
    echo -e "  ${RED}✗ Node '${node_id}' not found${NC}"
    exit 1
  fi

  echo "$new_tree" | save_tree
  echo -e "  ${YELLOW}⚠ Cancelled: ${node_id}${NC}"
}

cmd_status() {
  local tree
  tree=$(load_tree)
  echo ""

  local root
  root=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d.get('root') or '')
" 2>/dev/null)

  if [[ -z "$root" ]]; then
    echo -e "  ${YELLOW}No goal tree exists yet. Create one:${NC}"
    echo "    bash scripts/goal-tree.sh init \"<big goal title>\""
    echo ""
    return 0
  fi

  local active
  active=$(echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d.get('active') or '')
" 2>/dev/null)

  echo -e "${BOLD}═══ Goal Tree${NC}"
  echo ""

  # Print tree recursively via python3
  python3 -c "
import json

with open('$STATE_FILE') as f:
    d = json.load(f)

active_id = d.get('active', '')
root_id = d.get('root', '')

def print_node(nid, indent=0):
    if nid not in d['nodes']:
        return
    n = d['nodes'][nid]
    prefix = '  ' * indent
    status_icon = {'active': '○', 'done': '✓', 'cancelled': '✗', 'blocked': '⊘'}
    icon = status_icon.get(n['status'], '?')
    marker = '→' if nid == active_id else ' '
    depth_info = f' [d:{n[\"depth\"]}]' if n['depth'] > 0 else ''
    status_str = f' ({n[\"status\"]})' if n['status'] != 'active' else ''
    print(f'{prefix}{marker} {icon} {n[\"title\"]}{status_str}{depth_info}')
    for child in n.get('children', []):
        print_node(child, indent + 1)

if root_id:
    print_node(root_id)
else:
    print('  (empty tree)')

print()
if active_id and active_id in d['nodes']:
    print(f'  Active: {d[\"nodes\"][active_id][\"title\"]}')
    # Show path to root
    path = []
    cur = active_id
    while cur:
        if cur in d['nodes']:
            path.append(d['nodes'][cur]['title'])
            cur = d['nodes'][cur].get('parent')
        else:
            break
    path.reverse()
    print(f'  Path:  {\" → \".join(path)}')
" 2>/dev/null
}

cmd_current() {
  local tree
  tree=$(load_tree)

  local root
  root=$(echo "$tree" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('root') or '')" 2>/dev/null)

  if [[ -z "$root" ]]; then
    echo "  No goal tree."
    exit 1
  fi

  local active
  active=$(echo "$tree" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('active') or '')" 2>/dev/null)

  if [[ -z "$active" ]]; then
    echo "  No active node (tree may be complete)."
    exit 1
  fi

  echo ""
  echo -e "${BOLD}═══ Current Node${NC}"
  echo ""

  python3 -c "
import json
with open('$STATE_FILE') as f:
    d = json.load(f)

active_id = d.get('active', '')
if not active_id or active_id not in d['nodes']:
    print('  (no active node)')
else:
    n = d['nodes'][active_id]
    status_icon = {'active': '○', 'done': '✓', 'cancelled': '✗', 'blocked': '⊘'}
    icon = status_icon.get(n['status'], '?')
    print(f'  {icon} {n[\"title\"]}')
    print(f'  Depth: {n[\"depth\"]}  Status: {n[\"status\"]}  Phase: {n[\"phase\"]}')
    print(f'  Children: {len(n.get(\"children\", []))}')

    # Path to root
    path = []
    cur = active_id
    while cur:
        if cur in d['nodes']:
            path.append(d['nodes'][cur]['title'])
            cur = d['nodes'][cur].get('parent')
        else:
            break
    path.reverse()
    print(f'  Path: {\" → \".join(path)}')
" 2>/dev/null
  echo ""
}

# ── Main ──

main() {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
  init)
    local title="$*"
    if [[ -z "$title" ]]; then
      echo "Usage: bash scripts/goal-tree.sh init \"<title>\""
      exit 2
    fi
    cmd_init "$title"
    ;;
  branch)
    local parent_id="${1:-}"
    shift || true
    local title="$*"
    if [[ -z "$parent_id" || -z "$title" ]]; then
      echo "Usage: bash scripts/goal-tree.sh branch <parent-id> \"<title>\""
      exit 2
    fi
    cmd_branch "$parent_id" "$title"
    ;;
  close)
    cmd_close "${1:-}"
    ;;
  cancel)
    cmd_cancel "${1:-}"
    ;;
  status)
    cmd_status
    ;;
  current)
    cmd_current
    ;;
  *)
    usage
    exit 2
    ;;
  esac
}

main "$@"
