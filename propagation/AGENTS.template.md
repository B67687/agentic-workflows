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
3. **Handle directly** — Unless clearly justified to start a fresh session
4. **Compress before restarting** — Pass only task, context (3-5 bullets), files, done-when
5. **Update session-state.json** — Before heavy ops, resume, or restarting into fresh context
6. **Read contribution guidance first** — Before preparing a PR or other upstream-facing change, read `CONTRIBUTING.md` if it exists. If it does not, read the closest equivalent contribution guidance such as the repo `README`, maintainer docs, or `meta/` notes.
7. **Use research -> plan -> implement for non-trivial work** — Understand first, plan second, then change files.
8. **Slice oversized tasks early** — Big tasks should become milestone ladder plus first executable slice before normal planning.
9. **Think big, map coarsely, bet medium, execute tiny** — Compress the product experience, preserve the big goal, map major domains, shape one milestone bet, then work one verified slice at a time.
10. **Restart on phase boundaries** — New phase, new session. Do not drag long degraded threads forward.
11. **Normal-language tasking by default** — The user should not need to remember slash commands. Treat serious plain-language requests as implicit `/start-task` unless the task is obviously tiny.
12. **Prefer slash-command shortcuts internally when present** — Use `/start-task`, `/shape-product`, `/counsel`, `/task-tree`, `/north-star`, `/shape-milestone`, `/slice-task`, `/grill`, `/query`, `/session-boundary`, `/handoff`, `/research`, `/plan`, `/implement`, `/optimize`, and `/checkpoint` as internal workflow shortcuts instead of retyping long helper commands.
13. **Report the current lane before redirecting** — Tell the user where the work is, why, and the single next action. Do not hand them a menu unless there is a real choice with meaningful tradeoffs.
14. **Map before broad reading** — When a folder is unfamiliar or a task is broad, use `/repo-map` before targeted retrieval so context is selected deliberately instead of by wandering.
15. **Refuse unclear implementation** — If the files, scope, or verification path are unclear, stop and go back to research or planning instead of improvising edits.
16. **Grill costly ambiguity early** — If the request is broad, ambiguous, or expensive to misunderstand, challenge the assumptions before planning or implementing.
17. **Stop planning loops early** — After two planning refinements, pick the next executable slice instead of broadening the plan again.
18. **Optimize by evidence** — Measure first for normal optimization; do bounded architecture review for hard-to-reverse risks.
19. **Probe Git state before serious edits** — Check branch, dirt, and upstream state first.
20. **Use worktrees for isolated risky work** — Prefer a short-lived worktree branch when the work should not share the current checkout.

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
|- docs/workspace-system-overview.md (quick orientation)
|- topic-insights.md            (your lessons - update when you learn)
|- session-state.json           (current work state)
|- [folder-name]-content/        (YOUR WORK - hub never touches)
|- meta/                        (YOUR custom content - never touched)
|- archive/                     (session history)
```

---

## Agent System

Two context lanes for when you need them:

| Agent | When to Use |
|-------|-------------|
| **Direct lane** | Normal work, focused tasks, small or medium scopes |
| **Fresh-session lane** | 15+ turns, topic shift, quality degradation, or tangled context |

**Default:** Handle directly. Only restart into a fresh session when the context is clearly degrading.

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
