<!-- Managed-By: AI-Prompting-Library -->
# Topic Folder System Overview

This file explains the structure and conventions for this topic folder.

For the hub's central knowledge base, see the sibling `agentic-workflows` folder's `docs/workspace-system-overview.md`.

## What This Folder Is

This is a topic folder within the shared workspace.

| Area | What it is | Where normal work goes |
|---|---|---|
| `agentic-workflows` hub | Central knowledge and propagation system | (sibling folder) |
| This topic folder | Your project/topic workspace | `[folder-name]-content/` |

## Folder Structure

```
[Topic-Folder]/
|- AGENTS.md                         (hub-owned managed core)
|- .ai-prompting-hub.sh              (hub-owned managed core resolver)
|- docs/workspace-system-overview.md (hub-owned managed core)
|- git-github-best-practices.md      (hub-owned managed core)
|- quality-standards.md              (hub-owned managed core)
|- scripts/*.sh                      (hub-owned managed core — see below)
|- command/                          (hub-owned managed core slash commands)
|- .opencode/commands/               (hub-owned managed core, mirrored)
|- session-state.json                (repo-owned after bootstrap)
|- topic-insights.md                 (repo-owned after bootstrap)
|- .cleanup-protect                  (repo-owned)
|- archive/history-index.md          (repo-owned)
|- archive/history-full-detailed.md  (repo-owned)
|- [folder-name]-content/            (YOUR WORK GOES HERE)
`- meta/                             (YOUR custom content — never touched by propagation)
```

The hub manages: AGENTS.md, workspace-system-overview.md, git-github-best-practices.md, quality-standards.md, audit-folder-quality.sh, check-sync-status.sh, sync-from-hub.sh, and all scripts. Run `bash .ai-prompting-hub.sh` to locate the hub, or set `$AI_PROMPTING_HUB`.

## Key Rules

1. **Work goes in `[topic-name]-content/`** — The hub never touches this folder.
2. **`meta/` is protected** — Hub propagation never touches it.
3. **Content folder naming** — Kebab-case: `fluent-prs-content`
4. **Session state** — Read `session-state.json` on every resume.
5. **Ownership split** — Hub refreshes only managed core. Session state, topic-insights, cleanup-protect, and archive are repo-owned.
6. **No repo-local OpenCode config** — Use global config.
7. **Phase workflow** — Research → plan → implement for non-trivial work.
8. **Fast iteration** — Milestone ladder + first slice, not one giant plan.
9. **Anti-paralysis** — After two planning refinements, pick the next slice.
10. **Optimize by evidence** — Measure first; architecture review for hard-to-reverse risks.
11. **Session boundaries** — New phase, new session. Checkpoint when verified.

## Core Principles

See AGENTS.md for the full operating contract. Key ones: supply missing structure when safe, verify before presenting, handle directly unless clearly justified to spawn a subagent, think big bet medium execute tiny.

## Sync from Hub

```bash
./sync-from-hub.sh           # pull latest templates
./check-sync-status.sh       # check freshness
./audit-folder-quality.sh    # validate structure
```

## Common Slash Commands

Prefer these over raw script calls when your client supports them:

| Command | Use Case |
|---|---|
| `/route` | Route a normal-language task into the right lane |
| `/start-task` | Classify a task before starting |
| `/query` | Retrieve only relevant context |
| `/research` | Start a research phase |
| `/plan` | Start a planning phase |
| `/implement` | Start implementation |
| `/shape-product` | Grill and compress broad product goals |
| `/north-star` | Preserve long-horizon goals |
| `/shape-milestone` | Shape one bounded milestone bet |
| `/slice-task` | Break oversized tasks into milestones + first slice |
| `/task-tree` | Map large goals to domains and milestones |
| `/counsel` | Get independent challenge on a decision |
| `/grill` | Challenge assumptions before deeper work |
| `/git-start` | Probe branch and upstream state before edits |
| `/git-worktree` | Create isolated short-lived worktree branch |
| `/session-boundary` | Decide whether to continue or restart |
| `/phase-gate` | Verify implementation is actually allowed |
| `/plan-guard` | Keep planning from growing too large |
| `/optimize` | Govern optimization work |
| `/checkpoint` | Create a checkpoint commit |
| `/handoff` | Build continuation packet for new session |
| `/close-task` | Close a resolved or dead branch |
| `/finish-task` | Close + checkpoint composite |

To sync the command files: run `./sync-from-hub.sh`.

## Two-Git Architecture (Optional)

To keep GitHub repos clean, the workspace supports keeping public code separate from propagated files. Root git tracks propagated files; project git inside `content/` tracks your code. Add to `.gitignore`:

```
AGENTS.md
topic-insights.md
.cleanup-protect
docs/workspace-system-overview.md
```

## Root Discipline

Root is for propagated files and control files. Put normal work in `[folder-name]-content/`. Do not put source folders, notes, downloads, temp files, or datasets in root.
