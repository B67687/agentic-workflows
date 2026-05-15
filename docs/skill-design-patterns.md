# Skill Design Patterns

A shared language for structuring SKILL.md content. Derived from Google ADK's 5
agent skill design patterns and adapted to this workspace's 42 skills.

## Why Patterns Matter

The agentskills.io specification solved the *format* problem --- every tool now uses
the same `SKILL.md` with YAML frontmatter and Markdown body. But the spec says
nothing about how to structure the *content inside* the skill.

These 5 patterns are the architectural grammar. Name the pattern, and you know
immediately: what directories it needs, how instructions are organized, what L3
resources to load, and how to compose it with other patterns.

## The Five Patterns

### 1. Tool Wrapper --- "Make the agent an expert on demand"

| | |
|---|---|
| **Purpose** | Package library/framework conventions into on-demand knowledge |
| **Directories** | `references/` for API patterns, best practices, coding standards |
| **How it works** | SKILL.md instructs agent to `load_skill_resource` the reference file only when the relevant technology is in use |
| **Existing skills using this** | `api-and-interface-design`, `source-driven-development`, `security-and-hardening`, `browser-testing-with-devtools` |

**When to use:** The agent needs expert knowledge about a specific library,
framework, or domain --- but only when that topic arises.

**Example in this repo:** `api-and-interface-design/SKILL.md` tells the agent
how to design REST/GraphQL endpoints. API conventions belong in
`references/api-patterns.md` (L3), loaded only when the agent is designing
an interface --- not on every turn.

### 2. Generator --- "Produce consistent structured output"

| | |
|---|---|
| **Purpose** | Enforce fixed-structure output from a reusable template |
| **Directories** | `assets/` for output templates, `references/` for style guides |
| **How it works** | SKILL.md orchestrates: load template from `assets/`, read style guide from `references/`, ask user for variables, populate document |
| **Existing skills using this** | `documentation-and-adrs`, `spec-driven-development` |

**When to use:** Output must follow the same structure every time --- ADRs, specs,
reports, changelogs.

**Example in this repo:** `documentation-and-adrs/SKILL.md` generates ADRs.
The template lives in `assets/adr-template.md` (L3). The style guide lives in
`references/adr-style-guide.md` (L3). The SKILL.md just orchestrates.

### 3. Reviewer --- "Evaluate against a rubric"

| | |
|---|---|
| **Purpose** | Score code/content against a checklist by severity |
| **Directories** | `references/` for rubrics and checklists |
| **How it works** | Separates *what to check* (rubric in `references/`) from *how to check* (protocol in SKILL.md). Swap the rubric file, get a different review type |
| **Existing skills using this** | `code-review-and-quality`, `performance-optimization`, `blast-radius` |

**When to use:** You need to evaluate output against a standard with severity
levels (P0/P1/P2 or similar).

**Example in this repo:** `code-review-and-quality/SKILL.md` defines the 5-axis
review process. The actual checklist items live in
`references/review-checklist.md` (L3), loaded only when the agent decides to
review, not when the skill activates.

### 4. Inversion --- "The agent interviews you first"

| | |
|---|---|
| **Purpose** | Flip the conversation: agent asks structured questions before acting |
| **Directories** | `references/` for question banks |
| **How it works** | The skill explicitly refuses to generate output until the agent has a complete picture. The agent interviews the user, gathers context, then acts |
| **Existing skills using this** | `grill-me`, `structured-questioning` |

**When to use:** The cost of guessing wrong is high. Requirements are
unclear. The agent needs user context before producing output.

**Example in this repo:** `grill-me/SKILL.md` is a textbook Inversion pattern.
The agent refuses to proceed until the decision tree is fully resolved. The
question bank belongs in `references/question-bank.md` (L3).

### 5. Pipeline --- "Enforce a multi-step workflow with gates"

| | |
|---|---|
| **Purpose** | Enforce strict sequential workflow with checkpoints between steps |
| **Directories** | `references/` for per-step guidance, `scripts/` for automation, `assets/` for templates |
| **How it works** | Steps are numbered and sequential. Each step has an explicit Gate Condition --- step N+1 cannot start until step N's gate passes |
| **Existing skills using this** | `debugging-and-error-recovery`, `test-driven-development`, `incremental-implementation` |

**When to use:** Steps must execute in order. Skipping a step breaks the
workflow. Complex business processes.

**Example in this repo:** `debugging-and-error-recovery/SKILL.md` uses a 4-level
macro-to-micro funnel. Each level is a gate: Level 1 (System) must complete
before Level 2 (Domain) begins. Add explicit `Gate: PASS` conditions between
levels.

## Pattern Composition

Patterns compose. These are the most common pairings in this repo:

| Composition | Example in this repo |
|---|---|
| **Pipeline + Reviewer** | `debugging-and-error-recovery` includes `code-review-and-quality` at the fix-verification step |
| **Generator + Inversion** | `spec-driven-development` uses `grill-me` for requirements gathering before template filling |
| **Inversion -> Generator -> Pipeline** | `grill-me` -> `spec-driven-development` -> `implementation-planning` -> `incremental-implementation` (full feature workflow) |
| **Tool Wrapper + Generator** | `api-and-interface-design` conventions feed into `documentation-and-adrs` for API documentation |
| **Pipeline -> Reviewer -> Pipeline** | `incremental-implementation` slices, `code-review-and-quality` gates, then `git-workflow-and-versioning` for commit |

## Choosing a Pattern

| Question | Pattern | Complexity |
|---|---|---|
| Need to inject library/framework/domain context? | **Tool Wrapper** | Low |
| Need consistent template-based output? | **Generator** | Medium |
| Need to score against a checklist? | **Reviewer** | Low |
| Need to gather requirements before acting? | **Inversion** | Low |
| Need strict multi-step workflow? | **Pipeline** | High |

Start with the simplest pattern that fits. Most production skills need only one
or two patterns. The `handoffs` field in each skill's frontmatter shows how it
composes with others --- follow those links.

## Pattern-Compliant Directory Structure

```
skills/<skill-name>/
├── SKILL.md            # L2: Instructions (thin orchestrator)
├── references/         # L3: Rubrics, style guides, API patterns (loaded on demand)
├── assets/             # L3: Templates, schemas, examples (loaded on demand)
└── scripts/            # L3: Executable automation (run when instructions call for it)
```

The SKILL.md should be the *orchestrator* --- telling the agent what to load from
`references/` and `assets/` and when. Move detailed content into L3 files.

## Verification

After authoring or refactoring a skill:
1. `bash ./scripts/validate-skill-frontmatter.sh <name>` --- validates spec compliance
2. `bash ./scripts/skill-find.sh check <name>` --- verifies it's discoverable
3. Confirm `bash ./scripts/skill-toolset.sh list` shows the skill (after Slice 2)
4. Verify the SKILL.md can be loaded standalone (no broken L3 references)
