---
name: curate-product-context
description: Curate and maintain `.tap/product.md` — a compressed, agent-readable product-context file (what we build, audience, current focus, bets, non-goals). Auto-detects interview / review / refresh mode. One file, five sections, ≤ 80 lines, principle-driven. NOT for: tech stack (CLAUDE.md), architecture decisions (.tap/architecture.md), or feature roadmaps.
trigger-phrases: curate product context, update product context, product vision in repo, what are we building, product direction, install product context
handoffs: tap-audit (to assess readiness after product context), tech-roadmap (to build roadmap from context)
companion-script: scripts/curate-product-context.sh
---

# Curate Product Context

**Companion script:** `scripts/curate-product-context.sh` — generate `.tap/product.md` skeleton with product vision, focus, and non-goals.
```bash
bash ./scripts/curate-product-context.sh init "<product>"   # initialize product context
```

Install and maintain durable product-strategic context as an in-repo artifact (`.tap/product.md`) so human engineers and AI agents can make decisions without pinging the leader.

**Companion script:** `scripts/curate-product-context.sh`
```bash
bash ./scripts/curate-product-context.sh check-state    # check if file exists + age
bash ./scripts/curate-product-context.sh mode            # auto-detect mode
bash ./scripts/curate-product-context.sh read-inputs     # read existing inputs
bash ./scripts/curate-product-context.sh interview       # interview mode walkthrough
bash ./scripts/curate-product-context.sh review          # review mode protocol
bash ./scripts/curate-product-context.sh refresh         # refresh mode
bash ./scripts/curate-product-context.sh template        # product context format
```

## Process

### 0. Check State

Check for `.tap/product.md`. Age determines mode.

### 1. Auto-detect Mode

| Condition | Mode |
|-----------|------|
| File missing | **Interview** — walk all five sections |
| Exists, < 90 days | **Review** — prune-first, diff, confirm |
| Exists, ≥ 90 days | **Refresh** — capture shifts, then review |

### 2. Read Inputs

Check: CLAUDE.md, README.md, `.tap/tap-audit.md`, `.tap/system-health.md`, `.tap/architecture.md`, recent git log, merged PRs.

### 3. Run Mode

#### Interview (no file)

Walk five sections:

**Section 1 — What we build**: 1-3 sentences: the product + who it's for
**Section 2 — Audience & pain**: Who are the users? What pain? Principle line
**Section 3 — Current focus**: Problem this quarter, insight, success signal
**Section 4 — Bets**: 2-4 bets: what + why it'll work
**Section 5 — Non-goals**: What you're NOT doing + principle why

For Principle lines (sections 2, 5), use coaching:
> A Principle is the underlying belief that shapes decisions.
> Not a goal, feature, or preference. If it stopped being true,
> would you decide differently?

#### Review (file exists, fresh)

Prune-first: read each section → "Still true?" → "Anything new?"

#### Refresh (file exists, stale)

Capture top-line shifts first → then run Review protocol.

### 4. Show Diff

Before writing:
- **Length check**: ≤ 80 lines. If over, identify sections to compress.
- **Duplication check**: Scan CLAUDE.md and `.tap/architecture.md` for overlap.
- **Present diff**: For interview, show full draft. For review/refresh, show unified diff.

Ask: "Write this to `.tap/product.md`? (yes / edit / cancel)"

### 5. Write on Confirm

On yes: write to `.tap/product.md`. Confirm + line count.

## Format Reference

```
# Product Context

## What we build
[1-3 sentences]

## Audience & pain
**Users:** [who, concretely]
**Pain:** [what hurts most]
**Principle:** [belief about audience]

## Current focus
**Problem:** [what you're solving this quarter]
**Insight:** [what showed you this]
**Success signal:** [measurable]

## Bets
- [bet 1]: [what + why]

## Non-goals
[what you're NOT doing]
**Principle:** [why boundary matters]
```

## Handoffs

- First run → recommend `tap-audit` next
- Major shift surfaced → recommend `systems-health` or re-audit

## Boundaries

- Does NOT describe the tech stack (CLAUDE.md's job)
- Does NOT capture architecture decisions (`.tap/architecture.md`'s job)
- Does NOT overwrite without explicit confirmation
- Single file, optimized for agent consumption
