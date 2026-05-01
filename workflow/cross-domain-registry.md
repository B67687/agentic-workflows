# Cross-Domain Registry

Central index of folders participating in the cross-domain knowledge flow.

## Registry

| Folder | Path | Status | Notes |
|--------|------|--------|-------|
| ai-prompting | `/home/namikaz/projects/dev/ai-prompting` | Central Hub | Central knowledge base and workflow owner |
| bus-app | `/home/namikaz/projects/dev/bus-app` | Active | Topic folder with repo-owned insights |
| fengshui | `/home/namikaz/projects/dev/fengshui` | Active | Topic folder with repo-owned insights |
| fluent-prs | `/home/namikaz/projects/dev/fluent-prs` | Active | Topic folder with repo-owned insights |
| hugo | `/home/namikaz/projects/dev/hugo` | Active | Topic folder with repo-owned insights |
| image-glass | `/home/namikaz/projects/dev/image-glass` | Active | Topic folder with repo-owned insights |
| image-magick | `/home/namikaz/projects/dev/image-magick` | Active | Topic folder with repo-owned insights |
| keyboard | `/home/namikaz/projects/dev/keyboard` | Active | Topic folder with repo-owned insights |
| math-learning-notes | `/home/namikaz/projects/dev/math-learning-notes` | Active | Topic folder with repo-owned insights |
| no-face-scan-app | `/home/namikaz/projects/dev/no-face-scan-app` | Active | Topic folder with repo-owned insights |
| open-codex | `/home/namikaz/projects/dev/open-codex` | Active | Topic folder with repo-owned insights |
| random | `/home/namikaz/projects/dev/random` | Active | Topic folder with repo-owned insights |
| reality | `/home/namikaz/projects/dev/reality` | Active | Topic folder with repo-owned insights |
| rss-reader | `/home/namikaz/projects/dev/rss-reader` | Active | Topic folder with repo-owned insights |
| wall-you | `/home/namikaz/projects/dev/wall-you` | Active | Topic folder with repo-owned insights |

## How to Add a New Folder

1. Create the new folder under `/home/namikaz/projects/dev`.
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
central_hub: ai-prompting
version: 2.0
last_updated: 2026-04-30
active_topic_folders: 14
workflow_mode: manual-approval
---
```
