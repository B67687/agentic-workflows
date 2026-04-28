<!-- Managed-By: AI-Prompting-Library -->
# Topic Folder System Overview

This file explains the structure and conventions for this topic folder.

For the hub's central knowledge base, see hub's docs/workspace-system-overview.md.

## What This Folder Is

This is a topic folder within the M-Namikaz-Others workspace.

| Area | What it is | Where normal work goes |
|---|---|---|
| `AI Prompting` hub | Central knowledge and propagation system | (in parent folder) |
| This topic folder | Your project/topic workspace | `[folder-name]-content/` |

## Folder Structure

Expected root structure:

```text
[Topic-Folder]/
|- AGENTS.md                    (operating contract - how AI should work)
|- workspace-system-overview.md (this file - quick orientation)
|- topic-insights.md            (your lessons - update when you learn something)
|- git-github-best-practices.md (git guidance)
|- quality-standards.md         (quality bar)
|- session-state.json           (current work state - read on resume)
|- .cleanup-protect             (protected files list)
|- [folder-name]-content/       (YOUR WORK GOES HERE)
|- archive/                    (session history)
|- meta/                       (optional - YOUR custom content)
|- audit-folder-quality.sh      (validation script)
|- check-sync-status.sh       (sync checker)
|- sync-from-hub.sh            (sync from hub)
`- opencode.json               (tool config)
```

## Key Rules

1. **Work goes in `[topic-name]-content/`** - This is your primary operating area. The hub never touches this folder.

2. **meta/ is protected** - Any folder or file in `meta/` is YOURS. Hub propagation only touches root files.

3. **Content folder naming** - Uses simple kebab-case: lowercase + spaces → dashes.
   - Example: "Fluent PRs" → `fluent-prs-content`

4. **Session state** - The file `session-state.json` tracks current work. Read it on every resume.

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

For deeper guidance, see hub's docs/ folder (sync to get latest):