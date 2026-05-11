---
version: alpha
name: Presentation Design
description: A clean, professional slide deck design language optimized for educational presentations, project pitches, and school projects. Built on a white canvas with a single accent color, generous projection-optimized typography, and a consistent four-slot layout system (title, content, code, diagram). Inspired by the clean readability of scientific talks and the visual clarity of modern pitch decks.

colors:
  primary: "#0066cc"
  primary-deep: "#0052a3"
  primary-soft: "#4d94ff"
  primary-bg-subtle: "#e8f0fe"
  ink: "#1d1d1f"
  ink-secondary: "#4a4a4a"
  ink-mute: "#8e8e93"
  ink-inverse: "#ffffff"
  canvas: "#ffffff"
  canvas-soft: "#f5f5f7"
  canvas-dark: "#1d1d1f"
  canvas-dark-soft: "#2c2c2e"
  accent-green: "#34c759"
  accent-orange: "#ff9500"
  accent-red: "#ff3b30"
  accent-purple: "#af52de"
  hairline: "#e5e5ea"
  hairline-strong: "#c7c7cc"
  link: "#0066cc"
  highlight-bg: "#fff3cd"
  highlight-text: "#856404"

  # ── Slide-specific ──
  title-slide-bg: "{colors.primary}"
  title-slide-text: "{colors.ink-inverse}"
  section-divider-bg: "{colors.canvas-dark}"
  section-divider-text: "{colors.ink-inverse}"
  code-bg: "#1e1e1e"
  code-text: "#d4d4d4"
  code-line-highlight: "#264f78"
  quote-bg: "{colors.canvas-soft}"
  quote-border: "{colors.primary}"
  table-header-bg: "{colors.canvas-soft}"
  table-row-alt: "{colors.canvas-soft}"
  table-border: "{colors.hairline}"

typography:
  slide-title:
    fontFamily: "SF Pro Display, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 40px
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: -0.8px
  slide-subtitle:
    fontFamily: "SF Pro Display, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 28px
    fontWeight: 400
    lineHeight: 1.25
    letterSpacing: 0
  slide-section:
    fontFamily: "SF Pro Display, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 48px
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: -0.96px
  slide-body:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 24px
    fontWeight: 400
    lineHeight: 1.45
    letterSpacing: 0
  slide-body-strong:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 24px
    fontWeight: 600
    lineHeight: 1.45
    letterSpacing: 0
  slide-body-sm:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 20px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0
  slide-caption:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.3
    letterSpacing: 0
    textColor: "{colors.ink-mute}"
  slide-bullet:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 22px
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: 0
  slide-bullet-strong:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.5
    letterSpacing: 0
  slide-code:
    fontFamily: "JetBrains Mono, 'Fira Code', 'Cascadia Code', ui-monospace, monospace"
    fontSize: 18px
    fontWeight: 450
    lineHeight: 1.6
    letterSpacing: 0
  slide-code-sm:
    fontFamily: "JetBrains Mono, 'Fira Code', 'Cascadia Code', ui-monospace, monospace"
    fontSize: 15px
    fontWeight: 450
    lineHeight: 1.5
    letterSpacing: 0
  slide-footer:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.2
    letterSpacing: 0
    textColor: "{colors.ink-mute}"
  slide-number:
    fontFamily: "SF Pro Text, Inter, system-ui, -apple-system, sans-serif"
    fontSize: 11px
    fontWeight: 500
    lineHeight: 1.0
    letterSpacing: 0
    textColor: "{colors.ink-mute}"

rounded:
  none: 0px
  sm: 4px
  md: 8px
  lg: 12px
  xl: 16px
  pill: 9999px

spacing:
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 40px
  huge: 48px
  section: 64px
  slide-margin: 48px

components:
  # ── Slide Types ──
  title-slide:
    backgroundColor: "{colors.title-slide-bg}"
    textColor: "{colors.title-slide-text}"
    padding: "{spacing.section} {spacing.slide-margin}"
    height: "100%"
    layout: "center"
  section-slide:
    backgroundColor: "{colors.section-divider-bg}"
    textColor: "{colors.section-divider-text}"
    padding: "{spacing.section} {spacing.slide-margin}"
    height: "100%"
    layout: "center"
  content-slide:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    padding: "{spacing.slide-margin}"
    height: "100%"
  content-slide-dark:
    backgroundColor: "{colors.canvas-dark}"
    textColor: "{colors.ink-inverse}"
    padding: "{spacing.slide-margin}"
    height: "100%"

  # ── Slide Header ──
  slide-header-bar:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    borderBottom: "1px solid {colors.hairline}"
    padding: "{spacing.md} {spacing.slide-margin}"
    height: 48px
  slide-title-area:
    padding: "{spacing.lg} {spacing.slide-margin} {spacing.sm}"
  slide-body-area:
    padding: "{spacing.sm} {spacing.slide-margin} {spacing.slide-margin}"

  # ── Title Slide Elements ──
  title-main:
    typography: "{typography.slide-title}"
    padding: "0 0 {spacing.sm} 0"
  title-subtitle:
    typography: "{typography.slide-subtitle}"
    padding: "0 0 {spacing.lg} 0"
    opacity: 0.85
  title-meta:
    typography: "{typography.slide-footer}"
    padding: "{spacing.xl} 0 0 0"
    opacity: 0.7

  # ── Content Elements ──
  body-text:
    typography: "{typography.slide-body}"
    margin: "0 0 {spacing.md} 0"
  body-text-sm:
    typography: "{typography.slide-body-sm}"
    margin: "0 0 {spacing.md} 0"
  bullet-list:
    typography: "{typography.slide-bullet}"
    margin: "0 0 {spacing.sm} 0"
    bulletColor: "{colors.primary}"
  numbered-list:
    typography: "{typography.slide-bullet}"
    margin: "0 0 {spacing.sm} 0"
    numberColor: "{colors.ink-secondary}"

  # ── Code ──
  code-block-slide:
    backgroundColor: "{colors.code-bg}"
    textColor: "{colors.code-text}"
    typography: "{typography.slide-code}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg} {spacing.xl}"
  code-block-compact:
    backgroundColor: "{colors.code-bg}"
    textColor: "{colors.code-text}"
    typography: "{typography.slide-code-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.md} {spacing.lg}"
  code-line-highlight:
    backgroundColor: "{colors.code-line-highlight}"
    borderLeft: "3px solid {colors.primary}"
    padding: "{spacing.xxs} {spacing.sm}"

  # ── Cards ──
  card-feature:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    typography: "{typography.slide-body-sm}"
    rounded: "{rounded.lg}"
    padding: "{spacing.xl}"
    shadow: "0 2px 8px rgba(0,0,0,0.06)"
  card-feature-accent:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    borderColor: "{colors.primary}"
    borderWidth: 2
    typography: "{typography.slide-body-sm}"
    rounded: "{rounded.lg}"
    padding: "{spacing.xl}"
    shadow: "0 2px 8px rgba(0,0,0,0.06)"
  card-stat:
    backgroundColor: "{colors.primary-bg-subtle}"
    textColor: "{colors.ink}"
    typography: "{typography.slide-body}"
    rounded: "{rounded.lg}"
    padding: "{spacing.xl}"

  # ── Callout & Quote ──
  callout-box:
    backgroundColor: "{colors.primary-bg-subtle}"
    textColor: "{colors.ink}"
    borderLeft: "4px solid {colors.primary}"
    typography: "{typography.slide-body-sm}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md} {spacing.lg}"
  callout-warning:
    backgroundColor: "{colors.highlight-bg}"
    textColor: "{colors.highlight-text}"
    borderLeft: "4px solid {colors.accent-orange}"
    typography: "{typography.slide-body-sm}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md} {spacing.lg}"
  pull-quote:
    backgroundColor: "{colors.quote-bg}"
    textColor: "{colors.ink}"
    borderLeft: "4px solid {colors.quote-border}"
    typography: "{typography.slide-subtitle}"
    rounded: "{rounded.sm}"
    padding: "{spacing.lg} {spacing.xl}"
    fontStyle: "italic"

  # ── Table ──
  table-container:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    borderColor: "{colors.table-border}"
    typography: "{typography.slide-body-sm}"
    rounded: "{rounded.lg}"
    padding: "{spacing.md}"
  table-header:
    backgroundColor: "{colors.table-header-bg}"
    typography: "{typography.slide-body-sm}"
    fontWeight: 600

  # ── Diagram Elements ──
  diagram-container:
    backgroundColor: "{colors.canvas-soft}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "{spacing.xl}"
  diagram-label:
    typography: "{typography.slide-caption}"
    textColor: "{colors.ink-mute}"
    padding: "{spacing.sm} 0 0 0"
  flow-arrow:
    color: "{colors.ink-secondary}"
    strokeWidth: 2

  # ── Footer / Navigation ──
  slide-footer-bar:
    backgroundColor: "{colors.canvas}"
    borderTop: "1px solid {colors.hairline}"
    padding: "{spacing.sm} {spacing.slide-margin}"
    height: 32px
  page-number:
    typography: "{typography.slide-number}"
    textColor: "{colors.ink-mute}"
    position: "bottom-right"
  progress-bar:
    backgroundColor: "{colors.primary}"
    height: 3px
    position: "bottom"
---

## Overview

This design system defines a visual language for **presentations and slide decks** — school projects, project pitches, technical talks, and educational lectures. Every token is chosen for maximum readability on projected displays (1024×768 to 1920×1080), with generous typography, high contrast, and a calm visual hierarchy that keeps attention on the content.

The system is built on a **four-slot slide architecture** that covers 95% of presentation needs:

1. **Title Slide** — Clean branded opener. Centered layout on colored or dark canvas.
2. **Section Divider** — Transition slide between major topics. Dark canvas with centered text.
3. **Content Slide** — The workhorse. Header + body area supporting text, bullets, images, tables, code blocks, and cards in flexible grid layouts.
4. **Full-Bleed Slide** — Photography, diagrams, code, or quotes that fill the canvas.

The design philosophy is **subtractive**: start with the minimum elements needed to communicate the idea, then remove anything that competes with the message. No decorative gradients, no shadows on text, no animation for its own sake.

**Key Characteristics:**
- Single accent color `{colors.primary}` (`#0066cc`) — carries titles on dark slides, link text, bullet markers, progress bars. Everything else is grayscale.
- Large projection-optimized typography: body at 24px minimum, code at 18px, titles at 40px.
- 16:9 aspect ratio as the default. 4:3 support via adjusted margins.
- White canvas for content slides (optimal projection contrast), dark canvas for dividers and title slides (visual rhythm).
- No background images or textures on text-heavy slides — pure canvas maximizes readability.
- Generous margins (48px) — slides that feel "crowded" fail at projection distance.
- Code slides use dark background (`{colors.code-bg}`) regardless of the slide theme — code always renders on dark for maximum syntax contrast.

## Colors

### Brand & Accent
- **Primary Blue** (`{colors.primary}` — `#0066cc`): The single accent color. Used on title slides (background), section dividers, inline links, bullet markers, progress bar, callout borders, and accent card borders. One color, one job: signal importance.
- **Primary Deep** (`{colors.primary-deep}` — `#0052a3`): Pressed / hover state for interactive elements (if slides are used in web-based viewers).
- **Primary Soft** (`{colors.primary-soft}` — `#4d94ff`): Lighter tint used for subtle accent fills (chart primary series, diagram highlights).
- **Primary Bg Subtle** (`{colors.primary-bg-subtle}` — `#e8f0fe`): The only tinted background surface — used for callout boxes and stat cards.

### Surface
- **Canvas** (`{colors.canvas}` — `#ffffff`): Default slide background for all content slides. Pure white for maximum projection contrast.
- **Canvas Soft** (`{colors.canvas-soft}` — `#f5f5f7`): Subtle off-white for diagram containers, table header backgrounds, pull quote backgrounds. Just enough tint to signal "this is a different content region."
- **Canvas Dark** (`{colors.canvas-dark}` — `#1d1d1f`): Dark canvas for section dividers and optional dark content slides. Near-black ink tone (not pure black).
- **Canvas Dark Soft** (`{colors.canvas-dark-soft}` — `#2c2c2e`): Slightly lifted dark for secondary dark-surface elements.
- **Hairline** (`{colors.hairline}` — `#e5e5ea`): 1px borders for tables and card edges.
- **Hairline Strong** (`{colors.hairline-strong}` — `#c7c7cc`): Slightly stronger borders for emphasis.

### Text
- **Ink** (`{colors.ink}` — `#1d1d1f`): All body text on light slides. Near-black for optimal projection contrast.
- **Ink Secondary** (`{colors.ink-secondary}` — `#4a4a4a`): Secondary text, less important bullets, diagram labels.
- **Ink Mute** (`{colors.ink-mute}` — `#8e8e93`): Captions, footer text, page numbers. Lowest priority — always at 12–16px.
- **Ink Inverse** (`{colors.ink-inverse}` — `#ffffff`): All text on dark slides and colored title slides.

### Semantic Accents
- **Green** (`{colors.accent-green}`): Success states, positive metrics, "correct" markers.
- **Orange** (`{colors.accent-orange}`): Warning states, attention markers, "in progress" indicators.
- **Red** (`{colors.accent-red}`): Error states, negative metrics, "incorrect" markers.
- **Purple** (`{colors.accent-purple}`): Secondary accent for diagram series differentiation.

### Code Surface
Code blocks use a separate color system on a dark background:
- Background: `{colors.code-bg}` (#1e1e1e) — consistent dark surface for all code slides.
- Text: `{colors.code-text}` (#d4d4d4) — light gray, not pure white, for reduced projection glare.
- Highlight: `{colors.code-line-highlight}` (#264f78) — deep blue highlight for focused lines.
- Token colors follow a high-contrast projection-friendly palette (not shown in tokens — apply standard syntax highlighting against the dark surface).

## Typography

### Font Family
Two faces carry the system:

1. **SF Pro Display** (or Inter) — display sizes for titles, section headers, and subtitles. Weight 700 for slide titles (bold enough to read across a lecture hall), 600 for section dividers, 400 for subtitles.
2. **SF Pro Text** (or Inter) — body text, bullets, captions, and all non-code content. Weight 400 body, 600 for emphasis.
3. **JetBrains Mono** (or Fira Code) — all code surfaces. Weight 450 ("Retina") for readability at projection scale.

### Hierarchy

| Token | Size | Weight | Line Ht | Use |
|---|---|---|---|---|
| `{typography.slide-section}` | 48px | 600 | 1.1 | Section divider headline (dark slide) |
| `{typography.slide-title}` | 40px | 700 | 1.15 | Title slide headline, content slide title |
| `{typography.slide-subtitle}` | 28px | 400 | 1.25 | Title slide subtitle, pull quote text |
| `{typography.slide-body}` | 24px | 400 | 1.45 | Default body text (projection minimum) |
| `{typography.slide-body-strong}` | 24px | 600 | 1.45 | Emphasized body text |
| `{typography.slide-body-sm}` | 20px | 400 | 1.4 | Secondary body, card text, table cells |
| `{typography.slide-bullet}` | 22px | 400 | 1.5 | Bullet point text (slightly larger for scanability) |
| `{typography.slide-bullet-strong}` | 22px | 600 | 1.5 | Emphasized bullet text |
| `{typography.slide-caption}` | 16px | 400 | 1.3 | Image captions, diagram labels, footnotes |
| `{typography.slide-code}` | 18px | 450 | 1.6 | Code blocks (projection scale) |
| `{typography.slide-code-sm}` | 15px | 450 | 1.5 | Compact code (when screen real estate is tight) |
| `{typography.slide-footer}` | 12px | 400 | 1.2 | Footer text, date, presenter name |
| `{typography.slide-number}` | 11px | 500 | 1.0 | Page number |

### Principles
- **24px minimum body text.** At projection distance, any text under 20px becomes unreadable past row 10. 24px is the safe default.
- **18px minimum code text.** Mono faces read smaller than proportional at the same point size. Code at 18px (or 15px in compact mode) ensures readability.
- **700 weight for titles.** Slides need bold headlines to anchor the visual hierarchy. 700 weight cuts through projection glare.
- **1.5 line-height for bullets.** Bullet lists need breathing room for scanability. 1.5 line height ensures each bullet reads as a distinct item.
- **0 tracking on body.** Projection doesn't need tight or loose tracking — neutral 0 keeps text crisp.
- **Negative tracking on display titles.** 40px titles at -0.8px tracking tighten the headline without affecting readability.

### Note on Font Substitutes
Inter (Google Fonts, variable) is the canonical substitute for SF Pro. JetBrains Mono is open-source (SIL OFL). Fira Code is a good alternative mono face.

## Layout

### Slide Dimensions
- **Default aspect ratio:** 16:9 (1920×1080 or 1280×720). All spacing tokens scale proportionally.
- **4:3 fallback:** Margins reduce from 48px to 32px. Body text drops to 22px. Code drops to 16px.

### Slide Layout Templates

**1. Title Slide — Centered**
```
┌──────────────────────────────────────────┐
│                                          │
│              ┌──────────┐                │
│              │  Logo     │                │
│              └──────────┘                │
│                                          │
│         Presentation Title               │  ← slide-title (40px/700)
│         Subtitle or context              │  ← slide-subtitle (28px/400)
│                                          │
│                                          │
│         Author Name • Date               │  ← slide-footer (12px)
│                                          │
└──────────────────────────────────────────┘
```
Full blue or dark background. Content centered vertically and horizontally.

**2. Content Slide — Title + Body**
```
┌──────────────────────────────────────────┐
│  Slide Title                             │  ← slide-title
├──────────────────────────────────────────┤
│                                          │
│  • Body text paragraph explaining the    │  ← slide-body
│    concept. Generous line height keeps   │
│    it readable at projection distance.   │
│                                          │
│  • Second point with supporting detail.  │  ← slide-bullet
│    Bullets align left under the title.   │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │ Callout or highlight box           │  │  ← callout-box
│  └────────────────────────────────────┘  │
│                                          │
│  ────────────────  ────────────────       │
│  │ Card 1       │  │ Card 2       │      │  ← card-feature
│  ────────────────  ────────────────       │
│                                          │
│  [footer bar with page number]           │
└──────────────────────────────────────────┘
```
The workhorse template. Header bar (optional), title area, body area with flexible content.

**3. Code Slide**
```
┌──────────────────────────────────────────┐
│  Slide Title                             │
├──────────────────────────────────────────┤
│  ┌────────────────────────────────────┐  │
│  │  function fibonacci(n: number) {  │  │
│  │    if (n <= 1) return n;          │  │  ← highlighted line
│  │    return fibonacci(n-1) +        │  │
│  │           fibonacci(n-2);         │  │
│  │  }                                │  │
│  │                                    │  │
│  │  // Recursive Fibonacci            │  │  ← code-block-slide
│  └────────────────────────────────────┘  │
│                                          │
│  Caption or explanation below code       │  ← slide-caption
└──────────────────────────────────────────┘
```
Dark code surface, title in header bar. Code fills the main area. Caption below.

**4. Two-Column Layout**
```
┌──────────────────────────────────────────┐
│  Slide Title                             │
├─────────────────────┬────────────────────┤
│                     │                    │
│  ┌───────────────┐  │  ┌──────────────┐  │
│  │  Content A    │  │  │  Content B   │  │
│  └───────────────┘  │  └──────────────┘  │
│                     │                    │
│  • Bullet about A   │  • Bullet about B  │
│  • More detail      │  • More detail     │
│                     │                    │
└─────────────────────┴────────────────────┘
```
Split at 50/50 with `{spacing.xl}` 32px gutter. Each column holds text, cards, diagrams, or images.

**5. Section Divider**
```
┌──────────────────────────────────────────┐
│                                          │
│                                          │
│              Section Title               │  ← slide-section (48px/600)
│                                          │
│        Brief context or subtitle         │
│                                          │
│                                          │
│                    Section 3 of 7         │
└──────────────────────────────────────────┘
```
Full dark background. Centered. No header, no footer — the content IS the transition.

### Spacing System
- **Base unit:** 4px.
- **Tokens:** `{spacing.xxs}` 4px · `{spacing.xs}` 8px · `{spacing.sm}` 12px · `{spacing.md}` 16px · `{spacing.lg}` 24px · `{spacing.xl}` 32px · `{spacing.xxl}` 40px · `{spacing.huge}` 48px · `{spacing.section}` 64px · `{spacing.slide-margin}` 48px.
- **Slide margins:** 48px on all sides. This is the minimum padding between content and slide edges at 1920×1080.
- **Title-to-body gap:** `{spacing.md}` 16px — tight enough to keep the title connected to its content.
- **Bullet spacing:** `{spacing.sm}` 12px between bullets — enough for scanability without wasting vertical space.
- **Card grid gap:** `{spacing.lg}` 24px between cards in a multi-card row.

### Grid
- **Max content width:** ~1600px on 1920×1080 slides (the 48px margin × 2 = 96px consumed; 1824px usable but centered to ~1600px for reading comfort).
- **Column patterns:** Single (full width), Two-column (50/50), Three-column (33/33/33), Sidebar (30/70).
- **Card grids:** 2-up (two equal features), 3-up (three stats/metrics), 4-up (four-item gallery).

### Whitespace Philosophy
Presentation slides are read from a distance. Crowded slides fail. The rule: **one idea per slide, with enough whitespace that the idea can breathe.** If a slide needs more than 4-5 bullet points, it should be two slides. If code needs scrolling, it's too much code for a single slide.

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| 0 — Flat | No shadow, no border | Default content slide elements |
| 1 — Card | `0 2px 8px rgba(0,0,0,0.06)` | Feature cards, stat cards |
| 2 — Elevated | `0 4px 16px rgba(0,0,0,0.1)` | Accent cards, callout boxes |

**Depth philosophy:** Presentations are 2-D media. Shadows should be barely perceptible — just enough to lift a card off the white canvas. No shadows on text, no shadows on code blocks, no shadows on slide backgrounds. The title slides and section dividers are intentionally flat (solid color fill, zero depth).

## Components

### Slide Types

**`title-slide`** — The opener. Background `{colors.title-slide-bg}` (primary blue), text `{colors.title-slide-text}` (white), centered layout, vertical padding `{spacing.section}`. Contains: `title-main` (presentation title), `title-subtitle` (optional subtitle), `title-meta` (author, date, event).

**`section-slide`** — Transition between sections. Background `{colors.section-divider-bg}` (dark), text `{colors.section-divider-text}` (white), centered layout. Shows section number and title.

**`content-slide`** — Default content surface. Background `{colors.canvas}`, text `{colors.ink}`. Optional `slide-header-bar` at the top containing the section label and slide title.

**`content-slide-dark`** — Dark variant for content (used sparingly for visual contrast). Background `{colors.canvas-dark}`, text `{colors.ink-inverse}`.

### Title Slide Elements

**`title-main`** — The primary headline. Rendered in `{typography.slide-title}` (40px/700). On colored/dark slides, white. Single line preferred; two lines max with reduced leading.

**`title-subtitle`** — Secondary text below the title. Rendered in `{typography.slide-subtitle}` (28px/400), opacity 0.85. Context: "A deep dive into..." or event name.

**`title-meta`** — Author, date, and affiliation. Rendered in `{typography.slide-footer}` (12px), opacity 0.7. Positioned at the bottom of the title slide.

### Content Elements

**`body-text`** — Paragraph text. `{typography.slide-body}` (24px/400), margin-bottom `{spacing.md}` 16px. Maximum 4 paragraphs per slide.

**`body-text-sm`** — Smaller body text for secondary explanations. `{typography.slide-body-sm}` (20px/400).

**`bullet-list`** — Unordered list item. `{typography.slide-bullet}` (22px/400), line-height 1.5. Bullet marker uses `{colors.primary}`. Margin-between `{spacing.sm}` 12px.

**`numbered-list`** — Ordered list item. Same typography as bullet. Number color `{colors.ink-secondary}` for reduced visual weight.

### Code

**`code-block-slide`** — Full-size code block. Background `{colors.code-bg}`, text `{colors.code-text}`, rendered in `{typography.slide-code}` (18px mono 450). Rounded `{rounded.lg}` 12px. Padding `{spacing.lg} {spacing.xl}`.

**`code-block-compact`** — Smaller code block for side-by-side layouts. Same background and text colors, but `{typography.slide-code-sm}` (15px).

**`code-line-highlight`** — Highlighted line within a code block. Background `{colors.code-line-highlight}`, left border `{colors.primary}`. Used to focus attention on the relevant line.

### Cards

**`card-feature`** — Default information card. White background, 1px hairline border, subtle Level 1 shadow. Used for 2-up or 3-up feature grids.

**`card-feature-accent`** — Accent card with a blue left border or blue border ring. Used for the primary/"key takeaway" card in a grid.

**`card-stat`** — Stat/metric card with blue-tinted background. Used for numbers: "94% faster," "10K users," etc. The number is rendered in `{typography.slide-body}` with strong weight, the label below in `{typography.slide-caption}`.

### Callouts & Quotes

**`callout-box`** — Information callout. Light blue-tinted background, 4px left blue border. Used for definitions, key concepts, "note" boxes.

**`callout-warning`** — Warning/attention callout. Yellow background, orange left border. Used for "common pitfall," "watch out," "important" notes.

**`pull-quote`** — Emphasized quotation. Gray background, blue left border, italic text in `{typography.slide-subtitle}` (28px). Used to highlight a key statement from a referenced source.

### Tables

**`table-container`** — Table wrapper. White background, hairline borders. Header rows use `table-header` which has a soft gray background and 600 weight. Alternating row colors (`table-row-alt`) for tables with more than 4 rows.

### Diagram Elements

**`diagram-container`** — Container for diagrams, charts, and illustrations. Soft gray background `{colors.canvas-soft}`, rounded corners, generous padding. The diagram renders inside at full width.

**`diagram-label`** — Caption label beneath a diagram. `{typography.slide-caption}` (16px), muted text.

### Footer & Navigation

**`slide-footer-bar`** — Bottom footer strip. 32px height, 1px hairline top border. Contains: slide title (left), page number (right).

**`page-number`** — Slide number. `{typography.slide-number}` (11px/500), muted text. Right-aligned in the footer bar.

**`progress-bar`** — Section progress indicator. 3px tall blue bar at the very bottom of the slide. Width corresponds to position within the section (0% at first slide, 100% at last).

## Do's and Don'ts

### Do
- Use `{colors.primary}` as the single accent — one blue carries titles, bullets, callouts, and progress. A second accent dilutes the signal.
- Render body text at 24px minimum — any smaller is unreadable past row 8 in a lecture hall.
- Keep code slides simple — one focused snippet per slide, 10-15 lines max. Use `code-line-highlight` to draw attention to the critical line.
- Start every section with a `section-slide` — the dark canvas transition signals "new topic" and resets the viewer's attention.
- Use `callout-box` for definitions and key concepts — the blue left border signals "remember this."
- Keep bullet lists to 4-5 items max. More than 5 means the slide needs splitting.
- Use `card-stat` for numbers — the tinted background makes metrics pop without relying on color alone.
- Use `pull-quote` sparingly — one per presentation maximum. The italic large text is a powerful emphasis tool that loses impact with overuse.

### Don't
- Don't use background images or textures behind text — projection glare makes text-over-image unreadable beyond the first row.
- Don't use more than two typefaces — the system uses Inter (body) + JetBrains Mono (code). Adding a third decorative face adds no communication value.
- Don't put code on a white background — code always renders on `{colors.code-bg}` dark surface for syntax contrast.
- Don't animate slide transitions (slides that fly in, rotate, or flip) — they distract from content and can cause motion sickness at projection scale.
- Don't use gradients on slide backgrounds — flat colors project cleanly; gradients show banding on most classroom projectors.
- Don't use text smaller than 16px for any purpose — even captions at 16px are pushing readability at projection distance.
- Don't use red/green alone to convey meaning — some in the audience may have color vision deficiency. Pair color with icons, text, or position.
- Don't put the slide number in the body area — it belongs in the footer bar at the bottom.

## Responsive Behavior

### Aspect Ratios

| Ratio | Width | Key Changes |
|---|---|---|
| 16:9 | 1920×1080 / 1280×720 | Default. All spacing tokens at full value. |
| 16:10 | 1920×1200 | Slightly more vertical space; body area extends by ~120px. |
| 4:3 | 1024×768 | Margins tighten from 48px to 32px. Body drops to 22px. Code drops to 16px. Card grids shift from 3-up to 2-up. |
| 3:2 | 1440×960 | Margins at 40px. Body stays at 24px. |

### Font Scaling
Title and body sizes should scale proportionally for smaller aspect ratios rather than reflowing. The recommended approach: scale all font sizes by 0.92× for 4:3, keep full size for 16:9 and 16:10.

### Card Collapse
- 3-up card grid at 16:9 → 2-up at 4:3 → 1-up at narrow export formats.
- 2-up card grid at 16:9 → 1-up at 4:3.
- Stat cards (4-up) → 2×2 grid at 4:3.

## Iteration Guide

1. Start with the **title slide** — presentation name, subtitle, author. This sets the tone.
2. Add **section dividers** — one per major topic. These structure the narrative arc.
3. Build **content slides** — one idea per slide. Bullet slides, then add code or diagram slides where the idea demands them.
4. Add **callout boxes** to highlight definitions or key concepts.
5. Review each slide: "Can I explain this in 30 seconds?" If not, split or simplify.
6. Verify minimum font sizes: no text under 20px (except captions at 16px).
7. Print to PDF and test on a projector if possible — slides that look good on a monitor often fail at projection distance.

## Known Gaps

- Video slide templates are not defined — the system assumes static slides. Video embeds would use the `diagram-container` pattern with a dark placeholder.
- Handout/notes page layout is not defined — companion handout design would need its own spacing and typography (smaller, denser, printer-friendly).
- Live demo slide format is not tokenized — a "live demo" slide would need a full-bleed browser/terminal surface pattern.
- Accessibility accommodations (large-print version, screen-reader-friendly export notes) are out of scope for this visual spec.
