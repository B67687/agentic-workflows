# AI Prompting Workspace

A living knowledge base for prompt design, agent workflows, and cross-repo lesson propagation. Not a code project.

## Operating Contract

**Core principle: Supply missing structure when safe.**

When the request is clear enough and risk is low, proactively:
- sharpen scope
- choose a sensible investigation order
- define verification targets
- choose the lightest execution lane
- switch to tests-first work when behavior changes

Only ask questions when the gap has real consequences for safety, scope, or correctness.

## Startup Order

1. `workflow/session-state.json` - active session state; read first on every resume
2. `docs/hub-quickstart.md` - fast orientation (replaces multi-file startup)
3. `AGENTS.md` - this operating contract
4. Task-specific files only when needed

For topic-folder work, read that folder's `meta/HANDOVER.md` first if it exists and you are resuming local work.

For topic-folder work, read that folder's `meta/HANDOVER.md` first if it exists and you are resuming local work.

## High-Signal Files

| File | Purpose |
|------|---------|
| `workflow/session-state.json` | Active session; read first on resume |
| `docs/workspace-system-overview.md` | Plain-language system map |
| `docs/core-agent-doctrine.md` | 10-principle backbone |
| `docs/session-checkpoint.md` | Checkpoint and recovery rules |
| `docs/repo-quality-analysis-protocol.md` | Compression, deletion, and redundancy protocol |
| `docs/daily-prompts.md` | Most-used prompts |
| `docs/prompt-templates.md` | Prompt library index |
| `personal-voice/VOICE-PROFILE.md` | User voice patterns; read before writing in the user's voice |

## Key Rules

- **Do not create new files** if an existing doc covers the need.
- **Verify aggressively**; verification is the quality engine.
- **Summarize work** with root cause, fix, verification, and residual risk.
- **Update the knowledge base** when a durable pattern appears.
- **Integrate research findings into docs/** within 3 days — do not leave durable insights in research/ or archive/
- **Use relative links** inside repo docs.
- **Read personal voice before writing for the user**: `personal-voice/VOICE-PROFILE.md`.
- **Session state on every resume**: read `workflow/session-state.json` before any other file.
- **Checkpoint before heavy operations**: update `workflow/session-state.json` before multi-phase work, bulk fetches, or large analysis.
- **Use PowerShell for mutating hub automation**. WSL read-only inspection can use `scripts/ws.sh`; see `docs/repo-tooling.md`.

## Structure Rules

- This hub's working areas are `docs/`, `research/`, `scripts/`, `workflow/`, `propagate-templates/`, `archive/`, and `personal-voice/`.
- Do not move hub content into `ai-prompting-content/` unless the whole hub is intentionally redesigned.
- In propagated project folders, normal work belongs in `[folder-name]-content/`.
- Keep propagated folder roots for `AGENTS.md`, `topic-insights.md`, `.cleanup-protect`, `git-github-best-practices.md`, `audit-folder-quality.ps1`, and truly root-scoped project files.
- If root drift exists, classify it first. Move only safe content; report active `.git` repos, caches, tool homes, build roots, or ambiguous folders.

## Session Documentation

At the end of meaningful work:

1. Update `workflow/session-state.json`.
2. Update `archive/history-2026-04.md` (or current month's history file) with a compact entry.
   - One entry per session or per major task phase.
   - Include: date, what changed, files created/moved/deleted, verification results.
3. For topic-folder work, update that folder's `archive/history-2026-04.md` (create `archive/` if needed) with the session summary and any external work.
4. Include decisions future sessions need.

**Rule:** Session state = every meaningful task. History archive = every session or major phase. Don't let history drift more than one session behind.

**History is NOT read by default.** It's for long-break resumes and understanding past decisions. The startup path is: session-state -> hub-quickstart -> task files. History is only read when explicitly needed.

## Compression And Cleanup

Use `docs/repo-quality-analysis-protocol.md` before deleting, merging, or compressing files.

Rules:
- Similar is not redundant.
- Different audiences may justify overlap.
- Orphaned but useful files should be linked or archived, not deleted.
- Historical/provenance content should be preserved unless it is clearly junk.
- Hot-path files should stay compact and link to deep references.

## Scripts

- `scripts/audit-folder-quality.ps1` - validate active authored files
- `scripts/ws.ps1` - common status, search, hotspot, validation, research-preview, and propagation wrapper
- `scripts/ws.sh` - WSL/Linux read-only status, search, hotspot, and validation wrapper
- `scripts/check-sync-status.ps1` - check propagation freshness
- `scripts/propagate-to-all.ps1 -Apply` - sync templates to topic folders
- `scripts/harvest-topic-insights.ps1` - collect topic lessons
- `scripts/build-cross-domain-candidates.ps1` - build promotion queue
- `scripts/merge-and-propagate.ps1` - merge reviewed lessons and propagate

## Cross-Domain Knowledge Flow

Topic folders write local lessons to `topic-insights.md`.

The hub can then:

1. harvest them into `workflow/harvested-topic-insights.md`
2. build `workflow/cross-domain-candidates.md`
3. merge transferable lessons into the smallest correct central doc
4. propagate changed templates only when shared folder defaults changed

Participating folders live in `workflow/cross-domain-registry.md`.

## Agentic Behavior Rules (Session 42)

When in agentic mode, the Orchestrator follows these rules:

### 1. Brevity by Default

- **Simple tasks:** One-sentence response
- **Medium tasks:** Bullets + code
- **Complex tasks:** Structured sections
- **Teaching:** Only when explicitly requested ("explain," "teach me")

### 2. Proactive Checkpointing

- Suggest handoff at **10+ turns**
- Compress context to **5-line summary** before spawning subsession
- Detect topic shifts and **spawn fresh context**

### 3. Automatic Routing

**Default behavior: Handle directly.** The Orchestrator handles tasks itself using available tools. Only spawn a subagent when the task clearly exceeds direct-handling thresholds.

**When to handle directly:**
- < 10 files search, simple patterns
- 1-3 line edits, single file
- File ops on < 10 files
- Doc updates, typos, short answers
- Simple Q&A, clarification
- Quick sanity checks
- Simple plans (< 5 steps)

**When to route to subagents:**

| Subtask Type | Threshold | Route To | Default Model | When |
|-------------|-----------|----------|---------------|------|
| Search / discovery | 10+ files, complex patterns | Explorer | M2.5 Free | Bulk search only |
| Fresh context needed | 15+ turns, topic shift, quality degradation | Worker | Same as Orchestrator (K2.6) or M2.7 | Long sessions |
| Different capabilities | 1M context, multimodal, math | Specialized model | Gemini, DeepSeek, etc. | Capability gap |

**Why only 2 subagents?**
- Drafter + Analyst merged into Worker — both just meant "do work with fresh context"
- Per-request cost difference is often zero now (free Sonnet 4.6, Gemini free tier, K2.6 promo)
- The real win is **fresh context**, not cheaper models

**All other tasks** — planning, docs, file ops, simple debug/review, Q&A, normal coding — should be handled directly by the Orchestrator. Only spawn when the benefit clearly exceeds the 4–8 second overhead.

**Three-tier fallback:**
1. **Tier 1 — Orchestrator direct:** Handle everything directly by default. Zero extra cost.
2. **Tier 2 — Fresh context (Worker):** Spawn @worker when context is degraded (15+ turns, topic shift). Same model, clean slate.
3. **Tier 3 — Escalation (Sonnet 4.6 / Opus 4.7):** Only when:
   - Security vulnerability is suspected or confirmed
   - Main AI failed twice on the same task
   - User explicitly requests premium analysis

**Cost rule:** Direct handling costs $0 extra. Worker subagent costs the same as direct (same model). Escalation to premium uses Copilot quota — keep it rare.

**Manual override:** `@explorer find auth_token` or "use K2.6 for this" bypasses routing.

### 4. Context Compression

When spawning subsessions, pass only:
- Task (specific, bounded)
- Context (3-5 bullets)
- Files (paths only)
- Constraints (hard limits)
- Done when (success criteria)

**Never pass:** full thread history, previous reasoning chains, teaching material.

### 5. Internal Coordination Notes

Do not add public-facing footers that disclose routing, model use, or internal execution mechanics unless the target repo or platform explicitly requires it.

Keep accountability in the right place:
- `workflow/session-state.json` records lanes, progress, files touched, verification, and residual risk.
- User-facing summaries focus on root cause, fix, verification, and remaining uncertainty.
- PRs and public comments stay project-native: no routing notes, model names, or generic automation tells.
- If a repo requires disclosure, follow that repo's rule and keep it concise.

### 6. Quality Guardrails

- Never downgrade critical tasks (debugging, final review)
- Verify specialist output before presenting
- If an agent misroutes 3× in a session, revert to monolithic
- User can override: "use K2.6 for this" bypasses routing
- If the same fix path fails twice, checkpoint, re-plan, or switch to fresh context before more edits

### 7. Fallback Chain

If primary model unavailable:
- Explorer (M2.5 Free) → Qwen3.5 Plus → M2.7
- Worker (K2.6) → K2.5 (61% more requests) → M2.7 → Sonnet 4.6 (Copilot)
- Worker (M2.7) → Qwen 3.6 Plus → K2.6 → Sonnet 4.6 (Copilot)
- Main AI (K2.6 or Sonnet 4.6) → Other provider's best model → Opus 4.7 (escalation)

---

## Deep References

| Topic | Reference |
|-------|-----------|
| Workspace map | `docs/workspace-system-overview.md` |
| Core doctrine, recursive self prompting, teaching | `docs/core-agent-doctrine.md` |
| Daily prompt shapes | `docs/daily-prompts.md` |
| Full prompt library | `docs/prompt-templates.md` |
| Token/context efficiency | `docs/token-efficient-prompting.md` |
| Agentic workflows | `docs/agentic-workflows.md` |
| Windows/WSL terminal strategy | `docs/repo-tooling.md` |
| Model selection and handover | `docs/model-selection-guide.md`, `docs/agent-context-handover.md` |
| Product/agent architecture | `docs/ai-product-building.md` |
| Cross-project memory | `docs/cross-project-memory-loop.md` |
| Personal voice system | `personal-voice/README.md` |
| Quality standards | `docs/quality-standards.md` |
| Session checkpoints | `docs/session-checkpoint.md` |
