<!-- AGENTS.md is the canonical operating contract for this workspace. This file is a
     Claude Code compatibility shim that delegates to AGENTS.md for the full contract.
     Keep this synchronized if AGENTS.md's startup order or key file references change. -->

# Operating Contract

This workspace follows the **agentic-workflows operating contract** defined in `AGENTS.md`.
Read that file first --- it contains the shared rules, conventions, recovery patterns,
escalation paths, and governance model that every agent in this workspace follows.

## Startup Order
1. `session-state.json` --- active session state; read first on every resume
2. `AGENTS.md` --- full operating contract (this file delegates to it)

## Key Files
| File | Purpose |
|------|---------|
| `session-state.json` | Active session state, current task, verification status |
| `AGENTS.md` | Canonical operating contract --- read this for full rules |
| `docs/workflow.md` | Compact workflow summary for fast orientation |
| `docs/session-checkpoint.md` | Checkpoint and recovery rules |
| `scripts/tools.sh` | Tool registry --- all agent-callable tools |
| `scripts/search-index.sh` | BM25 search across all text files |

## Quick Commands
```
bash ./scripts/tools.sh                   # Tool registry
bash ./scripts/session-status.sh          # Workspace orientation
bash ./scripts/test-smoke.sh              # Smoke test suite (31 tests)
bash ./scripts/search-index.sh "query"    # BM25 search
bash ./scripts/checkpoint-commit.sh -m "msg"  # Safe commit
```

<!-- swarmvault:managed:start -->
# SwarmVault Rules

- Read `swarmvault.schema.md` before compile or query style work. It is the canonical schema path.
- Treat `raw/` as immutable source input.
- Treat `wiki/` as generated markdown owned by the agent and compiler workflow.
- If `SWARMVAULT_OUT` is set, resolve generated artifact paths like `raw/`, `wiki/`, and `state/` under that directory.
- Read `wiki/graph/report.md` before broad file searching when it exists; otherwise start with `wiki/index.md`.
- For graph questions, prefer `swarmvault graph query`, `swarmvault graph path`, and `swarmvault graph explain` before broad grep/glob searching.
- Preserve frontmatter fields including `page_id`, `source_ids`, `node_ids`, `freshness`, and `source_hashes`.
- Save high-value answers back into `wiki/outputs/` instead of leaving them only in chat.
- Prefer `swarmvault ingest`, `swarmvault compile`, `swarmvault query`, and `swarmvault lint` for SwarmVault maintenance tasks.
<!-- swarmvault:managed:end -->


