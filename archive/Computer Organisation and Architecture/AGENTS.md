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
├── AGENTS.md                          (propagated - this file)
├── topic-insights.md                   (propagated - cross-domain insights)
├── git-github-best-practices.md        (propagated - git conventions)
├── .cleanup-protect                   (propagated - cleanup protection)
├── audit-folder-quality.ps1            (propagated - quality audit)
├── [topic-name]-content/              (mandatory primary operating area)
└── meta/                              (optional topic-specific context, create when needed)
    ├── HANDOVER.md                   (topic-specific handover notes)
    ├── quality-standards.md           (topic-specific quality criteria)
    └── ...                           (other topic-specific files)
```

### Operating Area

Do normal project work inside `[topic-name]-content/`.

Use the folder root only for propagated instruction files and truly root-scoped project files. If you need to add source code, notes, assets, datasets, drafts, or project-specific docs, put them under `[topic-name]-content/` unless there is a concrete tool reason they must live at the root.

Create `meta/` only when durable project context is needed, such as handover notes, local quality rules, or project-specific operating notes.

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

## Core Workflow

1. Build context before editing
2. Prefer root-cause fixes over symptom patches
3. Use the smallest maintainable change
4. Verify with closest local equivalent
5. Summarize root cause, fix, verification, residual risk
6. **Session state on every resume** — Read `meta/HANDOVER.md` first. It contains what was being worked on and what comes next.
7. **Checkpoint before heavy operations** — Update `meta/HANDOVER.md` BEFORE multi-phase work or bulk operations (see `docs/session-checkpoint.md` on the hub for the full system)

---

## Topic-Specific Procedures

Before working in this topic, read files in `meta/` if that folder exists:
- `HANDOVER.md` — **Session state: what was being worked on, what comes next, context pressure**
- `quality-standards.md` — Topic-specific quality criteria
- Other topic-specific files as needed

If `meta/` does not exist yet, do not create it unless the project needs durable topic-specific context.

### Session State (Multi-Phase Work)

For any task that spans more than one session:

**On resume:** Read `meta/HANDOVER.md` first — not AGENTS.md, not other docs. Cost: ~200 tokens vs reading everything.

**Before heavy operations:** Update `meta/HANDOVER.md` with current progress. Write BEFORE exhaustion, not after.

**The two rules:**
```
Rule 1: Read meta/HANDOVER.md FIRST on every resume
Rule 2: Write meta/HANDOVER.md BEFORE heavy operations
```

See the hub's `docs/session-checkpoint.md` for full trigger conditions, context pressure signs, and workflow.

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

## Deep References

For detailed guidance on specific topics:

- **Teaching Order** → `docs/core-agent-doctrine.md` (Teaching section)
- **Prompt templates** → `docs/prompt-templates.md`
- **Research workflow** → `docs/core-agent-doctrine.md` (Research section)
- **Token efficiency** → `docs/token-efficient-prompting.md`
- **Model selection** → `docs/model-selection-guide.md`
- **Session checkpoint** → `docs/session-checkpoint.md` (hub only — topic folders: use topic-specific `meta/HANDOVER.md`)

