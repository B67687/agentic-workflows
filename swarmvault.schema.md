# SwarmVault Schema

Edit this file to teach SwarmVault how this vault should be organized and maintained.

## Vault Purpose

- **Domain:** AI agent workflows, prompt engineering, tool-building for coding agents
- **Audience:** The orchestration agent (OpenCode) and its operator — both need fast, grounded answers about what tools exist, how they work, and how they fit together
- **Key questions the vault should answer:**
  - What scripts/tools are available in the workspace and what do they do?
  - What skills are installed and what companion scripts do they ship?
  - What sandboxing, dispatch, and health-monitoring infrastructure exists?
  - How are pipelines triggered, dispatched, and collected?
  - What MCP servers are configured and what capabilities do they provide?

## Naming Conventions

- Prefer stable, descriptive page titles matching the tool name (e.g., "scripts/sandbox" not "isolation-tool")
- Keep concept and entity names specific to the workspace domain
- Tool names use the hyphenated form from their filename (e.g., `agent-sandbox`, `agent-dispatch`, `context-pressure`)

## Page Structure Rules

- Source pages should stay grounded in the original material (AGENTS.md, session-state.json)
- Concept and entity pages should aggregate source-backed claims instead of inventing new ones
- Preserve contradictions instead of smoothing them away
- Every tool concept page should include: purpose, usage, companion files, and verification status

## Categories

- **script** — Executable scripts in `scripts/` (agent-dispatch.sh, context-pressure.sh, browser.sh, etc.)
- **command** — Slash commands in `commands/` (pipeline.md, session.md, task.md, etc.)
- **skill** — Agent skills in `skills/*/SKILL.md`
- **mcp_server** — MCP servers configured in opencode.jsonc (playwright, sequential-thinking, agentmemory)
- **sandbox** — Isolation mechanisms (.devcontainer/, agent-sandbox.sh)
- **pipeline** — Pipeline state management and task orchestration
- **health_monitor** — Session health and context pressure detection
- **test** — Smoke tests and verification scripts

## Relationship Types

- **uses** — A skill uses a script, a tool uses an MCP server
- **configures** — opencode.jsonc configures an MCP server
- **ships_with** — A skill ships a companion script
- **dispatches_to** — Pipeline dispatches to an agent (pi, codex, claude)
- **monitors** — Health monitor checks session state
- **tests** — Smoke test verifies a tool
- **sandboxes** — Sandbox isolates an agent operation
- **supersedes** — A new tool supersedes an old approach
- Depends on

## Grounding Rules

- Prefer raw sources over summaries.
- Cite source ids whenever claims are stated.
- Do not treat the wiki as a source of truth when the raw material disagrees.

## Exclusions

- List topics, claims, or page types the compiler should avoid generating.
