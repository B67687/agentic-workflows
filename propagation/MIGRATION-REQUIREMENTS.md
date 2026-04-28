# Migration Requirements Analysis - Pass 4

## CRITICAL: Missing Content Folders

4 topic folders are **MISSING** their content/ folders:

| Folder | Content Folder Needed | Status |
|--------|----------------------|--------|
| ImageMagick | imagemagick-content | **MISSING** |
| MathLearningNotes | mathlearningnotes-content | **MISSING** |
| NoFaceScanApp | nofacescanapp-content | **MISSING** |
| OpenCodex | opencodex-content | **MISSING** |

**Action:** Need to create these content folders before/since they don't have project code yet.

---

## Migration Category 1: ROOT → CONTENT/ (Project Files)

These files are at root but are PROJECT code, not hub artifacts. Should migrate to content/:

### MathLearningNotes (11 files, ~63KB)
| File | Size | Action |
|------|------|--------|
| LICENSE | 1KB | → math-learning-notes-content/ |
| README.md | 18KB | → math-learning-notes-content/ |
| Math-Lessons.ipynb | 6KB | → math-learning-notes-content/ |
| Template_Notebook.ipynb | 3KB | → math-learning-notes-content/ |
| Template_QUICKNOTE.ipynb | 1KB | → math-learning-notes-content/ |
| build_pages.py | 14KB | → math-learning-notes-content/ |
| environment.yml | 13KB | → math-learning-notes-content/ |
| pages-requirements.txt | 22B | → math-learning-notes-content/ |
| requirements.txt | 8B | → math-learning-notes-content/ |
| sync-state.json | 127B | → math-learning-notes-content/ OR delete |
| translate_notebooks.py | 7KB | → math-learning-notes-content/ |

**Plus folders at root:** algebra/, calculus/, discrete-mathematics/, fractals/

### OpenCodex (1 file, 127KB)
| File | Size | Action |
|------|------|--------|
| PROJECT-MAP.txt | 127KB | → open-codex-content/ |

---

## Migration Category 2: ROOT → META/ (Custom User Content)

These files are user's custom content and belong in meta/:

### Fluent PRs (2 files at root, should move to meta/)
| File | Size | Action |
|------|------|--------|
| PR-tracker.md | 3KB | → meta/ (custom tracking) |
| sync-state.json | 127B | → meta/ OR delete |

### Fluent PRs meta/ already has 14 files:
- 8 HANDOVER files (session notes)
- 2 lesson files
- quality-standards.md
- staggered-upstream-cadence.md
- Windows Uninstall Locations-bcuninstaller.txt

**Assessment:** These belong in meta/ - already correct location.

---

## Migration Category 3: Already Correct (No Action)

These are correctly located in meta/ - no migration needed:

| Folder | Contents | Status |
|--------|----------|--------|
| Bus App/meta/ | README.md | ✓ Correct |
| Hugo/meta/ | README.md, quality-standards.md | ✓ Correct |
| Image Glass/meta/ | README.md, lessons-scoop-prs.md, quality-standards.md | ✓ Correct |
| Keyboard/meta/ | README.md, quality-standards.md | ✓ Correct |
| MathLearningNotes/meta/ | README.md, quality-standards.md | ✓ Correct |
| Random/meta/ | README.md, quality-standards.md | ✓ Correct |
| Reality/meta/ | README.md, quality-standards.md | ✓ Correct |
| Wall You/meta/ | README.md, quality-standards.md | ✓ Correct |

---

## Migration Category 4: Content/ → ROOT (Not Needed)

No files need to move from content/ to root - this direction not needed.

---

## Migration Category 5: OTHER ISSUES

### Empty Content Folders
These content folders exist but are empty:
- Fengshui/fengshui-content/ (empty)
- Keyboard/keyboard-content/ (empty)
- RSS Reader/rss-reader-content/ (empty)
- Reality/reality-content/ (empty)

**Action:** These need content added - not a migration issue.

### Content Folders with Actual Project Code
These are correctly populated:
- Bus App/bus-app-content/ (gradle project)
- Fluent PRs/fluent-prs-content/ (project data)
- Image Glass/image-glass-content/ (full project)
- Hugo/hugo-content/ (Obsidian notes)
- Random/random-content/ (SGCC.pdf)
- Wall You/wall-you-content/ (ScenicFetch)

---

## Migration Action Plan

### Priority 1: CRITICAL - Create Missing Content Folders
```bash
mkdir -p ImageMagick/imagemagick-content
mkdir -p MathLearningNotes/mathlearningnotes-content
mkdir -p NoFaceScanApp/nofacescanapp-content
mkdir -p OpenCodex/opencodexcontent
```

### Priority 2: HIGH - Migrate Root Project Files
```bash
# MathLearningNotes → math-learning-notes-content/
mv MathLearningNotes/LICENSE MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/README.md MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/Math-Lessons.ipynb MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/Template_Notebook.ipynb MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/Template_QUICKNOTE.ipynb MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/build_pages.py MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/environment.yml MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/pages-requirements.txt MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/requirements.txt MathLearningNotes/math-learning-notes-content/
mv MathLearningNotes/translate_notebooks.py MathLearningNotes/math-learning-notes-content/
# Plus folders: algebra/, calculus/, discrete-mathematics/, fractals/

# OpenCodex → open-codex-content/
mv OpenCodex/PROJECT-MAP.txt OpenCodex/open-codex-content/
```

### Priority 3: MEDIUM - Migrate Custom Files to Meta
```bash
# Fluent PRs → meta/
mv "Fluent PRs/PR-tracker.md" "Fluent PRs/meta/"
mv "Fluent PRs/sync-state.json" "Fluent PRs/meta/"  # or delete
```

---

## Summary

| Category | Count | Effort |
|----------|-------|--------|
| Missing content folders (create) | 4 | Quick |
| Root → content/ (migrate project files) | 12 | Medium |
| Root → meta/ (migrate custom files) | 2 | Quick |
| Already correct | 8 folders | None |
| Empty content folders | 4 | Needs content |

---

## Questions Before Proceeding

1. **MathLearningNotes folders:** The folders (algebra/, calculus/, etc.) - should these move to content/ too?
2. **Fluent PRs sync-state.json:** Delete it since session-state.json is the standard now?
3. **Empty content folders:** Fengshui, Keyboard, RSS Reader, Reality - should these be populated or removed?

