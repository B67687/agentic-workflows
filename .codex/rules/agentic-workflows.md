---
description: Agentic Workflows harness operating contract for Codex CLI.
---

# Agentic Workflows --- Operating Contract

This project is an agent harness, not a code project. Read the full contract at `AGENTS.md`.

## Key Rules for Codex CLI

- **No new files** if an existing doc covers the need
- **Verify aggressively** --- verification is the quality engine
- **Summarize work** as root cause, fix, verification, residual risk
- **Read session-state.json first** on every resume
- **Commit after every meaningful change** --- use `bash ./scripts/checkpoint-commit.sh -m "summary"`
- **Batch file reads to 3 at a time** --- memory pressure on 4GB WSL2
- **Map before broad reading** --- use `bash ./scripts/repo-map.sh`

## Startup Order

1. `session-state.json` --- active session state
2. `AGENTS.md` --- full operating contract
3. `docs/workflow.md` --- workflow summary
4. Task-specific files only when needed

## Startup Hook

On session start, `.codex/hooks.json` fires:
- `swarmvault-graph-first.js` --- loads SwarmVault graph report into context

See `AGENTS.md` for the complete operating contract.
