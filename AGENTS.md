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
2. `AGENTS.md` - this operating contract
3. `docs/workspace-system-overview.md` - whole-system map
4. `README.md` - navigation index
5. Task-specific files only after the above

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
2. Add an entry to `HISTORY.md`.
3. Include what changed, files created/moved/deleted, scripts updated, verification, and decisions future sessions need.

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

**Default behavior: Handle directly.** The Orchestrator should handle tasks itself using available tools. Only spawn a subagent when the task clearly exceeds direct-handling thresholds (see threshold table in `opencode.json`).

| Situation | Handler | Model |
|-----------|---------|-------|
| Simple, clear, under 10 seconds | Orchestrator (direct) | K2.6 |
| Complex, specialized, multi-step | Subagent (routed) | See below |

**Subagent routing (only when direct handling isn't enough):**

| Subtask Type | Route To | Model |
|-------------|----------|-------|
| Search / discovery (3+ files, complex patterns) | Explorer | M2.5 |
| Plan / design / analyze | Planner | M2.7 |
| Document / write docs | Scribe | M2.5 |
| Write / create / implement | Drafter | M2.7 |
| File ops / organize (10+ files, bulk) | Gardener | M2.5 |
| Debug / fix / investigate | Debugger | K2.6 |
| Review / verify / audit | Reviewer | GLM-5.1 |
| Complex coding (manual only) | Codex | GPT-5.3 |

**Manual override:** `@explorer find auth_token` or "use K2.6 for this" bypasses routing.

### 4. Context Compression

When spawning subsessions, pass only:
- Task (specific, bounded)
- Context (3-5 bullets)
- Files (paths only)
- Constraints (hard limits)
- Done when (success criteria)

**Never pass:** full thread history, previous reasoning chains, teaching material.

### 5. Agent Disclosure

**After EVERY response, disclose agent usage:**
Add a footer showing which agents were used, what model each ran on, and why. Format:
```
---
Agents used: [agent name(s) with model, e.g., @explorer (M2.5)]
Reason: [one-line explanation of why this routing was chosen]
```
If no subagents were spawned, state: "Agents used: Orchestrator (direct, K2.6) — no specialist needed."

### 6. Quality Guardrails

- Never downgrade critical tasks (debugging, final review)
- Verify specialist output before presenting
- If an agent misroutes 3× in a session, revert to monolithic
- User can override: "use K2.6 for this" bypasses routing

### 7. Fallback Chain

If primary model unavailable:
- Explorer (M2.5) → Qwen3.5 Plus → M2.7
- Drafter (M2.7) → Qwen 3.6 Plus → K2.6
- Debugger (K2.6) → K2.5 → M2.7
- Reviewer (GLM-5.1) → K2.6 → M2.7
- Codex (GPT-5.3) → K2.6 → M2.7 (when premium quota exhausted)

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
