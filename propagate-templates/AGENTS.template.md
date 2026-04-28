<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: AGENTS -->
# AI Prompting Workspace

A living knowledge base for a topic domain. This file provides AI agents with context on how to work effectively in this folder.

## Operating Contract

**Core principle: Supply missing structure when safe.**

The user does not need perfect prompting skill. When a request is clear enough and risk is low, you must proactively:
- Sharpen the scope if it's too vague
- Add a sensible investigation order
- Define explicit verification targets
- Choose the right execution lane
- Switch to TDD when behavior changes

**Only ask questions when the gap has real consequences for safety, scope, or correctness.**

---

## The 10 Principles

From `docs/core-agent-doctrine.md`:

1. **Scope tightly** — Don't ask for "everything"
2. **Give rich evidence** — Logs, files, configs, then stop micromanaging
3. **Supply missing structure** — Fill in what the user misses
4. **Define done and verification early** — Success criteria matter
5. **Verification is learning** — Testing effect strengthens reasoning
6. **Choose the lightest lane** — Inline, reusable, isolated, review
7. **Plan when ambiguous** — Re-plan when execution wobbles
8. **Optimize quality, not volume** — Verification > generation
9. **Promote repeated work** — Turn recurring workflows into assets
10. **Update memory after lessons** — Compound, don't repeat
11. **Prefer simple code** — Add complexity only when concrete system demand requires it

---

## Recursive Self Prompting

When working on complex tasks, continuously prompt yourself until you reach a **plateau of conclusion**.

### The Loop
```
1. Make an initial attempt
2. Prompt yourself: "What else should I consider?"
3. Prompt yourself: "Am I missing anything?"
4. Prompt yourself: "Is this complete? What would make it better?"
5. Continue until plateau
6. Present to user for review
```

### Plateau Detection
You've reached plateau when:
- New iterations produce only minor refinements
- Your answers become consistent with previous answers
- You can articulate why you're done

**Use for**: Complex tasks, analysis, research, writing refinement
**Don't use for**: Simple questions or quick tasks

---

## Folder Structure

This workspace follows a standardized structure:

```
[Topic-Folder]/
├── AGENTS.md                          (propagated - operating contract)
├── workspace-system-overview.md       (propagated - what this project is)
├── session-state.json                 (propagated - current state, read first on resume)
├── topic-insights.md                   (propagated - your lessons)
├── git-github-best-practices.md        (propagated - git conventions)
├── quality-standards.md               (propagated - quality rules)
├── .cleanup-protect                   (propagated - cleanup protection)
├── audit-folder-quality.ps1            (propagated - quality audit)
├── check-sync-status.ps1              (propagated - sync checker)
├── sync-from-hub.ps1                  (propagated - sync from hub)
├── opencode.json                      (propagated - tool config)
├── opencode-agent-system.md           (propagated - agent instructions)
├── [topic-name]-content/              (mandatory primary operating area)
├── meta/                              (optional - YOUR content, never touched by hub)
│   ├── README.md                      (folder purpose)
│   ├── quality-standards.md           (topic-specific rules)
│   └── ...                            (other topic-specific files)
└── archive/                           (historical records)
```

### Quick Reference

| File | When to Read |
|------|--------------|
| `session-state.json` | First on every resume - where you left off |
| `workspace-system-overview.md` | When you need to understand project structure |
| `AGENTS.md` | When working with AI or need operating rules |
| `topic-insights.md` | When you need your lessons/learnings |

### Operating Area

Do normal project work inside `[topic-name]-content/`.

Use the folder root only for propagated instruction files and truly root-scoped project files. If you need to add source code, notes, assets, datasets, drafts, or project-specific docs, put them under `[topic-name]-content/` unless there is a concrete tool reason they must live at the root.

Create `meta/` only when durable project context is needed. This folder is NEVER touched by hub propagation — your content stays safe.

### What Goes in meta/

The `meta/` folder is for **your project-specific content** that the hub should never touch:

| File | Purpose |
|------|---------|
| `meta/README.md` | Explains this folder's purpose and structure |
| `meta/quality-standards.md` | Topic-specific quality rules (custom to this topic) |
| `meta/PROJECT.md` | Tech stack, conventions, special rules |
| `meta/HANDOVER.md` | (deprecated - use session-state.json instead) |
| Other files | Any project-specific notes, configs, or docs |

**Key rule**: Hub propagation only touches root files. The `meta/` folder is yours — completely protected from overwrites.

### Root Discipline

The folder root should stay boring and sparse.

Allowed at root:
- Propagated files: `AGENTS.md`, `topic-insights.md`, `git-github-best-practices.md`, `.cleanup-protect`, `audit-folder-quality.ps1`
- Optional project-control files that truly must be root-scoped, such as `.git`, `.gitignore`, `.github/`, `.vscode/`, or `meta/`
- Rare tool-required root files, only when the tool breaks if they are moved

Not allowed at root unless there is a concrete tool reason:
- source folders like `src/`, `app/`, `lib/`, `packages/`
- notes, drafts, research, copied docs, or assignment material
- assets, datasets, downloads, archives, temp folders, logs, caches, and generated outputs
- duplicate legacy content folders

If a folder already has root drift:
1. Do not add more work to the root item.
2. Identify whether it is safe content, generated junk, or tool-required state.
3. Move safe content into `[topic-name]-content/`.
4. Do not move `.git`, build caches, tool homes, or active project roots unless the user explicitly approves the move.
5. Report anything risky instead of guessing.

### What Goes Where

| Location | Type | Propagation | Protected |
|----------|------|------------|-----------|
| Root (standard files) | Templates | Yes | Yes (Managed-By marker) |
| `[topic-name]-content/` | Primary operating area and actual content | Created by propagation, then project-owned | No |
| `meta/` | Optional topic-specific context | No | No (no marker) |

### Managed-By Marker

Files with `<!-- Managed-By: AI-Prompting-Library -->` are **system-managed**:
- Propagated from central AI Prompting template
- Can be updated/merged by propagate-to-all.ps1
- Never delete these

Files **without** this marker are **protected**:
- Never overwritten by propagation
- Topic-specific content stays intact

---

## Sync from Hub (Self-Service)

This folder can pull the latest propagated templates from the AI Prompting hub at any time — no need to wait for the hub to push updates.

### Quick Sync

Run from this folder's root:
```powershell
.\sync-from-hub.ps1
```

Or preview changes first:
```powershell
.\sync-from-hub.ps1 -Preview
```

### What It Does

- Pulls latest templates from `AI Prompting/propagate-templates/`
- Updates managed files (those with `Managed-By` marker)
- Skips unmanaged files (your custom content is safe)
- Creates missing files (e.g., if new templates were added to the hub)

### When to Sync

- When you see "templates updated" in the hub's session state
- When a new template is announced
- Before starting major work (ensures you have latest conventions)
- After creating a new folder (run once to get all base files)

---

## Core Workflow

1. Build context before editing
2. Prefer root-cause fixes over symptom patches
3. Use the smallest maintainable change
4. Verify with closest local equivalent
5. Summarize root cause, fix, verification, residual risk
6. **Session state on every resume** — Read `session-state.json` first. It contains what was being worked on and what comes next.
7. **Checkpoint before heavy operations** — Update `session-state.json` BEFORE multi-phase work or bulk operations (see `docs/session-checkpoint.md` on the hub for the full system)

---

## Session State (Shared Memory)

This project uses `session-state.json` as the shared memory place — same system as the AI Prompting hub.

### The Two Rules

```
Rule 1: Read session-state.json FIRST on every resume
Rule 2: Write session-state.json BEFORE heavy operations
```

### How to Use session-state.json

**On resume:**
1. Read `session-state.json` first — not AGENTS.md, not other docs
2. Check: What's the current task? What's the status? What changed last? What's the context pressure?

**Before heavy operations:**
1. Update `session-state.json` with current progress
2. Write BEFORE exhaustion, not after
3. Include: what changed, files touched, verification, residual risk

**Session state structure:**
```markdown
## CURRENT STATE
- Session: session-N
- Status: active/in_progress/complete
- Context pressure: low/medium/high

## CURRENT TASK
- Name: what you're working on
- Status: in_progress/complete/blocked

## WHAT CHANGED
- Add bullets about what changed this session

## FILES TOUCHED THIS SESSION
- List files modified

## VERIFICATION
- How did you verify the work?

## RESIDUAL RISK
- What's still uncertain? What could go wrong?

## NEXT ACTION
- What's the next step?
```

### When to Update session-state.json

- At the start of a new session (after reading)
- Before heavy operations (bulk edits, multi-phase work)
- When task status changes (started, completed, blocked)
- When context pressure increases (you're getting tired or context is getting stale)

See the hub's `docs/session-checkpoint.md` for full trigger conditions, context pressure signs, and workflow.

### Session History

At the end of meaningful work, add a compact entry to `archive/history-YYYY-MM.md` (create `archive/` if needed). Include: date, what changed, files touched, decisions made.

**History is NOT read by default.** It's for long-break resumes and understanding past decisions. The startup path is: `session-state.json` → `AGENTS.md` → task files.

---

## Cleanup Protection

Before any cleanup (deleting files, removing folders):

1. Read `.cleanup-protect` to see what files are protected
2. Check each file for `<!-- Managed-By: AI-Prompting-Library -->` marker
3. NEVER delete any file that:
   - Is listed in `.cleanup-protect`
   - Contains the marker `Managed-By: AI-Prompting-Library`

### Protected Files

- `AGENTS.md` — Main instructions (has marker)
- `topic-insights.md` — Cross-domain insights (has marker)
- `git-github-best-practices.md` — Git conventions (has marker)
- `.cleanup-protect` — This protection list
- `audit-folder-quality.ps1` — Quality audit script
- Any file with `Managed-By: AI-Prompting-Library`

---

## Cross-Domain Knowledge Flow

Insights from this topic can contribute to the central AI Prompting knowledge base:

1. Add insights to `topic-insights.md`
2. Tag with `#ai-relevant`, `#cross-domain`, or `#universal`
3. Insights are harvested and reviewed for cross-domain relevance
4. Significant insights are merged into central docs

---

## Reasoning Effort

- `low` — Obvious, local, easy-to-verify changes
- `medium` — Normal topic work
- `high` — Ambiguous debugging, cross-file changes, risky work
- `xhigh` — Broad, difficult, expensive-to-get-wrong tasks

---

## Quality Standards

Run the audit before and after major changes:
```powershell
.\audit-folder-quality.ps1
```

The audit validates:
- Folder organization (naming, structure)
- Script quality (parameters, help, error handling)
- Content quality (cited claims)
- Markdown quality (headings, links)
- Template completeness

---

## Agentic Behavior Rules

When this project uses an agentic workflow system (e.g., OpenCode with `.opencode/agents/`), follow these rules:

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

**Default behavior: Handle directly.** The Orchestrator should handle tasks itself using available tools. Only spawn a subagent when the task clearly exceeds direct-handling thresholds.

| Situation | Handler |
|-----------|---------|
| Simple, clear, under 10 seconds | Orchestrator (direct) |
| Complex, specialized, multi-step | Subagent (routed) |

**Subagent routing (only when direct handling isn't enough):**

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
3. **Tier 3 — Escalation (Sonnet 4.6 / Opus 4.7):** Only when security is suspected, main AI failed twice, or user explicitly requests premium analysis.

**Cost rule:** Direct handling costs $0 extra. Worker subagent costs the same as direct (same model). Escalation to premium uses Copilot quota — keep it rare.

**Manual override:** `@explorer find X` or "use K2.6 for this" bypasses routing.

### 4. Internal Coordination Notes

Do not add public-facing footers that disclose routing, model use, or internal execution mechanics unless the target repo or platform explicitly requires it.

Keep accountability in the right place:
- `session-state.json` records lanes, progress, files touched, verification, and residual risk.
- User-facing summaries focus on root cause, fix, verification, and remaining uncertainty.
- PRs and public comments stay project-native: no routing notes, model names, or generic automation tells.
- If a repo requires disclosure, follow that repo's rule and keep it concise.

### 5. Context Compression
When spawning subsessions, pass only:
- Task (specific, bounded)
- Context (3-5 bullets)
- Files (paths only)
- Done when (success criteria)

**Never pass:** full thread history, previous reasoning chains, teaching material.

### 6. Quality Guardrails
- Never downgrade critical tasks (debugging, final review)
- Verify specialist output before presenting
- If an agent misroutes 3× in a session, revert to monolithic
- User can override: "use [best model] for this" bypasses routing
- If the same fix path fails twice, checkpoint, re-plan, or switch to fresh context before more edits

---

## Project Context

For project-specific instructions (tech stack, conventions, special rules), see `meta/PROJECT.md`. Create this file if it does not exist — it is never overwritten by hub propagation.

**Example `meta/PROJECT.md`:**
```markdown
# Project Context

## Tech Stack
- Language/framework:
- Package manager:

## Conventions
- Code style:
- Naming patterns:

## Special Rules
- Any project-specific behaviors or gotchas
```

---

## Deep References

For detailed guidance on specific topics:

- **Teaching Order** → `docs/core-agent-doctrine.md` (Teaching section)
- **Prompt templates** → `docs/prompt-templates.md`
- **Research workflow** → `docs/core-agent-doctrine.md` (Research section)
- **Token efficiency** → `docs/token-efficient-prompting.md`
- **Model selection** → `docs/model-selection-guide.md`
- **Agentic workflows** → `docs/agentic-workflows.md`
- **Session checkpoint** → `docs/session-checkpoint.md` (topic folders: use `session-state.json`)
