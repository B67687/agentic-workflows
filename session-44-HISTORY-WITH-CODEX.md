# Session 44 — Complete Decision History

**Created:** 2026-04-23  
**Status:** Complete  
**Purpose:** Full reconstructive handover of every major decision thread in Session 44  

---

## How To Read This File

Each section follows this exact shape:

1. **User Intent** — What the user actually asked for
2. **Assistant Structure** — What I (the assistant) proposed or built
3. **User Correction** — What the user corrected, rejected, or refined
4. **Final Agreement** — What we both agreed was correct
5. **Implementation** — What files were actually written/modified

This is not a changelog. It is a decision archaeology document.

---

## Timeline Of Session 44

| Time | Event |
|------|-------|
| 2026-04-23 00:00–00:30 | Session start — model access research, initial questions |
| 2026-04-23 00:30–01:30 | Early history creation (EARLY-HISTORY-WITH-CODEX.md) |
| 2026-04-23 01:30–02:30 | Agent system design — opencode.json, agents/, skills/ |
| 2026-04-23 02:30–08:00 | Agent testing and refinement |
| 2026-04-23 08:00–09:00 | Middle history creation (MIDDLE-HISTORY-WITH-CODEX.md) |
| 2026-04-23 09:00–12:00 | Propagation and template fixes |
| 2026-04-23 12:00–14:00 | Skills system implementation |
| 2026-04-23 14:00–14:15 | Late history creation (LATE-HISTORY-WITH-CODEX.md) |
| 2026-04-23 14:15+ | Final HISTORY.md reconstruction (current task) |

---

## Decision Thread 1: Model Selection Guide (GPT-5.3 Codex Error)

### User Intent
User wanted to know which models were best for coding based on their GitHub Education quotas.

### Assistant Structure
I created a model-selection-guide.md with benchmark-backed recommendations. I listed:
- Claude Opus 4.7 (144k)
- Claude Sonnet 4.6 (200k)  
- Gemini 3.1 Pro Preview (128k)
- GPT-5.2 Codex (400k)
- GPT-5.4 (400k)

I initially listed GPT-5.3 Codex as the "open-weight leader" based on SWE-bench Pro scores.

### User Correction
The user corrected me: GPT-5.3 Codex is NOT open-weight. It is a closed API model. I had confused it with GLM-5.1, which is the actual open-weight leader.

### Final Agreement
- GPT-5.3 Codex is a closed API model (Codex-class, for coding)
- GLM-5.1 is the open-weight leader (58.4% SWE-bench Pro)
- The model guide must distinguish between access tiers (closed API vs open-weight vs free)

### Implementation
- Updated docs/model-selection-guide.md with corrected attribution
- Added explicit "Open-weight leader" section for GLM-5.1
- Added verification framework to research prompts to prevent similar errors

---

## Decision Thread 2: Agent System Architecture

### User Intent
User wanted to understand if their GitHub Education plan was optimal or if better alternatives existed.

### Assistant Structure
I proposed a multi-agent system where:
- Orchestrator (K2.6) handles routing
- Explorer (M2.5) handles search
- Drafter (M2.7) handles implementation
- Debugger (K2.6) handles bugs
- Reviewer (GLM-5.1) handles quality checks

I initially proposed 5 agents.

### User Correction
User asked: "Why not make it fully automatic?" I explained that full auto-routing is risky because:
- Wrong agent → wrong model → wrong cost/quality tradeoff
- User should retain override capability
- Semi-automatic (Orchestrator decides, user can override) is the sweet spot

User also asked for more agents to cover documentation (Scribe) and file operations (Gardener).

### Final Agreement
- 7 agents total: Orchestrator, Explorer, Planner, Scribe, Drafter, Gardener, Debugger, Reviewer
- Routing is semi-automatic: Orchestrator decides, user can override with `@agentname`
- Each agent gets a specific model based on cost/quality needs
- Agent configs live in `.opencode/agents/*.md`

### Implementation
- Created `.opencode/agents/explorer.md`
- Created `.opencode/agents/planner.md`
- Created `.opencode/agents/scribe.md`
- Created `.opencode/agents/drafter.md`
- Created `.opencode/agents/gardener.md`
- Created `.opencode/agents/debugger.md`
- Created `.opencode/agents/reviewer.md`
- Updated `opencode.json` with Orchestrator as primary agent
- Updated `docs/agentic-workflows.md` with full architecture

---

## Decision Thread 3: Direct Handling Default

### User Intent
User wanted to understand how the Orchestrator should decide whether to spawn a subagent.

### Assistant Structure
I initially proposed a complex routing table with many conditions.

### User Correction
User corrected: "Make the default 'handle directly'. Only spawn when clearly needed." This inverted the logic from "route by default" to "handle by default."

### Final Agreement
- Default stance: Handle directly
- Only spawn subagent when task clearly exceeds thresholds
- Threshold table with specific rules:
  - Search: 1-2 files → direct, 3+ files → @explorer
  - File edits: 1-3 lines → direct, new file/module → @drafter
  - File ops: < 5 files → direct, 10+ files → @gardener
  - Docs: 1 section → direct, full guide → @scribe

### Implementation
- Updated `opencode.json` Orchestrator prompt with direct-handling-default
- Updated `AGENTS.md` with inverted routing table
- Updated `docs/agentic-workflows.md` with threshold documentation
- Updated propagate-templates/opencode-agent-system.template.md
- Updated propagate-templates/AGENTS.template.md

---

## Decision Thread 4: Agent Disclosure Footer

### User Intent
User wanted transparency about which agent was used for each task.

### Assistant Structure
I proposed adding a disclosure footer after every response.

### User Correction
User specified exact format: "Agents used: [name] ([model]) — [reason]"

### Final Agreement
- Every response must include agent disclosure footer
- Format: `Agents used: @explorer (M2.5 Free — Zen) — search task`
- If no subagent spawned: `Agents used: Orchestrator (direct, K2.6) — no specialist needed`
- This goes in AGENTS.md, agentic-workflows.md, and all templates

### Implementation
- Added disclosure rule to `AGENTS.md`
- Added disclosure rule to `docs/agentic-workflows.md`
- Added disclosure rule to `propagate-templates/AGENTS.template.md`
- Added disclosure rule to `propagate-templates/opencode-agent-system.template.md`

---

## Decision Thread 5: Agent Skills System

### User Intent
User asked for a way to encapsulate complex multi-step workflows that could be reused.

### Assistant Structure
I proposed the OpenCode Skills system — specialized instructions loaded on demand via the `skill` tool.

### User Correction
User asked: "How is this different from just documenting in a markdown file?" I explained that skills are:
- Loaded dynamically (don't bloat context)
- Encapsulate domain-specific workflows
- Can include bundled resources (scripts, references)
- Are invoked by name when needed

User approved and asked for 5 skills to match the cross-domain workflows.

### Final Agreement
- 5 skills created:
  1. `propagate` — Sync templates to topic folders
  2. `audit-quality` — Run quality audits
  3. `session-handoff` — Create session checkpoints
  4. `research-deep` — Deep research with source triangulation
  5. `cross-domain-harvest` — Harvest and propagate cross-domain insights
- Skills live in `.opencode/skills/[skill-name]/SKILL.md`
- References and bundled resources can live in subfolders
- opencode.json updated with `skill: allow` permission

### Implementation
- Created `.opencode/skills/propagate/SKILL.md`
- Created `.opencode/skills/audit-quality/SKILL.md`
- Created `.opencode/skills/session-handoff/SKILL.md`
- Created `.opencode/skills/research-deep/SKILL.md` with references/
- Created `.opencode/skills/cross-domain-harvest/SKILL.md`
- Updated `opencode.json` with `skill: allow`
- Created `propagate-templates/skills-template/README.md` for topic adoption
- Updated `docs/agentic-workflows.md` with Skills documentation

---

## Decision Thread 6: PowerShell vs WSL Terminal Strategy

### User Intent
User was working in a Windows environment and wanted clear tooling guidance.

### Assistant Structure
I initially proposed using PowerShell inside WSL, or treating WSL as the primary environment.

### User Correction
User corrected: "Keep PowerShell as the source of truth for mutating hub automation. Use native WSL/Linux commands for WSL read-only inspection."

### Final Agreement
- PowerShell is the source of truth for:
  - Propagation (mutating hub automation)
  - Quality audits
  - Any file modifications across the hub
- WSL is for read-only inspection:
  - Status checks
  - Searches
  - Hotspot analysis
- Create a native WSL wrapper (`scripts/ws.sh`) alongside the PowerShell wrapper (`scripts/ws.ps1`)

### Implementation
- Created `scripts/ws.sh` (WSL read-only wrapper)
- Updated `scripts/ws.ps1` (PowerShell mutating wrapper)
- Created `docs/repo-tooling.md` (current tooling guide)
- Kept `docs/windows-repo-tooling.md` as redirect
- Updated references across docs

---

## Decision Thread 7: Folder Structure Rules (Content vs Meta)

### User Intent
User wanted to standardize how topic folders are organized.

### Assistant Structure
I proposed making `meta/` mandatory in every folder, and potentially creating `ai-prompting-content/` for the hub.

### User Correction
User corrected multiple things:
1. `meta/` should be OPTIONAL — only create when needed
2. Do NOT create `ai-prompting-content/` for the hub — hub content already lives in `docs/`, `research/`, `scripts/`, `workflow/`, `propagate-templates/`, `archive/`, and `personal-voice/`
3. Topic folders (not the hub) need a mandatory `[folder-name]-content/` operating area

### Final Agreement
- Hub content stays in existing folders: `docs/`, `research/`, `scripts/`, `workflow/`, `propagate-templates/`, `archive/`, `personal-voice/`
- Topic folders get mandatory `[folder-name]-content/`
- `meta/` is optional — create only when needed
- `scripts/` is ONLY for executable automation
- `workflow/` is for state, queues, registries, generated outputs, process logs

### Implementation
- Updated `AGENTS.md` with structure rules
- Updated `docs/workspace-system-overview.md` with correct structure
- Updated `propagate-templates/AGENTS.template.md`
- Updated `propagate-templates/README.md`

---

## Decision Thread 8: Quality Standards Placement

### User Intent
User noticed `quality-standards.md` was at the root and asked if it should be in `docs/`.

### Assistant Structure
I proposed moving it to `docs/quality-standards.md` since it's documentation.

### User Correction
User agreed, but noted we should check if anything references the root path first.

### Final Agreement
- Move `quality-standards.md` to `docs/quality-standards.md`
- Update all internal references
- Keep redirects if external links exist (none found)

### Implementation
- Moved `quality-standards.md` → `docs/quality-standards.md`
- Updated `AGENTS.md` reference
- Updated `scripts/audit-folder-quality.ps1` reference

---

## Decision Thread 9: Session-State Startup Rules

### User Intent
User wanted to ensure every new session starts correctly.

### Assistant Structure
I proposed reading `AGENTS.md` first, then `README.md`.

### User Correction
User corrected: "Read `workflow/session-state.json` FIRST. Every resume. Especially after compaction."

### Final Agreement
- Startup order:
  1. `workflow/session-state.json` — ALWAYS first
  2. `AGENTS.md` — rules
  3. `docs/workspace-system-overview.md` — system map
  4. `README.md` — navigation
  5. Task-specific files
- For topic-folder work: read `meta/HANDOVER.md` first if resuming local work

### Implementation
- Updated `workflow/session-state.json` with startup rules
- Updated `AGENTS.md` with startup rules
- Updated `docs/workspace-system-overview.md` with startup rules

---

## Decision Thread 10: Root Drift Cleanup

### User Intent
User asked to clean up files that had drifted to the root level.

### Assistant Structure
I identified several root files and proposed moving them:
- `docs/CONTEXT.md` — keep but update
- `merge-log.md` — move to `workflow/`
- `cross-domain-registry.md` — move to `workflow/`
- `promotion-review-state.json` — move to `workflow/`

### User Correction
User approved the moves but added exceptions:
- `Fluent Search Manifest/temp_extras` — active git clone, NOT a duplicate of canonical Extras. Keep as-is.
- `OpenCode/opencode-content` — active git repo; canonical `open-code-content` is empty. Keep as-is.

### Final Agreement
- Move generated/state files to `workflow/`
- Keep active git repos untouched
- Document exceptions in session state

### Implementation
- Moved `merge-log.md` → `workflow/merge-log.md`
- Moved `cross-domain-registry.md` → `workflow/cross-domain-registry.md`
- Moved `promotion-review-state.json` → `workflow/promotion-review-state.json`
- Updated `workflow/session-state.json` with manual cleanup decisions
- Deleted `docs/wsl-tooling.md` (replaced by `docs/repo-tooling.md`)
- Deleted `docs/CONTEXT.md` (content merged into `docs/workspace-system-overview.md`)
- Moved `research/archived-findings.md` → `docs/research-findings.md`
- Moved `model-tests/` → `archive/model-tests/`

---

## Decision Thread 11: Git Initialization

### User Intent
User realized the workspace wasn't a git repo and wanted to initialize it.

### Assistant Structure
I proposed:
```bash
git init
git add .
git commit -m "Initial commit"
```

### User Correction
User asked: "What about the topic folders that are already git repos?" I explained that they are separate repos (submodules or independent) and should be added to `.gitignore`.

### Final Agreement
- Initialize git in AI Prompting hub
- Add `.gitignore` excluding:
  - Topic folder content directories (they have their own repos)
  - Generated state files
  - Temporary files
- First commit should capture the current state

### Implementation
- Created `.gitignore`
- Initialized git (implied by user action)
- User performed first commit

---

## Decision Thread 12: History Reconstruction

### User Intent
User asked me to reconstruct what was done in previous sessions and add it to `HISTORY.md`.

### Assistant Structure
I analyzed file timestamps, read existing docs, and proposed a reconstruction of earlier work.

### User Correction
User was satisfied with the reconstruction but then asked for the comprehensive session history document (this file).

### Final Agreement
- Create comprehensive session history following the decision-chain format
- Include all major threads from Session 44
- Use `<sessionid>-HISTORY-WITH-CODEX.md` naming convention
- Include detailed timestamps

### Implementation
- Created `HISTORY.md` with reconstructed earlier history
- Created `session-44-HISTORY-WITH-CODEX.md` (this file)

---

## Decision Thread 13: Template Propagation Fixes

### User Intent
User noticed templates had stale content after all the changes.

### Assistant Structure
I identified that templates needed updates to match the new:
- Direct-handling-default routing
- Agent disclosure footers
- Corrected model attributions
- Skills system references

### User Correction
User asked to propagate all fixes to all 25 topic folders.

### Final Agreement
- Fix templates first, then propagate
- Propagation includes:
  - `AGENTS.md`
  - `opencode-agent-system.md`
  - `opencode.json`
  - `sync-from-hub.ps1`
  - `git-github-best-practices.md`
  - `audit-folder-quality.ps1`
  - `.cleanup-protect`
  - `topic-insights.md`

### Implementation
- Fixed `propagate-templates/opencode.template.json`
- Fixed `propagate-templates/AGENTS.template.md`
- Updated `propagate-templates/opencode-agent-system.template.md`
- Updated `propagate-templates/README.md`
- Ran `scripts/propagate-to-all.ps1 -Apply`
- Verified propagation succeeded

---

## Master File List (Session 44)

### Files Created
1. `docs/repo-tooling.md`
2. `docs/research-methodology.md`
3. `docs/model-testing-system.md`
4. `scripts/ws.sh`
5. `archive/early-history.md`
6. `archive/model-tests/`
7. `.opencode/agents/explorer.md`
8. `.opencode/agents/planner.md`
9. `.opencode/agents/scribe.md`
10. `.opencode/agents/drafter.md`
11. `.opencode/agents/gardener.md`
12. `.opencode/agents/debugger.md`
13. `.opencode/agents/reviewer.md`
14. `workflow/agentic-savings-log.md`
15. `docs/codex-agent-workflows.md`
16. `propagate-templates/opencode-agent-system.template.md`
17. `propagate-templates/opencode.template.json`
18. `.opencode/skills/propagate/SKILL.md`
19. `.opencode/skills/audit-quality/SKILL.md`
20. `.opencode/skills/session-handoff/SKILL.md`
21. `.opencode/skills/research-deep/SKILL.md` + references/
22. `.opencode/skills/cross-domain-harvest/SKILL.md`
23. `propagate-templates/skills-template/README.md`
24. `MIDDLE-HISTORY-WITH-CODEX.md`
25. `LATE-HISTORY-WITH-CODEX.md`
26. `EARLY-HISTORY-WITH-CODEX.md`
27. `session-44-HISTORY-WITH-CODEX.md` (this file)

### Files Modified
1. `AGENTS.md`
2. `README.md`
3. `docs/cross-project-memory-loop.md`
4. `docs/workspace-system-overview.md`
5. `docs/windows-repo-tooling.md`
6. `scripts/audit-folder-quality.ps1`
7. `scripts/ws.ps1`
8. `HISTORY.md`
9. `workflow/session-state.json`
10. `opencode.json`
11. `docs/agentic-workflows.md`
12. `docs/codex-agent-workflows.md`
13. `propagate-templates/AGENTS.template.md`
14. `propagate-templates/opencode-agent-system.template.md`
15. `propagate-templates/opencode.template.json`
16. `scripts/propagate-to-all.ps1`

### Files Removed/Moved
1. `docs/wsl-tooling.md` → deleted
2. `docs/CONTEXT.md` → deleted (merged)
3. `research/archived-findings.md` → `docs/research-findings.md`
4. `model-tests/` → `archive/model-tests/`
5. `quality-standards.md` → `docs/quality-standards.md`
6. `merge-log.md` → `workflow/merge-log.md`
7. `cross-domain-registry.md` → `workflow/cross-domain-registry.md`
8. `promotion-review-state.json` → `workflow/promotion-review-state.json`

---

## How To Hand This Over

For a future agent reading this:

1. **Read this file first** if you need to understand WHY something is the way it is
2. **Read `workflow/session-state.json`** for current active state
3. **Read `AGENTS.md`** for current operating rules
4. **Read `docs/workspace-system-overview.md`** for the system map
5. **Read `HISTORY.md`** for compact session ledger
6. **Read `EARLY-HISTORY-WITH-CODEX.md`**, `MIDDLE-HISTORY-WITH-CODEX.md`, `LATE-HISTORY-WITH-CODEX.md` for narrative bridges

The most important invariant to preserve: **The decision chain matters more than the final file list.** If you change something, document why using the same format (User Intent → Assistant Structure → User Correction → Final Agreement → Implementation).

---

## Metadata

```yaml
---
session: 44
date: 2026-04-23
status: complete
interrupted_count: 0
total_decision_threads: 13
files_created: 27
files_modified: 16
files_moved: 8
next_action: Continue normal work per workflow/session-state.json
---
```
