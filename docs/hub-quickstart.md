# Hub Quickstart

Read this first on every resume. Everything else is linked.

## Current State

- **Session:** Check root `session-state.json` for the active task
- **System:** Phase-based direct workflow with deterministic intake, slicing, preflight, and checkpoint helpers
- **Main AI:** Kimi K2.6 (OpenCode Go) or Claude Sonnet 4.6 (Copilot)
- **Goal:** One main AI for 90% of work. Spawn subagents only for fresh context or bulk search.

## 10-Second Rules

1. **Handle directly** - Simple tasks, < 15 turns, normal coding/writing
2. **Slice oversized tasks first** - Big tasks should become milestone ladder plus first executable slice
3. **Research before coding** - For non-trivial tasks, understand first
4. **Preserve the big goal separately** - Use North Star for long-horizon targets and milestone shaping for the next bounded bet
5. **Plan before implementing** - Make the file/test plan explicit
5. **Cap planning loops** - After two refinements, stop broadening and choose the next slice
6. **Gate implementation** - If files, scope, or verification are unclear, stop and go back a phase
7. **Write session state** - Before heavy ops, update root `session-state.json`
8. **Health-probe after resume** - Read-only sanity check before risky mutations
9. **Restart on phase change** - New phase, new session
10. **Checkpoint verified phases** - Prefer small commits after verified milestones instead of carrying giant dirty diffs
11. **Trust small batches** - Faster and safer usually come from smaller verified slices, not bigger plans

## Project Context

- This hub manages topic folders in `/home/namikaz/projects/dev`
- Hub work: docs, research, scripts, templates, workflow state
- Topic work: inside `[topic-name]-content/`, resume from root `session-state.json`
- Propagate shared defaults: `bash scripts/propagate-to-all.sh --apply`
- Fast phase commands: `/start-task`, `/north-star`, `/shape-milestone`, `/slice-task`, `/grill`, `/research`, `/plan`, `/implement`, `/optimize`, `/query`, `/session-boundary`, `/checkpoint`, `/close-task`, `/finish-task`, `/git-start`, `/git-worktree`
- OpenCode command discovery should use `.opencode/commands/`; the repo also keeps `command/` as a readable mirrored command set
- Phase gate: `bash scripts/phase-gate.sh implement --research-done --plan-done --scope-bounded --verification-known`
- Git repo probe: `bash scripts/git-session-start.sh`
- Deterministic task intake: `bash scripts/task-intake.sh "task"`
- Deterministic implement preflight: `bash scripts/implement-preflight.sh "task" --research-done --plan-done --scope-bounded --verification-known`
- Isolated branch/worktree: `bash scripts/git-worktree-branch.sh branch-name`
- `/start-task` now begins with deterministic task intake and should choose current checkout vs worktree by default
- `/north-star` now preserves a large goal separately from execution detail
- `/shape-milestone` now turns a large goal into one bounded bet
- `/slice-task` now forces oversized work into a milestone ladder plus first executable slice
- `/plan` now begins with a planning guard and should stop planning loops before they become analysis paralysis
- `/optimize` now decides whether optimization should wait, measure first, optimize now, or trigger architecture review
- `/implement` now begins with deterministic repo plus phase preflight and should refuse unclear or risky checkout state by default
- `/checkpoint` now begins with deterministic checkpoint review before recommending a commit
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
| Fast stable delivery model | `docs/fast-stable-delivery.md` |
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
|- command/                         (hub-owned managed core slash commands)
|- north-star.sh                    (hub-owned managed core)
|- milestone-shape.sh               (hub-owned managed core)
|- task-intake.sh                   (hub-owned managed core)
|- task-slice.sh                    (hub-owned managed core)
|- phase-gate.sh                    (hub-owned managed core)
|- plan-guard.sh                    (hub-owned managed core)
|- optimize-gate.sh                 (hub-owned managed core)
|- checkpoint-commit.sh              (hub-owned managed core)
|- git-session-start.sh             (hub-owned managed core)
|- git-worktree-branch.sh           (hub-owned managed core)
|- retrieve-context.sh               (hub-owned managed core)
|- session-boundary.sh               (hub-owned managed core)
|- session-state.json                (repo-owned after bootstrap)
|- topic-insights.md                 (repo-owned after bootstrap)
|- archive/                          (repo-owned after bootstrap)
|- [topic]-content/                  (actual work)
`- meta/                             (optional project context)
```
