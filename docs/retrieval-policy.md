# Retrieval Policy

Use retrieval to pull in only the local context needed for the current step.

## Default Search Scope

The approved first-pass search scope is:

1. `session-state.json`
2. `AGENTS.md`
3. `docs/`
4. `meta/`
5. `topic-insights.md`
6. `archive/history-index.md`

Only include `archive/history-full-detailed.md` when the compact sources are not enough.

## Default Exclusions

Do not search broad low-signal areas by default:

- generated CSV and JSON artifacts
- build outputs
- `node_modules`
- tool caches
- binaries
- unrelated vendor trees
- historical deep archives unless explicitly needed

## Retrieval Order

When a task starts:

1. read `session-state.json`
2. read `AGENTS.md`
3. read `docs/workspace-system-overview.md`
4. run `bash ./scripts/retrieve-context.sh "your query"` for the exact step
5. pull deeper docs only if the top matches say they matter

This keeps context selective instead of flooding the session with everything that might be useful.

## Use Cases

Good retrieval queries are specific and step-bound:

```bash
bash ./scripts/retrieve-context.sh "managed core vs repo-owned"
bash ./scripts/retrieve-context.sh "git identity policy"
bash ./scripts/retrieve-context.sh "contribution guide rule"
```

Bad retrieval behavior is broad and speculative:

- "load everything about this repo"
- "search all history before doing anything"
- "read every doc just in case"
