# Cross-Domain Registry

Central index of folders participating in the cross-domain knowledge flow.

## Registry

| Folder | Path | Status | Notes |
|--------|------|--------|-------|
| agentic-workflows | `./` | Central Hub | Central knowledge base and workflow owner |
| *topic-folders* | `../<name>/` | Active | Propagated topic folders with repo-owned insights |

## How to Add a New Folder

1. Create the new folder under your topic folders root (e.g. `../<name>/`).
2. Run `bash ./scripts/propagate-to-all.sh --apply`.
3. Confirm the folder has the managed core plus repo-owned bootstrap files.
4. Use `[folder-name]-content/` as the primary operating area for normal project work.
5. Add an entry to this registry with status `Active`.
6. The folder will be picked up by `harvest-topic-insights.sh` when it has `topic-insights.md`.

## Status Definitions

| Status | Meaning |
|--------|---------|
| Central Hub | The main hub that owns the shared doctrine and templates |
| Active | Participating in the cross-domain lesson flow |
| Archived | No longer active, kept only for history |

## Metadata

```yaml
---
central_hub: agentic-workflows
version: 2.0
last_updated: 2026-05-08
active_topic_folders: 14
workflow_mode: manual-approval
---
```
