<!-- Managed-By: AI-Prompting-Library -->
# Topic Folder System Overview

This file explains the structure and conventions for this topic folder.

For the hub's central knowledge base, see hub's docs/workspace-system-overview.md.

## What This Folder Is

This is a topic folder within the shared workspace.

| Area | What it is | Where normal work goes |
|---|---|---|
| `ai-prompting` hub | Central knowledge and propagation system | (sibling folder) |
| This topic folder | Your project/topic workspace | `[folder-name]-content/` |

## Folder Structure

Expected root structure:

```text
[Topic-Folder]/
|- AGENTS.md                         (hub-owned managed core)
|- docs/workspace-system-overview.md (hub-owned managed core)
|- git-github-best-practices.md      (hub-owned managed core)
|- quality-standards.md              (hub-owned managed core)
|- audit-folder-quality.sh           (hub-owned managed core)
|- check-sync-status.sh              (hub-owned managed core)
|- sync-from-hub.sh                  (hub-owned managed core)
|- command/                          (hub-owned managed core slash commands)
|- phase-gate.sh                     (hub-owned managed core)
|- checkpoint-commit.sh              (hub-owned managed core)
|- retrieve-context.sh               (hub-owned managed core)
|- session-boundary.sh               (hub-owned managed core)
|- session-state.json                (repo-owned after bootstrap)
|- topic-insights.md                 (repo-owned after bootstrap)
|- .cleanup-protect                  (repo-owned after bootstrap)
|- archive/history-index.md          (repo-owned after bootstrap)
|- archive/history-full-detailed.md  (repo-owned after bootstrap)
|- [folder-name]-content/            (YOUR WORK GOES HERE)
`- meta/                             (optional - YOUR custom content)
```

## Key Rules

1. **Work goes in `[topic-name]-content/`** - This is your primary operating area. The hub never touches this folder.

2. **meta/ is protected** - Any folder or file in `meta/` is YOURS. Hub propagation never touches it.

3. **Content folder naming** - Uses simple kebab-case: lowercase + spaces → dashes.
   - Example: "Fluent PRs" → `fluent-prs-content`

4. **Session state** - The file `session-state.json` tracks current work. Read it on every resume.
5. **Ownership split** - The hub may refresh only the managed core. `session-state.json`, `topic-insights.md`, `.cleanup-protect`, and archive files are repo-owned after bootstrap.
6. **Runtime config** - Do not create repo-local OpenCode runtime config. Use the global config and the root session-state file instead.
7. **Phase workflow** - For non-trivial work, do research first, plan second, implement third.
8. **Session boundaries** - New phase, new session. Checkpoint when a phase is verified and restart when context quality drops.

## Core Principles

See AGENTS.md for the full 10 principles. Key ones:

- **Supply missing structure** when safe
- **Verify before presenting**
- **Handle directly** unless clearly justified to spawn subagent

## Sync from Hub

To sync the latest templates from the hub:

```bash
./sync-from-hub.sh
```

To check if you're up to date:

```bash
./check-sync-status.sh
```

For folder quality validation:

```bash
./audit-folder-quality.sh
```

To pull only the context relevant to one step:

```bash
./retrieve-context.sh "your query"
```

If your client supports slash commands, prefer:

```text
/query your query
```

To classify a task before starting:

```text
/start-task your task
```

To challenge assumptions before deeper work:

```text
/grill your task
```

To decide whether to continue or restart:

```bash
./session-boundary.sh --phase research --turns 8
```

Shortcut form:

```text
/session-boundary research 8
```

To verify that implementation is actually allowed:

```bash
./phase-gate.sh implement --research-done --plan-done --scope-bounded --verification-known
```

## Two-Git Architecture (Optional)

This workspace supports keeping public code separate from propagated files:

1. **Root git** (at workspace root): Tracks propagated files
2. **Project git** (inside subfolder): Only tracks your code for GitHub

To keep GitHub repos clean, add to `.gitignore`:
```
# AI-Prompting-Library propagated files
AGENTS.md
topic-insights.md
.cleanup-protect
workspace-system-overview.md
```

## Root Discipline

The folder root is for propagated files and control files. Put normal work in `[folder-name]-content/`.

Root should NOT collect: source folders, notes, docs, assets, downloads, archives, logs, temp folders, datasets, or duplicate legacy content. Move such content to content/ folder.

## Hub Reference

For deeper guidance, see the hub docs folder (sync to get latest):
