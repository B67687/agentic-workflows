# Propagation Templates

This folder contains templates that get propagated to subfolders in the M-Namikaz-Others workspace.

## Templates

| File | Purpose |
|------|---------|
| `AGENTS.template.md` | Main repo instruction file - copied as `AGENTS.md` |
| `topic-insights.template.md` | Local lessons tracking - copied as `topic-insights.md` |
| `.cleanup-protect.template.md` | Cleanup protection list - copied as `.cleanup-protect` |
| `git-github-best-practices.template.md` | Git/GitHub guidance - copied as `git-github-best-practices.md` |
| `audit-folder-quality.template.ps1` | Quality audit script - copied as `audit-folder-quality.ps1` |
| `opencode-agent-system.template.md` | Agentic workflow guide - copied as `opencode-agent-system.md` |
| `opencode.template.json` | OpenCode native agent config - copied as `opencode.json` |
| `sync-from-hub.template.ps1` | Self-service sync script - copied as `sync-from-hub.ps1` |
| `skills-template/` | Agent Skills templates and examples for `.opencode/skills/` |

## Two-Git Architecture

This workspace uses a nested git structure that allows tracking propagated files separately from public project code.

### Structure

```
project-folder/
|
|- .git                    ← Only tracks files in this folder (GitHub push)
|  |- .gitignore           ← Exclude propagated files
|  |- src/                 ← Public code
|
|- .git                    ← Tracks: everything at workspace root (local)
|
|- AGENTS.md              ← Propagated (tracked in root git only)
|- topic-insights.md      ← Propagated (tracked in root git only)
|- .cleanup-protect       ← Propagated (tracked in root git only)
|- project-folder-content/ ← Mandatory primary operating area
```

### How It Works

1. **Top-level git** (at M-Namikaz-Others): Tracks all propagated files and AGENTS.md
2. **Project git** (inside subfolder): Only tracks files in that specific project for GitHub
3. **GitHub push**: Use only the project-level git to push to GitHub
4. **Content folder**: Propagation creates `[folder-name]-content/` as the primary operating area for normal project work
5. **Optional meta**: Create `meta/` only when a project needs durable local context or handover notes
6. **Cleanup protection**: The `.cleanup-protect` file prevents propagated files from being deleted by cleanup scripts

### Root Discipline

The project folder root is for propagated files and truly root-scoped control files. Put normal work in `[folder-name]-content/`.

Root should not collect source folders, notes, docs, assets, downloads, archives, logs, temp folders, datasets, drafts, or duplicate legacy content folders. If old root content exists, classify it first and move only safe content; do not move `.git`, active project roots, caches, or tool-specific folders without explicit approval.

### Keeping Public Repos Clean

For repos that will be pushed to GitHub:

1. Add propagated files to the project's `.gitignore`:
   ```
   # AI-Prompting-Library propagated files
   AGENTS.md
   topic-insights.md
   .cleanup-protect
   ```

2. Run propagation on private repos only
3. The two-git architecture naturally keeps propagated files separate

## Propagation

Run from AI Prompting folder:
```bash
./scripts/propagate-to-all.sh --apply
```

This syncs templates to all subfolders in M-Namikaz-Others.

**Behavior:** CREATE ONLY mode
- Files are only created if they don't exist
- Existing files are NEVER overwritten or merged
- This preserves all custom content in topic folders

**For standards changes (migration):** If you change the template format and need to propagate the new format to all folders while converting existing content, use:
```bash
./scripts/migrate-templates.sh --template NAME --apply
```
