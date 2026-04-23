# Middle History With Codex

Generated: 2026-04-23 14:07:09 +08:00

This file is a handover-grade reconstruction of the middle phase of the `AI Prompting` workspace: the period where the repo shifted from a useful knowledge base into a more operational system with structure rules, cold-start discipline, command wrappers, terminal strategy, model-routing research, and native OpenCode agent workflows.

It is written for a future agent that needs to understand not only what changed, but why the changes took their final shape.

## Timestamp And Accuracy Notes

- Exact wall-clock timestamps were not preserved for every user/assistant message.
- The repo preserves session order and dates in `HISTORY.md`, `archive/history-2026-04.md`, and `workflow/session-state.json`.
- Where exact time is unavailable, entries use the best available timestamp format: `2026-04-22 / Session N / sequence order`.
- This file was created on `2026-04-23 14:07:09 +08:00`.
- Treat this as the narrative bridge between early history and the current active session ledger.

## Current Handover Snapshot

As of this file:

- The hub is a central knowledge and workflow system, not a normal app repo.
- Startup rule: read `workflow/session-state.json` first.
- Current active ledger is in `HISTORY.md`.
- Older full April history is in `archive/history-2026-04.md`.
- Early history is intended to live in `archive/early-history.md`, but some early details are still pending user input.
- The most important current operational docs are:
  - `AGENTS.md`
  - `README.md`
  - `docs/workspace-system-overview.md`
  - `docs/agentic-workflows.md`
  - `docs/repo-tooling.md`
  - `docs/model-selection-guide.md`
  - `docs/session-checkpoint.md`

Current command posture:

- PowerShell is the source of truth for mutating hub automation.
- `scripts/ws.ps1` is the main PowerShell wrapper.
- WSL is supported for native read-only inspection through `scripts/ws.sh`.
- Propagation still goes through PowerShell.

Pending manual decisions that predate this file:

- `Fluent Search Manifest/temp_extras`: active git clone, not safe to remove automatically.
- `OpenCode/opencode-content`: active git repo, canonical content folder is empty, not safe to move automatically.
- OpenCode Desktop may need restart/reload after native agent config changes.

## The Core Pattern Of This Middle Phase

Most important changes followed this loop:

1. User noticed friction or drift.
2. Codex proposed a structure or optimization.
3. User pushed back or refined the direction.
4. Codex adjusted the plan to preserve the user's intent.
5. The final agreement became repo rules, scripts, docs, or propagation templates.

The recurring user preference:

- Preserve useful history.
- Reduce cold-start cost.
- Make the system operational, not just documented.
- Prefer compact hot-path docs with deep references behind links.
- Keep structure strict enough that future agents can resume without rereading the world.
- Make wrappers and guardrails when a workflow repeats.
- Use stronger models only where they are worth the cost.

The recurring Codex contribution:

- Turn vague friction into an explicit operating contract.
- Add verification and audit loops.
- Convert repeated commands into scripts.
- Convert research into routing rules and docs.
- Preserve details in archive rather than delete them.

## Chronological Narrative

### Pre-Middle Context - GitHub Trending Research Handed Off

Timestamp: before the current Codex middle phase; reconstructed from user handoff.

User intent:

- The user had asked a prior Codex session to rescan the repo, research GitHub trending repos, deep dive worthwhile repos, integrate findings, and propagate lessons.
- The prior Codex session ended by suggesting language-filtered trending research.
- The user then asked for every research pass to report:
  - repos looked at
  - repos deep-dived
  - what was learned from each
  - combined learnings in a table
- That prior run stopped mid-message because of usage limits.

Codex improvement:

- The handoff established the expected research reporting format: repo-by-repo table plus combined learning synthesis.
- This became part of the broader `research -> integrate -> propagate -> document` operating style.

User improvement to the improvement:

- The user did not only want research output. They wanted a repeatable reporting structure so future research passes were auditable.

Final agreement:

- Research should not just be summarized. It should record selection, deep-dive rationale, findings per repo, and combined lessons.

Implementation state:

- The durable research cycle is represented across `research/`, `docs/research-methodology.md`, `research/integration-log.md`, and the active/archived research logs.

### 2026-04-22 / Session 26 - Session State And Checkpoint System

User intent:

- The repo was growing and context resets were expensive.
- Resuming required too much scanning.

Codex improvement:

- Identified the real cost pattern: context exhaustion was not only a model limit problem; it was a state-writing timing problem.
- Proposed a lightweight active state file that every future session reads before anything else.

User improvement to the improvement:

- The user wanted the system to be useful across interruptions and model switches, not only within one conversation.

Final agreement:

- Read `workflow/session-state.json` first on every resume.
- Write it before heavy operations, not after exhaustion.

Implemented:

- `workflow/session-state.json`
- `workflow/session-state.template.json`
- `docs/session-checkpoint.md`
- Startup rules in `AGENTS.md` and templates

Why it matters:

- This became the foundation for all later cold-start and handover work.

### 2026-04-22 / Sessions 27-28 - Folder Structure And Root Drift Cleanup

User intent:

- The user noticed that some propagated topic folders were not following the intended structure.
- Normal project work was appearing in roots instead of `[folder-name]-content/`.
- The user asked whether `AGENTS.md` described the structure properly, then asked Codex to analyze which root items were safe to remove and do the obvious cleanup immediately.

Codex improvement:

- Converted "folder mess" into a root-discipline model:
  - folder root is for propagated instructions and truly root-scoped project files
  - normal work belongs in `[folder-name]-content/`
  - ambiguous active repos require manual attention
  - audits should surface drift instead of relying on memory

User improvement to the improvement:

- The user wanted safe removal first, then a second pass after obvious cleanup.
- The user explicitly wanted ambiguous items called out rather than blindly moved.

Final agreement:

- Move safe legacy content into canonical content folders.
- Remove obvious generated/stale artifacts.
- Do not move active git repos or ambiguous tool homes without manual decision.
- Make structure drift visible in propagated audits.

Implemented:

- Tightened root-discipline language in `AGENTS.md` and `propagate-templates/AGENTS.template.md`.
- Added folder-structure warnings to propagated audit scripts.
- Propagated updated templates.
- Cleaned safe root drift.
- Left two manual decisions:
  - `Fluent Search Manifest/temp_extras`
  - `OpenCode/opencode-content`

Why it matters:

- This established the hub-vs-topic distinction that later docs rely on.

### 2026-04-22 / Sessions 29-30 - Workspace System Overview

User intent:

- The user said the main repo seemed fairly organized and asked Codex to explain what the repo does.
- The user wanted this explanation saved to a file so future agents could understand the repo "in a glance."
- Then the user switched to a deeper pass and asked for a second refinement.

Codex improvement:

- Created a plain-language system map rather than another dense reference doc.
- Explained the hub as:
  - central knowledge
  - distribution system
  - live workflow state
  - archive/preservation layer

User improvement to the improvement:

- The user wanted the overview good enough for both themselves and future agents.
- The second pass pushed it toward faster cold-start use rather than only explanatory completeness.

Final agreement:

- `docs/workspace-system-overview.md` is the first-pass system map.
- It should stay quick and link outward instead of becoming another long hot-path file.
- Startup order is:
  1. `workflow/session-state.json`
  2. `AGENTS.md`
  3. `docs/workspace-system-overview.md`
  4. `README.md`
  5. task-specific files

Implemented:

- Created and then tightened `docs/workspace-system-overview.md`.
- Updated `README.md`, `AGENTS.md`, and related docs to align with the startup order.

Why it matters:

- This is the first major step where the repo became self-orienting.

### 2026-04-22 / Session 31 - Repository Optimization

User intent:

- The user asked for optimizations after the repo became understandable.
- The hotspots were large hot-path files:
  - `research/research-log.md`
  - `HISTORY.md`
  - `docs/prompt-templates.md`
  - `AGENTS.md`
  - `docs/workspace-system-overview.md`
- The user supplied a detailed optimization plan and asked Codex to implement it.

Codex improvement:

- Treated the issue as hot-path context cost, not "delete old stuff."
- Preserved detail by archiving it and keeping current entrypoints lean.
- Added recursive audit guardrails so bloat would not silently return.

User improvement to the improvement:

- The user insisted historical content is valuable and should not be deleted.
- The plan explicitly required archive preservation, indexes, and validation.

Final agreement:

- Preserve content.
- De-hotpath old detail.
- Keep root files lean.
- Add audit budgets and recursive scanning.

Implemented:

- Archived full older history and research logs.
- Split `docs/prompt-templates.md` into `docs/prompt-library/`.
- Added `.rgignore`.
- Moved raw session snapshot into `archive/raw/`.
- Upgraded `scripts/audit-folder-quality.ps1` for recursive active-file scanning and context budgets.
- Updated `docs/quality-standards.md`, `research/README.md`, and references.

Why it matters:

- This created the repo's current "active files vs archive files vs generated files" doctrine.

### 2026-04-22 / Session 32 - Workspace Command Wrapper

User intent:

- The user asked Codex to analyze repeated commands and command patterns.
- The goal was to optimize not just files, but the agent's actual terminal workflow.

Codex improvement:

- Identified command clusters:
  - cold-start orientation
  - search/discovery
  - context-size checks
  - validation
  - archive/reference checks
  - research/propagation cycle
- Proposed a repo-local command wrapper rather than one-off shell snippets.

User improvement to the improvement:

- The user accepted the wrapper and asked for strong testing so the pattern would be "fullproof" for common cases.

Final agreement:

- Add a short PowerShell wrapper.
- Keep existing scripts authoritative.
- Default to read-only.
- Require explicit `-Apply` for mutating propagation.
- Add a test suite without relying on Pester.

Implemented:

- `scripts/ws.ps1`
- `scripts/test-ws.ps1`
- Help/status/hotspots/validate/search/research/propagate commands
- Mutation guards for preview paths
- Docs references in `AGENTS.md`, `README.md`, and `docs/workspace-system-overview.md`

Why it matters:

- This turned repeated operator habits into a stable interface.

### 2026-04-22 / Session 33 - Terminal Strategy: PowerShell vs WSL

User intent:

- The user asked whether Codex should use PowerShell, Command Prompt, Git Bash, or WSL.
- Files remained on Windows drives, but WSL was available.

Codex improvement:

- Initially recommended PowerShell as default because:
  - files lived on `M:\`
  - automation was PowerShell-first
  - WSL lacked native tooling at first
  - WSL `/mnt/*` scans can be slower and path-sensitive

User improvement to the improvement:

- The user challenged the idea that WSL was unsuitable just because tools were missing.
- The user clarified that if using WSL, they did not want to run PowerShell scripts inside WSL by default; native WSL commands should be used instead.
- The user hit an npm global install permission issue and wanted tooling guidance corrected.

Final agreement:

- PowerShell remains source of truth for mutating hub automation.
- WSL is valid for native read-only inspection.
- Do not require installing PowerShell in WSL unless specifically wanted.
- Use native WSL tools and a native bash wrapper for read-only checks.
- Consolidate tooling docs across Windows and WSL.

Implemented:

- `scripts/ws.sh` for WSL/Linux read-only:
  - `help`
  - `status`
  - `hotspots`
  - `search`
  - `validate`
- `docs/repo-tooling.md` as shared Windows/WSL tooling guide.
- `docs/windows-repo-tooling.md` kept as redirect.
- `docs/wsl-tooling.md` removed after consolidation.
- `scripts/ws.ps1 validate` reports terminal strategy.
- Audit learned `.sh` as a shell-script category.

Why it matters:

- This avoided maintaining two full automation surfaces while still making WSL useful.

### 2026-04-22 / Session 34 - Research Methodology

User intent:

- The user wanted research to rely on authoritative sources instead of random search results.

Codex improvement:

- Created a source hierarchy and verification method.
- Made explicit that model/AI information can go stale quickly and must be checked.

User improvement to the improvement:

- The user wanted this to be part of the system, not a one-off reminder.

Final agreement:

- Research should use source tiers:
  - vendor docs
  - academic papers
  - expert practitioners
  - community reports
  - anonymous or weak sources last
- Claims should be triangulated where possible.
- AI/model facts should be treated as temporally fragile.

Implemented:

- `docs/research-methodology.md`
- Integrated references in `README.md`, `docs/workspace-system-overview.md`, and research docs.

Why it matters:

- This raised the quality floor for all later model and tooling research.

### 2026-04-22 / Sessions 35-37 - Known Ledger Gap

Timestamp: 2026-04-22, exact session records not fully present in active `HISTORY.md`.

Known from current repo state:

- A model testing system existed and was later moved to `archive/model-tests/`.
- `archive/early-history.md` exists as the intended destination for early history, but the active ledger says it was awaiting user input.
- `workflow/session-state.json` includes references to these moves.

What a future agent should know:

- Do not assume Sessions 35-37 had no work.
- Treat this as a documentation gap in `HISTORY.md`, not proof of no activity.
- Look at `workflow/session-state.json`, `archive/model-tests/`, and file history if deeper reconstruction is required.

### 2026-04-22 / Sessions 38-40 - Model And Provider Routing Research

User intent:

- The user needed practical model-routing guidance across OpenCode Go and other providers.
- Specific concerns included cost, speed, request volume, and whether Kimi K2.6 was a true upgrade from MiniMax M2.7.

Codex improvement:

- Expanded from one model comparison into a broader routing strategy:
  - Session 38: K2.6 vs M2.7 and Go cost-efficiency
  - Session 39: all 10 OpenCode Go models
  - Session 40: cross-provider stack including Copilot, Gemini, DeepSeek, Qwen, and OpenCode Go

User improvement to the improvement:

- The user cared not only about quality, but also the 5-hour Go credit window and practical request volume.
- The user wanted to know which models are worth keeping, not just which benchmark wins.

Final agreement:

- K2.6 is quality king but not always volume king.
- M2.5 is speed/volume king for many interactive and search-heavy loops.
- M2.7 remains useful for bulk drafts and harness engineering.
- GLM-5.1 is powerful but expensive and should be used sparingly.
- Free and near-free tiers are important parts of the stack.

Implemented:

- Expanded `docs/model-selection-guide.md`.
- Added OpenCode Go comparison, all-model routing, provider routing, and cost-aware recommendations.

Why it matters:

- This directly informed the later agentic workflow model assignments.

### 2026-04-22 / Session 41 - PR Sequence Diagram Pattern

User intent:

- Capture a useful PR communication pattern and propagate it.

Codex improvement:

- Turned "use diagrams in PRs" into a selective rule:
  - use sequence diagrams for behavior-heavy PRs
  - skip them for trivial refactors

User improvement to the improvement:

- The underlying preference was signal over ceremony.

Final agreement:

- Add diagrams when explaining behavior in text takes more effort than drawing the interaction.
- Use GitHub-native Mermaid where possible.

Implemented:

- `docs/ai-product-building.md`
- `propagate-templates/git-github-best-practices.template.md`
- Propagated to topic folders.

Why it matters:

- This is an example of a small workflow lesson becoming a propagated practice.

### 2026-04-22 / Session 42 - Agentic Token-Efficiency System

User intent:

- Cut token burn by roughly 40-60% without losing continuity or quality.
- The user feared context loss when switching models or using multiple agents.

Codex improvement:

- Proposed native OpenCode agentic workflow:
  - Orchestrator as primary
  - cheaper specialists for cheap subtasks
  - stronger models only where justified
  - compressed context passed into subsessions
  - proactive checkpointing

Initial implementation shape:

- Orchestrator: K2.6
- Explorer: M2.5
- Planner: M2.7
- Scribe: M2.5
- Drafter: M2.7
- Gardener: M2.5
- Debugger: K2.6
- Reviewer: GLM-5.1

User improvement to the improvement:

- The user pushed the system away from over-orchestration.
- The important refinement was recursive-default correction:
  - direct handling should be the default
  - subagents should be exceptions
  - if a task can be done in under about 10 seconds, do it directly
- The user also wanted transparent agent/model disclosure.
- Later, the user accepted an Agent Skills layer for reusable workflows.

Final agreement:

- Default stance: Orchestrator handles directly.
- Spawn subagents only when the task exceeds direct-handling thresholds.
- Always disclose agents used and model information.
- Use skills for reusable workflow packages.
- Keep fallback chains documented as manual fallback, not fake automatic routing.

Implemented:

- `.opencode/agents/` with seven subagent definitions.
- `opencode.json` with Orchestrator primary agent and task permissions.
- Disabled built-in build agent as redundant fallback.
- `docs/agentic-workflows.md`.
- `docs/codex-agent-workflows.md`.
- `workflow/agentic-savings-log.md`.
- `.opencode/skills/` with:
  - `propagate`
  - `audit-quality`
  - `session-handoff`
  - `research-deep`
  - `cross-domain-harvest`
- `propagate-templates/opencode.template.json`.
- `propagate-templates/opencode-agent-system.template.md`.
- `propagate-templates/sync-from-hub.template.ps1`.
- `propagate-templates/skills-template/`.
- Propagated updated templates to 25 topic folders.

Post-audit refinements:

- Added Orchestrator edit/bash/webfetch permissions.
- Removed dead `grep*` from Explorer allowlist.
- Removed overlapping "fix" wording from Debugger description.
- Added AGENTS behavioral rules reference to Orchestrator prompt.
- Added direct-handling thresholds.
- Reordered prompt and routing docs so direct handling comes first.
- Added disclosure footer format including model names:
  - `Agents used: @explorer (M2.5)`
  - `Agents used: Orchestrator (direct, K2.6)`

Why it matters:

- This is the current agentic operating model. A future agent should not interpret "agentic" as "spawn agents constantly." The final design is "direct by default, specialist by exception."

### 2026-04-22 / Session 42 Later - Deep Repo Reanalysis And Optimization

User intent:

- After the agentic system, the user wanted the hub itself optimized again with the new understanding.

Codex improvement:

- Improved the repo's learning paths and reduced orientation friction.

User improvement to the improvement:

- The user wanted the repo to be useful at a glance and maintain its teaching/navigation role.

Final agreement:

- README should guide by intent, not just list folders.
- Old or lower-signal systems can move to archive.
- Research findings should live in docs when durable.

Implemented:

- Rewrote `README.md` with "I Want To..." paths.
- Deleted `docs/CONTEXT.md` after redirecting orientation to `AGENTS.md` and `README.md`.
- Added executive summaries to `docs/ai-product-building.md` and `docs/cognitive-identity.md`.
- Moved `research/archived-findings.md` to `docs/research-findings.md`.
- Archived `model-tests/` to `archive/model-tests/`.
- Added research integration rule to `AGENTS.md`.
- Initialized git repo in the hub for rollback safety.

Why it matters:

- The hub is now optimized around learning paths, not only operational docs.

## Decision Ledger

| Decision | Final State | Why |
|---|---|---|
| Startup order | `session-state -> AGENTS -> overview -> README -> task files` | Prevents expensive full rescans. |
| History preservation | Archive, do not delete, when provenance matters | Keeps formation context without hot-path bloat. |
| Hot-path docs | Keep lean and link outward | Reduces cold-start context cost. |
| Topic folder structure | Work goes in `[folder-name]-content/` | Keeps propagated roots clean. |
| Ambiguous cleanup | Report for manual decision | Avoids breaking active repos or tool homes. |
| Command workflow | Use `scripts/ws.ps1` for common PowerShell tasks | Replaces repeated ad hoc commands. |
| WSL role | Native read-only inspection through `scripts/ws.sh` | Useful without duplicating mutating workflows. |
| Mutating automation | PowerShell remains source of truth | Existing scripts and propagation are PowerShell-first. |
| Research quality | Use source hierarchy and triangulation | Avoids weak or stale AI/model claims. |
| Model routing | Cost/volume matters alongside quality | Best model is task-dependent, not absolute. |
| Agentic workflow | Direct by default, specialists by exception | Prevents token and latency waste from over-routing. |
| Agent disclosure | Always include agent/model usage in OpenCode workflow | Makes routing transparent and debuggable. |
| Skills | Package repeated workflows as skills | Reduces prompt repetition and improves consistency. |

## What Future Agents Should Do First

1. Read `workflow/session-state.json`.
2. Read `AGENTS.md`.
3. Read `docs/workspace-system-overview.md`.
4. For command work, run:

```powershell
.\scripts\ws.ps1 status
.\scripts\ws.ps1 validate
```

5. If in WSL and doing read-only inspection:

```bash
bash scripts/ws.sh status
bash scripts/ws.sh validate
```

6. For agentic/OpenCode questions, read:

- `docs/agentic-workflows.md`
- `docs/codex-agent-workflows.md`
- `opencode.json`
- `.opencode/agents/`
- `.opencode/skills/`

## Known Risks And Open Threads

- Active `workflow/session-state.json` is currently more detailed than `HISTORY.md` for Session 42. Use it as source for latest operational state.
- Sessions 35-37 are not fully documented in the active ledger.
- `docs/workspace-system-overview.md` still mentioned `model-tests/` in at least one observed state even though model tests were later archived; future cleanup may need to align that if still present.
- `archive/early-history.md` was intended to receive early user-provided history.
- OpenCode Desktop may need restart/reload after agent config updates.
- Manual root cleanup decisions still remain for:
  - `Fluent Search Manifest/temp_extras`
  - `OpenCode/opencode-content`

## Compact Handoff Summary

This middle phase turned the repo from a growing knowledge base into an operational hub.

The key transformation was not one single feature. It was a repeated pattern:

- user notices friction
- Codex turns it into structure
- user corrects the structure toward their real workflow
- final agreement becomes docs, scripts, audits, templates, and propagation

The durable philosophy:

- preserve history, but de-hotpath it
- make startup cheap
- make repeated commands wrappers
- make structure auditable
- make research source-backed
- make model use cost-aware
- make agentic systems direct by default
- propagate only genuinely shared rules
