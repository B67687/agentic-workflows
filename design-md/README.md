# DESIGN.md --- Visual Language Specs for AI Agents

A curated collection of `DESIGN.md` files that define how a project should look and feel. Drop one into your project root, and any AI coding agent instantly understands your visual language.

## What is DESIGN.md?

[DESIGN.md](https://stitch.withgoogle.com/docs/design-md/overview/) (from Google Stitch) is the design-system counterpart to `AGENTS.md`:

| File | Who reads it | What it defines |
|------|-------------|-----------------|
| `AGENTS.md` | Coding agents | How to build the project |
| `DESIGN.md` | Design agents | How the project should look and feel |

It's a single Markdown file with YAML frontmatter --- no Figma exports, no JSON schemas, no special tooling. Markdown is the format LLMs read best, so there's nothing to parse or configure. Drop it in your project root and tell your AI: *"build me a page that matches the DESIGN.md."*

## Collection

### Brand Design Systems (External)

For production-ready DESIGN.md files extracted from real brand websites (Vercel, Stripe, Apple, Supabase, Cursor, Linear, and 68+ more), see the canonical collection:

> **[awesome-design-md](https://github.com/VoltAgent/awesome-design-md)** --- 75K+ stars, 73 designs

Copy any of those into your project for instant brand-aligned UI generation.

### Custom Patterns (This Repo)

These DESIGN.md files fill gaps not covered by the canonical collection:

| File | Purpose |
|------|---------|
| [`code-visualization/DESIGN.md`](./code-visualization/DESIGN.md) | Visual language for programming language internals --- AST trees, execution traces, memory layouts, code reading interfaces |
| [`presentation/DESIGN.md`](./presentation/DESIGN.md) | Slide deck design for presentations and school projects --- projection-optimized typography, layout grid, color roles |

## How to Use

1. **Choose a DESIGN.md** that matches the visual style you want
2. **Copy it** into your project root as `DESIGN.md`
3. **Tell your AI agent** to use it --- e.g., *"Build me a landing page that follows DESIGN.md"* or *"Style this component according to DESIGN.md"*
4. **Customize** the tokens (colors, fonts, spacing) to fit your brand

## Format Overview

A DESIGN.md has two parts:

**YAML frontmatter** --- structured design tokens:
```yaml
colors:
  primary: "#0066cc"
  canvas: "#ffffff"
  ink: "#1d1d1f"
typography:
  display-xl:
    fontSize: 48px
    fontWeight: 600
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    rounded: "{rounded.pill}"
```

**Markdown body** --- narrative explanation:
- Overview describing the visual philosophy
- Color roles and usage rules
- Typography hierarchy table
- Component specs with token references
- Layout principles and spacing
- Do's and don'ts
- Responsive behavior guide

Tokens reference each other with `{section.key}` syntax (e.g., `{colors.primary}`, `{typography.display-xl}`), making the file self-referencing and AI-friendly.

## Related

- [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) --- 73 brand DESIGN.md files
- `AGENTS.md` --- How to build and operate this project
- `docs/design-md-pattern.md` --- Format reference and writing guide
- `docs/context-format.md` --- Domain language glossary (CONTEXT.md)
- `skills/frontend-ui-engineering/SKILL.md` --- Build production-quality UI with DESIGN.md input
