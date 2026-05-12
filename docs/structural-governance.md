# Structural Governance — Keeping the Workspace Clean Over Time

A recurring pattern: new things get added to the workspace, but without a consistent placement
strategy they end up in slightly-wrong places, requiring refactoring later.

This document defines a **structural governance system** — a small set of rules, a
classification guide, and a feedback loop — so new additions land in the right place
from day one.

## Authority

This pattern synthesizes four established principles from software architecture:

### 1. Conway's Law (Melvin Conway, 1968)

> Organizations which design systems are constrained to produce designs which are
> copies of the communication structures of these organizations.

**Reverse Conway Maneuver:** deliberately design the repository structure to produce
the desired contribution behavior. If the structure clearly screams "skills go here,
docs go here, scripts go here," then new contributions will naturally follow.

### 2. Screaming Architecture (Robert C. Martin, 2011)

> When you look at the top level directory structure, does it scream what the system
> is about, or does it scream the frameworks you used?

The root of this workspace should scream: **agent harness + systems engineering**.
Every directory has a clear role in managing, orchestrating, or extending AI agents
(`skills/`, `scripts/`, `commands/`, `propagation/`, `docs/`, `rules/`).
A new file should be obviously classifiable into exactly one of these roles.

### 3. Package Principles (Robert C. Martin, 1996)

- **Common Closure Principle (CCP):** Things that change together should be together.
  A skill and its companion script change together — they belong in the same directory.
- **Common Reuse Principle (CRP):** Things that are used together should be together.
  All files related to a skill belong in that skill's directory.
- **Reuse-Release Equivalence (REP):** The granularity of reuse is the same as the
  granularity of release. Each skill directory is independently usable.

### 4. Inbox Pattern (GTD / David Allen)

> The mind is for having ideas, not holding them.

A staging area for unclassified content prevents premature placement decisions.
New content lands in `inbox/` and gets classified later. This reduces the cost of
getting it "wrong" — it's not wrong, it's just not yet classified.

## The Governance System

### The Classification Guide

When adding something new to this workspace, answer one question:

**What kind of thing is this?**

| If it's... | Put it in... | Examples |
|---|---|---|
| A repeatable process with steps | `skills/<name>/` | `skills/doubt-driven-development/` |
| A reference document | `docs/<category>/` | `docs/assumption-expiry.md` |
| An automation script | `scripts/` or `skills/<name>/scripts/` | `scripts/context-pressure.sh` |
| A slash command | `commands/<name>.md` | `commands/session.md` |
| An agent behavior rule | `rules/<language>/` or `rules/common/` | `rules/common/coding-style.md` |
| A template for downstream repos | `propagation/<type>/` | `propagation/command/` |
| A session log or research note | `archive/` or `research/` | `archive/history-2026-05.md` |
| **I don't know** | `inbox/` | Staging — classify within 7 days |

### Decision Tree (for uncertain cases)

```
Is this a process with steps users follow?
  → YES → skills/<name>/ (create SKILL.md + optional companion script)
  → NO Is this a reference the agent reads?
    → YES → docs/<name>.md
    → NO Is this a tool the agent runs?
      → YES Is it specific to one skill?
        → YES → skills/<name>/scripts/
        → NO → scripts/
      → NO Is this a config or rule?
        → YES → rules/ or .gitignore
        → NO → inbox/
```

### The Inbox

The `inbox/` directory exists for exactly this purpose — a temporary holding area
for content that hasn't been classified yet.

Rules:
- New files that don't clearly fit anywhere go in `inbox/`
- Inbox items are classified within 7 days (enforced by detect-gaps.sh)
- Empty inbox = healthy workspace

### Enforcement (detect-gaps.sh Check 10)

When `detect-gaps.sh` runs at session start, it checks:
1. Does `inbox/` contain unclassified files?
2. If yes: list them with suggested classifications

## Example: Adding a New Skill

Without governance:
```
Add file: workflows/deploy-checklist.md  →  Wrong place (no "workflows/" dir)
                                       →  Needs refactoring later
```

With governance:
```
I want to add a deployment checklist.
→ Is this a process with steps? YES → skills/<name>/
→ Create skills/deploy-checklist/SKILL.md
→ Add companion script if needed: skills/deploy-checklist/scripts/checklist.sh
→ Update skills/manifest.json
→ Done. No refactoring needed.
```

## Verification

- [ ] inbox/ is empty at session end
- [ ] Every skill/ directory follows the pattern: SKILL.md + optional scripts/
- [ ] Every docs/ file is referenced from AGENTS.md Deep References
- [ ] detect-gaps.sh Check 10 reports inbox status
