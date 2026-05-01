# Agent System Evaluation & MCP Research

**Date:** 2026-04-24
**Status:** SUPERSEDED — Historical decision record only. The current system is the bash-first, four-system architecture documented in `docs/agentic-workflows.md`, `docs/cross-project-memory-loop.md`, and `docs/workspace-system-overview.md`.

**Purpose:** Honest assessment of the original 7-subagent system and early MCP adoption ideas. Kept for decision history, not as current implementation guidance.

---

## Part 1: Subagent Cost/Benefit Analysis (Historical)

### Original State (7 Agents)

The hub originally defined 7 subagents:

| Subagent | Model | Role | Cost |
|----------|-------|------|------|
| Explorer | M2.5 Free | Search / discovery | **Free** |
| Planner | M2.7 | Plan / design / analyze | Flat rate |
| Scribe | M2.5 Free | Document / write docs | **Free** |
| Drafter | M2.7 | Write / create / implement | Flat rate |
| Gardener | M2.5 Free | File ops / organize | **Free** |
| Debugger | M2.7 | Debug / fix / investigate | Flat rate |
| Reviewer | M2.7 | Review / verify / audit | Flat rate |

### The Honest Problem

**The specialization was fake.**

- Planner, Drafter, Debugger, and Reviewer all used **the same model** (M2.7).
- The only differences were their system prompts and task framing.
- A single M2.7 instance can plan, draft, debug, and review. The "role" was just a prompt wrapper.

**The real value was fresh context.**

When a subagent was spawned, it got a clean conversation with no accumulated degradation. This IS valuable for long sessions. But we didn't need 7 different agents to get fresh context — we just needed the ability to spawn a fresh context when needed.

### What Changed (April 2026)

The cost landscape collapsed:
- Copilot Student = free Sonnet 4.6
- Gemini AI Studio = 14,400 free req/day
- K2.6 = ~3,450 req/5hr during 3× promotion

**The per-request cost difference between "cheap" and "premium" became zero.**

### Final Simplification: 2 Agents

| Agent | Model | When to Spawn |
|-------|-------|---------------|
| **Explorer** | M2.5 Free | Large searches (>10 files), complex grep |
| **Worker** | Same as Orchestrator (K2.6) | Fresh context for long sessions, parallel work |

**Eliminated:** Planner, Scribe, Gardener, Drafter, Analyst, Debugger, Reviewer.

- **Planner/Scribe/Gardener** → Direct handling by Orchestrator is sufficient
- **Drafter/Analyst/Debugger/Reviewer** → Merged into Worker. All were just "do work with fresh context"

---

## Part 2: MCP (Model Context Protocol) Research

### What is MCP?

MCP is an open standard by Anthropic for connecting AI applications to external data sources and tools. Think of it as **"USB-C for AI"** — a standardized way for models to discover and use external capabilities.

### Core Concepts

| Concept | What It Is | Example |
|---------|-----------|---------|
| **Tools** | Functions the model can call | `read_file`, `git_commit`, `search_code` |
| **Resources** | Data sources the model can access | Files, databases, APIs |
| **Prompts** | Reusable templates | "Analyze this code for security issues" |

### Reference Servers (Official)

| Server | Purpose | Relevance to This Hub |
|--------|---------|----------------------|
| `mcp-server-filesystem` | Safe file operations | **High** — could replace direct file tool usage |
| `mcp-server-git` | Git operations | **High** — could standardize git workflow |
| `mcp-server-memory` | Persistent knowledge graph | **Medium** — could supplement session-state.json |
| `mcp-server-fetch` | Web fetching | **Medium** — could standardize research fetching |
| `mcp-server-sequential-thinking` | Structured reasoning | **Low** — we already have reasoning guides |
| `mcp-server-time` | Time/date utilities | **Low** — trivial utility |

### Ecosystem Support

MCP is supported by:
- Claude Desktop (native)
- Cursor (via configuration)
- VS Code Copilot (preview)
- Windsurf (via plugins)
- Continue.dev
- Any client implementing the MCP spec

### How This Repo Could Use MCP

#### As a Consumer (Use MCP Servers)

**High-value integrations:**

1. **Filesystem Server**
   - Safer file operations with explicit allowlists
   - Could replace direct `read`/`edit`/`write` tool calls with MCP-mediated operations
   - Benefit: Standardized permissions, audit trail

2. **Git Server**
   - Standardized git operations (commit, diff, branch, PR)
   - Could replace `scripts/ws.ps1` git invocations
   - Benefit: Consistent git behavior across different AI clients

3. **Memory Server**
   - Persistent knowledge graph across sessions
   - Could supplement `workflow/session-state.json` with semantic memory
   - Benefit: Cross-session learning without manual state management

**Medium-value integrations:**

4. **Fetch Server**
   - Standardized web fetching for research
   - Could replace ad-hoc `webfetch` calls
   - Benefit: Consistent research methodology across tools

#### As a Provider (Expose as MCP Server)

This is the **more interesting** direction for this hub.

The propagation, audit, and cross-domain harvesting systems could be exposed as an **MCP server** that any AI agent can use:

| Hub Function | MCP Tool Name | What It Does |
|-------------|---------------|--------------|
| `propagate-to-all.ps1` | `propagate_templates` | Sync templates to all topic folders |
| `audit-folder-quality.ps1` | `audit_quality` | Run quality audit on a folder |
| `harvest-topic-insights.ps1` | `harvest_insights` | Collect lessons from topic folders |
| `build-cross-domain-candidates.ps1` | `build_candidates` | Generate cross-domain promotion queue |
| `merge-and-propagate.ps1` | `merge_candidate` | Merge approved lesson and propagate |
| `check-sync-status.ps1` | `check_sync_status` | Check propagation freshness |

**Benefits of exposing as MCP server:**

1. **Any AI can use it.** Not just OpenCode Desktop. Claude Desktop, Cursor, Windsurf, etc. could all propagate templates and harvest insights.
2. **Standardized interface.** No need to teach each agent about PowerShell scripts.
3. **Composable.** Other MCP servers could build on top of hub operations.

### Feasibility Assessment

**Requirements:**
- Node.js 18+ or Python 3.10+
- npm or uvx (Python package manager)
- The user's environment has WSL with Python3 and npm — feasible

**Effort:**

| Approach | Effort | Value |
|----------|--------|-------|
| Consume filesystem + git servers | Low (configuration only) | Medium |
| Build hub MCP server (Node.js) | Medium (1-2 days) | High |
| Build hub MCP server (Python) | Medium (1-2 days) | High |
| Both consume + provide | Medium-High (2-3 days) | Very High |

### MCP Adoption Status

**Phase 1 (Consumer) — ATTEMPTED AND ROLLED BACK**

Added `mcpServers` configuration to `opencode.json`:
```json
"mcpServers": {
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "M:/M-Namikaz-Others"]
  }
}
```

**Result:** OpenCode Desktop does **not** recognize the `mcpServers` key. Config had no effect. Commented out pending native MCP support.

**Phase 2 (Provider) — DEFERRED**

Building an MCP server to expose hub scripts (propagate, audit, harvest) remains a good idea, but only when:
- OpenCode Desktop supports MCP, OR
- Multi-client usage becomes real (Claude Desktop, Cursor, etc.)

**Verdict:** MCP is promising but not yet usable in this workflow. Revisit when OpenCode adds native MCP support.

---

## Summary

| System | Original Verdict | Final Action |
|--------|-----------------|--------------|
| 7-subagent taxonomy | Over-engineered | **Simplified to 2 agents** (Explorer + Worker) |
| MCP adoption | Worth it gradually | **Rolled back** — OpenCode Desktop doesn't support MCP yet |
| Current scripts | Keep | **Historical only** — the current source of truth is the bash automation under `scripts/*.sh` |

---

*This evaluation is kept for decision history. The current system is documented in `docs/agentic-workflows.md`.*
