---
name: shaping-work
description: 'Shape rough ideas into clear, actionable work definitions --- lighter than full specs, focused on acceptance criteria. Use when someone has an unstructured idea --- feature requests, bug reports,
  Slack threads, customer feedback. NOT for: full specification (-> spec-driven-development), or implementation planning (-> implementation-planning).'
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob
metadata:
  companion-script: scripts/shape-work.sh
  handoffs: implementation-planning (to plan after shaping), product-discovery (to validate before committing)
  trigger-phrases: shape this, scope this, define this work, turn this into a ticket, flesh this out, what should we build, acceptance criteria
  bundle: product
---
# Shaping Work

Shape ambiguous ideas into clear work definitions. Focus on clarity, not process theater.

**Companion script:** `scripts/shape-work.sh`
```bash
bash ./scripts/shape-work.sh shape "<title>" "<desc>"      # feature work item
bash ./scripts/shape-work.sh bug "<title>" "<desc>"        # bug fix item
bash ./scripts/shape-work.sh improve "<title>" "<desc>"     # improvement item
bash ./scripts/shape-work.sh ac "<criterion>"               # check AC quality
```

## Principles

- **No jargon** --- write so anyone can understand
- **Product-focused** --- define *what*, not *how* to build it
- **Right level of detail** --- enough to act on, not a specification
- **Flag unknowns with recommendations** --- surface risks early, always propose a resolution

## Process

1. **Understand the request** --- Read the input. If intent is unclear, ask up to 3 targeted questions, then shape with stated assumptions.
2. **Understand the context** --- If handed off from product-thinker, use their context. Otherwise, read CLAUDE.md or README to understand the product.
3. **Shape the work** --- Write the definition. Pick the variant that fits.
4. **Surface unknowns with recommendations** --- Propose a resolution, list discarded alternatives with reasoning.
5. **Save the document** --- Save to `research/` with date prefix.

## Output Format

Always open with a **Shaped View block**:

```
`★ Shaped View ───────────────────────────────────`
[problem] -> [solution]
  ├─ [key flow or behavior 1]
  ├─ [key flow or behavior 2]
  └─ [key constraint or open question]
`─────────────────────────────────────────────────`
```

Rules:
- One `[problem] -> [solution]` line, then 2-4 tree branches
- Fits in one screen --- if you need to scroll, it's too long
- ASCII tree characters for structure

### Feature work

```
## [Clear, descriptive title]

[1-2 sentence description]

### Acceptance Criteria

- [Observable behavior, not implementation detail]
- [What triggers this feature]
- [What the user sees or experiences]
- [Key states and edge cases]

### Designs

[Link to Figma/designs or N/A]

### Risks & Unknowns

- **[Question or risk]**
  Recommend: [option] --- [why]
  Discarded: [option] ([why not])
```

### Bug fix

```
## Fix: [what's broken]

**Current behavior**: [what happens now]
**Expected behavior**: [what should happen]
**Reproduction**: [steps or conditions]

### Acceptance Criteria

- [The specific broken behavior to fix]
- [Related edge cases]

### Risks & Unknowns

- [questions with recommendations]
```

### Improvement / tech debt

```
## Improve: [what's being improved]

**Current state**: [what exists today]
**Desired state**: [what it should look like]

### Acceptance Criteria

- [Measurable outcomes]

### Risks & Unknowns

- [questions with recommendations]
```

### Acceptance Criteria Rules

These are consumed downstream by planning and QA:
- Each criterion must be **independently testable** (pass/fail without reading code)
- Describe observable behavior, not implementation
- Prefer specifics: concrete inputs, states, outputs
- No vague criteria ("works well", "is fast", "handles edge cases")

## What NOT to Include

- Technical implementation details (DB schemas, API designs, code patterns)
- Time estimates or assigned developers
- Detailed test cases (those come later)

## Examples

**Input**: "We need to show users how many items are in their cart in the header"

```
`★ Shaped View ───────────────────────────────────`
[users can't see cart size] -> [badge on cart icon]
  ├─ numeric badge on all pages
  ├─ hidden when cart is empty
  └─ updates immediately on add/remove
`─────────────────────────────────────────────────`

## Cart item count in header

Display a badge on the cart icon so shoppers can see how many items are in their cart without opening it.

### Acceptance Criteria

- Display a numeric badge on the cart icon in the site header
- Badge shows total quantity of items (not unique products)
- Badge is hidden when cart is empty (not showing "0")
- Count updates immediately when items are added/removed
- Badge is visible on all pages where the header appears

### Risks & Unknowns

- **Should the count persist across sessions for logged-out users?**
  Recommend: Yes, use localStorage --- users expect cart to survive tab close.
  Discarded: Server-side session (adds auth dependency for anonymous users)
- **Max display value for large carts?**
  Recommend: Show "99+" --- standard e-commerce pattern, avoids layout overflow.
  Discarded: Unlimited display (breaks layout at 4+ digits)
```

## Handoffs

- Shaped work that is well-understood -> `implementation-planning` for technical design
- Shaped work with high uncertainty -> `product-discovery` for validation before building

## Boundaries

- Does NOT specify technical implementation (-> `implementation-planning`)
- Does NOT validate ideas (-> `product-discovery`)
- Does NOT produce formal specs (-> `spec-driven-development`)
- Does NOT produce code or tests
