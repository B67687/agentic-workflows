---
name: tap-audit
description: Assess how ready a repository is for autonomous agent work. Scans documentation, MCP servers, CLI tools, permissions, test infrastructure, environments, and processes to produce a readiness assessment with actionable leverage points. Use when someone says "audit this repo", "how ready is this codebase", "assess this project", or when an agent enters an unfamiliar codebase and needs to understand it before working. Outputs to .tap/tap-audit.md.
trigger-phrases: audit this repo, tap audit, how ready is this codebase, assess this project, repo readiness, autonomous readiness
handoffs: systems-health (for ongoing health monitoring), retrospective (for event-driven learnings)
companion-script: scripts/tap-audit.sh
---

# TAP Audit

Assess how autonomous an agent can be in this repo right now. Produces a structured assessment at `.tap/tap-audit.md`.

This skill assesses the system: what's configured, what's missing, what's slowing delivery or letting bugs through.

**Companion script:** `scripts/tap-audit.sh`
```bash
bash ./scripts/tap-audit.sh check-existing   # check if existing audit is current
bash ./scripts/tap-audit.sh scan              # scan for key config files
bash ./scripts/tap-audit.sh dimensions        # assess harness dimensions
bash ./scripts/tap-audit.sh score             # calculate readiness score
bash ./scripts/tap-audit.sh leverage          # identify leverage points
bash ./scripts/tap-audit.sh report            # summary report
```

## Process

### 0. Check Existing Audit

If `.tap/tap-audit.md` exists, read it first:

- Parse `Last run:` date
- Run `git log --oneline --since="[date]"` for commits since
- Check key config changes: `git diff --name-only HEAD@{[date]} -- .claude/ .mcp.json package.json .github/ CLAUDE.md`

| Condition | Action |
|-----------|--------|
| `--force` flag | Full re-run |
| < 30 days, no key config changes | **Summary mode** — print score + leverage points. Stop. |
| < 30 days, key config changed | **Delta mode** — reassess only affected dimensions |
| >= 30 days, significant activity | Recommend full re-run, ask first |
| >= 30 days, low activity | **Summary mode** — likely still accurate. Stop. |

### 1. Scan the Repo

```
.claude/settings.json           → permissions
.claude/settings.local.json     → local overrides
.mcp.json                       → MCP servers
CLAUDE.md                       → coding instructions
AGENTS.md                       → agent boundaries
package.json / Cargo.toml       → stack + scripts
tsconfig.json / biome.json      → tooling config
.github/workflows/              → CI/CD setup
.tap/                           → existing project memory
```

Also run: `git log --oneline -20`, `git shortlog -sn --no-merges --since="90 days ago"`, `gh run list --limit 5` if tools available.

### 2. Assess Each Dimension

#### Environments
```
- Local:      [command] → [url]
- Preview:    [url or "not configured"]
- Staging:    [url or "not configured"]
- Production: [url or "not configured"]
```

#### Agent Harness Readiness

Mark ✓ (available) or ✗ (missing):

**Documentation**: CLAUDE.md? AGENTS.md? ADRs?
**Strategic Context**: `.tap/product.md`? ≤ 80 lines? mtime within 90 days?
**MCP Servers**: What's configured? What's missing for the stack?
**Skills**: What skills are available? What's missing?
**CLI Tools**: package manager, test runner, linter, build tool, deploy tool
**Permissions**: What's explicitly allowed and denied?
**Test Infrastructure**: Test count, coverage, types present

#### Readiness Score

- **FULL**: Agent can implement, test (unit + browser), access DB, verify end-to-end. CLAUDE.md comprehensive.
- **PARTIAL**: Agent can implement and run some tests. Some gaps.
- **MINIMAL**: Agent can read/write code but can't run tests, no MCP servers.

#### Design Complexity

Sample the 5-10 most-changed files recently. Check for:
- File size (proxy for module depth)
- Import fanout (proxy for coupling)
- Layer structure (pass-through wrappers, thin abstractions)
- Consistency (similar patterns or each file invents its own)

Rate: **Easy** / **Moderate** / **Hard** to modify.

#### Feedback Loops

Discover top 3 workflows. For each assess:

| Element | What to look for |
|---------|------------------|
| **Generator** | Can agent produce the output? |
| **Evaluator** | Can something other than generator verify? |
| **Handoff** | Can agent context-reset? |
| **Grading criteria** | Measurable quality expectations? |

Rate: **Closed loop** / **Open loop** / **No loop** / **Manual**

#### Approach Gaps

Flag what's MISSING that causes agent rework:
- Test coverage gaps (which areas have no tests?)
- Missing ADRs (where do agents guess at architectural intent?)
- Undocumented patterns (inconsistencies agents will copy?)

#### Process
- Branching strategy
- CI/CD pipeline (what runs, recent pass rate)
- Deploy mechanics (auto or manual)

### 3. Identify Leverage Points

Find 3-5. Each answers: what's slowing delivery OR letting defects through?

```
### N. [Short description] → [consequence]
- Symptom: [observable problem]
- Why it costs: [concrete impact on speed or quality]
- Fix: [cheapest intervention + estimated effort]
```

### 4. Write .tap/tap-audit.md

Create `.tap/` directory if needed. Write assessment.

### 5. Seed .tap/architecture.md

If `.tap/architecture.md` doesn't exist, create it now. Scan codebase for deliberate architectural decisions:
- Consistent patterns across the codebase
- Config that implies decisions (ORM, auth provider)
- Package choices that constrain patterns
- Comments explaining "why"

Write each decision in 2-4 lines. Capture the **principle** behind the decision.

## Presentation

```
`★ Audit View ────────────────────────────────────`
[repo name] — [readiness score]
  ├─ [top feedback loop finding]
  ├─ [#1 leverage point]
  └─ [cheapest fix to start with]
`─────────────────────────────────────────────────`
```

**Human mode**: Walk through findings. Ask if they want to address any leverage points now.

**Agent mode**: Write .tap/tap-audit.md and .tap/architecture.md silently. Log score. Proceed to task.

## Boundaries

- Does NOT describe the tech stack (CLAUDE.md's job)
- Does NOT set coding conventions (CLAUDE.md's job)
- Does NOT modify any code or config — read-only assessment
