# Hub Quickstart

Read this first on every resume. Everything else is linked.

## Current State

- **Session:** Check root `session-state.json` for the active task
- **System:** 1 main agent plus 2 optional subsession roles (Explorer + Worker)
- **Main AI:** Kimi K2.6 (OpenCode Go) or Claude Sonnet 4.6 (Copilot)
- **Goal:** One main AI for 90% of work. Spawn subagents only for fresh context or bulk search.

## 10-Second Rules

1. **Handle directly** - Simple tasks, < 15 turns, normal coding/writing
2. **Spawn Explorer** - Bulk search (10+ files), complex grep
3. **Spawn Worker** - Fresh context (15+ turns, topic shift, quality drop)
4. **Research before coding** - For non-trivial tasks, understand first
5. **Plan before implementing** - Make the file/test plan explicit
6. **Write session state** - Before heavy ops, update root `session-state.json`
7. **Health-probe after resume** - Read-only sanity check before risky mutations
8. **Restart on phase change** - New phase, new session
9. **Keep public output native** - No routing/model footers unless a platform requires disclosure
10. **Checkpoint verified phases** - Prefer small commits after verified milestones instead of carrying giant dirty diffs

## Project Context

- This hub manages topic folders in `/home/namikaz/projects/dev`
- Hub work: docs, research, scripts, templates, workflow state
- Topic work: inside `[topic-name]-content/`, resume from root `session-state.json`
- Propagate shared defaults: `bash scripts/propagate-to-all.sh --apply`
- Retrieve only relevant local context: `bash scripts/retrieve-context.sh "query"`
- Check whether to restart: `bash scripts/session-boundary.sh --phase research --turns 8`
- After changing propagation or sync scripts, run: `bash scripts/test-propagation-contract.sh`
- After a verified phase, use: `bash scripts/checkpoint-commit.sh -m "checkpoint summary"`

## Deep References (read only when needed)

| Need | File |
|------|------|
| Model selection | `docs/model-selection-guide.md` |
| Agent routing | `docs/agentic-workflows.md` |
| Phase workflow | `docs/phase-based-agent-workflow.md` |
| Retrieval policy | `docs/retrieval-policy.md` |
| Prompt templates | `docs/prompt-templates.md` |
| Core principles | `docs/core-agent-doctrine.md` |
| Research methodology | `docs/research-methodology.md` |
| Repo tooling | `docs/repo-tooling.md` |
| Quality standards | `docs/quality-standards.md` |
| Token efficiency | `docs/token-efficient-prompting.md` |

## Topic Folder Standard

```
[Topic]/
|- AGENTS.md                         (hub-owned managed core)
|- docs/workspace-system-overview.md (hub-owned managed core)
|- git-github-best-practices.md      (hub-owned managed core)
|- quality-standards.md              (hub-owned managed core)
|- checkpoint-commit.sh              (hub-owned managed core)
|- retrieve-context.sh               (hub-owned managed core)
|- session-boundary.sh               (hub-owned managed core)
|- session-state.json                (repo-owned after bootstrap)
|- topic-insights.md                 (repo-owned after bootstrap)
|- archive/                          (repo-owned after bootstrap)
|- [topic]-content/                  (actual work)
`- meta/                             (optional project context)
```
