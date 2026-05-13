# DESIGN.md Pattern --- Visual Language Specification

A `DESIGN.md` is a Markdown file that defines how a project should look and feel. It lives at the project root alongside `AGENTS.md` and serves as the canonical reference for visual design --- readable by humans and AI agents alike.

## Why

Without a design spec, AI agents default to generic UI patterns: purple/indigo gradients, rounded everything, and stock card grids. A `DESIGN.md` tells the agent exactly what colors, typography, components, and layout rules to use, producing consistent, brand-aligned output in one shot.

```
Without DESIGN.md:  "Build me a landing page" -> generic AI aesthetic
With DESIGN.md:     "Build me a landing page that matches DESIGN.md" -> brand-aligned UI
```

## When to Create

Create `DESIGN.md` when:
- You start a new project that has a UI
- You find the AI generating inconsistent visual output
- You want to reuse a visual style across multiple projects
- You're building an app, presentation, or visualization
- You want to define a custom visual language (e.g., for code visualization)

## Format

A DESIGN.md has two parts: **YAML frontmatter** (structured tokens) and **Markdown body** (narrative).

### YAML Frontmatter --- Design Tokens

```yaml
---
version: alpha
name: My Project Design
description: One-line summary of the visual language.

colors:
  primary: "#0066cc"       # Primary interactive color
  ink: "#1d1d1f"           # Body text
  canvas: "#ffffff"         # Page background
  # ... semantic color roles

typography:
  display-xl:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 48px
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: -1.44px
  # ... full type hierarchy

rounded:
  sm: 6px
  md: 8px
  lg: 12px
  pill: 9999px

spacing:
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  # ... spacing scale

components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button-md}"
    rounded: "{rounded.pill}"
    padding: 8px 16px
  # ... component specifications
---
```

### Token Reference Syntax

Tokens reference each other using `{section.key}` syntax:

| Expression | Resolves to |
|-----------|-------------|
| `{colors.primary}` | `#0066cc` |
| `{typography.display-xl}` | 48px/600 font specs |
| `{rounded.pill}` | `9999px` |
| `{spacing.lg}` | `24px` |
| `{component.button-primary}` | Button spec block |

This makes the file self-referencing and AI-friendly --- the agent resolves tokens when generating code.

### Markdown Body --- Narrative

After the frontmatter, provide rich markdown that an AI agent can read for context:

**Required sections:**

1. **Overview** --- Visual philosophy, mood, design approach, key characteristics
2. **Colors** --- Brand colors, surface colors, text colors, semantic colors. For each: hex value, role description, usage rules
3. **Typography** --- Font families, hierarchy table (token, size, weight, line-height, letter-spacing, use-case), font principles
4. **Layout** --- Spacing system, grid, container widths, whitespace philosophy
5. **Elevation & Depth** --- Shadow levels, surface hierarchy, decorative depth
6. **Shapes** --- Border radius scale, image geometry
7. **Components** --- Buttons, cards, inputs, navigation, signature components. Each with: appearance, states, token references
8. **Do's and Don'ts** --- Design guardrails and anti-patterns
9. **Responsive Behavior** --- Breakpoints, collapsing strategy, touch targets

**Optional sections:**
- Iteration Guide --- how to extend the design system
- Known Gaps --- what wasn't captured

## Rules

- **Tokenize everything.** Every color, font size, spacing value, border radius should be a token in the frontmatter. Never inline raw values in the narrative.
- **Reference tokens in narrative.** Use `{colors.primary}` in body text, never `#0066cc`. This teaches the agent to use the token system.
- **Be opinionated.** The Do's and Don'ts section is where the system earns its value. Explicit forbid anti-patterns.
- **Describe states.** For components, document default, pressed/active, and any other state. Skip hover (agents rarely handle it correctly).
- **Show, don't just tell.** A typography hierarchy table communicates faster than paragraphs.
- **Name components clearly.** `button-primary`, `card-feature`, `nav-bar`. These become the names the agent uses when generating code.
- **Stay project-scoped.** A DESIGN.md for a SaaS dashboard is different from one for a slide deck. Don't try to be universal.

## Maintenance

- **Update tokens when the brand evolves.** If the primary color shifts, update the token.
- **Add components as the UI grows.** New patterns get new component specs.
- **Review after major design changes.** If the visual philosophy shifts, rewrite the overview.
- **Keep token count reasonable.** ~15-25 color tokens, ~10-15 typography tokens, ~10-20 components is the sweet spot. More than that and the agent loses signal.

## DESIGN.md vs Other Project Docs

| Artifact | Purpose | When |
|----------|---------|------|
| **AGENTS.md** | How to build and operate | Project setup |
| **DESIGN.md** | How the project looks and feels | When visual design matters |
| **CONTEXT.md** | What domain terms mean | When multiple agents/humans work on the same codebase |
| **ADR** | Why decisions were made | When a hard-to-reverse decision crystallizes |

## Integration with Skills

The DESIGN.md feeds into:

- **frontend-ui-engineering**: Before building UI, check if DESIGN.md exists. If so, use it as the design reference. If not, ask the user or generate one.
- **spec-driven-development**: When specifying a new feature, reference DESIGN.md tokens in the spec.
- **incremental-implementation**: Each UI component implementation references DESIGN.md component specs.

## Examples

See `design-md/` in this repo:
- `design-md/code-visualization/DESIGN.md` --- Programming language visualization design
- `design-md/presentation/DESIGN.md` --- Slide deck design for presentations

External collection: [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) --- 73 brand design systems.

## Related

- `AGENTS.md` --- Project operating contract
- `skills/frontend-ui-engineering/SKILL.md` --- UI building skill
- `design-md/README.md` --- Collection overview
