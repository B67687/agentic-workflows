# Agent System Evaluation & MCP Research

**Date:** 2026-04-24
**Purpose:** Honest assessment of the current 7-subagent system and MCP adoption feasibility.

---

## Part 1: Subagent Cost/Benefit Analysis

### Current State

The hub defines 7 subagents:

| Subagent | Model | Role | Cost |
|----------|-------|------|------|
| Explorer | M2.5 Free | Search / discovery | **Free** |
| Planner | M2.7 | Plan / design / analyze | Flat rate |
| Scribe | M2.5 Free | Document / write docs | **Free** |
| Drafter | M2.7 | Write / create / implement | Flat rate |
| Gardener | M2.5 Free | File ops / organize | **Free** |
| Debugger | M2.7 | Debug / fix / investigate | Flat rate |
| Reviewer | M2.7 | Review / verify / audit | Flat rate |

Orchestrator handles tasks directly with K2.6 by default, escalating to M2.7 or Sonnet 4.6 only when needed.

### The Honest Problem

**The specialization is fake.**

- Planner, Drafter, Debugger, and Reviewer all use **the same model** (M2.7).
- The only differences are their system prompts and the task framing.
- A single M2.7 instance can plan, draft, debug, and review. The "role" is just a prompt wrapper.

**The real value is fresh context.**

When a subagent is spawned, it gets a clean conversation with no accumulated degradation. This IS valuable for long sessions. But we don't need 7 different agents to get fresh context — we just need the ability to spawn a fresh context when needed.

### Cost Reality

| Tier | Model | Cost | When Used |
|------|-------|------|-----------|
| Direct | K2.6 | $0 extra | Default for everything |
| Fresh context | M2.7 | Flat rate (Go) | When context is degraded |
| Escalation | Sonnet 4.6 | Pay-as-you-go ($3+/session) | Security or repeated failure |

The current three-tier fallback (direct → M2.7 → Sonnet) is **financially sound**. The problem is the overhead of choosing among 7 agents when 90% of tasks should be handled directly anyway.

### Usage Patterns (Inferred)

Based on the routing table and thresholds:

- **90%+ of tasks** should be handled directly by K2.6 (the Orchestrator)
- **5-8%** might benefit from fresh context (large searches, complex drafts)
- **<2%** need true escalation (security, repeated failures)

With this distribution, maintaining 7 distinct agents is overhead without proportional benefit.

### Recommendation: Simplify to 3 Roles

| Role | Model | When to Spawn | Why Keep |
|------|-------|---------------|----------|
| **Explorer** | M2.5 Free | Large searches (>10 files), complex grep patterns | Search is genuinely different from synthesis. M2.5 Free is actually free. |
| **Drafter** | M2.7 | New file/module creation, multi-file refactors | Fresh context helps for large writes. Same model as direct, but clean slate. |
| **Analyst** | M2.7 | Second opinion on debug/review, security concerns | Merged Debugger+Reviewer. Fresh context for verification. |

**Eliminate:** Planner, Scribe, Gardener.

- **Planner** → Direct handling by K2.6 is sufficient. Complex plans can be broken into steps and executed directly.
- **Scribe** → Direct writing by K2.6 is sufficient. The "specialization" added no model capability.
- **Gardener** → File operations under 10 files should be direct. Bulk operations are rare enough to warrant a fresh-context spawn of Drafter or direct execution.

### Alternative: Keep Definitions, Change Behavior

If removing agent definitions is disruptive (requires propagating to 25 topic folders), keep all 7 definitions but make the Orchestrator **much more aggressive** about direct handling:

- Only spawn Explorer for searches that genuinely exceed 10+ files
- Only spawn Drafter for new files/modules
- Never spawn Planner/Scribe/Gardener unless explicitly requested
- Merge Debugger+Reviewer behavior into a single "spawn fresh context" pattern

This preserves the taxonomy for rare cases without paying the cognitive overhead on every task.

### Migration Path

1. **Immediate:** Update AGENTS.md and docs/agentic-workflows.md to recommend direct handling for Planner/Scribe/Gardener tasks
2. **Short-term:** Merge Debugger and Reviewer definitions into a single Analyst definition
3. **Medium-term:** Remove Planner, Scribe, Gardener agent files; update propagation templates
4. **Long-term:** Evaluate whether even Explorer and Drafter are worth the spawn overhead vs. direct handling with periodic context compression

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

### Recommendation: Phased Adoption

**Phase 1: Consumer (Immediate, Low Effort)**

Add MCP server configuration to `opencode.json` or a separate `mcp.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "M:/M-Namikaz-Others"]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"]
    }
  }
}
```

This gives immediate benefit: safer file ops, standardized git commands.

**Phase 2: Provider (Short-term, Medium Effort)**

Build a lightweight MCP server in Python or Node.js that wraps the hub scripts:

```python
# Pseudo-code for hub MCP server
@mcp.tool()
def propagate_templates(apply: bool = False) -> str:
    """Propagate templates to all topic folders."""
    result = subprocess.run(
        ["pwsh", "-File", "scripts/propagate-to-all.ps1"]
        + (["-Apply"] if apply else []),
        capture_output=True, text=True
    )
    return result.stdout

@mcp.tool()
def audit_quality(folder: str = ".") -> dict:
    """Run quality audit on specified folder."""
    # ... implementation
```

**Phase 3: Integration (Medium-term)**

- Replace direct script invocations in `ws.ps1` with MCP tool calls where appropriate
- Use memory server for cross-session persistence
- Document MCP setup in `docs/repo-tooling.md`

### Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| MCP spec is still evolving | Stick to stable tools (filesystem, git). Avoid experimental servers. |
| Adds dependency on Node.js/npm | Both are already available in the user's environment. |
| Over-engineering for a single user | Start with Phase 1 (consumer only). Phase 2 only if multi-client usage is desired. |
| Security of filesystem server | Restrict to `M:/M-Namikaz-Others` only. Never allow root access. |

### Verdict

**MCP is worth adopting, but gradually.**

- **Phase 1 (consumer)** is low-risk, immediate value. Do it.
- **Phase 2 (provider)** is high-value if the user wants to use multiple AI clients (Claude Desktop, Cursor, etc.) with the same hub workflows. Defer until that need is real.
- **Phase 3 (full integration)** is long-term optimization. Only after Phases 1-2 are stable.

The hub's current PowerShell-based automation is not obsolete — MCP complements it by providing a standardized interface layer. Keep the scripts; add MCP as an optional frontend.

---

## Summary

| System | Verdict | Action |
|--------|---------|--------|
| 7-subagent taxonomy | **Over-engineered** | Simplify to 3 roles (Explorer, Drafter, Analyst) or make Orchestrator more aggressive about direct handling |
| MCP adoption | **Worth it, gradually** | Phase 1 (consumer) immediately; Phase 2 (provider) when multi-client need arises |
| Current scripts | **Keep** | Add MCP as interface layer, don't replace |

---

*This evaluation should be revisited in 3 months or after 10+ sessions with any new configuration.*
