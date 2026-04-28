# AI Prompting Workspace System Overview

This workspace is the control hub for `M:\M-Namikaz-Others`.

**Current environment:** Debian/WSL2 (2026-04-28). Primary terminal is WSL. All scripts use bash/Linux tooling.

It is not a normal app repo. It is a living knowledge base for:

- storing durable prompting and workflow knowledge
- capturing research findings
- promoting reusable lessons across topic folders
- propagating shared instruction files
- recovering context after long sessions
- keeping topic-folder roots clean
- preserving user content in meta/ folders

**What this system is NOT:** A code project with build outputs. It's a personal AI productivity system that learns from your work and distributes useful patterns to topic folders.

Shortest version:

> This hub learns useful patterns, stores them in central docs, and pushes reusable parts out to topic folders while protecting your custom content.

## 30-Second Read

| Subsystem | What it does | Main locations |
|---|---|---|
| Central knowledge | Stable guidance and research synthesis | `docs/`, `research/`, `archive/` |
| Distribution | Copies reusable rules outward | `propagate-templates/`, `scripts/propagate-to-all.sh` |
| Live workflow state | Tracks current work, sync state, harvested lessons, review queues | `workflow/` |

Most work follows:

```text
research -> integrate -> propagate -> verify -> document
```

Most important practical rules:

> On every resume, read `workflow/session-state.json` first.
> Then read `AGENTS.md` - it's the operating contract for this workspace.

## Fast Startup Protocol

| Step | Read | Why |
|---|---|---|
| 1 | `workflow/session-state.json` | Current task, last work, next action. |
| 2 | `docs/hub-quickstart.md` | Fast orientation (replaces multi-file startup). |
| 3 | Task-specific files | Deep docs, topic folders, scripts, or research logs. |

Do not start with a full repository scan unless the task actually needs it.

For topic-folder work:

- If `[Topic]/meta/HANDOVER.md` exists and you are resuming topic work, read it first.
- Otherwise read `[Topic]/AGENTS.md`, then `topic-insights.md`, then local `meta/` files if present.
- Real project work belongs in `[Topic]/[topic-name]-content/`.

## Hub vs Topic Folders

| Area | What it is | Where normal work goes |
|---|---|---|
| `AI Prompting` hub | Central knowledge and propagation system | `docs/`, `research/`, `scripts/`, `workflow/`, `propagate-templates/`, `archive/`, `personal-voice/` |
| Sibling topic folders | Individual project/topic workspaces | `[topic-name]-content/` |

Current topic folders (15):
`Bus App`, `Fengshui`, `Fluent PRs`, `Hackerthon`, `Hugo`, `Image Glass`, `ImageMagick`, `Keyboard`, `MathLearningNotes`, `NoFaceScanApp`, `OpenCodex`, `Random`, `Reality`, `RSS Reader`, `Wall You`

Do not create `ai-prompting-content/` in this hub unless the whole hub is intentionally redesigned.

**Content folder naming:** Uses simple kebab-case: lowercase + spaces to dashes. Example: "Fluent PRs" → `fluent-prs-content`

Expected topic-folder root:

```text
[Topic-Folder]/
|- AGENTS.md                    (propagated from hub)
|- topic-insights.md            (propagated from hub)
|- git-github-best-practices.md (propagated from hub)
|- quality-standards.md         (propagated from hub)
|- session-state.json           (propagated from hub)
|- .cleanup-protect             (propagated from hub)
|- audit-folder-quality.ps1     (propagated from hub)
|- check-sync-status.ps1        (propagated from hub)
|- sync-from-hub.ps1            (propagated from hub)
|- opencode.json                (propagated from hub)
|- opencode-agent-system.md     (propagated from hub)
|- [topic-name]-content/        (created by propagation - YOUR WORK GOES HERE)
`- meta/                       (optional - NEVER touched by hub propagation)
```

**Critical: meta/ is protected.** Hub propagation only touches root files. Your custom content in `meta/` is never overwritten or deleted.

## Top-Level Folder Map

| Path | Role |
|---|---|
| `docs/` | Main knowledge base. |
| `research/` | Active research intake and distilled findings. |
| `propagate-templates/` | Source templates copied into topic folders. |
| `scripts/` | Automation for propagation, sync checks, harvesting, review queues, cleanup, and audits. |
| `workflow/` | Stateful files: session state, sync state, registries, harvested lessons, review queues. |
| `archive/` | Preserved historical material, old logs, research campaigns, raw snapshots. |
| `personal-voice/` | User voice profile, samples, style injection, correction log. |

Root files:

| File | Role |
|---|---|
| `AGENTS.md` | Operating contract. Read after `workflow/session-state.json`. |
| `README.md` | Navigation index. |
| `opencode.json` | Local tool configuration. |

## Terminal Strategy

**Current (2026-04-28):** Primary terminal is Debian/WSL2. Windows filesystem accessible via `/mnt/M/`.

- Use native Linux commands and `scripts/ws.sh` for read-only inspection
- Use `scripts/propagate-to-all.sh` (bash) for propagation and mutating operations
- All hub scripts have been converted to bash for Linux-native execution
- See `docs/repo-tooling.md` for the Linux tool baseline

## Main Operating Loop

### 1. Research

Active research goes in `research/research-log.md`.

Completed long campaigns move to `archive/`.

Durable distilled findings go in `docs/research-findings.md`.

### 2. Integrate

Rewrite useful findings into the smallest correct central doc:

- context/cost lessons -> `docs/token-efficient-prompting.md`
- product or agent architecture -> `docs/ai-product-building.md`
- general workflow doctrine -> `docs/core-agent-doctrine.md`
- model routing -> `docs/model-selection-guide.md`
- research source quality -> `docs/research-methodology.md`
- cross-project lesson flow -> `docs/cross-project-memory-loop.md`

Track integration in `research/integration-log.md`.

### 3. Propagate

Propagate only when new topic folders need templates. **Does NOT overwrite existing files** (CREATE ONLY mode).

Current templates (13):

- `propagate-templates/AGENTS.template.md` - Operating contract (includes 11 principles)
- `propagate-templates/topic-insights.template.md` - Topic lessons
- `propagate-templates/git-github-best-practices.template.md` - Git workflow
- `propagate-templates/workspace-system-overview.template.md` - System overview reference
- `propagate-templates/audit-folder-quality.template.ps1` - Quality validation
- `propagate-templates/check-sync-status.template.ps1` - Sync status checker
- `propagate-templates/sync-from-hub.template.ps1` - Sync from hub script
- `propagate-templates/quality-standards.template.md` - Quality standards
- `propagate-templates/session-state.template.md` - Session state template
- `propagate-templates/opencode.template.json` - OpenCode config
- `propagate-templates/opencode-agent-system.template.md` - Agent system prompt
- `propagate-templates/.cleanup-protect.template.md` - Cleanup protection
- `propagate-templates/README.md` - Template index

Run:

```bash
# Currently requires Windows PowerShell or pwsh
# Bash version coming soon
pwsh ./scripts/propagate-to-all.ps1 -Apply
```

Content folder creation: The script creates `[topic-name]-content/` automatically with kebab-case naming.

### 4. Verify

For hub work:

```bash
bash scripts/ws.sh validate
bash scripts/ws.sh status
bash scripts/ws.sh hotspots
```

Use `bash scripts/ws.sh status`, `hotspots`, and `search -q "text"` for the common orientation and inspection loop.

For topic-folder structure work, also run that folder's:

```bash
./audit-folder-quality.sh
```

### 5. Document

At the end of meaningful work:

- update `workflow/session-state.json`
- link any archived detail instead of bloating hot-path files

## Source vs Generated Files

Usually edit directly:

- `AGENTS.md`, `README.md`
- `docs/*.md`
- `research/*.md`
- `propagate-templates/*`
- `workflow/session-state.json`
- `workflow/cross-domain-registry.md`

Usually generated or refreshed by scripts:

- `workflow/harvested-topic-insights.md`
- `workflow/cross-domain-candidates.md`
- `workflow/sync-state.json`

Generated files can be large. They should not be part of the default cold-start path.

## What This Optimizes For

This system tries to make work compound:

- learn from the task
- save the lesson
- generalize it when useful
- push it to other folders when appropriate
- reduce future rework

**Core principle:**

> **Prefer simple code, add complexity only when concrete system demand requires it.**
>
> - Prefer simple code. It reads faster, debugs easier, and ages better.
> - Add complexity only when a concrete system interaction or real-world use case demands it.
> - Premature abstraction is as harmful as premature optimization.
> - If you can't explain why a pattern is needed, it probably isn't.

This principle (in `docs/core-agent-doctrine.md` section 2C) reflects a key lesson from fixing the kebab-case bug: complex regex over-engineering caused a simple problem. Simpler is usually better.

Better work now should make the next work easier.

## Main Hub Scripts

**Linux/WSL Scripts:**

| Script | Purpose |
|---|---|
| `scripts/ws.sh` | Read-only: status, hotspots, validate, search |
| `scripts/propagate-to-all.sh` | Sync templates to topic folders (CREATE ONLY) |
| `scripts/migrate-templates.sh` | Migrate existing files to new template format |
| `scripts/audit-folder-quality.sh` | Validate active authored files |
| `scripts/check-sync-status.sh` | Check propagation freshness |
| `scripts/harvest-topic-insights.sh` | Collect topic lessons from all folders |
| `scripts/build-cross-domain-candidates.sh` | Build promotion queue for cross-domain lessons |
| `scripts/merge-and-propagate.sh` | Merge reviewed lessons and propagate |

Run `bash scripts/ws.sh` without arguments for quick help.