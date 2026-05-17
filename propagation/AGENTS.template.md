<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: AGENTS -->
# Topic Workspace

A topic workspace managed by the agentic-workflows hub. This file provides AI agents with context on how to work effectively in this folder.

## Operating Contract

**Core principle: Supply missing structure when safe.**

When the request is clear enough and risk is low, proactively:
- sharpen scope
- choose a sensible investigation order
- define verification targets
- choose the lightest execution lane
- switch to tests-first work when behavior changes

**Default fix conduct (macro-to-micro funnel):** When fixing any issue, start at the architectural/systemic/macro level and drill down to micro. The funnel has four levels — System (how does it connect?), Domain (which subsystem?), Module (which file/code path?), Root Cause (what specific logic fails?). Do not skip levels based on intuition.

**Automatic questioning (always on):**
- **Direction A (user -> agent):** When a request is vague, use the **Clarification Protocol** to sharpen it before acting.
- **Direction B (agent needs info -> user):** Use structured format: header, question, options with 1-line descriptions and a recommendation, why this matters, what comes next. Give a clear default. Ask one question at a time.
- **Never guess** when 1 question to the user resolves the ambiguity.

## Startup Order

1. `workflow-state.json` — active workflow state; read first on every resume
2. Lifecycle hooks run automatically (if `scripts/hooks/` exists)
3. `AGENTS.md` — this operating contract
4. Task-specific files only when needed

## Workflow-Driven Execution

The workflow runtime manages task execution as a state machine. Workflow definitions live in `workflow.d/`. State persists in `workflow-state.json`.

1. **Session start.** Read `workflow-state.json`. If a workflow is active, load the definition from `workflow.d/<id>.yaml` and resume at the current step.
2. **No active workflow?** Read `workflow.d/root.yaml`, run the `classify` step to route the user's request.
3. **Deterministic steps.** Run the script from `script:` field. Capture stdout as step result. Advance to next step.
4. **Deliberative steps.** Reason, propose options, back and forth with user until consensus. Advance on agreement.
5. **Branches.** If a step has `branches:`, match the result against branch keys and follow the target (next step or another workflow file).
6. **Persistence.** After each step, write step result to `workflow-state.json` under `context` and append to `trace`.
7. **Completion proposes next.** When all steps finish, check `next:` in the workflow definition. If set, propose to user: "X is done. Proceed to Y?"

Deterministic steps run automatically. Deliberative steps require user engagement — you propose, they react, you refine, consensus advances.

## High-Signal Files

| File | Purpose |
|------|---------|
| `workflow-state.json` | Active workflow state; read first on every resume |
| `workflow.d/` | Workflow definitions (state machines) |
| `topic-insights.md` | Topic learning and insights |
| `buglog.json` | Bug memory across sessions |
| `[folder-name]-content/` | Your actual work — hub never touches |

## Key Rules

- **No new files** if an existing doc covers the need.
- **Verify aggressively** — verification is the quality engine.
- **Weigh complexity cost against improvement magnitude** — "All else equal, simpler is better."
- **Commit after every meaningful change automatically.** After a verified edit, checkpoint, or completed slice, run the safe commit wrapper.
- **Fix macro-to-micro by default**: when fixing, start at the system architecture level and drill down to code.
- **Force fast slices**: break broad tasks into a milestone ladder, execute one slice at a time.
- **Think big, map coarsely, bet medium, execute tiny**: compress the goal, map domains, shape one milestone, implement one slice.
- **Map before broad reading** — When a folder is unfamiliar or a task is broad, use repo-map before targeted retrieval.

## Folder Structure

```
[Topic-Folder]/
|- AGENTS.md                    (this file — operating contract)
|- CLAUDE.md                    (Claude Code compatibility shim)
|- workflow-state.json          (current workflow state)
|- workflow.d/                  (workflow definitions — hub-propagated)
|- propagated/                  (hub-managed tools and scripts)
|- commands/                    (slash command references)
|- [folder-name]-content/       (YOUR WORK — hub never touches)
|- meta/                        (YOUR custom content — never touched)
```

**Note:** Files in `propagated/`, `workflow.d/`, and `commands/` are managed by the agentic-workflows hub. They may be overwritten on propagation. Do not edit them directly in the topic folder.

## Session Documentation

The workflow runtime (`workflow-state.json` trace) replaces manual session documentation. As the agent advances through workflow steps, it appends to `trace` automatically. No manual history writing needed.

## Skills

This topic folder has access to skills from the hub's `skills/` directory. When a task matches a skill, invoke it via the `skill` tool — follow the skill workflow exactly without implementing directly.

| Bundle | Purpose | Skills |
|--------|---------|--------|
| **define** | Spec, plan, break down work | idea-refine, spec-driven-development, planning-and-task-breakdown |
| **build** | Implement with discipline | incremental-implementation, test-driven-development, source-driven-development |
| **verify** | Debug, test, review, harden | debugging-and-error-recovery, code-review-and-quality, code-simplification |
| **ship** | Release, document, automate | git-workflow-and-versioning, ci-cd-and-automation, documentation-and-adrs |

## Deep References

| Topic | Reference |
|-------|-----------|
| Workflow system | See hub's `docs/workflow.md`, `workflow.d/SCHEMA.md` |
| Skills reference | See hub's `skills/` |
| Quality standards | See hub's `docs/quality-standards.md` |
| Git practices | See hub's `docs/git-github-best-practices.md` |
| Session checkpoints | See hub's `docs/session-checkpoint.md` |
