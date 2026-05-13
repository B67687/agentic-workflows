#!/usr/bin/env bash
# =============================================================================
# create-hl-agent.sh --- Scaffold a new 12-factor agent project
#
# Creates a ready-to-use agent project with all 12-factor-agent patterns:
#   - Operating contract (F2: own your prompts)
#   - State management (F5/F12: unified state + stateless reducer)
#   - Context retrieval (F3/F13: own your context + pre-fetch)
#   - Human-in-the-loop (F7: contact humans with tools)
#   - Notifications (F11: trigger from anywhere)
#
# Usage:
#   bash ./scripts/create-hl-agent.sh my-agent-name
#   bash ./scripts/create-hl-agent.sh my-agent-name --path /custom/path
#
# Reference: docs/12-factor-agents-integration.md
# =============================================================================

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: create-hl-agent.sh <agent-name> [options]

Create a new 12-factor agent project in the current directory.

Options:
  --path <dir>   Create the project in a specific directory
  --help, -h     Show this help
EOF
}

AGENT_NAME="${1:-}"
shift 2>/dev/null || true
TARGET_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) TARGET_PATH="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
done

if [ -z "$AGENT_NAME" ]; then
  echo "ERROR: agent name is required." >&2
  usage >&2
  exit 2
fi

# Determine target directory
if [ -z "$TARGET_PATH" ]; then
  TARGET_PATH="./$AGENT_NAME"
fi

if [ -d "$TARGET_PATH" ]; then
  echo "ERROR: target directory already exists: $TARGET_PATH" >&2
  exit 2
fi

echo "Creating 12-factor agent: $AGENT_NAME"
echo "  at: $TARGET_PATH"
echo ""

# --- Create directory structure ---
mkdir -p "$TARGET_PATH/scripts"
mkdir -p "$TARGET_PATH/docs"
mkdir -p "$TARGET_PATH/.runtime/a2h"
mkdir -p "$TARGET_PATH/.runtime/notifications"

# --- AGENTS.md (Factor 2: Own your prompts) ---
cat > "$TARGET_PATH/AGENTS.md" <<AGENTSEOF
# $AGENT_NAME --- 12-Factor Agent

<!-- 12-Factor Agent: Own your prompts (F2), Own your context (F3) -->

## Operating Contract

This agent follows the [12-Factor Agents](https://github.com/humanlayer/12-factor-agents)
methodology:

1. **Natural Language -> Tool Calls** --- Routes requests to structured handlers
2. **Own Your Prompts** --- This file is your first prompt. Every tool is documented.
3. **Own Your Context Window** --- session-state.json tracks state. AGENTS.md provides rules.
4. **Tools Are Structured Outputs** --- Each script is a tool with documented inputs/outputs.
5. **Unify Execution + Business State** --- session-state.json is the single source of truth.
6. **Launch/Pause/Resume** --- session-state.json + git checkpoints enable clean resume.
7. **Contact Humans with Tools** --- scripts/a2h-contact.sh for agent-to-human communication.
8. **Own Your Control Flow** --- scripts/ define the execution flow explicitly.
9. **Compact Errors** --- Error logs feed back into context for self-healing.
10. **Small, Focused Agents** --- Each script does one thing well.
11. **Trigger from Anywhere** --- (inbound triggers pending implementation)
12. **Stateless Reducer** --- state = reducer(state, event). session-state.json is append-only.
13. **Pre-Fetch All Context** --- scripts/prefetch-context.sh fetches deterministically.

## Key Scripts

| Tool | Description |
|------|-------------|
| \`scripts/a2h-contact.sh\` | Contact humans (F7) --- contact, approve, respond, list |
| \`scripts/error-counter.sh\` | Error counter (F9) --- increment, check, reset, context, escalate |
| \`scripts/prefetch-context.sh\` | Deterministic pre-fetch (F13) --- XML, JSON, compact |
| \`scripts/checkpoint.sh\` | Save state (F5, F12) --- commit session + changes |

## Rules

- Read session-state.json first on every resume
- Write session-state.json after every meaningful change
- Use a2h-contact.sh for all human interactions
- Pre-fetch context before every significant LLM turn
AGENTSEOF

# --- session-state.json (Factor 5: Unify state, Factor 12: Stateless reducer) ---
cat > "$TARGET_PATH/session-state.json" <<SESSIONEOF
{
  "session": 1,
  "status": "active",
  "contextPressure": "low",
  "currentTask": {
    "name": "Initialize $AGENT_NAME",
    "status": "in_progress"
  },
  "whatChanged": [],
  "filesTouched": [],
  "verification": [],
  "immediateNextSteps": [
    "Review AGENTS.md --- the operating contract",
    "Run: bash scripts/prefetch-context.sh --compact"
  ],
  "events": []
}
SESSIONEOF

# --- scripts/a2h-contact.sh (Factor 7: Contact humans with tools) ---
cp "$REPO_ROOT/scripts/a2h-contact.sh" "$TARGET_PATH/scripts/a2h-contact.sh"
chmod +x "$TARGET_PATH/scripts/a2h-contact.sh"

# --- scripts/error-counter.sh (Factor 9: Compact errors + escalate) ---
cp "$REPO_ROOT/scripts/error-counter.sh" "$TARGET_PATH/scripts/error-counter.sh"
chmod +x "$TARGET_PATH/scripts/error-counter.sh"

# --- scripts/prefetch-context.sh (Factor 13: Pre-fetch all context) ---
cp "$REPO_ROOT/scripts/prefetch-context.sh" "$TARGET_PATH/scripts/prefetch-context.sh"
chmod +x "$TARGET_PATH/scripts/prefetch-context.sh"

# --- scripts/checkpoint.sh (Factor 5/12: State management) ---
cat > "$TARGET_PATH/scripts/checkpoint.sh" << 'CHECKPOINTEOF'
#!/usr/bin/env bash
# checkpoint.sh --- Save agent state (12-factor F5/F12)
# Usage: bash ./scripts/checkpoint.sh <summary>
set -euo pipefail

SUMMARY="${1:-checkpoint}"

# Append event to session-state.json
python3 -c "
import json, sys
from datetime import datetime, timezone

state = json.load(open('session-state.json'))
event = {
    'timestamp': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
    'summary': '$SUMMARY',
    'filesChanged': state.get('filesTouched', [])[-3:]
}
state.setdefault('events', []).append(event)
json.dump(state, open('session-state.json', 'w'), indent=2)
print('Checkpoint recorded: ' + event['timestamp'])
"
CHECKPOINTEOF
chmod +x "$TARGET_PATH/scripts/checkpoint.sh"

# --- docs/README.md --- Project overview ---
cat > "$TARGET_PATH/README.md" <<READMEEOF
# $AGENT_NAME

A [12-Factor Agent](https://github.com/humanlayer/12-factor-agents).

## Quick Start

\`\`\`bash
# Check current state
cat session-state.json | head -20

# Pre-fetch context
bash ./scripts/prefetch-context.sh --compact

# Create a human contact (asks a question, waits for response)
bash ./scripts/a2h-contact.sh contact "What should I do first?" --urgency medium --channel cli

# Request approval for a high-stakes operation
bash ./scripts/a2h-contact.sh approve "deploy" '{"env":"production"}' --urgency high --channel cli
\`\`\`

## Structure

\`\`\`
$AGENT_NAME/
├── AGENTS.md              <- Operating contract (read first)
├── session-state.json     <- Unified state (events array for replay)
├── scripts/
│   ├── a2h-contact.sh     <- Contact humans (question + approval)
│   ├── error-counter.sh   <- Error counter + escalation
│   ├── prefetch-context.sh <- Deterministic context pre-fetch
│   └── checkpoint.sh      <- State checkpoint
├── .runtime/a2h/          <- A2H contact queue
├── .runtime/notifications/ <- Notification log
└── README.md
\`\`\`

## 12-Factor Principles

See \`AGENTS.md\` for the full principles reference.

| Factor | Local Implementation |
|--------|---------------------|
| F1 (NL->Tools) | This README + AGENTS.md |
| F2 (Own prompts) | AGENTS.md |
| F3 (Own context) | session-state.json |
| F4 (Tools = structured outputs) | scripts/ |
| F5 (Unify state) | session-state.json |
| F6 (Launch/Pause/Resume) | git + session-state.json |
| F7 (Contact humans) | scripts/a2h-contact.sh |
| F8 (Own control flow) | scripts/checkpoint.sh |
| F9 (Compact errors) | scripts/error-counter.sh |
| F10 (Small focused) | Each script does one thing |
| F10 (Small focused) | Each script does one thing |
| F11 (Trigger anywhere) | (inbound pending) |
| F12 (Stateless reducer) | session-state.json events |
| F13 (Pre-fetch context) | scripts/prefetch-context.sh |
READMEEOF

# --- .gitkeep files for empty dirs ---
touch "$TARGET_PATH/.runtime/a2h/.gitkeep"
touch "$TARGET_PATH/.runtime/notifications/.gitkeep"

echo ""
echo "✅ 12-factor agent created: $AGENT_NAME"
echo ""
echo "  cd $TARGET_PATH"
echo "  cat AGENTS.md         # read the operating contract"
echo "  bash scripts/prefetch-context.sh --compact  # quick orientation"
echo "  bash scripts/a2h-contact.sh help            # human contact help"
echo ""
echo "Reference: docs/12-factor-agents-integration.md"
