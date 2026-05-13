---
name: design-language
description: "Capture and enforce a product's visual design language --- principles and patterns that make it feel like itself. Two modes: Capture (distill design from Figma URLs, screenshots, or live URLs) and Review (check implementation against docs/design.md). NOT for: generating new UI (-> frontend-ui-engineering), accessibility audits, or token extraction."
trigger-phrases: capture this design, design language, design review, design fidelity, does this match our design, extract design direction, design principles
handoffs: shaping-work (to shape drift into work items), implementation-planning (to plan design fixes), frontend-ui-engineering (to implement UI)
companion-script: scripts/design-language.sh
---

# Design Language

**Companion script:** `scripts/design-language.sh` --- capture design principles, review implementation.
```bash
bash ./scripts/design-language.sh capture "<product>"   # capture design language
bash ./scripts/design-language.sh review "<product>"    # review implementation
```

Capture and enforce a product's visual language --- principles + patterns that make it feel like itself. Two modes, one skill.

- **Capture** --- given an external source (Figma URL, screenshot, live URL), distill novel design decisions and propose a diff to `docs/design.md`.
- **Review** --- given a component or screenshot plus existing `docs/design.md`, check fidelity and produce a structured critique.

**Companion script:** `scripts/design-language.sh`
```bash
bash ./scripts/design-language.sh capture <source>   # capture from (figma/url/screenshot)
bash ./scripts/design-language.sh review <file>       # review component
bash ./scripts/design-language.sh bootstrap           # create initial docs/design.md
bash ./scripts/design-language.sh check "<criterion>" # check observation quality
```

## Step 0: Route the Input

| Input shape | Mode |
|---|---|
| Figma URL | **Capture** (Figma source) |
| Live site URL | **Capture** (live URL) |
| Image file | **Capture** (screenshot) |
| Component path + existing docs/design.md | **Review** |
| Screenshot of own UI + docs/design.md | **Review** |
| External source + no docs/design.md | **Capture (bootstrap)** |

## Mode 1: Capture

### Step 1: Stage the Source

Stage a durable copy. For URLs, capture a screenshot. For local paths, copy to a dated location.

### Step 2: Extract Observations

Extract design observations. Focus on what's novel/product-shaping, not generic truths.

Reference vocabulary:
- **Hierarchy** --- how elements signal importance through size, weight, color, position
- **Density & Rhythm** --- spacing patterns, density of information
- **Motion** --- animation personality, transitions, micro-interactions
- **Chrome** --- UI chrome (navigation, headers, chrome) vs content area
- **Color** --- palette role and usage, not just hex values

### Step 3: Consolidate Before Adding (Anti-inflation)

- Does an existing principle in `docs/design.md` cover this? -> Tighten it, don't add
- Does it contradict? -> Flag in Divergences, don't silently add
- Only add if genuinely novel and uncovered

### Step 4: Propose the Diff

Include: edits to existing entries, new entries (justified), divergences, captures log entry.

Do NOT write to `docs/design.md` directly --- produce the diff; user commits.

## Mode 2: Review

### Step 1: Staleness Guard

If `docs/design.md` is > 8 weeks old, warn before critiquing against stale principles.

### Step 2: Read the Source

Prefer code over screenshots. Code gives truth; vision is unreliable for measurements.

### Step 3: Critique

Walk against: Principles -> Anti-principles -> Functional patterns -> Perceptual patterns -> Heuristics

Every finding must:
- Name the principle/heuristic by number/ID
- Cite exact file:line or element
- State violation in one line
- Propose concrete fix

### Step 4: Report

```
`★ Design View ───────────────────────────────────`
- Mode: [Capture/Review]
- [Lead observation or finding count]
- [Primary risk]
`─────────────────────────────────────────────────`
```

## Boundaries

- Does NOT write to docs/design.md directly --- advisory only
- Does NOT generate new UI (-> frontend-ui-engineering)
- Does NOT audit accessibility
- Does NOT extract or manage design tokens
