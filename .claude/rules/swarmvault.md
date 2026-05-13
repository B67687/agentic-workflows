---
description: SwarmVault graph-first repository rules.
paths:
  - "swarmvault.schema.md"
  - "raw/**"
  - "wiki/**"
  - "state/**"
---

# SwarmVault Rules

- Read `swarmvault.schema.md` before compile or query style work
- Treat `raw/` as immutable source input
- Treat `wiki/` as generated markdown owned by the workflow
- Read `wiki/graph/report.md` before broad file searching
- For graph questions, use `swarmvault graph query` before broad grep
- Save high-value answers to `wiki/outputs/`
- Prefer `swarmvault ingest`, `compile`, `query`, `lint` for maintenance
