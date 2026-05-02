<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: AGENTS -->
# AI Prompting Workspace

A living knowledge base for a topic domain. This file provides AI agents with context on how to work effectively in this folder.

## Operating Contract

**Core principle: Supply missing structure when safe.**

When a request is clear enough and risk is low, you must proactively:
- Sharpen the scope if vague
- Define verification targets
- Choose the lightest execution lane

**Only ask questions when gaps have real consequences for safety, scope, or correctness.**

---

## Key Principles

1. **Scope tightly** — Don't ask for "everything"
2. **Verify before presenting** — Testing strengthens reasoning
3. **Handle directly** — Unless clearly justified to spawn subagent
4. **Compress before spawning** — Pass only task, context (3-5 bullets), files, done-when
5. **Update session-state.json** — Before heavy ops, resume, or spawning subagents
6. **Read contribution guidance first** — Before preparing a PR or other upstream-facing change, read `CONTRIBUTING.md` if it exists. If it does not, read the closest equivalent contribution guidance such as the repo `README`, maintainer docs, or `meta/` notes.
7. **Use research -> plan -> implement for non-trivial work** — Understand first, plan second, then change files.
8. **Restart on phase boundaries** — New phase, new session. Do not drag long degraded threads forward.
9. **Prefer slash-command shortcuts when present** — Use `/start-task`, `/query`, `/session-boundary`, `/research`, `/plan`, `/implement`, and `/checkpoint` instead of retyping long helper commands.
10. **Refuse unclear implementation** — If the files, scope, or verification path are unclear, stop and go back to research or planning instead of improvising edits.

See hub's docs/core-agent-doctrine.md for full principles.

---

## Session State

Every session MUST update `session-state.json` before heavy operations or resume.

The file tracks: current task, what changed, files touched, verification, next steps.

Default resume order:
1. `session-state.json`
2. `AGENTS.md`
3. `docs/workspace-system-overview.md`

Do not create repo-local OpenCode runtime config or workspace-level `.opencode/` directories.
Treat `session-state.json`, `topic-insights.md`, `.cleanup-protect`, and archive history files as repo-owned after bootstrap.

---

## Folder Structure

```
[Topic-Folder]/
|- AGENTS.md                    (this file)
|- workspace-system-overview.md (quick orientation)
|- topic-insights.md            (your lessons - update when you learn)
|- session-state.json           (current work state)
|- [folder-name]-content/        (YOUR WORK - hub never touches)
|- meta/                        (YOUR custom content - never touched)
|- archive/                     (session history)
```

---

## Agent System

Two subagents for when you need them:

| Agent | When to Use |
|-------|-------------|
| **@explorer** | 10+ files, complex search patterns |
| **@worker** | 15+ turns, topic shift, quality degradation |

**Default:** Handle directly. Only spawn subagent when benefit clearly exceeds overhead.

---

## Recursive Self Prompting

For complex tasks, prompt yourself until plateau:
1. Make initial attempt
2. Ask: "What else should I consider?"
3. Ask: "Am I missing anything?"
4. Ask: "Is this complete?"
5. Stop when iterations produce only minor refinements

---

## Deep References

- Session state → session-state.json
- Topic insights → topic-insights.md
- Quality standards → quality-standards.md
- Git practices → git-github-best-practices.md
