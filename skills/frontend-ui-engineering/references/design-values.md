# design-values.md
# Design system values: spacing scale, layout breakpoints, color palette tokens, and typography system.
# Source: frontend-ui-engineering/SKILL.md (extracted to L3)

## Spacing and Layout

Use a consistent spacing scale. Don't invent values:

```css
/* Use the scale: 0.25rem increments (or whatever the project uses) */
/* Good */  padding: 1rem;      /* 16px */
/* Good */  gap: 0.75rem;       /* 12px */
/* Bad */   padding: 13px;      /* Not on any scale */
/* Bad */   margin-top: 2.3rem; /* Not on any scale */
```

### Typography

Respect the type hierarchy:

```
h1 -> Page title (one per page)
h2 -> Section title
h3 -> Subsection title
body -> Default text
small -> Secondary/helper text
```

Don't skip heading levels. Don't use heading styles for non-heading content.

#
