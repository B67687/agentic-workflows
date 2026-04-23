# Session 44 - Git & GitHub Best Practices History With Codex

Created: 2026-04-23
Session: session-44 (continuation)
Timezone: Asia/Singapore, UTC+08:00

---

## Purpose

This file documents the Git/GitHub best practices work and the template system refactor that occurred in the latter part of session-44. It is written for a future agent that needs to understand not just what changed, but the full decision chain that shaped the implementation.

Use this together with:
- `workflow/session-state.json` for current resume state
- `LATE-HISTORY-WITH-CODEX.md` for the agentic workspace redesign thread
- `MIDDLE-HISTORY-WITH-CODEX.md` for the bridge between early and late work
- `HISTORY.md` for the broader chronological ledger

---

## Executive Summary

This thread added Git and GitHub best practices as a first-class concern in the AI Prompting Library, then refactored the template propagation system to make it extensible.

The repeated pattern was:
1. User identified a gap or problem (AI agents causing merge conflicts, hardcoded propagation script)
2. Assistant proposed a structure
3. User corrected or refined the direction
4. We implemented and propagated

The biggest final agreements:
- Git/GitHub best practices must serve both humans and AI agents simultaneously
- Principle-focused docs without code examples are preferred for longevity
- Raw docs in `docs/` inform templates in `propagate-templates/` which get propagated
- The propagation script must discover templates dynamically, not hardcode them
- Template rename from `templates/` → `propagate-templates/` makes purpose unambiguous
- All propagated templates must support merge with Custom-Section preservation

---

## Master Timeline

| Timestamp | Precision | Event | Durable result |
|---|---|---|---|
| ~14:00 | Conversation start | User asks about adding Git/GitHub best practices | Decision to create doc |
| ~14:05 | Conversation | Assistant proposes A (general) vs B (AI-specific) | User says "A and B" |
| ~14:10 | Conversation | User chooses principle-focused over examples | No code literals in doc |
| ~14:15 | Conversation | User clarifies raw docs → templates → propagation flow | Confirmed dual-file approach |
| ~14:20 | File write | `docs/git-github-best-practices.md` created | Source doc |
| ~14:22 | File write | `propagate-templates/git-github-best-practices.template.md` created | Template with placeholders |
| ~14:25 | Conversation | User says "propogate" | Propagation initiated |
| ~14:28 | Script run | Preview propagation shows only 2 hardcoded templates | Discovered limitation |
| ~14:32 | Conversation | User asks about template vs raw docs distinction | Confirmed propagation flow |
| ~14:35 | Conversation | User proposes rename to `propagate-templates/` | Agreed on refactor |
| ~14:38 | Conversation | User notices script hardcoded to 2 templates | Decision to make dynamic |
| ~14:42 | File operation | Renamed `templates/` → `propagate-templates/` | Folder renamed |
| ~14:43 | File operation | Deleted `AGENTS.md` and `repo-lessons.md` duplicates | Cleanup |
| ~14:45 | File edit | Updated `propagate-to-all.ps1` to dynamically discover `*.template.md` | Dynamic discovery |
| ~14:47 | File edit | Added merge logic for additional templates | Custom-Section preservation |
| ~14:50 | File edit | Updated `README.md` and `AGENTS.md` references | Path updates |
| ~14:52 | Script run | Preview propagation shows 4 templates discovered | Verification |
| ~14:55 | Script run | Applied propagation to 21 repos | git-github-best-practices.md created in repos |
| ~15:00 | Conversation | User asks about opencode /init merge compatibility | Confirmed merge logic works |
| ~15:05 | Script run | Fixed additional template loop to use Merge-AGENTS | Full merge support |
| ~15:10 | Script run | Re-applied propagation with merge | MERGED status in 21 repos |
| ~15:15 | Conversation | User asks for full history reconstruction | This document created |
| ~15:20 | File edit | Added Session 4 entry to `HISTORY.md` | Historical record updated |

---

## Decision Threads

### Thread 1: Adding Git/GitHub Best Practices

**User intent:**
> "Since this is a main folder on best practices, i suppose we should add best practices for github usage/ git usage, what do you think? draft one"

**Assistant structure:**
Proposed two scopes:
- (A) General best practices anyone could use
- (B) Best practices specifically for working with AI agents in Git workflows
Asked user which direction.

**User correction:**
> "A and B, i think it overlaps a lot, as this project is about letting ai agents adhere to best rpactices it would directly affect ai agents"

User rejected the either/or framing. The doc should serve both audiences because the project's core value is teaching AI agents to follow best practices.

**Final agreement:**
The doc covers both general Git/GitHub best practices AND AI-agent-specific rules. The AI agent section is explicit about what agents must do differently from humans.

**Implemented files:**
- `docs/git-github-best-practices.md` - principle-focused source doc (~650 words)
- `propagate-templates/git-github-best-practices.template.md` - template with repo-customization placeholders

---

### Thread 2: Examples vs Principle-Focused

**User intent:**
Implicit - user wants high-quality, maintainable documentation.

**Assistant structure:**
Asked whether to include example commit message templates or stay principle-focused without code/literals.

**User correction:**
> "No - principle-focused"

User wants the doc to stay evergreen. Concrete examples can become outdated; principles don't.

**Final agreement:**
No code literals, no specific commands in examples. Use descriptive placeholders like `[branch naming convention]` instead of `feature/description`. The doc explains what good looks like without prescribing exact syntax.

**Implemented:**
Both the source doc and template use principle-focused language. Placeholders use `[descriptive name]` format for repo-specific customization.

---

### Thread 3: Raw Docs vs Templates - The Propagation Flow

**User intent:**
User understood the relationship but wanted confirmation:
> "in my understnad the raw docs is what affects the templates right? then the templates are propogated"

**Assistant structure:**
Confirmed the flow: docs/ (raw content) → templates/ (propagated to repos) → repos apply locally

**User correction:**
> "i think templates is the way to go"

User reinforced that templates are the correct pattern for this content.

**Final agreement:**
Create BOTH:
1. `docs/git-github-best-practices.md` - the source document, principle-focused
2. `propagate-templates/git-github-best-practices.template.md` - the propagated version with placeholders

**Implemented files:**
Both files created simultaneously. The template includes:
- `[AI agents should fetch before editing: enable/disable]`
- `[Require pre-commit remote check: yes/no]`
- `[Commit message format: freeform/imperative/conventional]`
- `[Max lines per commit: number or leave blank]`
- `[Primary workflow: trunk-based/feature-branches/gitflow]`
- `[Branch naming convention: prefix/description]`
- `[AI agents may auto-commit: yes/no]`
- `[AI agents may push directly: yes/no]`
- `<!-- Custom-Section: Git-GitHub -->` for repo-specific rules

---

### Thread 4: Template System Refactor - From Hardcoded to Dynamic

**User intent:**
User noticed a problem after asking to propagate:
> "did you ensure that the propogate is with merge included? because opencode has its own /init for add agents.md"

**Assistant structure:**
Discovered the `propagate-to-all.ps1` script was hardcoded to only 2 specific files:
```powershell
$AgentsTemplatePath = Join-Path $TemplatesDir "AGENTS.template.md"
$LessonsTemplatePath = Join-Path $TemplatesDir "repo-lessons.template.md"
```

The additional template loop I had added was simple create/skip, NOT merge with Custom-Section preservation.

**User correction:**
> "yes please, also you are cutting off for some reason at the end of your messages"
> "its not jsut github best practices but git as well"
> "rename template to propogate-templates if that is the better design decision, then the script shall just reference the folder instead? what do you think, and if you have better practices for this do improve on it"

User proposed:
1. Rename `templates/` → `propagate-templates/`
2. Script should reference the folder, not hardcode files
3. Make it not hardcoded
4. Improve on the design if I have better ideas

**Assistant structure:**
Analyzed current state and proposed:
- Rename folder for clarity
- Delete unused duplicate files (`AGENTS.md`, `repo-lessons.md` in templates/)
- Update script to dynamically discover `*.template.md` files
- Add merge logic for additional templates

**User correction:**
User asked for full structure and workflow before proceeding. Wanted to understand what would be removed and added.

After explanation, user said: "lets go"

**Final agreement:**
1. `templates/` → `propagate-templates/` (clear purpose)
2. Delete unused duplicates
3. Script dynamically discovers all `*.template.md` files
4. Any new template auto-propagates without script edits
5. All templates support merge with Custom-Section preservation

**Implemented files:**
- Renamed `templates/` → `propagate-templates/`
- Deleted `propagate-templates/AGENTS.md` (duplicate)
- Deleted `propagate-templates/repo-lessons.md` (duplicate)
- Updated `scripts/propagate-to-all.ps1`:
  - Dynamic discovery: `Get-ChildItem -Path $TemplatesDir -Filter "*.template.md"`
  - Backward-compatible variables for AGENTS and repo-lessons
  - Additional template loop with merge logic using `Merge-AGENTS` function
  - Summary output for each template type
- Updated `README.md` - structure diagram and template references
- Updated `AGENTS.md` (workspace) - structure diagram and high-signal files

**Propagation results:**
Discovered 4 templates: AGENTS, repo-lessons, copilot-instructions, git-github-best-practices
- git-github-best-practices.md: MERGED in 21 repos
- copilot-instructions.md: MERGED/UNCHANGED in 21 repos
- AGENTS.md: MERGED in 21 repos
- repo-lessons.md: UNCHANGED in 21 repos

---

### Thread 5: Merge Logic for Additional Templates

**User intent:**
User asked about opencode /init integration:
> "did you ensure that the propogate is with merge included? because opencode has its own /init for add agents.md"

**Assistant structure:**
Checked and found the additional template loop was simple create/skip:
```powershell
if ($existing -match $ManagedMarker) {
    Write-Host "SKIP (already managed)"
}
```

This meant templates with the Managed-By marker would be skipped entirely, not merged.

**User correction:**
User expected merge behavior to match AGENTS.md - preserving Custom-Section content while updating template sections.

**Final agreement:**
Additional templates must use the same merge logic as AGENTS.md. The `Merge-AGENTS` function (which preserves Custom-Section blocks) should be called for all managed templates, not just AGENTS.

**Implemented:**
Updated the additional template loop:
```powershell
if ($existing -match $ManagedMarker) {
    $merged = Merge-AGENTS -TemplateContent $templateContent -ExistingContent $existing
    if ($merged -eq $existing) {
        Write-Host "UNCHANGED (already managed)"
    } else {
        $merged | Set-Content $targetPath -Encoding UTF8
        Write-Host "MERGED"
    }
}
```

Re-applied propagation. All git-github-best-practices.md files now show MERGED status.

---

## Key Problems Solved

### Problem 1: AI Agents Causing Merge Conflicts
**Evidence:** User stated AI agents in OpenCode weren't fetching latest repo state before reading, causing merge conflicts later.

**Solution:** Added "State Awareness" as the first and most important section in the doc:
- Always fetch before starting work
- Check current branch against remote
- Understand remote changes before committing
- Resolve conflicts before pushing
- AI agents must confirm repo state is current before editing

### Problem 2: Hardcoded Propagation Script
**Evidence:** Script only processed 2 specific templates (`AGENTS.template.md` and `repo-lessons.template.md`). Adding `copilot-instructions.template.md` and `git-github-best-practices.template.md` required script modifications.

**Solution:** Script now dynamically discovers all `*.template.md` files in `propagate-templates/`. Adding a new template is now just dropping a file in the folder.

### Problem 3: Unclear Folder Purpose
**Evidence:** `templates/` folder contained both propagated templates and unused duplicate copies (`AGENTS.md`, `repo-lessons.md`). The name didn't distinguish between source docs and propagation targets.

**Solution:** Renamed to `propagate-templates/` to make purpose explicit. Deleted unused files.

### Problem 4: Additional Templates Not Merging
**Evidence:** The loop for templates other than AGENTS/repo-lessons used simple create/skip logic. Managed files would be skipped even if template had updates.

**Solution:** Added `Merge-AGENTS` call to the additional template loop, preserving Custom-Section content while updating template sections.

---

## Files Created

| File | Purpose |
|------|---------|
| `docs/git-github-best-practices.md` | Source documentation - principles for humans and AI agents |
| `propagate-templates/git-github-best-practices.template.md` | Propagation template with repo-customization placeholders |

## Files Deleted

| File | Reason |
|------|--------|
| `propagate-templates/AGENTS.md` | Unused duplicate of `AGENTS.template.md` |
| `propagate-templates/repo-lessons.md` | Unused duplicate of `repo-lessons.template.md` |

## Files Modified

| File | Changes |
|------|---------|
| `scripts/propagate-to-all.ps1` | Dynamic template discovery, merge logic for additional templates, summary output per template |
| `README.md` | Updated structure diagram (`templates/` → `propagate-templates/`), added new template reference |
| `AGENTS.md` (workspace) | Updated structure diagram, added template reference |
| `HISTORY.md` | Added Session 4 entry |

## Files Renamed

| Old | New |
|-----|-----|
| `templates/` | `propagate-templates/` |

## Propagation Results

All 21 repos in `M-Namikaz-Others` received:

| Template | Target File | Status |
|----------|-------------|--------|
| AGENTS.template.md | AGENTS.md | MERGED (21 repos) |
| repo-lessons.template.md | repo-lessons.md | UNCHANGED (21 repos) |
| copilot-instructions.template.md | copilot-instructions.md | MERGED/UNCHANGED (mixed) |
| git-github-best-practices.template.md | git-github-best-practices.md | MERGED (21 repos) |

---

## What Was NOT Done

The following were discussed but deferred:
- No commit to git was made (user would need to explicitly request)
- No update to `workflow/session-state.json` for this sub-thread
- No additional best practice docs (CI/CD, testing, etc.)

---

## How to Resume This Work

If a future session wants to continue:

1. Read `workflow/session-state.json` first
2. Read this file for context
3. Check `propagate-templates/` for current templates
4. Run `scripts/check-sync-status.ps1` to see if propagation is stale
5. Any new template added to `propagate-templates/*.template.md` will auto-propagate on next run

To add a new best practices doc:
1. Create source in `docs/[topic]-best-practices.md`
2. Create template in `propagate-templates/[topic]-best-practices.template.md`
3. Add `<!-- Managed-By: AI-Prompting-Library -->` and `<!-- Template: [Name] -->` markers
4. Add `<!-- Custom-Section: [Topic] -->` for repo-specific rules
5. Run `propagate-to-all.ps1 -Apply`

---

## Gaps in the Historical Record

- Exact timestamps are approximate (conversation-level, not clock-level)
- The first part of session-44 (agentic workspace redesign) is documented in `LATE-HISTORY-WITH-CODEX.md`
- This document covers only the Git/GitHub best practices sub-thread
- File `LastWriteTime` values show when files were written, not when decisions were made

---

## Metadata

```yaml
---
session: session-44
document_created: 2026-04-23
last_updated: 2026-04-23
thread: git-github-best-practices
status: complete
---
```