---
name: implementation-planning
description: Create technical implementation plans with phases, file changes, and verification steps. Use when a ticket, shaped work, or technical challenge needs a concrete implementation strategy before coding begins. Complements planning-and-task-breakdown (which decomposes into tasks) by producing the technical design — file-by-file plans with complete code snippets. NOT for: task breakdown (→ planning-and-task-breakdown), or executing code (→ incremental-implementation).
trigger-phrases: create a plan, plan this ticket, how should we implement, technical design, architect this, design the approach, refactor plan, implementation strategy
handoffs: incremental-implementation (to execute phase by phase), planning-and-task-breakdown (for task-level decomposition)
companion-script: scripts/plan-implementation.sh
---

# Implementation Planning

Take a ticket, shaped work, or technical challenge and create a detailed implementation plan that any developer or agent can follow.

**Companion script:** `scripts/plan-implementation.sh`
```bash
bash ./scripts/plan-implementation.sh locate "<feature>"     # sub-agent prompt for locating files
bash ./scripts/plan-implementation.sh patterns "<feature>"   # sub-agent for similar impls
bash ./scripts/plan-implementation.sh analyze "<feature>"    # sub-agent for flow analysis
bash ./scripts/plan-implementation.sh plan "<title>"          # implementation plan template
bash ./scripts/plan-implementation.sh phase "<name>"          # single phase template
bash ./scripts/plan-implementation.sh check "<plan>"          # plan quality check
```

## Principles

- **Research first** — understand the codebase before proposing solutions
- **Be specific** — include file paths, function names, complete code snippets
- **Be skeptical** — question assumptions, identify risks early
- **Decide, don't ask** — every open question gets a recommended resolution
- **Be practical** — focus on incremental, testable changes
- **Agent-agnostic** — plan should work for any implementer
- **Follow patterns** — match existing codebase conventions

## Process

### 1. Gather Context

Launch parallel sub-agents before planning:

```
# LOCATE — find where relevant files live
Explore: "Find all files related to [feature/domain].
  Group by: routes, use-cases, components, DB schema, tests."

# PATTERNS — find similar implementations to model after
Explore: "Find similar implementations to [what we're building].
  Read code thoroughly. Extract complete working examples."

# ANALYZE — trace how a related feature works end-to-end
Explore: "Analyze how [related feature] is implemented.
  Trace data flow from entry point to DB/API."
```

### 2. Present Options (if multiple approaches)

Option A: [approach] — Pros/Cons
Option B: [approach] — Pros/Cons
**Recommendation**: [which and why]

### 3. Write the Plan

```
# [Title] — Implementation Plan

## Overview
[1-2 sentences: what and why]

## Current State
[What exists now, what's missing, relevant code locations]

## Desired End State
[What should work when done, how to verify]

## Out of Scope
[What we're NOT doing]

## Implementation Approach
[High-level strategy]

### Phase 1: [Descriptive Name]

**What This Accomplishes:** [summary]

**Changes:**

File: path/to/file.ext
```[language]
// Complete code to add or modify — not snippets
```

### Phase Checks
- [ ] [command to run — build, typecheck, unit test]
- [ ] [expected output or behavior]

### Phase 2: [Descriptive Name]
[Same structure]

## Testing Strategy
- [ ] Unit tests: [what to test]
- [ ] Integration tests: [scenarios]

## File Summary
```
directory/
├── file1.ext  # Purpose
├── file2.ext  # Purpose
```

## Open Questions
Every question includes a recommended resolution.
- [Question] Recommend: [option] — [why]
```

### Phase Guidelines

- Each phase is **independently verifiable** via checks
- Earlier phases don't break existing functionality
- Can pause between phases if needed
- 1-3 files per phase typically
- Include **COMPLETE code**, not snippets
- Never use "..." or "// rest of code"

### What Makes a Good Plan

**Good** (specific, actionable):
- File paths exist or clearly describe where to create
- Code snippets show COMPLETE implementation
- Verification steps are concrete commands
- Expected outputs documented

**Bad** (vague, hand-wavy):
- "Update the relevant components"
- "Add appropriate error handling"
- Code snippets with "..." placeholders

## Handoffs

- After plan approval, use `incremental-implementation` to execute phase by phase
- Make the checkboxes match — `[x]` marks track progress during implementation

## Boundaries

- Does NOT execute code changes (→ `incremental-implementation`)
- Does NOT decompose into tasks (→ `planning-and-task-breakdown`)
- Does NOT shape work from rough ideas (→ `shaping-work`)
- Plan is a guide, not a rigid script — implementation may adapt
