# Propagation Analysis - Pass 3: Strategy Determination

## Template Files Available in Hub

| Template | Target | Status |
|----------|--------|--------|
| AGENTS.template.md | AGENTS.md | ✓ Standard |
| .cleanup-protect.template.md | .cleanup-protect | ✓ Standard |
| session-state.template.json | session-state.json | ✓ Standard |
| topic-insights.template.md | topic-insights.md | ✓ Standard |
| git-github-best-practices.template.md | git-github-best-practices.md | ✓ Standard |
| quality-standards.template.md | quality-standards.md | ✓ Standard |
| workspace-system-overview.template.md | docs/workspace-system-overview.md | ✓ Updated for docs/ |
| opencode.template.json | opencode.json | ✓ Standard |
| audit-folder-quality.template.sh | audit-folder-quality.sh | ✓ Bash converted |
| check-sync-status.template.sh | check-sync-status.sh | ✓ Bash converted |
| sync-from-hub.template.sh | sync-from-hub.sh | ✓ Bash converted |
| history.template.md | archive/history.md | ✓ Standard |

## File Categorization by Strategy

### Category A: DIRECT PROPAGATE (Safe - No Custom Content)
These files match templates exactly and can be safely propagated:

| File | Folders Affected |
|------|------------------|
| AGENTS.md | All 14 (all have this) |
| .cleanup-protect | All 14 (all have this) |
| session-state.json | All 14 (all have this) |
| topic-insights.md | All 14 (all have this) |
| git-github-best-practices.md | All 14 (all have this) |
| quality-standards.md | All 14 (all have this) |
| opencode.json | All 14 (all have this) |
| audit-folder-quality.sh | All 14 (all have this - converted from PS1) |
| check-sync-status.sh | All 14 (all have this - converted from PS1) |
| sync-from-hub.sh | All 14 (all have this - converted from PS1) |
| docs/workspace-system-overview.md | All 14 (created in Pass 1) |
| archive/history.md | Need to verify - some have history-2026-04.md |

### Category B: PRESERVE (Custom Content Exists)
These files exist in topic folders with custom content - DO NOT OVERWRITE:

| Folder | File | Action |
|--------|------|--------|
| Fluent PRs | PR-tracker.md | PRESERVE - custom PR tracking |
| Fluent PRs | sync-state.json | PRESERVE - custom sync state |
| MathLearningNotes | README.md | PRESERVE - project README |
| MathLearningNotes | sync-state.json | PRESERVE - custom sync |
| MathLearningNotes | pages-requirements.txt | PRESERVE - project file |
| MathLearningNotes | requirements.txt | PRESERVE - project file |
| OpenCodex | PROJECT-MAP.txt | PRESERVE - 127KB project file |

### Category C: PROTECTED BY STRUCTURE
These locations are already protected from hub propagation:

| Location | Reason |
|----------|---------|
| meta/ | Explicitly protected - hub never touches |
| [folder]-content/ | Explicitly protected - hub never touches |
| .git/ | Git repository data |
| .opencode/ | Tool configuration |

### Category D: OLD ARTIFACTS (Delete or Clean Up)
These files are remnants that should be cleaned:

| Folder | File | Type | Action |
|--------|------|------|--------|
| Wall You | workspace-system-overview.md (root) | Old location | MOVE to docs/ |
| All | archive/history-2026-04.md | Old format | Should be archive/history.md |

### Category E: PROJECT FILES (Not Hub Artifacts)
These .ps1 files are in content/ folders - project code, NOT hub artifacts:

| Folder | File | Reason |
|--------|------|--------|
| Image Glass | image-glass-content/Setup/AdvancedInstaller/IG_Opera_Download.ps1 | Project code |
| NoFaceScanApp | no-face-scan-app-content/launch-fullscreen.ps1 | Project code |
| OpenCodex | open-codex-content/github/script/sign-windows.ps1 | Project code |

## Propagation Strategy Summary

### Step 1: Add Missing Structure
- [ ] Add docs/ to Wall You (missing from Pass 1)

### Step 2: Safe to Propagate
All standard templates can be propagated. CREATE ONLY mode means:
- Files only created if missing
- Existing custom files preserved

### Step 3: Verify Before Propagation
After propagation, verify:
- No custom files overwritten
- All standard files present
- docs/workspace-system-overview.md created

### Step 4: Post-Propagation Cleanup
- Move Wall You workspace-overview from root to docs/
- Consider renaming history-2026-04.md to history.md (or consolidate)

## Special Considerations

### MathLearningNotes
This folder has significant extra files at root:
- LICENSE
- Math-Lessons.ipynb
- README.md (17979 bytes - large!)
- Template_Notebook.ipynb
- Template_QUICKNOTE.ipynb
- build_pages.py
- environment.yml
- pages-requirements.txt
- Folders: algebra/, calculus/, discrete-mathematics/, fractals/

**These are project files** - NOT hub artifacts. They're in the root because this project started before the content/ convention.

### OpenCodex
Has PROJECT-MAP.txt (127KB) at root - this is a project artifact, NOT a hub file.

### Fluent PRs
Has sync-state.json at root - custom tracking file from before session-state.json was standard.

## Recommendations

1. **Run propagation with --apply** - Safe because CREATE ONLY mode preserves custom files
2. **Add Wall You docs/ before propagation** - Quick fix
3. **After propagation, verify** - Check that custom files weren't touched
4. **Consider migrating project files** - MathLearningNotes and OpenCodex have project files at root that could move to content/
