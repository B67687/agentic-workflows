# Cross-Domain Registry

Central index of folders participating in the cross-domain knowledge flow.

## Registry

| Folder | Path | Status | Joined |
|--------|------|--------|--------|
| AI Prompting | M:\M-Namikaz-Others\AI Prompting | Central Hub | 2026-04-19 |
| AnotherNotes | M:\M-Namikaz-Others\AnotherNotes | Active | 2026-04-19 |
| BulkCrapUninstaller | M:\M-Namikaz-Others\BulkCrapUninstaller | Active | 2026-04-19 |
| Bus App | M:\M-Namikaz-Others\Bus App | Active | 2026-04-19 |
| Claude Code Source | M:\M-Namikaz-Others\Claude Code Source | Active | 2026-04-19 |
| Claw Code | M:\M-Namikaz-Others\Claw Code | Active | 2026-04-19 |
| Codex Replacement | M:\M-Namikaz-Others\Codex Replacement | Archived | 2026-04-19 |
| Comfer | M:\M-Namikaz-Others\Comfer | Active | 2026-04-19 |
| Computer Organisation and Architecture | M:\M-Namikaz-Others\Computer Organisation and Architecture | Archived | 2026-04-22 |
| Fengshui | M:\M-Namikaz-Others\Fengshui | Active | 2026-04-19 |
| Fluent Search Manifest | M:\M-Namikaz-Others\Fluent Search Manifest | Active | 2026-04-19 |
| Hackerthon | M:\M-Namikaz-Others\Hackerthon | Active | 2026-04-21 |
| Handbrake | M:\M-Namikaz-Others\Handbrake | Active | 2026-04-19 |
| Hugo | M:\M-Namikaz-Others\Hugo | Active | 2026-04-19 |
| Image Glass | M:\M-Namikaz-Others\Image Glass | Active | 2026-04-19 |
| ImageMagick | M:\M-Namikaz-Others\ImageMagick | Active | 2026-04-22 |
| Keyboard | M:\M-Namikaz-Others\Keyboard | Active | 2026-04-19 |
| LocalSend | M:\M-Namikaz-Others\LocalSend | Active | 2026-04-19 |
| MathLearningNotes | M:\M-Namikaz-Others\MathLearningNotes | Active | 2026-04-19 |
| NoFaceScanApp | M:\M-Namikaz-Others\NoFaceScanApp | Active | 2026-04-21 |
| Noise Generator | M:\M-Namikaz-Others\Noise Generator | Active | 2026-04-19 |
| OOP Project | M:\M-Namikaz-Others\OOP Project | Active | 2026-04-19 |
| OpenCode | M:\M-Namikaz-Others\OpenCode | Active | 2026-04-19 |
| Random | M:\M-Namikaz-Others\Random | Active | 2026-04-19 |
| Reality | M:\M-Namikaz-Others\Reality | Active | 2026-04-19 |
| UniGetUI | M:\M-Namikaz-Others\UniGetUI | Active | 2026-04-19 |
| Wall You | M:\M-Namikaz-Others\Wall You | Active | 2026-04-19 |

## How to Add a New Folder

1. Create the new folder.
2. Run `scripts/propagate-to-all.ps1 -Folders [FolderName] -Apply`.
3. Confirm the folder has `AGENTS.md`, `topic-insights.md`, `.cleanup-protect`, and `[folder-name]-content/`.
4. Use `[folder-name]-content/` as the primary operating area for normal project work.
5. Add entry to this registry with status "Active" and current date.
6. The folder will be picked up by `harvest-topic-insights.ps1` automatically.

## Status Definitions

| Status | Meaning |
|--------|---------|
| Central Hub | AI Prompting - the central knowledge base |
| Active | Participating in cross-domain flow |
| Pending write access | Folder exists but propagation could not write required files |
| Inactive | Has `topic-insights.md` but not participating |
| Archived | No longer active |

## Metadata

```yaml
---
central_hub: AI Prompting
version: 1.0
created: 2026-04-19
last_updated: 2026-04-22
total_folders: 25
---
```

