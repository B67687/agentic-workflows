---
name: spec-driven-development
description: Creates specs before coding. Use when starting a new project, feature, or significant change and no specification exists yet. Use when requirements are unclear, ambiguous, or only exist as
  a vague idea.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, write, grep
metadata:
  companion-script: scripts/spec-generator.sh
  handoffs: planning-and-task-breakdown (to decompose), grill-me (to clarify)
  trigger-phrases: write a spec, specification, define requirements, scope this, what are we building, requirements doc
  pattern: generator
  bundle: define
---
## Presentation

```
`★ Spec View ─────────────────────────────────────`
- [Feature/Project] --- [status: DRAFT / REVIEW / APPROVED]
- [Scope: what's in / what's out]
- [Top open question]
`─────────────────────────────────────────────────`
```

# Spec-Driven Development

**Companion script:** `scripts/spec-generator.sh` --- spec scaffolding, assumptions formatting, and gate review checklists.
```bash
bash ./scripts/spec-generator.sh spec "<name>" "<desc>"   # full spec document
bash ./scripts/spec-generator.sh assumptions "<claim>"     # assumption entry
bash ./scripts/spec-generator.sh checklist                 # gate review checklist
```

## Overview

Write a structured specification before writing any code. The spec is the shared source of truth between you and the human engineer --- it defines what we're building, why, and how we'll know it's done. Code without a spec is guessing.

## When to Use

- Starting a new project or feature
- Requirements are ambiguous or incomplete
- The change touches multiple files or modules
- You're about to make an architectural decision
- The task would take more than 30 minutes to implement

**When NOT to use:** Single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained.

## The Gated Workflow

Spec-driven development has four phases. Do not advance to the next phase until the current one is validated.

```
SPECIFY ──-> PLAN ──-> TASKS ──-> IMPLEMENT
   │          │        │          │
   ▼          ▼        ▼          ▼
 Human      Human    Human      Human
 reviews    reviews  reviews    reviews
```

### Phase 1: Specify

Start with a high-level vision. Ask the human clarifying questions until requirements are concrete.

**Surface assumptions immediately.** Before writing any spec content, list what you're assuming:

```
ASSUMPTIONS I'M MAKING:
1. This is a web application (not native mobile)
2. Authentication uses session-based cookies (not JWT)
3. The database is PostgreSQL (based on existing Prisma schema)
4. We're targeting modern browsers only (no IE11)
-> Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The spec's entire purpose is to surface misunderstandings *before* code gets written --- assumptions are the most dangerous form of misunderstanding.

**Mark ambiguity explicitly.** When a requirement is underspecified, do not guess. Use `[NEEDS CLARIFICATION: <specific question>]` inline:

```markdown
- FR-006: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified]
- FR-007: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]
```

The phase gate (`phase-gate.sh --check-ambiguity`) scans for unresolved `[NEEDS CLARIFICATION]` markers and BLOCKs the implement phase until they are resolved. This prevents the most common LLM failure mode: confident-sounding incorrect assumptions.

**Write a spec document covering these six core areas:**

> See `assets/spec-template.md` (L3) for the fill-in-the-blank template with objective,
> tech stack, commands, project structure, code style, testing strategy, boundaries,
> success criteria, and open questions sections. Load with:
> `bash ./scripts/skill-toolset.sh resource spec-driven-development assets/spec-template.md`

The six core areas are: **Objective** (what/why/who/success), **Commands** (full
build/test/lint/dev commands), **Project Structure** (directory layout), **Code Style**
(convention example), **Testing Strategy** (framework, coverage, test levels), and
**Boundaries** (Always / Ask First / Never).

**Reframe instructions as success criteria.** When receiving vague requirements, translate them into concrete conditions:

```
REQUIREMENT: "Make the dashboard faster"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s on 4G connection
- Initial data load completes in < 500ms
- No layout shift during load (CLS < 0.1)
-> Are these the right targets?
```

This lets you loop, retry, and problem-solve toward a clear goal rather than guessing what "faster" means.

### Phase 2: Plan

With the validated spec, generate a technical implementation plan:

1. Identify the major components and their dependencies
2. Determine the implementation order (what must be built first)
3. Note risks and mitigation strategies
4. Identify what can be built in parallel vs. what must be sequential
5. Define verification checkpoints between phases

The plan should be reviewable: the human should be able to read it and say "yes, that's the right approach" or "no, change X."

### Phase 3: Tasks

Break the plan into discrete, implementable tasks:

- Each task should be completable in a single focused session
- Each task has explicit acceptance criteria
- Each task includes a verification step (test, build, manual check)
- Tasks are ordered by dependency, not by perceived importance
- No task should require changing more than ~5 files

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm --- test command, build, manual check]
  - Files: [Which files will be touched]
```

### Phase 4: Implement

Execute tasks one at a time following `incremental-implementation` and `test-driven-development` skills. Use `context-engineering` to load the right spec sections and source files at each step rather than flooding the agent with the entire spec.

## Keeping the Spec Alive

The spec is a living document, not a one-time artifact:

- **Update when decisions change** --- If you discover the data model needs to change, update the spec first, then implement.
- **Update when scope changes** --- Features added or cut should be reflected in the spec.
- **Commit the spec** --- The spec belongs in version control alongside the code.
- **Reference the spec in PRs** --- Link back to the spec section that each PR implements.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This is simple, I don't need a spec" | Simple tasks don't need *long* specs, but they still need acceptance criteria. A two-line spec is fine. |
| "I'll write the spec after I code it" | That's documentation, not specification. The spec's value is in forcing clarity *before* code. |
| "The spec will slow us down" | A 15-minute spec prevents hours of rework. Waterfall in 15 minutes beats debugging in 15 hours. |
| "Requirements will change anyway" | That's why the spec is a living document. An outdated spec is still better than no spec. |
| "The user knows what they want" | Even clear requests have implicit assumptions. The spec surfaces those assumptions. |

## Red Flags

- Starting to write code without any written requirements
- Asking "should I just start building?" before clarifying what "done" means
- Implementing features not mentioned in any spec or task list
- Making architectural decisions without documenting them
- Skipping the spec because "it's obvious what to build"

## Verification

Before proceeding to implementation, confirm:

- [ ] The spec covers all six core areas
- [ ] The human has reviewed and approved the spec
- [ ] Success criteria are specific and testable
- [ ] Boundaries (Always/Ask First/Never) are defined
- [ ] The spec is saved to a file in the repository
