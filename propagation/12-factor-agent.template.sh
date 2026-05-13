#!/usr/bin/env bash
# =============================================================================
# 12-factor-agent.template.sh --- Scaffold a new 12-factor agent project
#
# Propagation template: Run this in an empty directory to create a new agent.
# Adapted from scripts/create-hl-agent.sh for propagation system.
#
# Usage:
#   bash ./propagation/12-factor-agent.template.sh my-agent-name
#
# 12-Factor Principles covered:
#   F2: AGENTS.md operating contract
#   F3: session-state.json context management
#   F5/F12: Unified state + stateless reducer (events array)
#   F7: a2h-contact.sh human contact protocol
#   F11: (inbound triggers pending)
#   F13: prefetch-context.sh deterministic pre-fetch
# =============================================================================

set -euo pipefail

AGENT_NAME="${1:-}"

if [ -z "$AGENT_NAME" ]; then
  echo "Usage: bash ./propagation/12-factor-agent.template.sh <agent-name>"
  echo ""
  echo "Creates a new 12-factor agent project in the current directory."
  echo "Rename the <agent-name> directory after creation."
  exit 2
fi

TARGET_DIR="$AGENT_NAME"

if [ -d "$TARGET_DIR" ]; then
  echo "ERROR: target directory already exists: $TARGET_DIR"
  exit 2
fi

echo "Creating 12-factor agent: $AGENT_NAME"
echo ""

# Directory structure
mkdir -p "$TARGET_DIR/scripts" "$TARGET_DIR/docs" "$TARGET_DIR/.runtime/a2h" "$TARGET_DIR/.runtime/notifications"

# AGENTS.md (F2)
cat > "$TARGET_DIR/AGENTS.md" << 'EOF'
# {{AGENT_NAME}} --- 12-Factor Agent

## Operating Contract

This agent follows the [12-Factor Agents](https://github.com/humanlayer/12-factor-agents)
methodology for building reliable LLM applications.

### Principles

1. **Natural Language -> Tool Calls** --- Route requests to structured handlers
2. **Own Your Prompts** --- This file is your first prompt. Own it.
3. **Own Your Context Window** --- session-state.json is your state. AGENTS.md is your rules.
4. **Tools Are Structured Outputs** --- Every script is a documented tool.
5. **Unify Execution + Business State** --- One source of truth: session-state.json
6. **Launch/Pause/Resume** --- Checkpoints enable clean resume anywhere.
7. **Contact Humans with Tools** --- a2h-contact.sh for human-in-the-loop.
8. **Own Your Control Flow** --- scripts/ define explicit execution paths.
9. **Compact Errors** --- Log errors, add them to context, self-heal.
10. **Small, Focused Agents** --- Each script does one thing well.
11. **Trigger from Anywhere** --- (inbound triggers pending implementation)
12. **Stateless Reducer** --- state = reducer(state, event). Events are append-only.
13. **Pre-Fetch All Context** --- prefetch-context.sh runs before LLM turns.

### Available Tools

| Tool | Purpose |
|------|---------|
| `scripts/a2h-contact.sh` | Contact humans (questions + approvals) |
| `scripts/prefetch-context.sh` | Deterministic context pre-fetch |
| `scripts/checkpoint.sh` | Save state checkpoint |

### Rules

- Read session-state.json first on every resume
- Update session-state.json after every meaningful change
- Use a2h-contact.sh for all human interactions
- Pre-fetch context before every significant LLM turn
EOF

# session-state.json (F5/F12)
cat > "$TARGET_DIR/session-state.json" << 'EOF'
{
  "session": 1,
  "status": "active",
  "contextPressure": "low",
  "currentTask": {
    "name": "Initialize {{AGENT_NAME}}",
    "status": "in_progress"
  },
  "whatChanged": [],
  "filesTouched": [],
  "verification": [],
  "immediateNextSteps": [
    "Read AGENTS.md --- the operating contract"
  ],
  "events": []
}
EOF

echo "  [F2] AGENTS.md --- operating contract"
echo "  [F5/F12] session-state.json --- unified state + events"

# Replace placeholder
sed -i "s/{{AGENT_NAME}}/$AGENT_NAME/g" "$TARGET_DIR/AGENTS.md" 2>/dev/null || true
sed -i "s/{{AGENT_NAME}}/$AGENT_NAME/g" "$TARGET_DIR/session-state.json" 2>/dev/null || true

touch "$TARGET_DIR/.runtime/a2h/.gitkeep" "$TARGET_DIR/.runtime/notifications/.gitkeep"
echo "  [F7] .runtime/a2h/ --- A2H contact queue directory"

echo ""
echo "✅ 12-factor agent created: $AGENT_NAME"
echo ""
echo "Next steps:"
echo "  cd $AGENT_NAME"
echo "  cat AGENTS.md         # read the operating contract"
echo ""
echo "Add these scripts from the hub to complete the setup:"
echo "  cp ../scripts/a2h-contact.sh scripts/"
echo "  cp ../scripts/error-counter.sh scripts/"
echo "  cp ../scripts/prefetch-context.sh scripts/"
echo "  chmod +x scripts/*.sh"
