# AI Prompting Workspace System Overview

This workspace is the control hub for `M:\M-Namikaz-Others`.

It is not a normal app repo. It is a working system for:

- storing durable prompting and workflow knowledge
- capturing research findings
- promoting reusable lessons across topic folders
- propagating shared instruction files
- recovering context after long sessions
- keeping topic-folder roots clean

Shortest version:

> This hub learns useful working patterns, stores them in central docs, and pushes reusable parts out to topic folders.

## 30-Second Read

| Subsystem | What it does | Main locations |
|---|---|---|
| Central knowledge | Stable guidance and research synthesis | `docs/`, `research/`, `archive/` |
| Distribution | Copies reusable rules outward | `propagate-templates/`, `scripts/propagate-to-all.ps1` |
| Live workflow state | Tracks current work, sync state, harvested lessons, review queues | `workflow/` |

Most work follows:

```text
research -> integrate -> propagate -> verify -> document
```

Most important practical rule:

> On every resume, read `workflow/session-state.json` first.

## Fast Startup Protocol

| Step | Read | Why |
|---|---|---|
| 1 | `workflow/session-state.json` | Current task, last work, next action, risks, files touched. |
| 2 | `AGENTS.md` | Operating rules. |
| 3 | `docs/workspace-system-overview.md` | System map without scanning the whole workspace. |
| 4 | `README.md` | Navigation to the right docs/scripts. |
| 5 | Task-specific files | Deep docs, topic folders, scripts, or research logs. |

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

Do not create `ai-prompting-content/` in this hub unless the whole hub is intentionally redesigned.

Expected topic-folder root:

```text
[Topic-Folder]/
|- AGENTS.md
|- topic-insights.md
|- git-github-best-practices.md
|- .cleanup-protect
|- audit-folder-quality.ps1
|- [topic-name]-content/
`- meta/                  optional
```

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

Use PowerShell for mutating hub automation. This workspace is Windows-filesystem and most write workflows are PowerShell-script based.

WSL can be used for native Linux read-only inspection through `scripts/ws.sh`. See `docs/repo-tooling.md` for the shared Windows/WSL tool baseline.

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

Propagate only when shared topic-folder defaults changed.

Main sources:

- `propagate-templates/AGENTS.template.md`
- `propagate-templates/topic-insights.template.md`
- `propagate-templates/git-github-best-practices.template.md`
- `propagate-templates/audit-folder-quality.template.ps1`
- `propagate-templates/.cleanup-protect.template.md`

Run:

```powershell
.\scripts\propagate-to-all.ps1 -Apply
```

### 4. Verify

For hub work:

```powershell
.\scripts\ws.ps1 validate
.\scripts\audit-folder-quality.ps1
.\scripts\check-sync-status.ps1
```

Use `.\scripts\ws.ps1 status`, `hotspots`, and `search -Query "text"` for the common orientation and inspection loop.

For topic-folder structure work, also run that folder's:

```powershell
.\audit-folder-quality.ps1
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

Better work now should make the next work easier.
