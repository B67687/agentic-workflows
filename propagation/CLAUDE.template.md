<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: CLAUDE -->
# Project Instructions

This file bridges Claude Code with the project's operating contract.

@AGENTS.md

## Quick Start

- Read `session-state.json` first on every resume to understand current session context
- Run `bash ./scripts/git-session-start.sh` for branch status on session start
- Use `commands/` for slash commands (task, plan, implement, research, session, etc.)

## Key Documents

| File | Purpose |
|------|---------|
| `AGENTS.md` | Full operating contract and principles |
| `session-state.json` | Active session state and context |
| `docs/workflow.md` | Workflow summary (if exists) |
| `buglog.json` | Past bugs and fixes |

## Commit Protocol

After any meaningful change, run:
```bash
bash ./scripts/checkpoint-commit.sh -m "summary of changes"
```

Never leave verified work uncommitted.
