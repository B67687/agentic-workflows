# SwarmVault Schema

Edit this file to teach SwarmVault how this vault should be organized and maintained.

## Vault Purpose

- **Domain:** AI agent workflows, prompt engineering, tool-building for coding agents
- **Audience:** The orchestration agent (OpenCode) and its operator --- both need fast, grounded answers about what tools exist, how they work, and how they fit together
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

- **script** --- Executable scripts in `scripts/` (agent-dispatch.sh, context-pressure.sh, browser.sh, etc.)
- **command** --- Slash commands in `commands/` (pipeline.md, session.md, task.md, etc.)
- **skill** --- Agent skills in `skills/*/SKILL.md`
- **mcp_server** --- MCP servers configured in opencode.jsonc (playwright, sequential-thinking, agentmemory)
- **sandbox** --- Isolation mechanisms (.devcontainer/, agent-sandbox.sh)
- **pipeline** --- Pipeline state management and task orchestration
- **health_monitor** --- Session health and context pressure detection
- **test** --- Smoke tests and verification scripts
- **community** --- Groups of related entities forming a topic cluster (GraphRAG pattern). Communities share source_ids, relationship targets, or tags. Compiled to `wiki/communities/` when the graph is dense enough to warrant hierarchical summarization.

## Relationship Types

- **uses** --- A skill uses a script, a tool uses an MCP server
- **configures** --- opencode.jsonc configures an MCP server
- **ships_with** --- A skill ships a companion script
- **dispatches_to** --- Pipeline dispatches to an agent (pi, codex, claude)
- **monitors** --- Health monitor checks session state
- **tests** --- Smoke test verifies a tool
- **sandboxes** --- Sandbox isolates an agent operation
- **supersedes** --- A new tool supersedes an old approach
- **contains** --- A community contains entities (community -> entity)
- **related_via** --- Two entities relate through shared membership in a community (entity -> entity, via community)
- **summarizes** --- A community summary summarizes a set of entities (summary -> entity)
- Depends on

## Grounding Rules

- Prefer raw sources over summaries.
- Cite source ids whenever claims are stated.
- Do not treat the wiki as a source of truth when the raw material disagrees.

## Community Hierarchy (GraphRAG Pattern)

The knowledge graph can organize into **communities** -- clusters of related
entities. Community structure follows the GraphRAG pattern:

- **Community detection:** Groups of entities that share source_ids,
  tags, or relationship targets form a community.
- **Hierarchical levels:** Communities can nest (topics -> subtopics).
  Each level produces a summary that synthesizes its member entities.
- **Query routing:** Broad questions use community summaries (global).
  Specific questions use entity-level lookup (local).

This is a compile-time optimization: communities are pre-computed during
indexing so that query-time retrieval can choose the right scope.

Community pages live at `wiki/communities/<name>.md`. They must include
frontmatter fields: `page_id`, `community_level`, `member_ids`, `summary`.

## Exclusions

- List topics, claims, or page types the compiler should avoid generating.
