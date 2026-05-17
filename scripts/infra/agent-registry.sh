#!/usr/bin/env bash
# =============================================================================
# agent-registry.sh --- Cross-agent manifest registry
#
# Formal registry for agent properties (binary, commands dir, context format,
# capabilities). Makes adding a new agent a one-line registration call
# instead of editing multiple scripts.
#
# Usage:
#   agent-registry.sh list                    List all registered agents
#   agent-registry.sh list --available        Only installed agents
#   agent-registry.sh list --json             Machine-readable JSON
#   agent-registry.sh register <id> [opts]    Register a new agent
#   agent-registry.sh show <id>              Show agent manifest
#   agent-registry.sh find --capability <c>   Find agents with a capability
#   agent-registry.sh sync                   Refresh availability status
#   agent-registry.sh init                   Create default registry
#
# Manifest location: .runtime/agent-registry.json
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY_DIR="$REPO_ROOT/.runtime"
REGISTRY_FILE="$REGISTRY_DIR/agent-registry.json"

# Colors
USE_COLOR=true
if [[ "${NO_COLOR:-}" == "true" ]] || ! [[ -t 1 ]]; then
  USE_COLOR=false
fi
GREEN=""; CYAN=""; YELLOW=""; DIM=""; RED=""; RESET=""
if $USE_COLOR; then
  GREEN="\033[32m"; CYAN="\033[36m"; YELLOW="\033[33m"
  DIM="\033[2m"; RED="\033[31m"; RESET="\033[0m"
fi

usage() {
  cat >&2 <<'EOF'
Usage:
  agent-registry.sh list [--available|--json]
  agent-registry.sh register <id> [--binary <path>] [--commands-dir <dir>]
                        [--context-file <path>] [--context-format <fmt>]
                        [--capabilities <json>] [--install <cmd>]
                        [--description <text>]
  agent-registry.sh show <id>
  agent-registry.sh find --capability <name>
  agent-registry.sh sync
  agent-registry.sh init
EOF
  exit 1
}

# ── Registry I/O ─────────────────────────────────────────────────────────────

load_registry() {
  if [[ ! -f "$REGISTRY_FILE" ]]; then
    echo '{"version":"1.0","agents":[]}'
  else
    cat "$REGISTRY_FILE"
  fi
}

save_registry() {
  mkdir -p "$REGISTRY_DIR"
  cat > "$REGISTRY_FILE"
}

# ── Default agents ───────────────────────────────────────────────────────────

default_agents() {
  python3 << 'PYEOF'
import json
agents = [
    {
        "id": "pi",
        "name": "pi-coding-agent",
        "binary": "pi",
        "status": "unknown",
        "commands_dir": ".pi/prompts",
        "context_file": None,
        "context_format": "markdown",
        "capabilities": {
            "reasoning": ["auto", "high", "max", "non-think"],
            "formats": ["text", "json"],
            "handoff": True
        },
        "install": None,
        "description": "pi-coding-agent --- default agent for async dispatch"
    },
    {
        "id": "codex",
        "name": "Codex CLI",
        "binary": "codex",
        "status": "installable",
        "commands_dir": None,
        "context_file": ".codex/hooks.json",
        "context_format": "json",
        "capabilities": {
            "reasoning": ["auto"],
            "formats": ["text"],
            "handoff": False
        },
        "install": "npm install -g @openai/codex",
        "description": "OpenAI Codex CLI --- agentic coding in terminal"
    },
    {
        "id": "claude",
        "name": "Claude Code",
        "binary": "claude",
        "status": "installable",
        "commands_dir": None,
        "context_file": ".claude/settings.json",
        "context_format": "json",
        "capabilities": {
            "reasoning": ["auto"],
            "formats": ["text"],
            "handoff": False
        },
        "install": "npm install -g @anthropic/claude-code",
        "description": "Anthropic Claude Code --- agentic coding assistant"
    },
    {
        "id": "opencode",
        "name": "DeepSeek OpenCode",
        "binary": "opencode",
        "status": "available",
        "commands_dir": ".opencode/commands",
        "context_file": "opencode.jsonc",
        "context_format": "jsonc",
        "capabilities": {
            "reasoning": ["auto"],
            "formats": ["text"],
            "handoff": False
        },
        "install": None,
        "description": "DeepSeek OpenCode --- current primary agent"
    }
]
print(json.dumps({"version": "1.0", "agents": agents}, indent=2))
PYEOF
}

# ── Commands ─────────────────────────────────────────────────────────────────

cmd_init() {
  if [[ -f "$REGISTRY_FILE" ]]; then
    echo "Registry already exists: $REGISTRY_FILE"
    echo "Run 'agent-registry.sh sync' to refresh status."
    exit 1
  fi
  default_agents | save_registry
  echo "Created agent registry: $REGISTRY_FILE"
  echo "  Agents: pi (default), codex, claude, opencode"
  echo "Run 'agent-registry.sh sync' to check availability."
}

cmd_list() {
  local filter_available=false
  local as_json=false

  for arg in "$@"; do
    case "$arg" in
      --available) filter_available=true ;;
      --json) as_json=true ;;
    esac
  done

  local registry
  registry=$(load_registry)

  local py_filter="False"
  $filter_available && py_filter="True"

  if $as_json; then
    if $filter_available; then
      python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
data['agents'] = [a for a in data['agents'] if a.get('status') == 'available']
print(json.dumps(data, indent=2))
" <<< "$registry"
    else
      echo "$registry"
    fi
    return
  fi

  echo -e "${CYAN}Agent Registry${RESET}"
  echo -e "${DIM}File: $REGISTRY_FILE${RESET}"
  echo ""

  python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
agents = data.get('agents', [])
filter_avail = $py_filter
for a in agents:
    if filter_avail and a.get('status') != 'available':
        continue
    sid = a['id']
    sname = a.get('name', '')
    sstatus = a.get('status', 'unknown')
    sbinary = a.get('binary', '?')
    caps = a.get('capabilities', {})
    cap_str = ', '.join(k for k, v in caps.items() if v)
    desc = a.get('description', '')
    
    # Color status
    if sstatus == 'available':
        status_display = '\033[32mavailable\033[0m'
    elif sstatus == 'installable':
        status_display = '\033[33minstallable\033[0m'
    else:
        status_display = sstatus
    
    print(f'  {sid:10s}  [{status_display}]  {sbinary:12s}  {desc}')
    if caps:
        print(f'             {cap_str}')
    print()
" <<< "$registry"
}

cmd_show() {
  local id="${1:-}"
  [[ -z "$id" ]] && { echo "Usage: agent-registry.sh show <id>"; exit 1; }

  local registry
  registry=$(load_registry)

  python3 -c "
import json, sys
target = sys.argv[1]
data = json.loads(sys.stdin.read())
for a in data.get('agents', []):
    if a['id'] == target:
        print(json.dumps(a, indent=2))
        sys.exit(0)
avail = ', '.join(a['id'] for a in data.get('agents', []))
print(f'Agent \"{target}\" not found.')
print(f'Available: {avail}')
sys.exit(1)
" "$id" <<< "$registry"
}

cmd_register() {
  local id="${1:-}"
  [[ -z "$id" ]] && { echo "Usage: agent-registry.sh register <id> [options]"; exit 1; }
  shift

  local binary="" commands_dir="" context_file="" context_format="markdown"
  local capabilities='{"reasoning":["auto"],"formats":["text"],"handoff":false}'
  local install="" description=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --binary) binary="$2"; shift 2 ;;
      --commands-dir) commands_dir="$2"; shift 2 ;;
      --context-file) context_file="$2"; shift 2 ;;
      --context-format) context_format="$2"; shift 2 ;;
      --capabilities) capabilities="$2"; shift 2 ;;
      --install) install="$2"; shift 2 ;;
      --description) description="$2"; shift 2 ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
  done

  local registry
  registry=$(load_registry)

  python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
agents = data.get('agents', [])

# Check if already registered
for i, a in enumerate(agents):
    if a['id'] == '$id':
        # Update existing
        if '$binary': a['binary'] = '$binary'
        if '$commands_dir': a['commands_dir'] = '$commands_dir'
        if '$context_file': a['context_file'] = '$context_file'
        if '$context_format': a['context_format'] = '$context_format'
        if '$capabilities': a['capabilities'] = json.loads('$capabilities')
        if '$install': a['install'] = '$install'
        if '$description': a['description'] = '$description'
        a['status'] = 'available' if '$binary' and __import__('shutil').which('${binary:-none}') else 'unknown'
        print(f'Updated agent: $id')
        sys.exit(0)
    i += 1

# Add new
new_agent = {
    'id': '$id',
    'name': '$id',
    'binary': '${binary:-$id}',
    'status': 'available' if __import__('shutil').which('${binary:-$id}') else 'registered',
    'commands_dir': '${commands_dir:-null}',
    'context_file': '${context_file:-null}',
    'context_format': '$context_format',
    'capabilities': json.loads('$capabilities'),
    'install': '${install:-null}',
    'description': '${description:-Agent: $id}',
}
if new_agent['commands_dir'] == 'null': new_agent['commands_dir'] = None
if new_agent['context_file'] == 'null': new_agent['context_file'] = None
if new_agent['install'] == 'null': new_agent['install'] = None
agents.append(new_agent)
data['agents'] = agents
print(json.dumps(data, indent=2))
" <<< "$registry" > "$REGISTRY_FILE"

  echo "Registered agent: $id"
}

cmd_find() {
  local capability=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --capability) capability="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  [[ -z "$capability" ]] && { echo "Usage: agent-registry.sh find --capability <name>"; exit 1; }

  local registry
  registry=$(load_registry)

  echo -e "${CYAN}Agents with capability '${capability}':${RESET}"
  echo ""

  python3 -c "
import json, sys
target_cap = sys.argv[1]
data = json.loads(sys.stdin.read())
agents = data.get('agents', [])
found = False
for a in agents:
    caps = a.get('capabilities', {})
    if target_cap in caps and caps[target_cap]:
        desc = a.get('description', '')
        print(f'  {a[\"id\"]:10s}  [{a.get(\"status\", \"?\")}]  {a.get(\"binary\", \"?\")}')
        print(f'             {desc}')
        print()
        found = True
if not found:
    print('  No agents found.')
" "$capability" <<< "$registry"
}

cmd_sync() {
  local registry
  registry=$(load_registry)

  echo "Syncing agent registry..."
  echo ""

  # Show status + write updated JSON to registry file
  local sync_script
  sync_script=$(mktemp /tmp/agent-sync.XXXXXX.py)
  cat > "$sync_script" << 'PYEOF'
import json, sys, shutil, os
registry_file = os.environ.get('_REGISTRY_FILE', '')
data_file = os.environ.get('_SYNC_TMP', '')
with open(data_file) as f:
    data = json.load(f)

agents = data.get('agents', [])
for a in agents:
    binary = a.get('binary', '')
    old_status = a.get('status', 'unknown')
    if binary and shutil.which(binary):
        a['status'] = 'available'
    elif a.get('install'):
        a['status'] = 'installable'
    elif binary:
        a['status'] = 'unavailable'
    new_status = a['status']
    marker = '\u2713' if new_status == 'available' else '\u2717'
    print(f'  {marker} {a["id"]:10s}  {old_status:12s} -> {new_status:12s}  ({binary})')

data['version'] = '1.0'
with open(registry_file, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
print()
print(f'  Registry updated: {registry_file}')
PYEOF
  local sync_tmp
  sync_tmp=$(mktemp /tmp/agent-registry.XXXXXX.json)
  echo "$registry" > "$sync_tmp"
  _REGISTRY_FILE="$REGISTRY_FILE" _SYNC_TMP="$sync_tmp" python3 "$sync_script"
  rm -f "$sync_script" "$sync_tmp"
  echo ""
  echo "Sync complete: $REGISTRY_FILE"
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  [[ $# -lt 1 ]] && usage

  local cmd="$1"
  shift

  case "$cmd" in
    init)    cmd_init "$@" ;;
    list)    cmd_list "$@" ;;
    show)    cmd_show "$@" ;;
    register) cmd_register "$@" ;;
    find)    cmd_find "$@" ;;
    sync)    cmd_sync "$@" ;;
    help|--help|-h) usage ;;
    *) echo "Unknown command: $cmd"; usage ;;
  esac
}

main "$@"
