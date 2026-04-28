# Hub Quickstart

Read this first on every resume. Everything else is linked.

## Current State

- **Session:** Check `workflow/session-state.json` for active task
- **System:** 1 main agent plus 2 optional subsession roles (Explorer + Worker)
- **Main AI:** Kimi K2.6 (OpenCode Go) or Claude Sonnet 4.6 (Copilot)
- **Goal:** One main AI for 90% of work. Spawn subagents only for fresh context or bulk search.

## 10-Second Rules

1. **Handle directly** - Simple tasks, < 15 turns, normal coding/writing
2. **Spawn Explorer** - Bulk search (10+ files), complex grep
3. **Spawn Worker** - Fresh context (15+ turns, topic shift, quality drop)
4. **Plan when ambiguous** - But plan directly, don't spawn a planner
5. **Write session state** - Before heavy ops, update `workflow/session-state.json`
6. **Health-probe after resume** - Read-only sanity check before risky mutations
7. **Keep public output native** - No routing/model footers unless a platform requires disclosure

## Project Context

- This hub manages 25+ topic folders in `M:\M-Namikaz-Others`
- Hub work: docs, research, scripts, templates, workflow state
- Topic work: inside `[topic-name]-content/`, read `meta/HANDOVER.md` on resume
- Propagate templates: `scripts/propagate-to-all.ps1 -Apply`

## Deep References (read only when needed)

| Need | File |
|------|------|
| Model selection | `docs/model-selection-guide.md` |
| Agent routing | `docs/agentic-workflows.md` |
| Prompt templates | `docs/prompt-templates.md` |
| Core principles | `docs/core-agent-doctrine.md` |
| Research methodology | `docs/research-methodology.md` |
| Repo tooling | `docs/repo-tooling.md` |
| Quality standards | `docs/quality-standards.md` |
| Token efficiency | `docs/token-efficient-prompting.md` |

## Topic Folder Standard

```
[Topic]/
|- AGENTS.md              (propagated)
|- topic-insights.md      (propagated)
|- git-github-best-practices.md (propagated)
|- .cleanup-protect       (propagated)
|- audit-folder-quality.ps1 (propagated)
|- [topic]-content/       (actual work)
`- meta/                  (optional project context)
   |- PROJECT.md          (project-specific rules)
   `- HANDOVER.md         (session state)
```
