---
version: alpha
name: Code Visualization Design
description: An educational visual language for explaining how programming languages work — AST trees, execution traces, memory layouts, control flow graphs, and code reading interfaces. Designed to maximize clarity at projection scale (slides, videos, docs) while remaining readable at screen scale. Inspired by craft conf, typescript book illustrations, and compiler explorer visualizations.

colors:
  # ── Tokens (Lexer / Syntax Highlighting) ──
  token-keyword: "#d73a49"
  token-keyword-dark: "#ff7b89"
  token-string: "#032f62"
  token-string-dark: "#9ecbff"
  token-number: "#005cc5"
  token-number-dark: "#79b8ff"
  token-identifier: "#24292e"
  token-identifier-dark: "#e1e4e8"
  token-function: "#6f42c1"
  token-function-dark: "#b392f0"
  token-type: "#005cc5"
  token-type-dark: "#79b8ff"
  token-operator: "#d73a49"
  token-operator-dark: "#ff7b89"
  token-comment: "#6a737d"
  token-comment-dark: "#959da5"
  token-constant: "#005cc5"
  token-constant-dark: "#79b8ff"
  token-annotation: "#6f42c1"
  token-annotation-dark: "#b392f0"
  token-punctuation: "#24292e"
  token-punctuation-dark: "#e1e4e8"
  token-variable: "#e36209"
  token-variable-dark: "#ffab70"
  token-parameter: "#24292e"
  token-parameter-dark: "#e1e4e8"

  # ── AST Nodes ──
  ast-expression-fill: "#ddf4ff"
  ast-expression-stroke: "#54aeff"
  ast-expression-text: "#0550ae"
  ast-statement-fill: "#dafbe1"
  ast-statement-stroke: "#4ac26b"
  ast-statement-text: "#024c1a"
  ast-declaration-fill: "#f3e8ff"
  ast-declaration-stroke: "#a475f9"
  ast-declaration-text: "#55398a"
  ast-literal-fill: "#fff1e5"
  ast-literal-stroke: "#f0883e"
  ast-literal-text: "#953800"
  ast-type-node-fill: "#ddf4ff"
  ast-type-node-stroke: "#54aeff"
  ast-type-node-text: "#0550ae"
  ast-error-fill: "#ffeef0"
  ast-error-stroke: "#cf222e"
  ast-error-text: "#82071e"

  # ── Execution / Call Stack ──
  exec-stack-frame: "#f6f8fa"
  exec-stack-frame-active: "#ddf4ff"
  exec-stack-frame-border: "#d0d7de"
  exec-arrow-flow: "#54aeff"
  exec-arrow-return: "#4ac26b"
  exec-arrow-error: "#cf222e"
  exec-heap-object: "#fff8c5"
  exec-heap-object-stroke: "#d4a72c"
  exec-heap-pointer: "#6f42c1"
  exec-heap-pointer-line: "#a475f9"

  # ── Control Flow ──
  cfg-block-fill: "#f6f8fa"
  cfg-block-stroke: "#d0d7de"
  cfg-block-text: "#24292e"
  cfg-branch-true: "#4ac26b"
  cfg-branch-false: "#cf222e"
  cfg-loop-back: "#54aeff"
  cfg-edge: "#57606a"

  # ── Type Visualization ──
  type-primitive-fill: "#ddf4ff"
  type-primitive-stroke: "#54aeff"
  type-composite-fill: "#f3e8ff"
  type-composite-stroke: "#a475f9"
  type-generic-fill: "#fff1e5"
  type-generic-stroke: "#f0883e"
  type-constraint-line: "#4ac26b"
  type-error-fill: "#ffeef0"
  type-error-stroke: "#cf222e"

  # ── Surface ──
  canvas-light: "#ffffff"
  canvas-off: "#f6f8fa"
  canvas-dark: "#0d1117"
  canvas-code: "#f6f8fa"
  canvas-code-dark: "#161b22"
  hairline: "#d0d7de"
  hairline-dark: "#30363d"
  ink: "#24292e"
  ink-secondary: "#57606a"
  ink-dark: "#e1e4e8"
  ink-secondary-dark: "#8b949e"
  annotation-bg: "#fff8c5"
  annotation-bg-dark: "#3d3200"
  annotation-text: "#24292e"
  annotation-text-dark: "#e1e4e8"
  highlight-line: "#ddf4ff"
  highlight-line-dark: "#0d1b2e"
  selection-bg: "#54aeff33"
  selection-bg-dark: "#58a6ff33"

typography:
  display-hero:
    fontFamily: "SF Pro Display, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 40px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: -0.8px
  display-section:
    fontFamily: "SF Pro Display, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 28px
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: -0.56px
  display-card:
    fontFamily: "SF Pro Display, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: -0.3px
  body-lg:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 18px
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: 0
  body-md:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: 0
  body-sm:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0
  caption:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.3
    letterSpacing: 0
  button-label:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.0
    letterSpacing: 0
  code-lg:
    fontFamily: "JetBrains Mono, 'Fira Code', 'Cascadia Code', ui-monospace, monospace"
    fontSize: 16px
    fontWeight: 450
    lineHeight: 1.6
    letterSpacing: 0
  code-md:
    fontFamily: "JetBrains Mono, 'Fira Code', 'Cascadia Code', ui-monospace, monospace"
    fontSize: 14px
    fontWeight: 450
    lineHeight: 1.6
    letterSpacing: 0
  code-sm:
    fontFamily: "JetBrains Mono, 'Fira Code', 'Cascadia Code', ui-monospace, monospace"
    fontSize: 12px
    fontWeight: 450
    lineHeight: 1.5
    letterSpacing: 0
  code-annotation:
    fontFamily: "JetBrains Mono, 'Fira Code', 'Cascadia Code', ui-monospace, monospace"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0
  ast-node-label:
    fontFamily: "JetBrains Mono, 'Fira Code', 'Cascadia Code', ui-monospace, monospace"
    fontSize: 11px
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: -0.11px
  graph-label:
    fontFamily: "Inter, system-ui, -apple-system, sans-serif"
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: 0

rounded:
  none: 0px
  sm: 4px
  md: 6px
  lg: 8px
  xl: 12px
  full: 9999px

spacing:
  xxs: 2px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px
  huge: 48px
  section: 64px

components:
  # ── Code Surfaces ──
  code-viewer:
    backgroundColor: "{colors.canvas-code}"
    textColor: "{colors.ink}"
    typography: "{typography.code-md}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg}"
  code-viewer-dark:
    backgroundColor: "{colors.canvas-code-dark}"
    textColor: "{colors.ink-dark}"
    typography: "{typography.code-md}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg}"
  code-line-highlighted:
    backgroundColor: "{colors.highlight-line}"
    borderColor: "{colors.token-keyword}"
    borderWidth: "0 0 0 3px"
    padding: "{spacing.xxs} {spacing.sm}"
  code-line-highlighted-dark:
    backgroundColor: "{colors.highlight-line-dark}"
    borderColor: "{colors.token-keyword-dark}"
    borderWidth: "0 0 0 3px"
    padding: "{spacing.xxs} {spacing.sm}"
  code-annotation-badge:
    backgroundColor: "{colors.annotation-bg}"
    textColor: "{colors.annotation-text}"
    typography: "{typography.code-annotation}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xxs} {spacing.sm}"

  # ── AST Nodes ──
  ast-expression: # Any expression (binary, call, member, etc.)
    backgroundColor: "{colors.ast-expression-fill}"
    borderColor: "{colors.ast-expression-stroke}"
    textColor: "{colors.ast-expression-text}"
    typography: "{typography.ast-node-label}"
    rounded: "{rounded.md}"
    padding: "{spacing.xs} {spacing.sm}"
    shape: "rounded-rect"
  ast-statement: # Any statement (if, while, return, etc.)
    backgroundColor: "{colors.ast-statement-fill}"
    borderColor: "{colors.ast-statement-stroke}"
    textColor: "{colors.ast-statement-text}"
    typography: "{typography.ast-node-label}"
    rounded: "{rounded.none}"
    padding: "{spacing.xs} {spacing.sm}"
    shape: "rect"
  ast-declaration: # Variable/function/class declarations
    backgroundColor: "{colors.ast-declaration-fill}"
    borderColor: "{colors.ast-declaration-stroke}"
    textColor: "{colors.ast-declaration-text}"
    typography: "{typography.ast-node-label}"
    rounded: "{rounded.md}"
    padding: "{spacing.xs} {spacing.sm}"
    shape: "rounded-rect"
  ast-literal: # Literal values (numbers, strings, booleans)
    backgroundColor: "{colors.ast-literal-fill}"
    borderColor: "{colors.ast-literal-stroke}"
    textColor: "{colors.ast-literal-text}"
    typography: "{typography.ast-node-label}"
    rounded: "{rounded.full}"
    padding: "{spacing.xxs} {spacing.sm}"
    shape: "pill"
  ast-type-node: # Type annotations / type nodes
    backgroundColor: "{colors.ast-type-node-fill}"
    borderColor: "{colors.ast-type-node-stroke}"
    textColor: "{colors.ast-type-node-text}"
    typography: "{typography.ast-node-label}"
    rounded: "{rounded.md}"
    padding: "{spacing.xs} {spacing.sm}"
    shape: "rounded-rect"
    borderStyle: "dashed"
  ast-error-node: # Error nodes (parse errors, type errors)
    backgroundColor: "{colors.ast-error-fill}"
    borderColor: "{colors.ast-error-stroke}"
    textColor: "{colors.ast-error-text}"
    typography: "{typography.ast-node-label}"
    rounded: "{rounded.md}"
    padding: "{spacing.xs} {spacing.sm}"
    shape: "rounded-rect"
    borderWidth: 2
  ast-edge-label:
    typography: "{typography.graph-label}"
    textColor: "{colors.ink-secondary}"
    fontSize: 10px

  # ── Execution Visualization ──
  stack-frame:
    backgroundColor: "{colors.exec-stack-frame}"
    borderColor: "{colors.exec-stack-frame-border}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.sm}"
    padding: "{spacing.sm} {spacing.md}"
  stack-frame-active:
    backgroundColor: "{colors.exec-stack-frame-active}"
    borderColor: "{colors.exec-stack-frame-border}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.sm}"
    padding: "{spacing.sm} {spacing.md}"
    borderWidth: 2
  heap-object:
    backgroundColor: "{colors.exec-heap-object}"
    borderColor: "{colors.exec-heap-object-stroke}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm} {spacing.md}"
  heap-pointer-label:
    textColor: "{colors.exec-heap-pointer}"
    typography: "{typography.code-annotation}"

  # ── Control Flow Graph ──
  cfg-block:
    backgroundColor: "{colors.cfg-block-fill}"
    borderColor: "{colors.cfg-block-stroke}"
    textColor: "{colors.cfg-block-text}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm} {spacing.md}"
  cfg-block-entry:
    backgroundColor: "{colors.exec-stack-frame-active}"
    borderColor: "{colors.cfg-block-stroke}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.lg}"
    padding: "{spacing.sm} {spacing.md}"
    borderWidth: 2
  cfg-decision:
    backgroundColor: "{colors.cfg-block-fill}"
    borderColor: "{colors.cfg-block-stroke}"
    textColor: "{colors.cfg-block-text}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.sm}"
    padding: "{spacing.sm} {spacing.md}"
    shape: "diamond"

  # ── Type Visualization ──
  type-primitive:
    backgroundColor: "{colors.type-primitive-fill}"
    borderColor: "{colors.type-primitive-stroke}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.full}"
    padding: "{spacing.xxs} {spacing.sm}"
  type-composite:
    backgroundColor: "{colors.type-composite-fill}"
    borderColor: "{colors.type-composite-stroke}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.xs} {spacing.sm}"
  type-generic:
    backgroundColor: "{colors.type-generic-fill}"
    borderColor: "{colors.type-generic-stroke}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.xs} {spacing.sm}"
  type-error:
    backgroundColor: "{colors.type-error-fill}"
    borderColor: "{colors.type-error-stroke}"
    textColor: "{colors.ink}"
    typography: "{typography.code-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.xs} {spacing.sm}"
    borderWidth: 2

  # ── Annotations & Labels ──
  annotation-callout:
    backgroundColor: "{colors.annotation-bg}"
    textColor: "{colors.annotation-text}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm} {spacing.md}"
    borderColor: "{colors.exec-heap-object-stroke}"
  section-tag:
    backgroundColor: "{colors.hairline}"
    textColor: "{colors.ink-secondary}"
    typography: "{typography.caption}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xxs} {spacing.sm}"

  # ── Navigation ──
  viz-toolbar:
    backgroundColor: "{colors.canvas-off}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.lg}"
    padding: "{spacing.xs} {spacing.sm}"
    height: 40px
  viz-tab:
    backgroundColor: "{colors.canvas-light}"
    textColor: "{colors.ink}"
    typography: "{typography.button-label}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xs} {spacing.sm}"
  viz-tab-active:
    backgroundColor: "{colors.token-type}"
    textColor: "{colors.canvas-light}"
    typography: "{typography.button-label}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xs} {spacing.sm}"
---

## Overview

This design system defines a visual language for **educational code and programming-language visualization** — explaining how compilers, interpreters, type systems, and runtime environments work. Every token, shape, and layout rule is chosen to maximize comprehension at projection scale (lectures, talk slides, video) while remaining readable at screen scale (documentation, blog posts, interactive tools).

The system is built on a **three-layer hierarchy**:

1. **Code Surface** — The annotated source code layer. Syntax-highlighted lines with inline annotations, highlight markers, and callout badges. This is the anchor — every visualization starts from code.
2. **Tree/Graph Layer** — AST trees, control flow graphs, type constraint graphs. Structural diagrams that sit beside (or below) the code surface, connected by edge lines and node references.
3. **Runtime Layer** — Call stacks, heap layouts, execution traces. Temporal or memory diagrams that show what happens *when* code runs.

Each layer has its own color logic and shape grammar, but they share a unified typography system (JetBrains Mono for code/nodes, Inter for labels/body) and spacing grid.

**Key Characteristics:**
- Dual-theme: light (code readability, docs) and dark (presentation, video recording) — every token has a `-dark` variant
- Token-type syntax highlighting follows the GitHub Primer color system — recognizable to any developer
- Shape grammar maps to node semantics: ellipses for expressions, rectangles for statements, diamonds for decisions, pills for literals
- Edge lines use arrow-terminated paths with semantic colors (blue for flow, green for true/return, red for error/false)
- Code lines connect to AST nodes via subtle dashed reference lines — the viewer always knows *which code produced which tree*
- Annotation-first: every diagram should have brief natural-language callouts explaining *why*, not just *what*

## Colors

### Token Colors (Syntax Highlighting)

The syntax highlighting system follows the GitHub Primer Dark/Light palette for developer familiarity:

| Token Role | Light | Dark | Used For |
|---|---|---|---|
| Keyword | `{colors.token-keyword}` `#d73a49` | `{colors.token-keyword-dark}` `#ff7b89` | `if`, `while`, `return`, `let`, `class`, `import` |
| String | `{colors.token-string}` `#032f62` | `{colors.token-string-dark}` `#9ecbff` | String and template literals |
| Number | `{colors.token-number}` `#005cc5` | `{colors.token-number-dark}` `#79b8ff` | Numeric literals |
| Identifier | `{colors.token-identifier}` `#24292e` | `{colors.token-identifier-dark}` `#e1e4e8` | Variable names, function names |
| Function | `{colors.token-function}` `#6f42c1` | `{colors.token-function-dark}` `#b392f0` | Function calls, method names |
| Type | `{colors.token-type}` `#005cc5` | `{colors.token-type-dark}` `#79b8ff` | Type annotations, class names |
| Operator | `{colors.token-operator}` `#d73a49` | `{colors.token-operator-dark}` `#ff7b89` | `+`, `-`, `*`, `=>`, `==` |
| Comment | `{colors.token-comment}` `#6a737d` | `{colors.token-comment-dark}` `#959da5` | Comments and docstrings |
| Constant | `{colors.token-constant}` `#005cc5` | `{colors.token-constant-dark}` `#79b8ff` | `true`, `false`, `null`, `this` |
| Annotation | `{colors.token-annotation}` `#6f42c1` | `{colors.token-annotation-dark}` `#b392f0` | Decorators, attributes |
| Punctuation | `{colors.token-punctuation}` `#24292e` | `{colors.token-punctuation-dark}` `#e1e4e8` | Braces, parens, semicolons, commas |
| Variable | `{colors.token-variable}` `#e36209` | `{colors.token-variable-dark}` `#ffab70` | Mutable variable declarations |
| Parameter | `{colors.token-parameter}` `#24292e` | `{colors.token-parameter-dark}` `#e1e4e8` | Function parameters |

### AST Node Colors

Each AST node type has a distinct color role — the fill color is the primary recognition cue, supported by the shape grammar:

| Role | Fill | Stroke | Text | Shape |
|---|---|---|---|---|
| Expression | `{colors.ast-expression-fill}` `#ddf4ff` | `{colors.ast-expression-stroke}` `#54aeff` | `#0550ae` | Rounded rect |
| Statement | `{colors.ast-statement-fill}` `#dafbe1` | `{colors.ast-statement-stroke}` `#4ac26b` | `#024c1a` | Rect (sharp) |
| Declaration | `{colors.ast-declaration-fill}` `#f3e8ff` | `{colors.ast-declaration-stroke}` `#a475f9` | `#55398a` | Rounded rect |
| Literal | `{colors.ast-literal-fill}` `#fff1e5` | `{colors.ast-literal-stroke}` `#f0883e` | `#953800` | Pill |
| Type Node | `{colors.ast-type-node-fill}` `#ddf4ff` | `{colors.ast-type-node-stroke}` `#54aeff` | `#0550ae` | Rounded rect (dashed) |
| Error Node | `{colors.ast-error-fill}` `#ffeef0` | `{colors.ast-error-stroke}` `#cf222e` | `#82071e` | Rounded rect (2px) |

### Execution & Memory Colors

| Role | Color | Used For |
|---|---|---|
| Stack frame | `{colors.exec-stack-frame}` `#f6f8fa` | Inactive call stack frames |
| Active frame | `{colors.exec-stack-frame-active}` `#ddf4ff` | Currently executing frame |
| Flow arrow | `{colors.exec-arrow-flow}` `#54aeff` | Execution flow direction |
| Return arrow | `{colors.exec-arrow-return}` `#4ac26b` | Return value flow |
| Error arrow | `{colors.exec-arrow-error}` `#cf222e` | Error/exception propagation |
| Heap object | `{colors.exec-heap-object}` `#fff8c5` | Heap-allocated objects |
| Pointer label | `{colors.exec-heap-pointer}` `#6f42c1` | Reference/pointer labels on the stack |

### Surface Colors

| Token | Light | Dark | Used For |
|---|---|---|---|
| Canvas | `{colors.canvas-light}` `#ffffff` | `{colors.canvas-dark}` `#0d1117` | Page background |
| Canvas Code | `{colors.canvas-code}` `#f6f8fa` | `{colors.canvas-code-dark}` `#161b22` | Code block background |
| Ink | `{colors.ink}` `#24292e` | `{colors.ink-dark}` `#e1e4e8` | Primary text |
| Hairline | `{colors.hairline}` `#d0d7de` | `{colors.hairline-dark}` `#30363d` | Borders, dividers |
| Highlight | `{colors.highlight-line}` `#ddf4ff` | `{colors.highlight-line-dark}` `#0d1b2e` | Active/highlighted line |

## Typography

### Font Family

Two faces carry the system:

1. **JetBrains Mono** (or Fira Code / Cascadia Code) — all code surfaces, AST node labels, inline snippets, stack frames, type labels. Weight 450 (the "Retina" weight) provides excellent readability at small sizes without being too heavy. Ligatures enabled for presentation contexts, disabled for accuracy checking.
2. **Inter** (or SF Pro) — all body text, section headings, annotations, toolbar labels, edge labels. The clean humanist sans pairs well with the mono face while remaining highly readable at projection scale.

### Hierarchy

| Token | Size | Weight | Line Ht | Use |
|---|---|---|---|---|
| `{typography.display-hero}` | 40px | 600 | 1.2 | Visualization title / slide headline |
| `{typography.display-section}` | 28px | 600 | 1.25 | Section header within a visualization |
| `{typography.display-card}` | 20px | 600 | 1.3 | Card heading, diagram title |
| `{typography.body-lg}` | 18px | 400 | 1.5 | Body text, annotation paragraphs |
| `{typography.body-md}` | 15px | 400 | 1.5 | Secondary body, toolbar labels |
| `{typography.body-sm}` | 13px | 400 | 1.4 | Callout text, annotation body |
| `{typography.caption}` | 12px | 400 | 1.3 | Captions, section tags |
| `{typography.button-label}` | 14px | 500 | 1.0 | Tab and button labels |
| `{typography.code-lg}` | 16px | 450 | 1.6 | Primary code view (projection) |
| `{typography.code-md}` | 14px | 450 | 1.6 | Secondary code view (screen) |
| `{typography.code-sm}` | 12px | 450 | 1.5 | Stack frames, type nodes, inline code |
| `{typography.code-annotation}` | 12px | 400 | 1.4 | Inline code annotations & line numbers |
| `{typography.ast-node-label}` | 11px | 500 | 1.2 | Labels inside AST nodes |
| `{typography.graph-label}` | 12px | 500 | 1.2 | Edge labels, branch labels, arrow labels |

### Principles
- **Code at 450 weight, body at 400.** The mono face needs slightly more weight than body to match optical density.
- **Code-lg (16px) for projection.** When rendering code for a talk slide or lecture video, 16px is the minimum readable size. For screen, 14px is the default.
- **AST labels at 11px.** Nodes must be compact to keep trees readable. 11px with 500 weight maintains legibility.
- **Line height 1.6 for code.** Tighter than markdown's 1.7+ but loose enough for inline annotations between lines.

### Note on Font Substitutes
JetBrains Mono is open-source (SIL OFL). If unavailable: **Fira Code** or **Cascadia Code** at weight 450. For body: **Inter** (Google Fonts, variable) is the canonical substitute — weights 400/500/600 map directly.

## Layout

### Visualization Layout Patterns

The system supports four canonical layout modes:

**1. Side-by-Side (Code + Diagram)**
```
┌─────────────────┬─────────────────────────┐
│                 │                         │
│   Code Viewer   │   AST / CFG / Type      │
│   (40% width)   │   Diagram (60% width)   │
│                 │                         │
└─────────────────┴─────────────────────────┘
```
Code on the left, diagram on the right. Lines in the code viewer that have corresponding diagram nodes are highlighted. Dashed reference lines connect code ranges to diagram nodes.

**2. Stacked (Code above, Diagram below)**
```
┌───────────────────────────────────────────┐
│                 Code Viewer               │
├───────────────────────────────────────────┤
│           AST / Execution Trace           │
└───────────────────────────────────────────┘
```
Full-width code on top, full-width diagram below. Used when the diagram needs horizontal space for trees or execution traces.

**3. Annotation (Code + Embedded Callouts)**
```
┌───────────────────────────────────────────┐
│  Code Viewer with inline annotations      │
│                                          │
│  ┌─ Annotation callout ─────────────────┐ │
│  │  "This is what happens..."           │ │
│  └──────────────────────────────────────┘ │
│                                          │
│  → Arrow pointing to the relevant line    │
└───────────────────────────────────────────┘
```
Code fills the viewport with numbered lines. Annotations are positioned to the right (or below) as callout cards, connected by arrow lines to specific line ranges.

**4. Full-Screen Diagram (AST / CFG / Memory)**
```
┌───────────────────────────────────────────┐
│  ┌───┐                                   │
│  │ S │───┐                               │
│  └───┘   │   ┌───┐                       │
│           ├──→│ E │                       │
│  ┌───┐   │   └───┘                       │
│  │ S │───┘                               │
│  └───┘                                   │
└───────────────────────────────────────────┘
```
The diagram fills the full canvas. Used for complex AST trees, large CFGs, or memory snapshots. A compact code mini-viewer may sit in the corner.

### Spacing System
- **Base unit:** 4px. Every layout value is a multiple of 4.
- **Tokens:** `{spacing.xxs}` 2px (fine node padding) · `{spacing.xs}` 4px · `{spacing.sm}` 8px · `{spacing.md}` 12px · `{spacing.lg}` 16px · `{spacing.xl}` 24px · `{spacing.xxl}` 32px · `{spacing.huge}` 48px · `{spacing.section}` 64px.
- **Code line spacing:** The 1.6 line-height on `{typography.code-md}` (14px) produces ~22.4px per line. Annotation callouts align to this rhythm.
- **AST tree gap:** `{spacing.md}` 12px between sibling nodes vertically, `{spacing.sm}` 8px horizontally.
- **Edge-to-node margin:** `{spacing.sm}` 8px minimum from edge line to nearest node boundary.

### Grid
- **Code viewer gutter:** 32px left padding for line numbers (rendered in `{typography.code-sm}` at reduced opacity).
- **Diagram container:** Flexible width, depends on layout mode. No max-width constraint (trees need room to breathe).
- **Node grid:** AST nodes in a tree layout follow a top-down alternating grid — parent centered above children, children evenly spaced.

### Whitespace Philosophy
Code visualizations are information-dense by nature. Whitespace is used to **separate visual groups** (AST layers, stack frames, CFG blocks), not to decorate. Internal padding inside nodes is tight (`{spacing.xs}` 4px–`{spacing.sm}` 8px) so the tree remains compact enough to scan.

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| 0 — Flat | No shadow, 1px hairline border | Code viewer, surface elements |
| 1 — Card | `0 1px 3px rgba(0,0,0,0.08)` | Annotation callouts, stack frames, node cards |
| 2 — Popup | `0 4px 12px rgba(0,0,0,0.12)` | Active frame, hovered node, tooltip |
| 3 — Modal | `0 8px 24px rgba(0,0,0,0.16)` | Detail panel, code inspection popup |

### Depth Philosophy
The visualization system is intentionally **flat** — AST trees and execution traces have inherent visual hierarchy through their structure. Shadows are used sparingly to lift interactive elements (hovered nodes, annotation callouts) above the static surface. Code viewers have no shadow (they're the ground truth layer).

## Shapes & Node Grammar

The shape grammar is the **primary semantic signal** for AST visualization. Every node type has a fixed shape:

| Shape | Node Type | Example |
|---|---|---|
| **Rounded rectangle** (`{rounded.md}` 6px) | Expression, Declaration, Type Node | BinaryExpression, VariableDeclaration |
| **Sharp rectangle** (`{rounded.none}` 0px) | Statement | IfStatement, WhileStatement, ReturnStatement |
| **Pill** (`{rounded.full}`) | Literal | NumberLiteral, StringLiteral, BooleanLiteral |
| **Diamond** (`shape: diamond`) | Decision node (CFG) | Branch condition |
| **Dashed border** | Abstract / inferred node | Type variable, generic parameter |
| **2px solid border** | Error / problem node | Parse error, type error |

### Edge Styles

| Edge Type | Style | Color | Arrow | Use |
|---|---|---|---|---|
| Parent-child | Solid | `{colors.hairline}` | → | AST tree edges |
| Execution flow | Solid | `{colors.exec-arrow-flow}` | → | Sequential execution |
| Branch-true | Solid | `{colors.cfg-branch-true}` | → | True branch in CFG |
| Branch-false | Dashed | `{colors.cfg-branch-false}` | → | False branch in CFG |
| Loop back | Solid | `{colors.cfg-loop-back}` | ↻ | Loop back edge in CFG |
| Return | Solid | `{colors.exec-arrow-return}` | → (hollow) | Return value flow |
| Error | Solid (2px) | `{colors.exec-arrow-error}` | → | Exception/error propagation |
| Reference | Dashed | `{colors.hairline}` | none | Code line → AST node reference |
| Pointer | Solid | `{colors.exec-heap-pointer-line}` | → (open) | Stack → heap reference |

## Components

### Code Viewer

**`code-viewer`** — The primary code display surface. Light background with syntax highlighting.
- Background `{colors.canvas-code}`, text in `{colors.ink}` with token-level color highlighting.
- Each line rendered in `{typography.code-md}` (14px). Line numbers in `{typography.code-sm}` aligned left in gutter.
- Highlighted lines use `code-line-highlighted` — left border accent in the token color of the highlighted element.
- Code selection uses `{colors.selection-bg}`.

**`code-viewer-dark`** — Dark variant for presentations and video.
- Same structure, inverted colors. Background `{colors.canvas-code-dark}`, text `{colors.ink-dark}`.

**`code-line-highlighted`** — A line in the code viewer that corresponds to a diagram element.
- 3px left border in `{colors.token-keyword}`, background `{colors.highlight-line}`. Used to connect code to AST nodes.

### AST Nodes

**`ast-expression`** — Expression nodes (BinaryExpression, CallExpression, MemberExpression, etc.)
- Fill `{colors.ast-expression-fill}`, stroke `{colors.ast-expression-stroke}`, rounded rect shape.
- Label in `{typography.ast-node-label}` (11px mono 500).
- Children connected below via solid hairline edges.
- Semantic hint: expressions evaluate to values — the rounded shape signals "produces a value."

**`ast-statement`** — Statement nodes (IfStatement, WhileStatement, ReturnStatement, etc.)
- Fill `{colors.ast-statement-fill}`, stroke `{colors.ast-statement-stroke}`, sharp rect shape.
- Sharp corners signal "performs an action" vs "produces a value."

**`ast-declaration`** — Declaration nodes (VariableDeclaration, FunctionDeclaration, ClassDeclaration)
- Fill `{colors.ast-declaration-fill}`, stroke `{colors.ast-declaration-stroke}`, rounded rect.

**`ast-literal`** — Literal value nodes (NumberLiteral, StringLiteral, BooleanLiteral)
- Fill `{colors.ast-literal-fill}`, stroke `{colors.ast-literal-stroke}`, pill shape.
- Pill shape distinguishes literals from all other node types at a glance.

### Execution Visualization

**`stack-frame`** — A call stack frame in the execution trace.
- Background `{colors.exec-stack-frame}`, 1px hairline border, `{typography.code-sm}` inside.
- Shows: function name, arguments, return address (optional).
- Stack grows downward. The active frame (`stack-frame-active`) gets a blue accent background + 2px border.

**`heap-object`** — A heap-allocated object in memory diagrams.
- Background `{colors.exec-heap-object}`, border `{colors.exec-heap-object-stroke}`, rounded md.
- Shows: type name, field-value pairs in `{typography.code-sm}`.
- Connected to stack frames via pointer arrows.

### Control Flow Graph

**`cfg-block`** — A basic block in the control flow graph.
- Background `{colors.cfg-block-fill}`, border `{colors.cfg-block-stroke}`, rounded md.
- Contains: one or more statements (non-branching), rendered in `{typography.code-sm}`.
- Entry block (`cfg-block-entry`) has a 2px border and sits at the top.

**`cfg-decision`** — A branch decision node (diamond shape).
- Diamond shape distinguishes decisions from regular blocks.
- Two outgoing edges: true (green solid) and false (red dashed).

### Type Visualization

**`type-primitive`** — Primitive type nodes (number, string, boolean, void).
- Pill shape, light blue fill. Compact — just the type name.

**`type-composite`** — Composite type nodes (object types, structs, arrays).
- Rounded rect, purple fill. Shows fields/members inside.

**`type-generic`** — Generic type parameters/variables.
- Rounded rect, orange fill, label shows the generic name (T, K, V, etc.).
- Dashed border to signal "abstract / not yet resolved."

**`type-error`** — Type error nodes.
- Red fill, 2px red border. Used to highlight type mismatches in type-checking visualizations.

### Annotations

**`annotation-callout`** — A natural-language explanation card connected to a code line or diagram node.
- Background `{colors.annotation-bg}`, text `{colors.annotation-text}`, border `{colors.exec-heap-object-stroke}`.
- Connected to the target via a dashed reference line.
- Content: brief explanation (1-3 sentences) in `{typography.body-sm}`.
- Positioned to the right of the code viewer in side-by-side mode, or floating near the relevant node in diagram mode.

**`code-annotation-badge`** — An inline badge inside a code line.
- Background `{colors.annotation-bg}`, `{typography.code-annotation}` inside.
- Used to label specific tokens or expressions with short notes ("this is the receiver", "type inferred as number").

### Toolbar & Tabs

**`viz-toolbar`** — The visualization mode switcher.
- Background `{colors.canvas-off}`, `{typography.body-sm}`.
- Contains: viz-tab items for switching between AST / CFG / Execution / Type views, plus controls for step-through (in execution traces).

**`viz-tab`** / **`viz-tab-active`** — Individual tab in the toolbar.
- Inactive: white background, `{colors.ink}` text.
- Active: filled with `{colors.token-type}`, white text. The active tab color matches the primary blue of the system.

## Do's and Don'ts

### Do
- Connect every diagram element back to a specific code range — the viewer should always know *what code produced this node*.
- Use the shape grammar consistently: expressions are rounded, statements are sharp, literals are pills, decisions are diamonds.
- Include annotation callouts with every visualization — code diagrams without explanations teach only *what*, not *why*.
- Use the dark theme for projection (talks, videos, slides) and the light theme for documentation (docs, blogs, READMEs).
- Render code at `{typography.code-lg}` (16px) for any visualization meant for projection. At screen-only, `{typography.code-md}` (14px) is fine.
- Keep AST trees balanced — parent centered above children, children evenly spaced. Unbalanced trees are hard to read.
- Use branch labels on CFG edges: "true" / "false" on decision branches, "next" on sequential edges.

### Don't
- Don't mix shapes within the same semantic category — all expressions must use the same shape.
- Don't render AST trees with more than 5 depth levels visible at once — deeper trees should be collapsible or paginated.
- Don't use the code viewer background for diagram elements or vice versa — the code surface and diagram surface are visually distinct.
- Don't use the annotation callout colors for nodes — annotations have a yellow tint that should not appear in the AST layer.
- Don't render more than one visualization mode at full opacity — the active mode (AST, CFG, or Execution) is fully opaque; inactive modes can ghost at 30% opacity in the background.
- Don't use solid reference lines for code-to-node connections — those are always dashed to distinguish them from tree edges.
- Don't use gradient fills on any node — nodes must have flat fills for clarity at small sizes.

## Responsive Behavior

### Breakpoints

| Name | Width | Key Changes |
|---|---|---|
| Desktop | ≥ 1024px | Side-by-side layout (code 40%, diagram 60%). Full feature set. |
| Tablet | 768–1023px | Stacked layout (code above, diagram below). Toolbar collapses to icon-only. |
| Mobile | < 768px | Single-panel — toggle between code and diagram views via tabs. Nodes shrink to minimum padding. |

### Interactive Elements
- Node hover: subtle Level 2 shadow + 0.5px scale increase. Connected nodes in the tree highlight simultaneously.
- Code line hover: the highlighted line's left border animates in. Corresponding AST node pulses.
- Step-through (execution traces): numbered step indicators. Previous-step frames dim to `0.6` opacity.

### Collapsing Strategy
- Deep AST trees: children beyond depth 3 are collapsible. A "+N" badge shows the count of collapsed children.
- Long stack traces: only the top 5 frames shown by default; "Show N more" expands below.
- Wide CFGs: branches beyond 3 siblings scroll horizontally with a persistent "fit to view" toggle.

## Iteration Guide

1. Start with the **code surface** — syntax-highlighted code with correct token colors is the anchor.
2. Add the **AST layer** — parse the code and render the tree using the shape grammar. Verify each node type gets the correct shape.
3. Add **annotations** — explain the interesting nodes. "This is where the type is inferred," "This branch is always taken."
4. If explaining execution: add the **call stack and heap** visualization beneath the code.
5. If explaining control flow: render the **CFG** from the AST, with true/false labels on branches.
6. If explaining types: switch to the **type visualization** layer showing type constraints and unification.
7. Verify every diagram element has a reference back to the code. If something is floating without a code connection, it's not educational.

## Known Gaps

- Multi-file visualization (cross-module references, imports, namespace resolution) is not tokenized — the current system is single-file/single-scope.
- Animation and transition timing tokens are not defined — step-through execution relies on numbered frames rather than interpolated animation.
- Concurrent execution visualization (threads, async/await) needs additional token colors for distinct thread traces.
- Error recovery visualization (how the parser recovers from errors) needs additional node types for error-recovery tokens.
