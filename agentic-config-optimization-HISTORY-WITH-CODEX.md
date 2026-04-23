# Session-44 History — Model Switching, Folder Cleanup & Archive Recovery

**Session:** session-44 (2026-04-23)  
**Status:** Complete  
**Models Used:** MiniMax M2.5 Free (OpenCode Zen)  
**Context:** User had 2 main tasks: (1) model switching strategy for 12 available AIs, and (2) folder cleanup script for M-Namikaz-Others workspace. Session derailed into OpenCode session recovery.

---

## Master Timeline

| Time | Event |
|------|-------|
| **Start** | User asks about model switching causing context loss, and folder cleanup script |
| **~T+2m** | User shares 12 models across 3 providers |
| **~T+5m** | Assistant researches model benchmarks via web search |
| **~T+15m** | Assistant creates model-selection-guide.md + cleanup-folders.ps1 |
| **~T+20m** | User asks about recovering archived OpenCode sessions (derailment begins) |
| **~T+45m** | Assistant investigates OpenCode GitHub source code for archive mechanism |
| **~T+60m** | Discovery: sessions weren't archived, just filtered by directory |
| **~T+65m** | Session-recovery-guide.md updated with actual fix |
| **~T+70m** | User requests full session history document (this file) |

---

## Decision Thread 1: Model Switching Strategy

### User Intent
> "When I switch models I assume yall do not share context, which means if I switch too often then there will probably be communication errors. I am thinking making the previous AI generate a handover prompt every time I want to switch."

### Assistant Structure
Agreed that frequent switching without handover causes errors. Proposed improved handover format:
```
## Handover Summary
### What is done
### What remains
### Current direction & why
### Critical context
### Where to pick up
```
Also proposed session state file idea.

### User Correction
> "Oh yes the session state idea is very good!"

Then asked: "Do you know what AI you are and what AIs are available? Sometimes maybe you know better that the next task actually should use another AI."

### Final Agreement
- Create a model selection guide that documents all available models
- Guide should recommend which model for which task dynamically
- Include session state file for handovers
- Assistant should proactively recommend model switches based on task characteristics

### Implementation
Created `model-selection-guide.md` with:
- Quick decision matrix by task type
- All 12 models documented with strengths/weaknesses/best use
- Benchmark comparison tables (coding, reasoning, computer use)
- Pricing tiers
- Dynamic switching triggers (when to escalate)
- Provider preferences for duplicates

---

## Decision Thread 2: Which Models to Document

### User Intent
Shared complete list:
- OpenCode Zen: Big Pickle, MiniMax M2.5 Free
- GitHub Copilot: Claude Opus 4.6, Claude Sonnet 4.6, Gemini 3.1 Pro Preview, GPT-5.2-Codex, GPT-5.4
- OpenRouter: Claude Sonnet 4.6, DeepSeek V3.2 Speciale, Gemini 3.1 Pro Preview, Uncensored (free)

### Assistant Research
Searched benchmarks for each model:
- Claude Opus 4.6 vs Sonnet 4.6: 80.8% vs 79.6% SWE-bench, 5x price difference
- GPT-5.4 vs 5.3 Codex: 5.4 is now the default recommendation
- DeepSeek V3.2 Speciale: 93% AIME, 2386 Codeforces, $0.28/1M tokens
- MiniMax M2.5 Free: 80.2% SWE-bench, essentially free

### User Correction
Asked about duplicate models across providers (same model on Copilot and OpenRouter).

### Final Agreement
Document all 12 models. For duplicates, recommend provider based on tool integration quality. Note that Copilot versions are likely more optimized for coding agent flows.

### Implementation
Model guide includes all 12 models with benchmark-backed recommendations. Provider preference table added.

---

## Decision Thread 3: Folder Cleanup Script Features

### User Intent
> "Should we add a script to propagate for folder cleanup?"

### Assistant Structure
Proposed 4 features: remove empty dirs, detect stale folders, check inconsistent structure, archive old folders.

### User Correction
> "Yes all of that!"

Then asked about protection for important stale folders: "Some files should not be cleaned up even if stale, like if I left the project, the main files might become stale after 30 days but they are still important."

### Final Agreement
- Remove empty directories
- Detect stale folders (>30 days default, configurable)
- Check structure consistency across repos
- Archive old folders (non-repo only)
- **Protection:** Folders with `.cleanup-ignore` are skipped
- **Default mode:** Report-only (preview), require `--Apply` to execute
- Stale repo folders (with .git or AGENTS.md) are flagged but NOT auto-archived

### Implementation
Created `cleanup-folders.ps1` with parameters:
- `--RemoveEmpty`
- `--DetectStale` (with `-Days` parameter)
- `--CheckStructure`
- `--ArchiveOld`
- `--Apply` (default: report-only)

---

## Decision Thread 4: Monthly Model Guide Updates

### User Intent
> "AI models move fast, every month there will likely be an overhaul."

### Assistant Structure
Proposed 3 options: (A) reminder in guide, (B) scheduled prompt, (C) metadata tracking.

### User Correction
> "I like all 3, you can combine them."

Also requested: "Make sure to check if new authoritative sources exist, even these change frequently."

### Final Agreement
Combine all 3:
- Monthly verification section with exact URLs to check
- Update schedule with review cadence
- Metadata header with dates and sources tracked
- Include community sources (Reddit r/LLMDevs, r/LocalLLaMA)

### Implementation
Added to `model-selection-guide.md`:
```markdown
## Monthly Verification
Check these sources in order:
1. https://openrouter.ai/leaderboard
2. https://evals.xyz/swe-bench
3. https://awesomeagents.ai
4. Release blogs
5. Reddit r/LLMDevs, r/LocalLLaMA

## Update Schedule
- Review cadence: First week of each month
- Next review: 2026-05-13
- Reminder: Ask your AI to "refresh model-selection-guide.md"
```

---

## Decision Thread 5: OpenCode Session Recovery (Major Derailment)

### User Intent
> "Where does archives go in opencode? Ive accidentally archived 2 sessions due to misclick."

### Assistant Investigation
Searched OpenCode docs and GitHub:
- Found PR #15250: "view archived sessions & unarchive" (Feb 2026)
- Found PR #13961: archive/unarchive support in TUI
- Suggested Settings → Data → Archived Sessions

### User Correction
Could not find archived sessions in UI. Version is 1.4.3. Database exists at `%APPDATA%\opencode\opencode.db`.

### Assistant Investigation (Deeper)
Searched GitHub source code:
- Found `time_archived` column in `session` table
- Found that `list()` filters by `isNull(SessionTable.time_archived)` by default
- Suggested setting `time_archived` to NULL in SQLite Browser

### User Attempt
Set `time_archived` to NULL for 5 session IDs. Restarted laptop. Sessions still not visible in Desktop UI.

### Assistant Deep Investigation
Analyzed actual database output from user:
```
ses_278d2ca... | Best-in-class tool substitutions... | global | M:\M-Namikaz-Others\AI Prompting | NULL | ...
```

All sessions had `time_archived = NULL`! They were NOT archived.

### Discovery
Version 1.4.3 uses **directory-based filtering**, not `time_archived`. Sessions are scoped to current working directory. The user's sessions were created in different directories, so they appeared "archived" (hidden) when in the wrong directory.

### Final Agreement
- Sessions are not lost
- Open TUI from the original directory (`M:\M-Namikaz-Others\AI Prompting`)
- Sessions appear correctly there
- This is a Desktop UI bug fixed in later versions

### Implementation
Updated `session-recovery-guide.md` with:
- Actual cause (directory filtering, not archiving)
- SQL query to check session locations
- Solution: navigate to original directory
- Note about Desktop vs TUI behavior

---

## Decision Thread 6: Scoop vs GitHub Release (Brief)

### User Intent
Wanted to update OpenCode to fix archive bug.

### Assistant Structure
Discussed 3 options: scoop update, manual download, dual installation.

### User Correction
Discovered 1.4.3 IS the latest version. Scoop was not the issue.

### Final Agreement
User decided NOT to pursue in this session. Would handle in a separate session.

### Implementation
None in this session.

---

## Files Created/Modified

| File | Action | Purpose |
|------|--------|---------|
| `model-selection-guide.md` | Created | Benchmark-backed model recommendations for 12 AIs |
| `cleanup-folders.ps1` | Created | Folder cleanup script with report-only default |
| `session-recovery-guide.md` | Created + updated | How to recover "archived" sessions (actually directory-filtered) |

---

## Key Lessons for Future Sessions

1. **Model switching:** Use session state file for handovers. Check `model-selection-guide.md` for recommendations.
2. **Cleanup script:** Always run report-only first. Protected folders use `.cleanup-ignore`.
3. **OpenCode Desktop 1.4.3:** Sessions filtered by directory, not actually archived. Use TUI from correct directory.
4. **Model guide:** Review monthly. Sources change frequently.

---

## What This Session Was Actually About

The user started with 2 clear tasks:
1. Model switching strategy (handover prompts + which model when)
2. Folder cleanup script

Session derailed into OpenCode session recovery. Main tasks were completed before derailment. Recovery investigation took ~45 minutes but resulted in accurate documentation.

---

Last updated: 2026-04-23
