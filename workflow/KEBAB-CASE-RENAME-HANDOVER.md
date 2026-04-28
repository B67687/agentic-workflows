# Kebab-Case Rename Handoff

## What Happened

All 14 topic folders + hub have been or are being renamed to kebab-case:
- `Bus App` → `bus-app`
- `Fluent PRs` → `fluent-prs`
- `Image Glass` → `image-glass`
- `ImageMagick` → `imagemagick`
- `MathLearningNotes` → `math-learning-notes`
- `NoFaceScanApp` → `no-face-scan-app`
- `RSS Reader` → `rss-reader`
- `Wall You` → `wall-you`
- `AI Prompting` → `ai-prompting` (hub itself)

## Current Status

- Propagation completed successfully
- All 14 topic folders have proper structure:
  - 9+ root files (AGENTS.md, scripts, etc.)
  - content/ folder
  - docs/workspace-system-overview.md
  - archive/history.md

## What Needs to Happen After Rename

### 1. Update Propagation Scripts

The propagation script needs to know about the new folder names. After rename:

```bash
# Verify propagation still works
cd /home/namikaz/projects/dev/ai-prompting
./scripts/propagate-to-all.sh --check
```

### 2. Update check-sync-status.sh

Each topic folder's check-sync-status.sh references the parent folder name. These may need updating after rename.

### 3. Verify Scripts Work

Run in each folder:
```bash
./audit-folder-quality.sh
./check-sync-status.sh
```

## Folder Structure After Rename

```
/home/namikaz/projects/dev/
├── ai-prompting/          (hub)
│   ├── docs/
│   ├── propagation/
│   ├── scripts/
│   └── workflow/
├── bus-app/
│   ├── bus-app-content/
│   ├── docs/
│   └── ...
├── fluent-prs/
│   ├── fluent-prs-content/
│   ├── meta/
│   └── ...
└── ... (12 more folders)
```

## Key Files That Reference Folder Names

| File | What it references |
|------|-------------------|
| scripts/propagate-to-all.sh | Topic folder names (auto-scans) |
| scripts/check-sync-status.sh | Parent folder path |
| .opencode/package.json | Dependencies (safe) |
| */.git/config | Git remotes (may need update) |

## Testing Checklist

After rename completes:

- [ ] Verify all 15 folders (14 + hub) renamed correctly
- [ ] Run `./scripts/propagate-to-all.sh --check` from hub
- [ ] In each folder: `./check-sync-status.sh`
- [ ] In each folder: `./audit-folder-quality.sh`
- [ ] Git status in each folder - remotes may need update

## Resume Rules

When resuming work after rename:

1. Read `workflow/session-state.json` FIRST
2. Check that all folder names are consistent
3. Verify scripts reference correct paths
4. Run check-sync-status.sh in each folder

## Contact

This handoff was created during Session 54.
