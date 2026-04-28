---
name: cross-domain-harvest
description: Harvest topic insights from all 25 topic folders, build cross-domain promotion queue, and propagate approved lessons back to the hub. Use when the user asks to harvest insights, cross-domain review, promote lessons, or merge candidates.
when_to_use: "Run periodically (weekly or after significant work in topic folders) to collect lessons worth sharing across projects."
allowed-tools: Bash(powershell)
---

# Cross-Domain Knowledge Flow

This skill orchestrates the full knowledge flow: topic folders → hub → all topic folders.

## Phase 1: Harvest

Collect lessons from all participating topic folders.

```bash
cd /home/namikaz/projects/dev/AI\ Prompting
./scripts/harvest-topic-insights.sh
```

**What it does:**
- Scans all 25 folders for `topic-insights.md`
- Collects entries into `workflow/harvested-topic-insights.md`
- Reports counts per folder

**Expected output:** "Harvested N insights from X folders."

## Phase 2: Build Candidates

Identify transferable lessons worth promoting to the hub.

```powershell
.\scripts\build-cross-domain-candidates.ps1
```

**What it does:**
- Reads harvested insights
- Identifies patterns that apply across multiple domains
- Creates candidates in `workflow/cross-domain-candidates.md`
- Assigns promotion status (ready / needs-review / defer)

**Expected output:** "Built Y candidates from N harvested insights."

## Phase 3: Review

Present candidates to the user for approval.

**Format:**
```
## Candidate: [brief description]
- **Source:** [folder name]
- **Original:** [exact quote]
- **Generalized:** [hub-ready wording]
- **Target doc:** [where it should live in hub]
- **Status:** ready | needs-review | defer
```

**User actions:**
- "Approve candidate 1" → proceed to Phase 4
- "Reject candidate 2" → mark as rejected
- "Defer candidate 3" → keep for later review

## Phase 4: Merge and Propagate

Merge approved candidates into hub docs and propagate to all folders.

```powershell
.\scripts\merge-and-propagate.ps1 -CandidateId "<id>"
```

**What it does:**
1. Inserts generalized wording into target hub doc
2. Adds back-link note in source folder's topic-insights.md
3. Updates `workflow/merge-log.md`
4. Runs `propagate-to-all.ps1` to sync updated templates

## Full Pipeline (One-Shot)

If the user says "Run full harvest pipeline":

1. Run Phase 1 (Harvest)
2. Run Phase 2 (Build Candidates)
3. Present Phase 3 (Review)
4. After approval, run Phase 4 (Merge and Propagate)
5. Report: "Pipeline complete. N insights harvested, Y candidates built, Z approved and propagated."

## Rules
- Never merge without explicit user approval
- Always generalize before inserting into hub (remove project-specific details)
- Preserve original context in source folder's topic-insights.md
- Update session-state.json after each phase
