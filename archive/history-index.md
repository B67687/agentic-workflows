# AI Prompting Workspace — History Index

> Quick reference for workspace evolution. Detailed narratives in [history-full-detailed.md](history-full-detailed.md).
> Order: Newest first. See detailed file for full intention→discussion→implementation threads.

---

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
