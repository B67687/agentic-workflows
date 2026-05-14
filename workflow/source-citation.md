# Source Citation Workflow

**Goal:** Every claim, pattern, or integration point in this workspace must cite its source --- at minimum Title + URL.

Applied automatically to any research-adjacent task, documentation update, or skill creation. Do not skip.

---

## Minimum Citation Format

```
[Project Name](https://github.com/org/repo) --- brief context on what was used
```

Cite at the point of use (inline or as a footnote), not just in a bibliography.

## When to Cite

| Action | Must Cite |
|--------|-----------|
| Referencing a project, tool, or paper | Title + URL |
| Adopting a pattern or architecture | Original source + variation notes |
| Integrating code, config, or templates | Source repo + exact file path |
| Research claim in a doc | URL + authority weighting |
| Creating a new skill | Sources consulted + inspiration |
| Updating the README ecosystem | Every project listed |

## Enforcement Points

### In Research (`research/research-prompt.md`)
- Phase 2: `Source: <URL>` + `Date:` + `Authority:` per source
- Phase 5: Save to `workflow/source-registry.md` (or pass to the next phase)
- Output format: Every finding includes confidence level + source URL

### In Documentation (`docs/`)
- Every doc section that references external work gets: `**Source:** [Title](URL)`
- ADRs link to the sources that informed the decision
- Comparison docs have a final "Sources" section

### In Skills (`skills/`)
- Skill frontmatter `source` field: `github: org/repo` or `url: https://...`
- Inline citations at the point of pattern adoption
- L3 references include source URLs

### In Code (`scripts/`, `commands/`)
- Header comment for derived scripts: `# Based on: https://github.com/org/repo --- [notes]`
- Algorithm implementations: `# Source: [paper/URL]`

## Source Registry

High-value sources discovered during research should be added to the registry for future reference:

```
bash ./scripts/learnings-save.sh "Source: <name> (<URL>)" source-tracking
```

## Verification

- For any doc or skill change: `rtk grep -n 'http\?://' <file>` to verify citations exist
- Before merging: confirm every external claim has a linked source
- If a claim cannot be sourced, flag it: `[UNSOURCED --- needs verification]`
