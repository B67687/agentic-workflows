# MCP Architecture Reference

## What This Is

A compact reference for how MCP (Model Context Protocol) fits in this workspace --- what we use, what we don't, and what patterns exist in the ecosystem worth knowing about.

---

## Current Surface

Our MCP configuration lives in `~/.config/opencode/opencode.jsonc` under the `mcp` key:

| MCP Server | Purpose | Enabled |
|------------|---------|---------|
| `sequential-thinking` | Structured multi-step reasoning | Yes |
| `agentmemory` | Cross-session persistent memory (auto-capture + search) | Yes |

Both run as local commands via `npx`. No remote MCP servers, no custom MCP server running from this repo.

---

## MCP Philosophy in This Repo

**Native-first, MCP as supplement.** Documented in `docs/repo-tooling.md`:

- Use native CLI tools (`rg`, `fd`, `bash jq`, `git`) over MCP equivalents for speed
- MCP is appropriate for: reasoning aids (sequential-thinking), persistence (agentmemory), and any capability without a fast native alternative
- Do not wrap working native tools in MCP --- it adds latency with no benefit

---

## Reference: UI-TARS-desktop's MCP-Native Architecture

ByteDance's [UI-TARS-desktop](https://github.com/bytedance/UI-TARS-desktop) (Apache 2.0, 32k★) provides a reference architecture where **MCP is the agent kernel**, not a bolt-on:

```
┌─────────────────────────────┐
│        Agent TARS           │
│  ┌───────────────────────┐  │
│  │     MCP Client        │──┼──-> Unified MCP transport (in-memory,
│  │  (@agent-infra/       │  │     stdio, SSE, Streamable HTTP)
│  │   mcp-client)         │  │
│  └──────────┬────────────┘  │
│             │               │
│  ┌──────────▼────────────┐  │
│  │   MCP Servers         │  │
│  │  ┌──────────────────┐ │  │
│  │  │ browser-use       │ │  │
│  │  │ computer-use      │ │  │
│  │  │ filesystem        │ │  │
│  │  │ search            │ │  │
│  │  │ shell             │ │  │
│  │  └──────────────────┘ │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Key patterns worth knowing about:**

| Pattern | In UI-TARS | In This Repo |
|---------|-----------|-------------|
| MCP as agent kernel | All tool routing, model calls, context streaming go through MCP | MCP is a supplement (2 servers) |
| Multi-transport support | Single `MCPClient` class handles in-memory, stdio, SSE, HTTP | Single transport (local stdio via `npx`) |
| Tool filtering | Glob-based allow/block lists per server | Not needed yet |
| Custom MCP server | `@agent-infra/mcp-servers` package (filesystem, search, shell, etc.) | None written yet |

**Relevance:** If we ever need to expose hub functionality (propagation, audit, harvesting) programmatically to external agents, their `@agent-infra/mcp-client` package shows the cleanest pattern --- a unified client with pluggable transports. Their `MCPClient` with filter support is a reference for how to do this without coupling to any specific transport.

---

## Extension Points

These are speculative --- not planned work, just documented patterns for when the need arises:

1. **Hub MCP server** --- Expose propagation, audit, harvesting as MCP tools. The original analysis (`archive/research/agent-system-evaluation.md#as-a-provider`) has a detailed table. This is worth doing when an external agent needs to consume hub services.

2. **Multi-transport MCP client** --- If we ever run agents across hosts, the multi-transport pattern from `@agent-infra/mcp-client` avoids rewriting tool access per transport.

3. **MCP tool filtering** --- If we accumulate many MCP servers, glob-based allow/block per server prevents tool namespace collisions.

---

## Related Docs

| Topic | Doc |
|-------|-----|
| Native vs MCP tool choice | `docs/repo-tooling.md` |
| Original MCP research (historical) | `archive/research/agent-system-evaluation.md` |
| MCP code context retrieval | `docs/token-efficient-prompting.md` |
| UI-TARS SDK guide | [@ui-tars/sdk](https://github.com/bytedance/UI-TARS-desktop/blob/main/docs/sdk.md) |
| MCP specification | [modelcontextprotocol.io](https://modelcontextprotocol.io/) |
