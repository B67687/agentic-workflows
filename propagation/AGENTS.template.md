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
11. **Normal-language tasking by default** — The user should not need to remember slash commands. Treat serious plain-language requests as implicit `/route` unless the task is obviously tiny.
12. **Use prompt contracts as internal self-checks** — Before non-trivial phase work, check outcome, context, constraints, examples, verification, and ask/proceed policy. Ask only when missing information would materially change the result.
13. **Map before broad reading** — When a folder is unfamiliar or a task is broad, use `/repo-map` before targeted retrieval.
14. **Refuse unclear implementation** — If files, scope, or verification path are unclear, stop and go back to research or planning.
15. **Grill costly ambiguity early** — Challenge assumptions before planning or implementing broad/ambiguous requests.
16. **Stop planning loops early** — After two refinements, pick the next slice instead of broadening.
17. **Optimize by evidence** — Measure first; architecture review for hard-to-reverse risks.
18. **Probe Git state before serious edits** — Check branch, dirt, and upstream state first.
19. **Use worktrees for isolated risky work** — Prefer a short-lived worktree branch for risky or parallel work.
20. **Batch file reads to 3 at a time** — Avoid dispatching 6+ parallel reads mixed with a long-running build. Memory pressure on a 4GB WSL2 VM can interrupt tool execution.
21. **Use `gradle-build` for Gradle projects** — Instead of bare `./gradlew`. The wrapper runs the build then stops the daemon, freeing ~600MB–1.8GB RSS on WSL2.

See hub's `docs/core-agent-doctrine.md` for full principles.

---

## Session State

Every session MUST update `session-state.json` before heavy operations or resume.

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

| Lane | When to Use |
|------|-------------|
| **Direct** | Normal work, focused tasks, small or medium scopes |
| **Fresh session** | 15+ turns, topic shift, quality degradation, tangled context |

**Default:** Handle directly. Only restart into a fresh session when context is clearly degrading.

---

## Recursive Self Prompting

For complex tasks, prompt yourself until plateau:
1. Make initial attempt
2. Ask: "What else should I consider?" → "Am I missing anything?" → "Is this complete?"
3. Stop when iterations produce only minor refinements

---

## Deep References

- Session state → `session-state.json`
- Topic insights → `topic-insights.md`
- Quality standards → `quality-standards.md`
- Git practices → `git-github-best-practices.md`
