# ai-prompting Workspace System Overview

This workspace is the control hub for `/home/namikaz/projects/dev`.

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
| Distribution | Copies reusable rules outward | `propagation/`, `scripts/propagate-to-all.sh` |
| Live workflow state | Tracks current work, sync state, harvested lessons, review queues | `workflow/` |

Most work follows:

```text
research -> integrate -> propagate -> verify -> document
```

Most important practical rules:

> On every resume, read `session-state.json` first.
> Then read `AGENTS.md` - it's the operating contract for this workspace.

## Fast Startup Protocol

| Step | Read | Why |
|---|---|---|
| 1 | `session-state.json` | Current task, last work, next action. |
| 2 | `docs/hub-quickstart.md` | Fast orientation (replaces multi-file startup). |
| 3 | Task-specific files | Deep docs, topic folders, scripts, or research logs. |

Do not start with a full repository scan unless the task actually needs it.

For topic-folder work:

- Use `meta/HANDOVER.md` only as historical context when the root `session-state.json`, `AGENTS.md`, and overview docs are not enough.
- Otherwise read `[Topic]/session-state.json`, then `[Topic]/AGENTS.md`, then `[Topic]/docs/workspace-system-overview.md`, and only then local `meta/` files if present.
- Real project work belongs in `[Topic]/[topic-name]-content/`.

## Hub vs Topic Folders

| Area | What it is | Where normal work goes |
|---|---|---|
| ai-prompting hub | Central knowledge and propagation system | `docs/`, `research/`, `scripts/`, `workflow/`, `propagation/`, `archive/`, `personal-voice/` |
| Sibling topic folders | Individual project/topic workspaces | `[topic-name]-content/` |

Current topic folders (15):
`bus-app`, `fengshui`, `fluent-prs`, `hackerthon`, `hugo`, `image-glass`, `imagemagick`, `keyboard`, `math-learning-notes`, `no-face-scan-app`, `opencodex`, `random`, `reality`, `rss-reader`, `wall-you`

Do not create `ai-prompting-content/` in this hub unless the whole hub is intentionally redesigned.

**Content folder naming:** Uses simple kebab-case: lowercase + spaces to dashes. Example: "Fluent PRs" → `fluent-prs-content`

Fast iteration rules:

- broad tasks should become milestone ladder plus first executable slice
- after two planning refinements, stop broadening and choose the next slice
- one verified slice beats one giant speculative plan

Expected topic-folder root:

```text
[Topic-Folder]/
|- AGENTS.md                         (hub-owned managed core)
|- docs/workspace-system-overview.md (hub-owned managed core)
|- git-github-best-practices.md      (hub-owned managed core)
|- quality-standards.md              (hub-owned managed core)
|- audit-folder-quality.sh           (hub-owned managed core)
|- check-sync-status.sh              (hub-owned managed core)
|- sync-from-hub.sh                  (hub-owned managed core)
|- task-intake.sh                    (hub-owned managed core)
|- task-slice.sh                     (hub-owned managed core)
|- phase-gate.sh                     (hub-owned managed core)
|- plan-guard.sh                     (hub-owned managed core)
|- checkpoint-commit.sh              (hub-owned managed core)
|- session-state.json                (repo-owned after bootstrap)
|- topic-insights.md                 (repo-owned after bootstrap)
|- .cleanup-protect                  (repo-owned after bootstrap)
|- archive/history-index.md          (repo-owned after bootstrap)
|- archive/history-full-detailed.md  (repo-owned after bootstrap)
|- [topic-name]-content/             (created by propagation - YOUR WORK GOES HERE)
`- meta/                             (optional - NEVER touched by hub propagation)
```

**Critical: meta/ is protected.** Hub propagation only touches root files. Your custom content in `meta/` is never overwritten or deleted.

## Top-Level Folder Map

| Path | Role |
|---|---|
| `docs/` | Main knowledge base. |
| `research/` | Active research intake and distilled findings. |
| `propagation/` | Source templates copied into topic folders. |
| `scripts/` | Automation for propagation, sync checks, harvesting, review queues, cleanup, and audits. |
| `workflow/` | Stateful files: session state, sync state, registries, harvested lessons, review queues. |
| `archive/` | Preserved historical material, old logs, research campaigns, raw snapshots. |
| `personal-voice/` | User voice profile, samples, style injection, correction log. |

Root files:

| File | Role |
|---|---|
| `AGENTS.md` | Operating contract. Read after `session-state.json`. |
| `README.md` | Navigation index. |

## Terminal Strategy

**Current (2026-04-30):** Primary terminal is Debian/WSL2. Use Linux paths and bash-first tooling by default.

- Use native Linux commands and `scripts/ws.sh` for read-only inspection
- Use `scripts/propagate-to-all.sh` (bash) for propagation and mutating operations
- All hub scripts have been converted to bash for Linux-native execution
- See `docs/repo-tooling.md` for the Linux tool baseline

## Governance Model

- Global runtime authority: `/home/namikaz/.config/opencode/opencode.jsonc`
- Per-repo resume authority: root `session-state.json`
- Per-repo context order: `session-state.json` -> `AGENTS.md` -> `docs/workspace-system-overview.md` -> repo content and `meta/`
- Repo-local OpenCode runtime config is not part of the supported structure
- Workspace-level `.opencode/` directories are not part of the supported structure
- After model, tool, OS, or app-variant changes, run a repo-wide scan and remove stale runtime assumptions before continuing normal work

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

Propagation has two behaviors:

- bootstrap missing shared files into topic folders
- refresh only the hub-owned managed core in existing topic folders

Current template ownership split:

- Managed core:
  - `propagation/AGENTS.template.md`
  - `propagation/workspace-system-overview.template.md`
  - `propagation/git-github-best-practices.template.md`
  - `propagation/quality-standards.template.md`
  - `propagation/audit-folder-quality.template.sh`
  - `propagation/check-sync-status.template.sh`
  - `propagation/sync-from-hub.template.sh`
- Repo-owned after bootstrap:
  - `propagation/topic-insights.template.md`
  - `propagation/session-state.template.json`
  - `propagation/.cleanup-protect.template.md`
  - `propagation/history-index.template.md`
  - `propagation/history-full-detailed.template.md`

Run:

```bash
bash ./scripts/propagate-to-all.sh
bash ./scripts/propagate-to-all.sh --apply
```

Content folder creation: the script creates `[topic-name]-content/` automatically with kebab-case naming.
Managed refresh never overwrites repo-owned files like `session-state.json`, `topic-insights.md`, or archive history.

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

- update `session-state.json`
- link any archived detail instead of bloating hot-path files

## Source vs Generated Files

Usually edit directly:

- `AGENTS.md`, `README.md`
- `docs/*.md`
- `research/*.md`
- `propagation/*`
- `session-state.json`
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
