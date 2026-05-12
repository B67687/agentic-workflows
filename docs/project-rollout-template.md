# Project Rollout Template

Use this file to make the same best practices show up across all repos consistently.

## The Reliable Pattern

Do not rely on memory or one-off prompts alone.

Use a 3-layer setup:

1. A central library of shared guidance
2. A repo-level instruction file
3. A repo-level lessons file for local conventions

## Scope Hierarchy

One of the most useful operating patterns is to separate instructions by who owns the state and who should share it.

Use this hierarchy:

1. Central canonical library
2. Personal/global layer
3. Repo-local team layer
4. Component-local layer
5. Git-ignored local overrides

### 1. Central canonical library

This folder is the durable source of shared ideas, templates, and reusable workflow patterns.

Use it for:

- prompting doctrine
- reusable templates
- rollout scripts
- lessons that transfer across repos

Do not assume every tool will auto-load this folder directly.

### 2. Personal/global layer

Use the tool's user-level config or global instruction files for:

- personal preferences
- private credentials and auth-backed setup
- cross-project habits
- personal memory that should not be committed to a repo

### 3. Repo-local team layer

Use repo-root files for:

- build and test commands
- team-shared conventions
- validation rules
- local lessons for maintainers and repo culture

This is the most portable default across coding tools.

### 4. Component-local layer

For large repos or monorepos, put subsystem-specific rules near the subsystem.

Use this for:

- framework-specific conventions
- local architecture rules
- component-specific test or build behavior

This keeps irrelevant instructions out of the main path.

### 5. Git-ignored local overrides

Use git-ignored files for personal repo-specific overrides that should not become team rules.

Examples:

- personal local settings
- local auth helpers
- temporary debugging preferences

## Recommended File Layout Per Repo

### 1. Root `AGENTS.md`

This is the most portable default for agent-style coding workflows.

Put in:

- key build and test commands
- how to validate work
- repo do-not rules
- branching, PR, and issue conventions
- architecture or platform checks that must never be skipped
- references to the local lessons file

### 2. Local lessons file

Recommended name:

- `topic-insights.md`

Use this for:

- maintainer preferences
- real-world conventions that differ from docs
- mistakes to avoid repeating
- scope boundaries
- environment pitfalls

### 3. Optional GitHub-specific instructions

For GitHub Copilot, current GitHub docs say you can add:

- `.github/copilot-instructions.md` for repository-wide instructions
- `.github/instructions/*.instructions.md` for path-specific instructions

GitHub's docs also state that agent instructions can use `AGENTS.md`, and mention `CLAUDE.md` or `GEMINI.md` in the repository root as alternatives for those ecosystems.

## Best Operating Model

Keep one canonical library here:

- [authoritative-agent-best-practices.md](authoritative-agent-best-practices.md)
- [daily-prompts.md](daily-prompts.md)
- [prompt-templates.md](prompt-templates.md)

But do not dump that whole library into every repo.

Instead, copy only the repo-relevant distilled rules into the repo's own `AGENTS.md`.

If a tool supports global instruction files, point that global layer at your canonical library or a distilled personal subset.
Still keep a short repo-local `AGENTS.md` for repo truth.

## What To Put In Every Repo's `AGENTS.md`

Keep it short and high-signal.

Source-backed parallel:

- Anthropic's current Claude Code docs recommend keeping always-loaded instruction files specific, concise, and under about 200 lines per file.

Practical takeaway for this template:

- aim much shorter than the limit when possible
- keep only always-needed repo truth here
- move long procedures to lessons files, rules files, or task-specific docs

Good categories:

1. Mission-critical commands
2. Validation rules
3. Reasoning-effort guidance
4. Repo conventions
5. Risk boundaries
6. Lessons-file location
7. Scope boundaries

## Minimal `AGENTS.md` Template

```md
# Repo Instructions

Use this file before making code, CI, issue, or PR changes in this repository.

## Core Workflow

1. Build context before editing.
2. Prefer root-cause fixes over symptom patches.
3. Use the smallest maintainable change.
4. Verify with the closest local equivalent of CI or production behavior.
5. Summarize root cause, fix, verification, and residual risk.

## Required Checks

- Setup: [install command]
- Test: [test command]
- Lint: [lint command]
- Build: [build command]

## Reasoning Effort

- Default to `medium`.
- Use `low` for small obvious local work.
- Use `high` for ambiguity, multi-step debugging, or riskier changes.
- Use `xhigh` only when the task is broad, difficult, or expensive to get wrong.

## Repo Conventions

- [branching rule]
- [PR title/body rule]
- [issue rule]
- [style or architecture rule]

## Scope Boundaries

- keep team-shared repo rules here
- keep personal preferences or secrets out of committed files
- keep subsystem-specific rules close to the subsystem when needed

## Do-Not Rules

- [never bypass tests]
- [never patch around upstream semantics]
- [never skip architecture/platform checks]

## Local Lessons

Before PR or issue work, read:
- [topic-insights.md]

If a maintainer reveals a new convention, update that file before continuing similar work.
```

## Recommended Bootstrap Process For Every New Repo

1. Create root `AGENTS.md`.
2. Create a repo-specific lessons file.
3. Add build, test, lint, and validation commands immediately.
4. Decide what belongs in personal/global config versus repo-local config.
5. Add the first 5 to 10 repo conventions only.
6. After the first real PR review, update the lessons file with what was learned.
7. If the same correction keeps repeating, promote it into `AGENTS.md`, a repo command, or another reusable asset.
8. Add component-local instructions only when a subsystem truly needs them.
9. Prune stale instructions instead of only appending.

## How To Make This Scale Across Many Repos

### Option A: Manual but clean

For each new repo:

1. Copy the `AGENTS.md` template
2. Fill in commands and conventions
3. Add a repo lessons file

This is the most reliable option.

### Option B: Use a personal repo template

Keep a starter repo or snippet collection containing:

- base `AGENTS.md`
- base lessons file
- optional `.github/copilot-instructions.md`

When starting a new repo, copy from that template.

This is the best balance for most people.

### Option C: Script the bootstrap

Use the hub's bash automation to bootstrap missing files and refresh only the managed core.

Use this if you initialize lots of repos.

Scripts available in `scripts/`:
- `propagate-to-all.sh` - bootstrap missing repo files and refresh the managed core
- `check-sync-status.sh` - report managed-core drift versus repo-owned-by-design files
- `harvest-topic-insights.sh` - collect repo-owned lessons into a central snapshot
- `build-cross-domain-candidates.sh` - build explicit promotion candidates from the harvested snapshot
- `merge-and-propagate.sh` - merge one approved candidate into the hub and optionally re-propagate the managed core

### Safe sync rule

The propagation workflow uses two ownership classes:

- **Hub-owned managed core** can be refreshed
- **Repo-owned files** are bootstrapped once and then left alone

That means:

- `AGENTS.md`, `archive/superseded/workspace-system-overview.md`, `git-github-best-practices.md`, `quality-standards.md`, `audit-folder-quality.sh`, `check-sync-status.sh`, and `sync-from-hub.sh` can be updated from the hub
- `session-state.json`, `archive/history-index.md`, `archive/history-full-detailed.md`, `topic-insights.md`, and `.cleanup-protect` are repo-owned after bootstrap and are never overwritten by propagation

### Example sync usage

```bash
cd scripts
bash ./propagate-to-all.sh --folder repo-one --preview
bash ./propagate-to-all.sh --folder repo-two --preview
```

To refresh the managed core across all repos:

```bash
cd scripts
bash ./propagate-to-all.sh --preview
```

Runs in preview mode by default. Use `--apply` to write changes.

Then rerun with `--apply` when the target set looks correct.

### Cross-domain registry workflow

Refresh the managed core, then harvest lessons, then build candidates:

```bash
cd scripts
bash ./propagate-to-all.sh --apply
bash ./harvest-topic-insights.sh
bash ./build-cross-domain-candidates.sh
```

Promotion stays manual. After reviewing a candidate, use `merge-and-propagate.sh` to merge it into the hub and optionally run another managed-core refresh.

## Current Source-Backed Guidance

As of April 10, 2026, the most consistent official pattern is:

- keep instructions in repo files
- keep them concise
- include validation steps
- keep sessions focused
- give agents concrete context and acceptance criteria

For details, see:

- [authoritative-agent-best-practices.md](authoritative-agent-best-practices.md)

## Cross-Project Memory Loop

If you want this system to keep getting better, repos need a path to feed lessons back here.

Use this loop:

1. Capture the lesson locally in the repo's lessons file.
2. Keep repo-specific details local unless the lesson changes how work should be done elsewhere.
3. Harvest candidate lessons into this central repo on a regular cadence.
4. Build a smaller promotion-review queue from the harvested lessons.
5. Record review decisions so promoted, local-only, and discarded candidates stay tracked across rebuilds.
6. Generalize and deduplicate the reviewed candidates here.
7. Promote the reusable parts into the right central docs or templates.
8. Redistribute the updated templates back out with the sync scripts.

If the promotion-review queue is empty across existing repos, that usually means those repos still need a template resync so their local lessons files expose the newer structure cleanly.

For the concrete procedure, see:

- [cross-project-memory-loop.md](cross-project-memory-loop.md)

## My Recommendation

If you want one system that works well across tools and repos, do this:

1. Keep this folder as your canonical library.
2. Put a short `AGENTS.md` in every repo root.
3. Put a local lessons file in every repo that has non-obvious culture.
4. Only add GitHub-specific instruction files when you actively use GitHub Copilot there.

That gives you consistency without stuffing every project with too much text.
