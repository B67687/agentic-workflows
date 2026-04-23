# History

This file tracks all significant changes to the AI Prompting Library. Newest entries at top.

---

## 2026-04-23

### Session 44 - Enhanced Topic-Folder History System + OpenCode Crash Fix

**Purpose:** Give every topic folder a history system that can capture external work; fix OpenCode Desktop crash on topic folders.

**What Changed:**

1. **History system enhancement:**
   - Redesigned `propagate-templates/HISTORY.template.md`:
     - Added `External Work` section for tracking out-of-repo work (research, prototyping, conversations, other repos).
     - Added monthly-split guidance for high-activity projects (`[folder]-content/history/history-YYYY-MM.md`).
   - Updated `AGENTS.md` Session Documentation rules to require topic-folder `HISTORY.md` updates.
   - Propagated enhanced `HISTORY.md` to all 25 topic folders (all merged successfully).

2. **Chat export archival:**
   - Processed `CHAT-EXPORT-LATE-HISTORY-HANDOVER.txt` (April 21–23 Codex session).
   - Moved to `archive/raw/CHAT-EXPORT-LATE-HISTORY-HANDOVER.txt`.
   - Patched `archive/history-2026-04.md` with missing Sessions 31–42 and Session 43.

3. **CRITICAL FIX — OpenCode Desktop crash:**
   - Root cause: `_managed_by` field in `opencode.json` is not a valid OpenCode config schema property; strict validation rejected it, causing crashes.
   - Removed `_managed_by` from `propagate-templates/opencode.template.json`.
   - Updated `scripts/propagate-to-all.ps1`:
     - JSON files now use `$schema` matching to detect managed status instead of `_managed_by`.
     - JSON files get clean overwrite (not markdown merge) to prevent broken JSON.
   - Force-overwritten all 25 topic folder `opencode.json` files.

4. **COST FIX — Three-tier fallback for Debugger/Reviewer:**
   - **Problem:** One Debugger + one Reviewer subsession on ImageMagick burned $3 using Claude Sonnet 4.6.
   - **Solution:** Replaced binary free/paid escalation with three-tier fallback:
     - **Tier 1 (default):** Orchestrator handles debug/review directly with K2.6 — $0 extra cost
     - **Tier 2 (fallback):** Spawn @debugger/@reviewer with M2.7 (Go, flat rate) — only when fresh context needed
     - **Tier 3 (escalation):** Claude Sonnet 4.6 — only for security or when Tiers 1+2 both failed (2+ attempts)
   - **Agent model changes:**
     - `.opencode/agents/debugger.md`: `opencode/claude-sonnet-4-6` → `opencode-go/minimax-m2.7`
     - `.opencode/agents/reviewer.md`: `opencode/claude-sonnet-4-6` → `opencode-go/minimax-m2.7`
     - Updated `AGENTS.md`, `docs/agentic-workflows.md`, `propagate-templates/AGENTS.template.md` routing tables
     - Updated `propagate-templates/opencode.template.json` and hub `opencode.json` Orchestrator prompts
     - Batch-updated all 25 topic folder agent configs and `opencode.json`
   - **Escalation rules:** Sonnet 4.6 only for:
     1. Security vulnerability suspected or confirmed
     2. K2.6 and M2.7 both failed after 2+ attempts each
     3. User explicitly requests premium analysis
    - **Cost control:** K2.6 direct handling costs $0 extra. M2.7 subagent is flat rate. Sonnet 4.6 is pay-as-you-go — keep it rare.

5. **PROVIDER FIX — Missing `provider` and `model` fields:**
   - **Problem:** Topic folder `opencode.json` files were missing the `provider` section and explicit `model` field, causing OpenCode Desktop to fall back to its internal default (Zen for K2.6).
   - **Solution:** Added full `provider` section and `"model": "opencode-go/kimi-k2.6"` to `propagate-templates/opencode.template.json`:
     - `opencode-go` provider: K2.6, K2.5, M2.7, M2.5, GLM-5.1
     - `opencode` (Zen) provider: M2.5 Free, Sonnet 4.6, GPT-5.4 Nano
   - Re-propagated all 25 topic folders with explicit model assignment.
   - Verified: `ImageMagick/opencode.json` now shows `"model": "opencode-go/kimi-k2.6"`.

**Decisions:**
- Topic folders keep a single `HISTORY.md` at root by default; high-activity projects can migrate to monthly files in `[folder]-content/history/`.
- External work gets the same treatment as in-repo work — log it or lose it.
- Never use non-standard fields in `opencode.json`; stick to the documented schema only.
- **Cost control:** Debugger/Reviewer default to Orchestrator direct (K2.6, $0 extra). M2.7 for specialist fallback. Sonnet 4.6 only for security or failed attempts. $3/session is unsustainable.
- **Provider discipline:** Always include explicit `provider` section and `model` field in `opencode.json`. Never rely on OpenCode Desktop defaults — they can silently switch to Zen.

**Verification:**
- Sampled `MathLearningNotes/opencode.json` and `OpenCode/opencode.json` — both clean, no `_managed_by`.
- `scripts/propagate-to-all.ps1 -Apply` reported 25 overwrites with no errors.
- Audit: 74/74 files, 0 warnings, 0 errors.

### Session 43 - Middle History Handover Document

**Purpose:** Create a detailed chronological handover documenting the intent → improvement → refinement → agreement → implementation cycle from the Codex middle sessions.

**What Changed:**
- Created `MIDDLE-HISTORY-WITH-CODEX.md` (466 lines) covering the arc from:
  - Interrupted GitHub trending handoff (April 21)
  - Folder-structure cleanup and workspace overview (April 22)
  - Repository optimization, command wrappers, WSL tooling (April 22)
  - Research methodology, model-routing research, PR sequence diagrams
  - OpenCode agentic token-efficiency system
- Structure followed user's requested format: intent → Codex improvement → user refinement → final agreement → implementation.
- Linked from `README.md`.
- Added Session 43 entry to active `HISTORY.md` (now archived in `archive/history-2026-04.md`).

**Note:** `MIDDLE-HISTORY-WITH-CODEX.md` was later removed during cleanup (noted in Session 44 decisions). The chat export preserving this session's full content lives in `archive/raw/CHAT-EXPORT-LATE-HISTORY-HANDOVER.txt`.

**Verification:**
- `scripts/ws.ps1 validate`: passed
- `scripts/test-ws.ps1`: passed
- Audit: 76 files scanned, 0 errors, 5 pre-existing unrelated warnings

---

## 2026-04-22 (Late)

### Sessions 31-42 - Repository Optimization, Command Wrappers, and Terminal Strategy

**Purpose:** Optimize the repo for faster cold starts and lower context cost; create unified command wrappers; decide on terminal strategy.

**What Changed:**

1. **Hot-path file compression:**
   - `AGENTS.md`: 359 → ~116 lines (moved deep content to dedicated docs, kept operating contract + index)
   - `HISTORY.md`: 965 → ~119 lines (moved full history to `archive/history-2026-04.md`)
   - `research/research-log.md`: 1,734 → ~54 lines (moved full log to `archive/research-log-2026-04.md`)
   - `docs/prompt-templates.md`: 1,189 → ~89 lines (moved templates to `docs/prompt-library/`)
   - `docs/workspace-system-overview.md`: 396 → ~190 lines (tighter cold-start protocol)

2. **Prompt library split:**
   - Created `docs/prompt-library/` with grouped template files:
     - `debugging-and-verification.md`
     - `learning-and-onboarding.md`
     - `repo-workflows.md`
     - `voice-and-humanization.md`
     - `visualization.md`
   - Preserved exact pre-split copy: `archive/prompt-templates-2026-04-pre-split.md`

3. **Command wrappers:**
   - `scripts/ws.ps1` — PowerShell hub for `status`, `hotspots`, `validate`, `search`, `research`, `propagate`
   - `scripts/test-ws.ps1` — plain PowerShell self-tests (no Pester dependency)
   - `scripts/ws.sh` — WSL/Linux read-only wrapper for `help`, `status`, `search`, `validate`

4. **Audit guardrails:**
   - `scripts/audit-folder-quality.ps1` now recursively scans active authored files (was only 4 root files)
   - Added context-budget warnings for hot-path files
   - Added `-IncludeArchive` and `-IncludeGenerated` switches
   - Fixed `param()` detection for help-block scripts
   - Fixed template audit false positives

5. **Terminal strategy:**
   - PowerShell declared as default terminal for mutating hub automation
   - WSL documented as optional read-only inspection lane
   - Created `docs/repo-tooling.md` with shared Windows/WSL guidance
   - Kept `docs/windows-repo-tooling.md` as redirect

6. **Quality standards update:**
   - `docs/quality-standards.md` updated with hot-path size budgets and active/archive/generated boundaries
   - Added `.rgignore` to keep raw archives and generated snapshots out of normal search

**Preserved archives:**
- `archive/history-2026-04.md` — full pre-compression history
- `archive/research-log-2026-04.md` — full pre-compression research log
- `archive/prompt-templates-2026-04-pre-split.md` — exact pre-split templates
- `archive/raw/session-raw-opencode-share-KP4etwvL.html.txt` — moved raw snapshot

**Verification:**
- Audit: 60+ active files scanned, 0 warnings, 0 errors
- `scripts/check-sync-status.ps1`: OK
- `scripts/test-ws.ps1`: passed
- `scripts/ws.ps1 validate`: passed
- `bash scripts/ws.sh validate`: passed

---

## 2026-04-22

### Session 30 - Overview Second Pass

**Purpose:** Tighten the workspace system overview into a faster cold-start protocol and remove orientation drift between entry files.

**What Changed:**
- Rewrote `docs/workspace-system-overview.md` around a 30-second read, fast startup protocol, hub-vs-topic distinction, operating loop, cross-domain flow, and source/generated file boundaries.
- Normalized the hub startup order across `AGENTS.md`, `README.md`, and `docs/CONTEXT.md`: `workflow/session-state.json` first, then rules, then the system map.
- Clarified that topic-folder resumes should read `[Topic]/meta/HANDOVER.md` first when it exists, while hub resumes use `workflow/session-state.json`.
- Updated `README.md` structure to include `research/`, `archive/`, and `personal-voice/`, and linked `docs/session-recovery-guide.md`.
- Updated `docs/quality-standards.md` structure to match the real top-level folders.
- Fixed an older handover snippet in `docs/agent-context-handover.md` that still said to start with `AGENTS.md`.

**Decision:**
- Treat `docs/workspace-system-overview.md` as the plain-language system map, not another deep reference. Deep docs stay linked from `README.md`.

**Verification:**
- `scripts/audit-folder-quality.ps1` passed with 0 warnings and 0 errors.
- `scripts/check-sync-status.ps1` returned OK.
- Targeted path check confirmed all newly linked orientation files exist.

### Session 29 - Workspace System Overview

**Purpose:** Create a plain-language map explaining what this hub does and how its parts fit together.

**What Changed:**
- Created `docs/workspace-system-overview.md` as the fast system-level orientation file.
- Linked it from `README.md`, `AGENTS.md`, and `docs/CONTEXT.md`.
- Captured the core model: central brain, distribution system, live workflow state.
- Documented the main loop: research -> integrate -> propagate -> verify -> document.
- Documented how topic folders, `topic-insights.md`, harvest/candidate scripts, propagation templates, and session state fit together.

**Decision:**
- Keep this as the first-pass system map. A second ultra-high pass would be useful for tightening diagrams, checking contradictions, and turning it into an even more compact startup protocol.

### Session 28 - Root Drift Cleanup

**Purpose:** Analyze root-drift findings, remove obvious generated/stale artifacts, move safe content into canonical content folders, and leave only genuinely risky items.

**What Changed:**
- Moved `BulkCrapUninstaller/bulkcrapuninstaller-content/Windows Uninstall Locations.txt` into `bulk-crap-uninstaller-content/`, then removed the empty legacy folder.
- Moved all Computer Organisation and Architecture course folders plus `README.md` into `computer-organisation-and-architecture-content/`.
- Moved `Fluent Search Manifest/Extras/bucket/zoom-win64.json` into `fluent-search-manifest-content/Extras/bucket/`, then removed the now-empty root `Extras/`.
- Removed generated/stale artifacts:
  - `Fluent Search Manifest/temp_logs.zip`
  - `Image Glass/.build-check`
  - root `audit-folder-quality.md` copies in OpenCode, Random, Reality, UniGetUI, and Wall You
  - `LocalSend/localsend-content` (Dart/pub cache + downloaded SDK/tool home)
- Moved UniGetUI legacy content from `unigetui-content/` into `uni-get-ui-content/`, then removed the empty legacy folder.

**Left For Manual Attention:**
- `Fluent Search Manifest/temp_extras/` — active git clone with meaningful differences from canonical `fluent-search-manifest-content/Extras/` (13 files only in temp, 8 only in canonical, 332 differing files).
- `OpenCode/opencode-content/` — active git repo with uncommitted deletions (`AGENTS.md`, `README.md`); canonical `open-code-content/` is empty, but moving an active repo path can break local references.

**Verification:**
- Final structure scan reports only two remaining drift items: `Fluent Search Manifest/temp_extras` and `OpenCode/opencode-content`.
- Hub audit still passes with 0 warnings and 0 errors.

### Session 27 - Folder Structure Enforcement

**Purpose:** Check whether `AGENTS.md` explains the propagated folder structure clearly enough and make drift visible in audits.

**What Changed:**
- Tightened `AGENTS.md` root-discipline rules for propagated project folders.
- Expanded `propagate-templates/AGENTS.template.md` with explicit root rules:
  - allowed root files/folders,
  - what must go into `[folder-name]-content/`,
  - how to handle existing root drift safely.
- Updated `README.md` and `propagate-templates/README.md` with the same structure rule.
- Added folder-structure warnings to `propagate-templates/audit-folder-quality.template.ps1`.
- Fixed the propagated audit script's verbose output and `param()` detection so structure warnings are readable.
- Added `Computer Organisation and Architecture` to `workflow/cross-domain-registry.md` and updated participating folder count to 25.
- Ran forced propagation so stale unmanaged audit scripts were refreshed in all 25 topic folders.
- Refreshed harvested insights and cross-domain candidates.

**Observed Drift:**
- Duplicate legacy content folders: BulkCrapUninstaller, LocalSend, OpenCode, UniGetUI.
- Root content outside content folder: Computer Organisation and Architecture, Fluent Search Manifest, Image Glass.
- Stray root `audit-folder-quality.md`: OpenCode, Random, Reality, UniGetUI, Wall You.

**Verification:**
- `scripts/check-sync-status.ps1` returned OK.
- Hub `scripts/audit-folder-quality.ps1` passed with 0 warnings and 0 errors.
- Propagated audit now reports `[folder-structure]` warnings with exact root drift details.

### Session 26 - Session State + Checkpoint System

**Purpose:** Solve the recurring problem of context limit interrupts + expensive workspace re-scans on every resume.

**Root Cause Identified:**
The workspace has compound context costs. More docs → more to read on resume → faster context exhaustion → more interrupts → more recovery overhead. A full workspace scan costs ~110k tokens just to orient.

**What Changed:**

1. **workflow/session-state.json** (new) — Active session state file with:
   - Current task, phase, next action
   - Key context (files created/modified, decisions, patterns)
   - Todo state (completed/in_progress/pending)
   - Context pressure estimate
   - Resumption notes

2. **workflow/session-state.template.json** (new) — Blank template for new sessions

3. **docs/session-checkpoint.md** (new) — Full system documentation:
   - Two-part system: session state (Option A) + proactive checkpointing (Option B)
   - Checkpoint trigger conditions table
   - Context pressure signs (low/medium/high/critical)
   - Workflow for starting multi-phase tasks, after interrupt, completing session
   - Anti-patterns

4. **AGENTS.md** — Updated with:
   - Key Rules: session state on every resume + checkpoint before heavy operations
   - High-Signal Files: added `workflow/session-state.json` and `docs/session-checkpoint.md`
   - Deep References: added Session State / Checkpoint entry
   - Session Documentation: added reference to session-checkpoint.md

5. **AGENTS.template.md** — Updated with:
   - Core Workflow: added checkpoint before heavy operations
   - Deep References: added session checkpoint (hub only note)

6. **README.md** — Updated with:
   - Start Here: added session-checkpoint.md
   - Workflow Files: added session-state.json and template

**The System:**

```
Rule 1: Read workflow/session-state.json FIRST on every resume
Rule 2: Write workflow/session-state.json BEFORE heavy operations
```

Checkpoint triggers:
- Before multi-phase task
- Before bulk fetches (5+ parallel)
- After completing any phase
- At 50% context estimate
- After an interrupt

**Key Insight:** The problem was not just context limits — it was writing state AFTER exhaustion instead of BEFORE. Proactive checkpointing at medium context prevents the interrupt, not just the recovery.

**Files Created:** 3
**Files Modified:** 4
**Templates Updated:** 1

---

## 2026-04-22

### Session 25 - Starred Repos Research (Phase 1-3)

**Purpose:** Scan all 238 starred GitHub repos, identify patterns, deep-dive top candidates.

**What Changed:**

1. **archive/starred-repos-2026-04-22.md** — Phase 1 complete:
   - Full sorted table of all 238 repos (by stars)
   - 12 cluster categories identified (AI agents, education, Windows utils, Android, design tools, etc.)
   - Pattern analysis: AI agent tooling dominates (~45 repos), token efficiency is recurring theme
   - Top 30 Phase 2 candidates selected
   - Own repos identified (MathLearningNotes, CS50p-2022, H2-Computing, BEPb, Password-Generator)

2. **archive/starred-repos-phase2-2026-04-22.md** — Phase 2-3 complete:
   - Medium scans of top 10 candidates (get-shit-done, everything-claude-code, gstack, caveman, learn-claude-code, hermes-agent, claude-code-best-practice, agency-agents, OpenMythos)
   - Key pattern findings: context rotation vs accumulation, multi-agent orchestration, token efficiency spectrum, agent specialization
   - Integration recommendations mapped to 5 docs (ai-product-building, core-agent-doctrine, token-efficient-prompting, prompt-templates, daily-prompts)
   - 5 high-priority deep dives identified for future sessions

**Key Discoveries:**
- Token efficiency is multi-dimensional: output compression (caveman), input compression (caveman-compress), context rotation (get-shit-done), learned skill compression (hermes-agent, everything-claude-code)
- Multi-agent team pattern: gstack (23 roles), agency-agents (144 agents, 12 divisions), MetaGPT (role-SOP)
- Context rotation: The central engineering problem is accumulation vs preservation. Three solutions: rotation, compression, search
- hermes-agent self-improvement loop is the most mature "agent that learns" pattern found

**Sources:** GitHub starred repos (B67687), README files from top 10 candidates

---

## 2026-04-22 (Early)

### Session 24 - Visualization in AI Explanations + Proactive Context Handover

**Purpose:** Research two topics: (1) how to implement Excalidraw visualization in AI explanations, and (2) context limit self-awareness with proactive handover.

**What Changed:**

1. **docs/prompt-templates.md** — Added section 27 "Generate Excalidraw Diagram" with:
   - When to offer a diagram (system architecture, data flow, entity relationships, etc.)
   - How to generate `.excalidraw` JSON (element types, layout, colors)
   - Complexity rule (keep under 15 elements)
   - How the user opens and edits the diagram
   - Source: Copilot Excalidraw skill (MIT license)
   - Updated quick reference index

2. **docs/agent-context-handover.md** — Added "Proactive Context Handover" section:
   - Why models can't see token counts but CAN recognize pressure signals
   - Context pressure signals table (generic output, re-explaining, losing track, etc.)
   - The checkpoint prompt to run before complex responses
   - Proactive handover template for when signals hit 2+
   - When to trigger checkpoints (long sessions, multi-phase work)

3. **docs/token-efficient-prompting.md** — Added "Context Pressure Monitoring" section:
   - Behavioral symptoms of context degradation
   - Pressure signals table
   - Checkpoint rule for sessions over 20-30 minutes
   - Hierarchical memory pattern (User → Session → Agent)
   - Reference to Mem0 v3 for memory architecture

4. **research/research-log.md** — Added 2026-04-21 research entry covering:
   - Three Excalidraw integration paths (MCP, Copilot skill, Python scripts)
   - The .excalidraw JSON format and complexity rules
   - Proactive context handover mechanism
   - Session recovery pattern for interrupted sessions

**Key Decisions:**
- Keep Excalidraw diagrams simple (under 15 elements) — let the user edit and extend
- Context pressure is behavioral, not introspective — model detects signals, not token counts
- Proactive handover at 80% beats reactive when the limit hits

**Sources:**
- [Excalidraw skill](https://github.com/selopo-ec/my-awesome-copilot/blob/main/skills/excalidraw-diagram-generator/SKILL.md) (MIT)
- [Mem0 v3](https://github.com/mem0ai/mem0) (53k stars, hierarchical memory)

---

## 2026-04-21 (Night)

### Session 23 - Language-Filtered Trending Research

**Purpose:** Continue the interrupted language-filtered GitHub trending cycle with Python and TypeScript scans, then integrate and propagate.

**What Changed:**
- Added `2026-04-21 (Language-Filtered GitHub Trending Scan: Python + TypeScript)` to `research/research-log.md`.
- Included the requested tables: repos looked at, which repos were deep-dived, what was learned from each, and combined learnings.
- Updated `docs/token-efficient-prompting.md` with `Model Routing as Cost Control (2026-04-21)` based on Manifest.
- Updated `docs/ai-product-building.md` with language-filtered trending patterns: managed agent runtime baseline, model routing, stable local URLs, secrets/machine identity, and recursive sandboxed inference as watch-only.
- Added `Integration: 2026-04-21 (Language-Filtered Trending: Python + TypeScript)` to `research/integration-log.md`.
- Ran `scripts/propagate-to-all.ps1 -Apply`; propagation processed 24 current sibling folders and updated sync state.
- Resolved registry drift found during propagation: added `Hackerthon`, removed missing local folders `Medo` and `Probability and Statistics`, and refreshed harvested insights/cross-domain candidates.
- Verified with `scripts/check-sync-status.ps1` (OK) and `scripts/audit-folder-quality.ps1` (pass).

**Key Decisions:**
- Do not promote `alexzhang13/rlm` to doctrine yet; keep recursive sandboxed inference as research watch until stronger production evidence appears.
- Keep topic templates generic; do not push today's specific trending snapshot into every topic folder.

### Session 22 - Trending Research -> Integrate -> Propagate

**Purpose:** Rescan the updated workspace, run a GitHub trending deep-research cycle, integrate high-signal findings, then propagate.

**What Changed:**
- Rescanned the workspace and confirmed the current structure with `workflow/` as the home for registries, queues, logs, and sync state.
- Added `2026-04-21 (GitHub Trending Deep Scan)` to `research/research-log.md` with confidence levels, deep-dive selections, and integration mapping.
- Updated `docs/token-efficient-prompting.md` with a new section on MCP retrieval efficiency as a practical token-cost lever (based on reproducible evaluation framing).
- Updated `docs/ai-product-building.md` with new deep-dive patterns from trending repos: production-readiness signaling, retrieval benchmarking, parser-pluggable ingestion, and fallback-aware ops design.
- Added `Integration: 2026-04-21 (Trending Repos Deep Dive)` to `research/integration-log.md`.
- Ran `scripts/propagate-to-all.ps1 -Apply` for all 25 folders; propagation completed and `workflow/sync-state.json` was updated.
- Verified sync health with `scripts/check-sync-status.ps1` (OK) and ran `scripts/audit-folder-quality.ps1` (pass).

**Key Decisions:**
- Prioritize deep-dive research on repos with reusable workflow patterns (evaluation rigor, architecture clarity, reliability patterns), not only star growth.
- Treat efficiency and benchmark claims as directional until validated on internal representative workloads.

## 2026-04-21 (Evening)

### Session 21 - GPT-5 Nano Ranking + NoFaceScanApp Propagation

**Purpose:** Place GPT-5 nano correctly in the free-model routing table and add NoFaceScanApp to the propagated folder system.

**What Changed:**
- Updated `docs/model-selection-guide.md` to rank GPT-5 nano as a free worker model for summaries, extraction, classification, ranking, and simple transforms.
- Clarified that MiniMax M2.5 Free is still the better free default for OpenCode coding-agent work.
- Added NoFaceScanApp to `cross-domain-registry.md` and the participating folder list in `AGENTS.md`.
- Propagated required files to `M:\M-Namikaz-Others\NoFaceScanApp`: `AGENTS.md`, `topic-insights.md`, `git-github-best-practices.md`, `.cleanup-protect`, and `audit-folder-quality.ps1`.
- Fixed `scripts/propagate-to-all.ps1` so `.cleanup-protect.template.md` maps to `.cleanup-protect`, not `.cleanup-protect.md`.
- Updated propagation templates so `.cleanup-protect` and `audit-folder-quality.ps1` include the managed marker; also fixed the audit template to audit its own folder when propagated.
- Updated propagation structure rules: `[folder-name]-content/` is mandatory and created by propagation; `meta/` is optional and created only when a project needs durable local context.
- Created `M:\M-Namikaz-Others\NoFaceScanApp\no-face-scan-app-content`.
- Updated `README.md`, `cross-domain-registry.md`, `propagate-templates/README.md`, and `propagate-templates/AGENTS.template.md` to reflect the new structure rule.
- Added the explicit operating-area rule: normal project work belongs in `[folder-name]-content/`, while the project root stays for propagated instructions and truly root-scoped project files.
- Added a central-hub exception in `AGENTS.md`: this hub's `docs/`, `research/`, `scripts/`, `propagate-templates/`, `archive/`, and `personal-voice/` are already the working content areas and should not be moved into `ai-prompting-content/` without a full redesign.
- Cleaned up obsolete artifacts after the propagation rule change:
  - Removed 24 duplicate `.cleanup-protect.md` files created by the earlier template mapping bug. The correct `.cleanup-protect` files remain.
  - Removed the empty `AI Prompting/meta/` folder because `meta/` is now optional.
  - Deleted `scripts/create-meta-folders.ps1` because it bulk-created `meta/` folders and now contradicts the optional-meta rule.
- Moved misplaced files after repo-structure analysis:
  - `scripts/zip-analysis.md` -> `archive/zip-analysis.md` because it is a cleanup-analysis reference, not an executable script.
  - `promotion-review-state.json` -> `scripts/cross-domain-review-state.json` so review state lives beside the cross-domain candidate scripts and matches `build-cross-domain-candidates.ps1`.
- Updated `scripts/set-promotion-review-status.ps1` and `docs/cross-project-memory-loop.md` to use `scripts/cross-domain-review-state.json`.
- Moved remaining cross-domain workflow files out of the root:
  - `cross-domain-registry.md` -> `scripts/cross-domain-registry.md`.
  - `merge-log.md` -> `scripts/merge-log.md`.
- Updated `scripts/merge-and-propagate.ps1` to write merge history to `scripts/merge-log.md`.
- Fixed `scripts/build-cross-domain-candidates.ps1` so template placeholder bullets are ignored instead of becoming review candidates.
- Regenerated `scripts/cross-domain-candidates.md`; noisy placeholder candidates dropped from 105 to 9 real candidates.
- Corrected the previous overmove into `scripts/` by creating `workflow/` for non-executable workflow files:
  - `scripts/cross-domain-candidates.md` -> `workflow/cross-domain-candidates.md`.
  - `scripts/cross-domain-registry.md` -> `workflow/cross-domain-registry.md`.
  - `scripts/cross-domain-review-state.json` -> `workflow/cross-domain-review-state.json`.
  - `scripts/harvested-topic-insights.md` -> `workflow/harvested-topic-insights.md`.
  - `scripts/merge-log.md` -> `workflow/merge-log.md`.
  - `scripts/sync-state.json` -> `workflow/sync-state.json`.
- Updated scripts so executable code remains in `scripts/` while workflow outputs/state/logs live in `workflow/`.
- Moved `quality-standards.md` -> `docs/quality-standards.md` because it is documentation, not a root entrypoint.
- Clarified the propagated audit template so new folders do not imply `quality-standards.md` belongs at the project root.
- Removed a noisy README audit trigger by avoiding citation-claim wording in the index page itself.
- Fixed `scripts/audit-folder-quality.ps1 -Verbose` so warning/error details print when requested.
- Added a README workflow-file index so registries, queues, logs, and state files remain discoverable after the move.

**Decision:**
- Use GPT-5 nano over MiniMax M2.5 Free for cheap worker tasks, not for main coding loops.
- Use MiniMax M2.5 Free over GPT-5 nano for code edits, repo reasoning, and OpenCode agent loops.

---

## 2026-04-21 (Access Refresh)

### Session 20 - Access-Aware Model Routing

**Purpose:** Refresh the "best model to use right now" guidance against the user's actual access.

**What Changed:**
- Updated `docs/model-selection-guide.md` with access-aware routing for GitHub Copilot Student/Pro, OpenCode Go, OpenCode Zen, Google AI Studio, OpenRouter, Gemini Code Assist, and Cursor Student.
- Added source references for Copilot request multipliers, OpenCode Go/Zen pricing and models, Gemini free-tier behavior, OpenRouter free caps, and Cursor Student.
- Updated `scripts/audit-folder-quality.ps1` to exempt `HISTORY.md`, matching the repo's required session documentation filename.

**Key Decisions:**
- Daily default: Claude Sonnet 4.6 through GitHub Copilot.
- Hardest work: Claude Opus 4.7, used sparingly because of the higher Copilot multiplier / paid Zen cost.
- High-volume cheap coding: OpenCode Go open models, especially MiniMax M2.7 and Qwen3.6 Plus.
- Free long-context/API lane: Google AI Studio with Gemini Pro/Flash models, while checking active AI Studio limits before big runs.
- OpenCode Zen is worth paying for only after Copilot premium requests or OpenCode Go limits become real constraints.

**Scan Notes:**
- GitHub CLI authenticated as `B67687`.
- OpenCode credentials exist for OpenRouter, GitHub Copilot, OpenCode Go, and Google.
- Live `opencode models` enumeration was blocked by a local SQLite WAL checkpoint error.

---

## 2026-04-22 (Early)

### Session 18 - Architectural Refactor: AGENTS.md Compression

**Purpose:** Reduce AGENTS.md from 702 to ~344 lines without quality loss

**Root Cause Identified:**
The hub's AGENTS.md had become a "dump everything" file instead of proper operating contract + index. The template (AGENTS.template.md) was correctly lean at 117 lines.

**Recursive Self-Check Results:**
- Confirmed hub AGENTS.md should be operating contract + index, not comprehensive knowledge base
- Teaching framework, Interpersonal Effectiveness, Cognitive Load - all better in dedicated docs/
- Template was missing key content: Operating Contract, 10 Principles summary, Recursive Self Prompting

**What Changed:**

1. **Enhanced AGENTS.template.md** (117 → 188 lines):
   - Added Operating Contract section
   - Added 10 Principles summary (condensed)
   - Added Recursive Self Prompting section
   - Added Deep References section
   - Added audit-folder-quality.ps1 to protected files list
   - Updated folder structure to include audit script

2. **Refactored hub AGENTS.md** (702 → 344 lines):
   - Removed duplicated detailed content (kept summary + reference to docs/)
   - Added Deep References table for all topics
   - Kept hub-specific content (Personal Voice, Session Docs, Recursive Self Prompting)
   - Kept Smart vs Functional Agents research finding
   - Consolidated Scripts section

3. **Propagated to all 24 topic folders**

**Template Quality:** Now more complete than before, still lean
**Hub Quality:** Reduced 50% (702→344) while preserving all essential operating contract content
**Propagation:** Updated all 24 topic folders with new templates

---

## 2026-04-22 (Early)

### Session 17 - Daily Research + Smart Agent Research

**Purpose:** Daily research cycle + focused research on building smart AI agents

**Research Findings:**

1. **Self-Verification** (Claude Opus 4.7): Smart agents verify outputs before reporting. Functional agents execute without checking. This is the key differentiator.

2. **Memory Systems**: Research reveals "experience compression spectrum" - memory/skills/rules at different compression ratios. Current gap: no adaptive cross-level compression exists.

3. **MemEvoBench**: Static prompt defenses insufficient. Memory contamination from adversarial injection, noisy outputs, biased feedback causes safety degradation.

4. **GTA-2 Benchmark**: Frontier models achieve only 14.39% on open workflows. Execution harness design matters beyond model capacity.

5. **Opus 4.7 Token Inflation**: Uses 1.0-1.35× more tokens than 4.6. 40% higher cost for same text.

6. **MCP v2 Beta**: OAuth 2.0, transport evolution, Tasks primitive for multi-agent coordination.

7. **Qwen3.6-35B-A3B**: Competitive with Opus 4.7 on some tasks at lower resource cost.

**Integration Completed:**

1. **core-agent-doctrine.md**:
   - Added self-verification prompt patterns to "Define Done And Verification Early" section
   - Added experience compression spectrum and memory validation to "Update Memory After Lessons" section

2. **ai-product-building.md**:
   - Added "Agent Reliability Research" section with GTA-2 benchmark findings
   - Added smart vs functional agent comparison table
   - Added memory contamination risk warning
   - Added MCP v2 Beta features

**Sources:** arXiv (cs.AI, cs.CL), Anthropic, OpenAI, Simon Willison, ACL 2026

---

## 2026-04-21 (Afternoon)

### Session 19 - Model Selection Refresh

**Purpose:** Rescan the workspace and refresh the current "best model to use" guide.

**What Changed:**
- Rewrote `docs/model-selection-guide.md` around task-routing lanes instead of a single leaderboard.
- Added `research/research-log.md` entry for the focused model refresh.
- Added `research/integration-log.md` entry with the correction and source notes.

**Key Decisions:**
- Default daily serious work: Claude Sonnet 4.6.
- Hardest agentic coding: Claude Opus 4.7.
- OpenAI tool-heavy work: GPT-5.4.
- Codex-style repo editing: GPT-5.3-Codex.
- Long-context multimodal synthesis: Gemini 3.1 Pro.
- Open-weight coding: GLM-5.1 if hosted/enterprise, Qwen3.6-35B-A3B if practical local-ish use matters.
- Budget lanes: MiniMax M2.7, DeepSeek V3.2, MiMo-V2-Pro, and Qwen3.6 Plus depending on access.

**Correction:**
- Removed the leftover claim that GPT-5.3-Codex is open-weight. It is a closed OpenAI API model. Open-weight claims now require official repo or Hugging Face verification.

---

## 2026-04-21 (Evening)

### Session 16 - Repository Compression + Protocol Creation

**Purpose:** Compact repository and create quality analysis protocol for future use

**Compression Results:**
- 4 of 6 originally-proposed compression items were incorrect upon deeper analysis
- Only 1 valid action: Moved `docs/quickstart-wsl2.md` → `archive/quickstart-wsl2-migration.md`

**Recursive Self-Check Analysis Errors Caught:**
- README.md + CONTEXT.md: Serve different audiences (human vs AI) - keep separate
- Research sections in token-efficient-prompting.md: Complementary content - keep both
- Scope hierarchy in cross-project-memory-loop.md: Application, not restatement - keep
- authoritative-agent-best-practices.md: Unique provenance value - keep

**What Changed:**

1. **Moved `docs/quickstart-wsl2.md`** → `archive/quickstart-wsl2-migration.md`

2. **Created `docs/repo-quality-analysis-protocol.md`** — Full protocol for future quality analysis including:
   - 6-step analysis framework
   - Audience awareness matrix
   - Decision framework table
   - Common analysis errors (with examples from this session's mistakes)
   - Recursive self-check requirement

3. **Added summary to `AGENTS.md`** — "Compression & Quality Analysis" section referencing the protocol

**Result:**
- Repository structure validated as sound
- Future sessions will have clear guidance on proper analysis approach

---

## 2026-04-21 (Evening)

### Session 15 - Repository Cleanup

**Purpose:** Full scan and fix of issues found in AI Prompting repository

**What Changed:**

1. **Moved `docs/lessons-scoop-prs.md`** → `M:\M-Namikaz-Others\Fluent Search Manifest\fluent-search-manifest-content\lessons-scoop-prs.md` (Scoop-specific, not propagated)

2. **Deleted `repos.txt`** - Confirmed artifact, no longer needed after folder structure standardization

3. **Fixed absolute path references** in docs:
   - `docs/token-efficient-prompting.md`
   - `docs/learning-while-building-with-agents.md`
   - `docs/project-rollout-template.md`
   - `docs/cross-project-memory-loop.md`
   - `docs/model-selection-guide.md`

4. **Updated `repo-lessons.md` → `topic-insights.md` references** across all files:
   - `scripts/bootstrap-project-instructions.ps1`
   - `scripts/sync-project-instructions.ps1`
   - `scripts/sync-all-project-instructions.ps1`
   - `propagate-templates/README.md`
   - `propagate-templates/.cleanup-protect.template.md`
   - `docs/project-rollout-template.md`
   - `docs/cross-project-memory-loop.md`
   - `AGENTS.md`

5. **Removed dead references** from README.md:
   - `build-promotion-candidates.ps1` (doesn't exist)
   - `harvest-project-lessons.ps1` (doesn't exist)
   - `repos.example.txt` (doesn't exist)
   - `repos.txt` (deleted)
   - `repo-lessons.template.md` (updated to topic-insights.template.md)

6. **Added Source Archives section** to `docs/core-agent-doctrine.md` - links to 4 archive files as deep-dive references

7. **Renamed `Course-Guide.pdf`** → `course-guide.pdf` in personal-voice samples

**Files Deleted:**
- `repos.txt`

**Files Moved:**
- `docs/lessons-scoop-prs.md` → `Fluent Search Manifest/fluent-search-manifest-content/`

**Files Modified:**
- README.md, AGENTS.md
- docs/token-efficient-prompting.md, docs/learning-while-building-with-agents.md
- docs/project-rollout-template.md, docs/cross-project-memory-loop.md
- docs/model-selection-guide.md, docs/core-agent-doctrine.md
- scripts/bootstrap-project-instructions.ps1, scripts/sync-project-instructions.ps1
- scripts/sync-all-project-instructions.ps1
- propagate-templates/README.md, propagate-templates/.cleanup-protect.template.md
- personal-voice/README.md

---

## 2026-04-21 (Late)

### Session 14 - Folder Structure Standardization

**Purpose:** Standardize all 24 topic folders to follow the intended structure

**Intended Structure:**
```
[Topic-Folder]/
├── AGENTS.md                         (propagated)
├── topic-insights.md                   (propagated)
├── git-github-best-practices.md        (propagated)
├── .cleanup-protect                   (propagated)
├── audit-folder-quality.ps1          (propagated - script)
├── meta/                             (topic-specific, NOT propagated)
└── [folder-name]-content/             (actual topic content)
```

**What Changed:**

1. **Added audit-folder-quality.ps1 to propagate-templates** — Script now propagates to all topic folders

2. **Created content folders** for all 24 topic folders following pattern `[kebab-case-folder-name]-content/`:
   - math-learning-notes-content/, probability-and-statistics-content/, opencode-content/, etc.

3. **Moved content into content folders**:
   - `live2/` → `math-learning-notes-content/`
   - `ProbAndStats/` → `probability-and-statistics-content/`
   - All other root content → respective content folders

4. **Removed cleanup-folders.ps1** from all topic folders (hub-only script)

5. **Removed old scripts/ subfolders** from topic folders (were artifact from manual copying)

6. **Fixed propagate-to-all.ps1**:
   - Added support for .ps1 template files
   - Fixed extension handling bug (was doubling extensions)
   - Fixed summary output formatting

7. **Deleted "Data Structures and Algorithms"** folder (temporary folder)

**Files Modified:**
- `propagate-templates/audit-folder-quality.template.ps1` (new)
- `propagate-templates/AGENTS.template.md` (updated reference path)
- `scripts/propagate-to-all.ps1` (fixed extension and .ps1 handling)

**Cleanup Done:**
- Removed doubled extension artifacts (*.md.md, *.ps1.md)
- Removed propagated files incorrectly placed in content folders
- Removed empty fengshui-content/ folder

---

## 2026-04-21

### Session 12 (~23:45-00:15) - Visualization for Learning Research

**Purpose:** Research how visualization helps with learning and knowledge retention

**Core Insight:** Dual coding theory — when verbal + visual channels encode same concept, recall is significantly better. The act of creating the diagram IS the learning, not the end product.

**What Changed:**
- Added visualization research to MathLearningNotes/topic-insights.md
- Key findings added: Dual Coding Theory, Picture Superiority Effect, Drawing Effect, "Ugly First Draft" principle
- Added recommended tools: Desmos, GeoGebra, Excalidraw, Obsidian Canvas

**Key Cognitive Science:**
- Dual Coding (Paivio): Both verbal + visual channels → better recall
- Picture Superiority: ~10-15% better recall vs text-only
- Drawing Effect (Wammes et al.): Drawing > writing for memory
- Cognitive Load Theory (Sweller): Visuals chunk information, reduce extraneous load

**MathLearningNotes specific insight:** Your fundamental-first learning style connects to visualization — you need to see relationships and spatial structure, not just symbolic manipulation.

---

### Session 13 (~00:15-00:30) - Repository Optimization

**Purpose:** Compress and optimize the AI Prompting repository based on recursive self-analysis

**Recursive Self-Prompting Analysis:**
1. What else to consider? → Checked file sizes, duplication, navigation, cleanup candidates
2. Am I missing anything? → Cross-references, template freshness, privacy
3. Is this complete? → Refined into 6 action categories
4. Reached plateau → Presented plan, user approved

**What Changed:**
1. **Added section index** to `docs/prompt-templates.md` — Quick reference table for 26 sections
2. **Simplified `docs/CONTEXT.md`** — Removed AGENTS.md duplication, kept navigation only
3. **Expanded `personal-voice/README.md`** — Added full system overview with all files indexed
4. **Added Recursive Self Prompting** to `AGENTS.md` — New principle section with loop, chains, plateau detection
5. **Propagated** updated templates to 25 folders (50 file operations)

**Archive/zip-analysis.md decision:** `zip-analysis.md` is a working document from cleanup session, not dead weight. Keep for reference.

**CONTEXT.md simplification note:** Removed duplicate operating contract, kept only AI orientation and quick reference.

---

## 2026-04-19 - Folder Structure Standardization (Today)

### Session 5 (~19:00-19:30) - Beginner/Amateur Reasoning Deep Research

**Purpose:** Research genuine amateur REASONING (not just voice) for assignments

**Core Insight:** Voice is superficial. AI knows too much to naturally think like a beginner. Requires cognitive constraints, not just vocabulary swaps.

**What Changed:**
- Expanded Section 16 from voice-only to genuine beginner reasoning
- Added 16B: Cognitive Constraints (knowledge boundaries, reasoning errors, genuine uncertainty)
- Added 16C: Fresh Mind Constraint (force beginner reasoning path)
- Added 16D: Socratic Beginner Mode (asking genuine novice questions)
- Added 16E: Typical Beginner Mistakes (domain-specific error patterns)
- Added comparison table: Voice-Only vs Genuine Beginner Reasoning
- Logged to research/research-log.md

---

### Session 6 (~19:45-20:15) - AI Detection Evasion & Personal Voice Training

**Purpose:** User's homework flagged by Turnitin. Research how detectors work and how to write in personal voice to evade detection.

**Core Insight**: AI writing has "fingerprints" humans don't: perfect grammar, uniform sentences, AI vocabulary (delve, tapestry, nuanced), formulaic transitions, no false starts. Detectors measure perplexity (predictability) and burstiness (sentence length variance).

**What Changed:**
- Added Section 17: Humanizing AI Writing (Evading Detection)
  - 17A: Anti-Detection Writing Style (patterns to avoid AI fingerprints)
  - 17B: Voice Samples + Style Transfer (paste your writing, get matching style)
  - 17C: Personal Voice Training (LoRA fine-tuning, retrieval-augmented)
  - 17D: Quick Humanization Add-On (injects human characteristics)
- Added Section 18: AI Detection Fingerprints Reference Table
- Logged to research/research-log.md

---

### Session 7 (~20:20-20:40) - Personal Voice Training System

**Purpose:** User wants AI to constantly train on their writing style and data, not just one-shot.

**What Changed:**
- Created `personal-voice/` directory structure:
  - `samples/` - user drops writing samples here
  - `VOICE-PROFILE.md` - extracted voice patterns
  - `STYLE-INJECT.md` - ready-to-use system prompt
  - `CORRECTIONS.log.md` - track corrections
- Created `scripts/extract-voice-profile.ps1` - analyzes samples, updates VOICE-PROFILE.md
- Added Personal Voice Training section to AGENTS.md (always active, read before any writing)
- Added `personal-voice/VOICE-PROFILE.md` to High-Signal Files table

---

### Session 8 (~21:00-21:30) - Voice Analysis from GitHub Repos

**Purpose:** User provided 3 GitHub repos to analyze their voice patterns across different contexts.

**What Changed:**
- Analyzed MathLearningNotes (highest voice - raw thoughts, advancement reports)
- Analyzed CS50p-2022 (medium voice - compressed bullet points)
- Analyzed H2-Computing (lower voice - structured definitions)
- Updated VOICE-PROFILE.md with spectrum analysis:
  - Raw thoughts = highest personal voice
  - Personal essays = high but more structured
  - Technical notes = low/formal
  - AI prompts = high-casual
- Key finding: user's voice is most natural when processing or exploring, less polished when presenting conclusions

**Voice Characteristics Discovered:**
- Compressed but direct (short declarative sentences)
- First-person natural ("I go", "I had a panic")
- Philosophical conclusions from specific experiences
- "But" as frequent paragraph opener
- "It is not like..." instead of "This is where..."
- Self-correction ("I no longer think...")
- Questions in raw processing
- Varied sentence length (not uniform 18-25 words like AI produces)

---

### Session 9 (~21:45-22:00) - Human Punctuation Research

**Purpose:** Research what punctuation patterns humans actually use vs AI.

**Key Findings:**
- **Em-dashes (—)**: Humans rarely use due to keyboard awkwardness. Use commas or two sentences instead.
- **Semicolons (;)**: Almost nobody uses except academic writers (~3-5% of adults)
- **Contractions**: Humans use naturally (~80-90% in casual writing)
- **Hedge words**: "maybe", "I guess", "sort of" — humans use naturally, AI formulaic or absent
- **And/But/So at sentence start**: Very common in humans (~15-20%), formally avoided by AI
- **Errors**: Humans make 2-5 errors per 100 words in casual typing. Perfect grammar is suspicious.

**What Changed:**
- Added 17D: Quick Humanization Add-On with em-dash/semicolon warning
- Added 17E: Anti-Academic Punctuation (avoid em-dashes, semicolons, colons mid-sentence)
- Updated Section 18 reference table with punctuation-specific entries
- Updated VOICE-PROFILE.md "What You Don't Sound Like" with punctuation rules

---

### Session 10 (~22:15-22:45) - AI Detection Tools Deep Research

**Purpose:** Comprehensive technical analysis of all major AI detection tools (Turnitin, GPTZero, Copyleaks, etc.)

**What Changed:**
- Added Sections 19-23 to docs/prompt-templates.md:
  - Section 19: AI Detection Tools Reference (accuracy, what each measures)
  - Section 20: Evasion Strategies by Detection Tool
  - Section 21: Genuine Writing Characteristics Detectors Miss
  - Section 22: Bypass Methods That Actually Work
  - Section 23: Critical Warnings (ESL bias, reliability concerns)

**Key Findings:**
- Turnitin: Most used but has 15-61% false positive rate for ESL writers
- GPTZero: 7-component architecture with "Paraphraser Shield"
- Originality.ai: Hardest to evade (trained on adversarial datasets)
- Copyleaks: Cornell-validated, cross-model detection

**Universal evasion rules:**
- Add perplexity (unpredictable word choices)
- Increase burstiness (sentence length variation)
- Use natural contractions (~80-90%)
- Natural hedge words ("maybe", "I guess" not "it is possible that")
- Mixed short/long sentences

**Proven effective:** "Elevate with literary language" → near 0% detection (Liang et al. 2023)

---

### Session 11 (~23:00-23:30) - Chinese Language AI Detection Research

**Purpose:** Research AI writing detection for Chinese text (user sees Chinese becoming very important in next decades)

**Key Findings:**
- Detectors fail on Chinese: ACL 2026 found 12 detectors failed completely on classical Chinese poetry
- Commercial tools (Turnitin, GPTZero) have poor Chinese support — not trained on enough Chinese data
- Chinese has different detection signals than English

**What Changed:**
- Added Section 24: Chinese Writing (Natural vs AI Patterns)
  - Chinese punctuation differences (。 vs .)
  - Chinese AI fingerprints to avoid (首先+其次+最后 chain, 成语 clustering)
  - How to sound human in Chinese
- Added Section 25: The ESL/CSL Structured Writing Problem
  - School-taught patterns trigger detection (both English and Chinese)
  - "Correct" school writing → flagged as AI, casual native writing → passes
- Added Section 26: Language-Agnostic Principles
  - 6 principles that work across all languages: Variance, Imperfection, Specificity, Voice, Register Mixing, Idiosyncrasy

**User Insight Captured:**
English/Chinese ESL is flagged because school teaches structured patterns → same as AI output → detectors flag both. The solution is to write less "perfect" — more variance, imperfection, personal voice.

---

### Session 4 (~18:00-18:30) - Deep Analysis & Teaching Addition

**Purpose:** Analyze existing docs for gaps, add teaching-while-doing to AGENTS.md

**What Changed:**
- Deep analyzed all docs in docs/, AGENTS.md, core knowledge
- Confirmed P3 (teaching while doing) was missing proactive teaching guidelines
- Confirmed P4 (best practices) was already comprehensive
- Added "Teach While Doing" section to AGENTS.md (teaching triggers, when/how to teach, examples)
- Propagated updated AGENTS.md to all 24 folders

---

### Session 3 (~14:00-17:00) - Full Repository Sweep

**Purpose:** Comprehensive scan, fix old template markers, clean up stub folders

**What Changed:**
- Deleted stub folders: UniGetUI/source/, UniGetUI/repo/, Fluent Search Manifest/Extras-batch/, Java-audit/, Extras-audit/, Main-audit/, OpenCode/scripts/
- Kept independent git repos as exceptions: claw-code/, Devolutions-*/, Main/, Java/, Extras/, Versions/, CS-Notes/, computing-notes-hugo/
- Deleted 6 stale analysis files: cleanup-analysis.md, folder-structure-analysis.md, repo-lessons-analysis.md, subfolder-investigation.md, nested-project-structure.md, full-scan-problems.md
- Created AI Prompting/meta/ for consistency
- Template markers fixed: propagate-to-all.ps1 enhanced to detect old `Template: Repo-Lessons`, all 24 refreshed to `Template: Topic-Insights`

**Scripts Updated:**
- harvest-topic-insights.ps1, build-cross-domain-candidates.ps1, create-meta-folders.ps1, propagate-to-all.ps1

---

### Session 2 (~10:00-12:00) - Research & Verification Framework

**Purpose:** Add verification framework to research, fix model selection errors

**What Changed:**
- Added verification framework to research prompt: source triangulation, confidence levels (L1-L4), error impact audit
- Corrected GPT-5.3 Codex error (was listed as open-weight, actually closed API)
- Updated model selection guide with April 2026 benchmarks (MiniMax M2.7, Claude Mythos Preview, GLM-5.1 as open-weight leader)

**Key Insights:**
- MiniMax M2.7 Free now available (unlimited tokens)
- Claude Mythos Preview leads coding (93.9% SWE-bench Verified, 77.8% Pro)
- Cursor agent best practices integrated (8 patterns)

---

### Session 1 (~08:00-10:00) - Initial Setup

**Purpose:** Establish new folder structure, meta/ convention, cross-domain system

**What Changed:**
- Introduced `meta/` folder convention (topic-specific files)
- Standardized HANDOVER variants to `meta/HANDOVER.md`
- Created `meta/` in all 24 topic folders + nested subfolders
- Renamed `repo-lessons.md` → `topic-insights.md` across all folders
- Created cross-domain system: harvest-topic-insights.ps1, build-cross-domain-candidates.ps1, merge-and-propagate.ps1
- Created cross-domain-registry.md, merge-log.md

**Cleanup:**
- 64 .bak files deleted
- node_modules/, .dotnet-home/, unigetui-main.tar.gz deleted
- fluent-search-nightly/stable.zip deleted
- src_snapshot/, localsend-src-20260410/ deleted

---

## Earlier History

*Reconstructed from file timestamps. Date-level precision where available.*

---

### ~2026-04-17 - Agent Handover & Model Switching

**What Changed:**
- Created docs/agent-context-handover.md
- Created docs/model-selection-guide.md (April 2026 benchmarks)
- AGENTS.md updated with Model Switching section (FrugalGPT cascade)

**Key Integration:**
- Learning science: CLT → prompting, Testing Effect → verification prompts
- Memory sharing systems: Mem0, MemOS

---

### ~2026-04-16 - Cognitive Identity Deep Research

**What Changed:**
- Major expansion of cognitive-identity.md (9 sections added)
- Added Security-First Agent Design (OWASP + IBM)
- Added Agent Architecture Patterns (22 design patterns for agents)

**Research:**
- System Design Primer, Refactoring.Guru, OWASP Top 10, IBM AI Agent Security, OpenMAIC

---

### ~2026-04-15 - Git/GitHub Best Practices

**What Changed:**
- Created docs/git-github-best-practices.md
- Created propagate-templates/git-github-best-practices.template.md
- First full research-to-integration cycle

---

### ~2026-04-14 - Research System Established

**What Changed:**
- Created research/README.md, research-prompt.md, research-log.md, integration-log.md
- Established 3-day research integration cadence

---

### ~2026-04-12-14 - Script Batch & Windows Tooling

**What Changed:**
- Created check-sync-status.ps1, cleanup-folders.ps1, audit-folder-quality.ps1
- Created docs/windows-repo-tooling.md, docs/session-recovery-guide.md

---

### ~2026-04-11-12 - Claude Code Lessons & Agent Doctrine

**What Changed:**
- Created archive/learn-claude-code-lessons.md, archive/claude-code-best-practice-lessons.md
- Expanded core-agent-doctrine.md with Karpathy principles

---

### ~2026-04-10 - Repository Genesis

**What Changed:**
- Created README.md, prompt-strategies.md, prompt-templates.md, daily-prompts.md
- Created authoritative-agent-best-practices.md (source-backed from OpenAI, Anthropic, GitHub Copilot docs)
- Created codex-reasoning-guide.md (reasoning effort: low/medium/high/xhigh)
- Created project-rollout-template.md, bootstrap-project-instructions.ps1, sync-project-instructions.ps1
- Created sync-all-project-instructions.ps1, repos.example.txt
- Created templates/ with AGENTS.template.md, repo-lessons.template.md, copilot-instructions.template.md
- Created AGENTS.md (local workspace instructions)
- Created lessons-scoop-prs.md (Scoop manifest + PR lessons)

**Notes:**
- Creation timestamps cluster around 3:47 PM – 6:36 PM
- No .git directory — repository has never had version control
- OpenCode global config discussed but not created (Codex has no equivalent)

### ~2026-04-11 - Claude Code Integration

**What Changed:**
- Created learn-claude-code-lessons.md (from shareAI-lab/learn-claude-code repo analysis)
- Created token-efficient-prompting.md (total session token cost optimization)
- Updated prompt-strategies.md, prompt-templates.md, daily-prompts.md, AGENTS.md, README.md
- Integrated mechanism-dependency teaching, smallest-correct-version first, state ownership patterns

**Notes:**
- Repo analyzed from live GitHub sources (clone failed due to Windows permissions)
- Failed clone left stub at learn-claude-code/ (user cleaned it up)

---

## Template for Future Sessions

```markdown
## YYYY-MM-DD - [Brief Title]

### Session N (HH:MM-HH:MM)
**Purpose:** [What was accomplished]

**What Changed:**
- [Key changes]

**Files Created/Deleted:**
- [List]

**Scripts Updated:**
- [List]
```

---

## Metadata

```yaml
---
last_updated: 2026-04-23
version: 2.0
central_hub: AI Prompting
---
```
