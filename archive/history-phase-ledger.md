# AI Prompting Workspace — Session Ledger

> Compressed phase history. Full detailed narrative: [archive/history-full-detailed.md](archive/history-full-detailed.md)
> Order: Newest first. Each phase links to the detailed threads.

---

## Phase 9: History Consolidation & Quality Hardening (2026-04-23)

**Purpose:** Merge all historical records into a canonical ledger and harden quality gates.

**Key Decisions:**
- Merged early/middle/late Codex histories + OpenCode session histories into single HISTORY.md
- Established archive discipline: full narrative → archive, compressed ledger → HISTORY.md
- Fixed audit false positives (code-block heading skips), broken README links, and script structure gaps

**Files Changed:** HISTORY.md, README.md, scripts/audit-folder-quality.ps1, scripts/check-opencode-agents.ps1, scripts/retire-repo.ps1

---

## Phase 8: System Overview & Tooling (2026-04-22)

**Purpose:** Create a plain-language system map and establish terminal strategy.

**Key Decisions:**
- `docs/workspace-system-overview.md` as the 30-second cold-start map
- PowerShell = mutating automation lane; WSL/Linux = read-only inspection lane
- `scripts/ws.ps1` (PowerShell) and `scripts/ws.sh` (WSL) as unified workspace wrappers

**Files Created:** docs/workspace-system-overview.md, docs/repo-tooling.md, scripts/ws.ps1, scripts/ws.sh

---

## Phase 7: Agentic System Maturation (2026-04-22 to 2026-04-23)

**Purpose:** Build native OpenCode agentic workflow infrastructure and propagate across 25 topic folders.

**Key Decisions:**
- Orchestrator (K2.6) handles simple tasks directly; subagents spawn only for bounded specialist work
- 7 subagents: Explorer, Planner, Scribe, Drafter, Gardener, Debugger, Reviewer
- 5 skills: propagate, audit-quality, session-handoff, research-deep, cross-domain-harvest
- Agent disclosure footer mandatory on every response
- Direct-handling default propagated to all topic folder AGENTS.md templates

**Files Created:** .opencode/agents/*.md, .opencode/skills/*/, docs/agentic-workflows.md, docs/codex-agent-workflows.md, workflow/agentic-savings-log.md

---

## Phase 6: Workspace Standardization & Root Cleanup (2026-04-19 to 2026-04-21)

**Purpose:** Standardize folder structure across 25 topic folders and enforce semantic organization.

**Key Decisions:**
- Mandatory `[folder-name]-content/` operating area for all topic folders
- `meta/` is optional; do not bulk-create
- Hub is exempt from content-folder rule (its working areas already exist at top level)
- `workflow/` for state/registries/queues; `scripts/` for executables only
- Root drift cleanup: classify before moving, leave active `.git` repos for manual decision

**Files Created:** workflow/cross-domain-registry.md, workflow/merge-log.md, workflow/sync-state.json
**Files Modified:** AGENTS.md, propagate-templates/AGENTS.template.md, scripts/propagate-to-all.ps1

---

## Phase 5: Cognitive Identity & Model Routing (2026-04-16 to 2026-04-17)

**Purpose:** Document model access tiers and cognitive-identity research.

**Key Decisions:**
- Model choice is task/access/cost routing, not a single global ranking
- Daily default: Claude Sonnet 4.6 via Copilot; hardest work: Opus 4.7 sparingly
- Cheap volume: OpenCode Go models; free long-context: Google AI Studio
- Cognitive identity docs expanded with security-first agent design and 22 architecture patterns

**Files Created/Modified:** docs/model-selection-guide.md, docs/agent-context-handover.md, docs/cognitive-identity.md

---

## Phase 4: Git Best Practices & Template Refactor (2026-04-15)

**Purpose:** Add Git/GitHub best practices as first-class propagated concern and make template system extensible.

**Key Decisions:**
- Docs serve both humans and AI agents simultaneously
- Principle-focused over code examples (evergreen, no literal syntax)
- Raw docs → templates → propagation pipeline
- `propagate-to-all.ps1` dynamically discovers `*.template.*` instead of hardcoding
- Templates renamed from `templates/` → `propagate-templates/` for unambiguous purpose

**Files Created:** docs/git-github-best-practices.md, propagate-templates/git-github-best-practices.template.md
**Files Modified:** scripts/propagate-to-all.ps1, README.md, AGENTS.md

---

## Phase 3: Research System & Quality Infrastructure (2026-04-12 to 2026-04-14)

**Purpose:** Establish research intake, quality validation, and session recovery.

**Key Decisions:**
- 3-day research integration cadence: research → integrate → propagate
- Source hierarchy with confidence levels for authoritative research
- `docs/quality-standards.md` as central standards doc
- `scripts/audit-folder-quality.ps1` for automated quality validation
- `docs/session-recovery-guide.md` for interrupted-session resume

**Files Created:** research/README.md, research/research-prompt.md, research/research-log.md, research/integration-log.md, docs/quality-standards.md, docs/session-recovery-guide.md, scripts/audit-folder-quality.ps1, scripts/harvest-topic-insights.ps1, scripts/build-cross-domain-candidates.ps1

---

## Phase 2: Claude Code Lessons & Agent Doctrine (2026-04-11 to 2026-04-12)

**Purpose:** Capture Claude Code best practices and formalize agent design principles.

**Key Decisions:**
- Archived external best practices (Simon Willison, Boris, learn-claude-code)
- `docs/core-agent-doctrine.md` as 10-principle backbone
- Cross-project memory loop: topic folders write local lessons → hub harvests → propagates back

**Files Created:** docs/core-agent-doctrine.md, docs/daily-prompts.md, docs/prompt-templates.md, docs/cross-project-memory-loop.md, docs/tdd-with-agents.md, docs/learning-while-building-with-agents.md, archive/learn-claude-code-lessons.md, archive/claude-code-best-practice-lessons.md, archive/simon-willison-agentic-engineering-lessons.md

---

## Phase 1: Repository Genesis (2026-04-10)

**Purpose:** Create the AI Prompting hub with foundational knowledge base and propagation infrastructure.

**Key Decisions:**
- Hub is a living knowledge base, not a normal app repo
- `AGENTS.md` as operating contract for AI assistants
- `propagate-templates/` for shared templates synced to topic folders
- `scripts/bootstrap-project-instructions.ps1` and `sync-project-instructions.ps1` for automation

**Files Created:** README.md, AGENTS.md, docs/core-agent-doctrine.md, docs/daily-prompts.md, docs/prompt-templates.md, propagate-templates/AGENTS.template.md, propagate-templates/topic-insights.template.md, scripts/bootstrap-project-instructions.ps1, scripts/sync-project-instructions.ps1

---

## Archive Index

| Era | Detail Level | Location |
|-----|-------------|----------|
| Full merged narrative (all sessions) | Maximum | [archive/history-full-detailed.md](archive/history-full-detailed.md) |
| April 2026 compact sessions | Medium | [archive/history-2026-04.md](archive/history-2026-04.md) |
| Early history (sessions 1–11) | Reconstructed | [archive/early-history.md](archive/early-history.md) |
