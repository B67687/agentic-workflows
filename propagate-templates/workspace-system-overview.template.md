<!-- Managed-By: AI-Prompting-Library -->
# Topic Folder System Overview

This file explains the structure and conventions for this topic folder.

For the hub's central knowledge base, see `M:\M-Namikaz-Others\AI Prompting\docs\workspace-system-overview.md`.

## What This Folder Is

This is a topic folder within the `M:\M-Namikaz-Others` workspace.

| Area | What it is | Where normal work goes |
|---|---|---|
| `AI Prompting` hub | Central knowledge and propagation system | `docs/`, `research/`, `scripts/`, `workflow/` |
| This topic folder | Your project/topic workspace | `[topic-name]-content/` |

## Folder Structure

Expected root structure:

```text
[Topic-Folder]/
|- AGENTS.md                    (from hub - operating contract)
|- workspace-system-overview.md  (from hub - this file)
|- topic-insights.md            (from hub - your lessons)
|- git-github-best-practices.md (from hub)
|- quality-standards.md         (from hub)
|- session-state.json           (from hub - current work state)
|- .cleanup-protect             (from hub)
|- audit-folder-quality.sh     (from hub - validation)
|- check-sync-status.sh        (from hub - sync checker)
|- sync-from-hub.sh            (from hub - sync script)
|- opencode.json                (from hub - tool config)
|- opencode-agent-system.md     (from hub - agent instructions)
|- [topic-name]-content/        (YOUR WORK GOES HERE)
`- meta/                       (optional - YOUR custom content, never touched by hub)
```

## Key Rules

1. **Work goes in `[topic-name]-content/`** - This is your primary operating area. The hub never touches this folder.

2. **meta/ is protected** - Any folder or file in `meta/` is YOURS. Hub propagation only touches root files.

3. **Content folder naming** - Uses simple kebab-case: lowercase + spaces → dashes.
   - Example: "Fluent PRs" → `fluent-prs-content`

4. **Session state** - The file `session-state.json` tracks current work. Read it on every resume.

## Core Principles

From `docs/core-agent-doctrine.md`:

- **Scope tightly** — Don't ask for "everything"
- **Give rich evidence** — Logs, files, configs, then stop micromanaging
- **Supply missing structure** — Fill in what the user misses
- **Define done and verification early** — Success criteria matter
- **Verification is learning** — Testing effect strengthens reasoning
- **Choose the lightest lane** — Inline, reusable, isolated, review
- **Plan when ambiguous** — Re-plan when execution wobbles
- **Optimize quality, not volume** — Verification > generation
- **Promote repeated work** — Turn recurring workflows into assets
- **Update memory after lessons** — Compound, don't repeat
- **Prefer simple code** — Add complexity only when concrete system demand requires it

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

## Hub Reference

- Hub location: `M:\M-Namikaz-Others\AI Prompting`
- Hub docs: `M:\M-Namikaz-Others\AI Prompting\docs\`
- Session state template: `M:\M-Namikaz-Others\AI Prompting\propagate-templates\`