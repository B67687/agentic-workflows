# AI Prompting Workspace — History Index

> Quick reference for workspace evolution. Detailed narratives in [history-full-detailed.md](history-full-detailed.md).
> Order: Newest first. See detailed file for full intention→discussion→implementation threads.

---

## Phase 25: Agent Dreaming Integration (2026-05-12)
- Bridged "agent dreaming" / divergent thinking concept to the existing `divergent-ideation` skill
- Enhanced skill description to cover play/exploration contexts naturally
- Removed unnatural trigger phrases; improved description instead

## Phase 24: AGENTS.md Restructuring (2026-05-12)
- Fixed numbering in Agentic Behavior Rules (was 1→2→3→10→4→5→...→1→2→3→4→5→6→7→8→9→10→11→12)
- Removed Cost section from Persistent Memory (irrelevant at runtime)
- Corrected skill count: 28 → 41
- Removed ghost `agent/` directory reference from Structure Rules
- Added markdown links to agent-skills setup guides, rules/, .tap/, archive content
- Added orphaned doc references to Deep References table

## Phase 23: Companion Scripts — Full Coverage (2026-05-12)
- 13 new companion scripts across 6 batches: doubt-driven, tdd, git-workflow, code-review, source-driven, security, performance, plan-breakdown, spec-generator, ci-check, grill, increment-slice, simplify-check, context-engineering, divergent-ideation, shipping-and-launch, api-contract, migrate-plan, skill-test
- Achieved 41/41 (100%) companion script coverage (was 5/27 = 19%)

## Phase 22: TAP Skills Integration (2026-05-12)
- Added 14 TAP methodology skills (product-thinker, strategic-thinker, shaping-work, product-discovery, product-primitives, design-language, implementation-planning, loop-check, tighten-loop, tap-audit, systems-health, retrospective, curate-product-context, blast-radius)
- Enhanced frontmatter on all 41 skills
- Added .tap/ project memory directory
- Added learnings strategy documentation
- Updated manifest.json with new bundles

## Phase 21: Ruflo Integration (2026-05-12)
- CLI-only model (0MB persistent cost), daemon stopped
- Memory init (sql.js WASM) hangs on WSL2 — evaluated as non-viable for this platform
- Plugin bridge evaluation: SKIPPED (markdown ≠ TypeScript fundamentally)
- Hooks retained: route, pretrain, session-restore

## Phase 20: 4-Layer Governance Architecture (2026-05-12)
- Layer 1 — Tiered file classification (.gitignore with exact tier comments: Tier 3 generated, Tier 4 external)
- Layer 2 — Skill completeness contract (detect-gaps.sh Check 8)
- Layer 3 — Archive growth policy (detect-gaps.sh Check 9, 300KB hot-path budget)
- Layer 4 — Auto-healing (HEAL=1 mode for BM25 rebuild)
- Fixed ruvector.db tracking (1.6M SQLite DB untracked, *.db pattern added)
- Fixed archive budget (was 150KB on archive files, too aggressive — moved to 300KB on hot-path only)

## Phase 19: Assumption Expiry + Health Monitoring (2026-05-12)
- Assumption expiry pattern: scripts/assumption-expiry.sh (check/list/mark/dismiss/init)
- docs/assumption-expiry.md with 4 authoritative sources
- detect-gaps.sh Check 6: expired assumption flagging at session start
- session-state.json assumptions[] array with TTL tracking
- Context pressure: --persist/--auto modes, cross-session trend tracking
- detect-gaps.sh Check 7: context pressure + trend at session start

## Phase 18: System Research (2026-05-12)
- research/well-maintained-system-research.md — 9 authoritative sources synthesized
- Sources: Ford (Evolutionary Architecture), Taleb (Antifragile), Fowler (Tech Debt), Meyer (Design by Contract), Lehman (Laws of Evolution), Hunt & Thomas (Pragmatic Programmer), DORA, Google SRE
- Retroactive plan docs: archive/phase5-assumption-expiry-plan.md, archive/phase6-system-research-plan.md
- Added `/task-tree` for decomposing large goals into coarse domains, milestone candidates, and first slices
- Routed long-horizon oversized goals from intake toward `/shape-product` followed by `/task-tree`
- Documented the rule that the tree prevents blind spots but should not become a full project plan

## Phase 16: Counsel Model Selection Policy (2026-05-06)
- Confirmed counsel model grouping is the right direction only as role-based selection, not fixed permanent panels
- Added benchmark-informed evidence hierarchy for choosing free OpenRouter candidates
- Added a refreshable `counsel-models.json` registry and model-selection helper
- Documented current role groupings for lite and full counsel

## Phase 15: Product Shaping & Counsel Gate (2026-05-06)
- Added product shaping before North Star for broad product goals
- Added a counsel gate for shaping, milestone, architecture, and optimization decisions
- Routed long-horizon task intake toward `/shape-product`
- Documented counsel as targeted judgment support, not default implementation behavior

## Phase 14: Fast Stable Delivery Alignment (2026-05-05)
- Added an explicit external alignment model tying the workflow to Working Backwards, Shape Up, DORA, and Trunk-Based Development
- Documented the shared principle that speed and stability improve together through smaller verified batches
- Added a dedicated fast-stable-delivery reference doc
- Updated core workflow and overview docs so the system explains not just what to do, but why it follows this structure

## Phase 16: Prompt Contract Self-Checks (2026-05-06)
- Added `prompt-contract.sh` and `/prompt-contract`
- Converted prompting best practices into an internal checklist: outcome, context, constraints, examples, verification, and ask/proceed policy
- Routed `/research`, `/plan`, `/implement`, and `/route` through the prompt contract
- Propagated prompt-contract helpers into topic folders

## Phase 15: Provider Runtime Hardening (2026-05-06)
- Removed `small_model` from live OpenCode config after Google rejected it as an invalid request field
- Added Google model discovery/sync from Google's own OpenAI-compatible `/models` endpoint
- Confirmed `gemini-3.1-pro-preview` is listed for the current Google key, while direct test currently hits 429 quota/rate
- Added OpenCode auth-profile switching helper for multiple OpenCode Go subscriptions
- Documented provider runtime, account switching, memory expectations, and frontier prompting lessons

## Phase 14: Context Mapping & Normal-Language Routing (2026-05-06)
- Added `repo-map.sh` and `/repo-map` so unfamiliar folders get compact orientation before targeted retrieval
- Added `workflow-router.sh` and `/route` so serious normal-language prompts route through intake automatically
- Updated task intake so obvious tiny edits route direct, while large nostalgic/product goals route to product shaping and task-tree decomposition
- Propagated route and repo-map managed core into topic folders
- Documented source-backed harness lessons from OpenAI Codex docs, SWE-agent, Agentless, and SWE-Dev

## Phase 13: Big-Goal Execution Model (2026-05-05)
- Added North Star shaping for long-horizon goals
- Added milestone shaping so big goals become bounded bets before slice execution
- Made `start-task` the default shaping entrypoint in docs and command behavior
- Added optimization lane with evidence-based gating and bounded architecture review
- Added glanceable workflow diagrams for big-goal execution, planning levels, and optimization

## Phase 12: Fast Iteration Guardrails (2026-05-04)
- Added deterministic oversized-task slicing with `/slice-task`
- Added planning-loop guard so large work plans only the next executable slice
- Updated workflow docs to prefer milestone ladder plus first slice over giant one-shot plans
- Documented anti-paralysis rule: after two planning refinements, move back toward execution

## Phase 11: Runtime Simplification & Drift Cleanup (2026-04-30 to 2026-05-01)
- Replaced split local runtime assumptions with one global OpenCode runtime authority
- Removed repo-local OpenCode config and workspace-level `.opencode/` drift across topic repos
- Rebuilt propagation around managed-core vs repo-owned ownership rules
- Simplified harvest/promotion into read-only intake plus explicit manual promotion
- Added propagation smoke tests and operator guidance for future refactors

## Phase 10: Kebab-Case Rename & Standardization (2026-04-30)
- Renamed all 14 topic folders + hub to kebab-case
- Updated all propagation scripts to reference new names
- Fixed wall-you content folder (had literal backslash in name)
- Removed duplicate empty content folders (image-magick, math-learning-notes, no-face-scan-app)
- Removed duplicate subject folders in math-learning-notes (algebra, calculus, etc.)
- Created missing archive/ folders in open-codex and wall-you
- All 14 topic folders now standardized with proper structure

## Phase 9: History Consolidation (2026-04-23)
- Merged all historical records into canonical ledger
- Established archive discipline: narrative → archive, index → here

## Phase 8: System Overview & Tooling (2026-04-22)
- `docs/workspace-system-overview.md` as cold-start map
- PowerShell = mutating; WSL = read-only inspection
- Unified wrappers: `scripts/ws.ps1` / `scripts/ws.sh`

## Phase 7: Agentic System (2026-04-22 to 2026-04-23)
- Orchestrator handles simple; subagents for specialist work
- 7 subagents, 5 skills propagated across 25 topic folders

## Phase 6: Workspace Standardization (2026-04-19 to 2026-04-21)
- Mandatory `[folder-name]-content/` for topic folders
- `workflow/` for state/registries; `scripts/` for executables

## Phase 5: Model Routing (2026-04-16 to 2026-04-17)
- Model choice = task/access/cost routing
- Daily: Sonnet 4.6; Hardest: Opus 4.7; Volume: OpenCode Go models

## Phase 4: Git Best Practices (2026-04-15)
- Docs serve humans + AI agents
- Dynamic template discovery in propagate-to-all

## Phase 3: Research & Quality (2026-04-12 to 2026-04-14)
- 3-day research integration cadence
- `docs/quality-standards.md`, `scripts/audit-folder-quality.ps1`

## Phase 2: Agent Doctrine (2026-04-11 to 2026-04-12)
- `docs/core-agent-doctrine.md` as 10-principle backbone
- Cross-project memory loop established

## Phase 1: Repository Genesis (2026-04-10)
- Hub as living knowledge base
- `propagation/` for shared templates
- `AGENTS.md` as operating contract

---

## Earlier Sessions (1-11)
Sessions 1-11 content integrated into [history-full-detailed.md](history-full-detailed.md).

---

## Archive

| File | Purpose |
|------|---------|
| history-index.md | This file - quick phase index |
| history-full-detailed.md | Full narrative with intention→discussion→implementation |
