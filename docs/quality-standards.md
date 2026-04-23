# Quality Standards

This file documents the quality standards for this knowledge base. These standards ensure the folder itself follows best practices — the meta-quality principle.

## Purpose

- Document what "good" looks like for each part type
- Provide criteria for the audit script
- Enable consistent quality across propagated folders

---

## 1. Folder Organization

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | lowercase-kebab | `daily-prompts.md` |
| Scripts | lowercase-kebab | `propagate-to-all.ps1` |
| Templates | lowercase-kebab | `AGENTS.template.md` |
| Subfolders | lowercase-kebab | `templates/` |

### Structure Rules

- Root-level: core docs, scripts, templates
- Subfolders: domain-specific content
- No orphan files: every file linked from at least one other file
- One source of truth: no duplicate content; files reference, not repeat
- Hot-path files stay compact and link to archives or deep references
- Preserve historical/provenance content in `archive/` before removing it from active files

### Categorization

```
/ (root)
|- AGENTS.md               # Operating contract
|- README.md               # Human navigation
|- HISTORY.md              # Session history
|- docs/                   # Core documentation
|- scripts/                # Executable automation scripts
|- workflow/               # Generated workflow files, logs, registries, state
|- research/               # Research logs and integration notes
|- archive/                # Preserved reference material
|- propagate-templates/    # Reusable propagation templates
`- personal-voice/         # User voice profile and samples
```

---

## 2. Script Quality

### Required Elements

Every `.ps1` script must have:

1. **Parameter block** — named parameters, not positional
2. **Help comment** — synopsis, description, examples
3. **Error handling** — try/catch for risky operations
4. **WhatIf support** — `-WhatIf` parameter for dry runs

### Best Practices

- No hardcoded paths: use `$PSScriptRoot` or parameters
- Verbose output: use `-Verbose` for debugging
- Exit codes: 0 for success, 1+ for failure
- Idempotent: safe to run multiple times

### PowerShell Syntax Standards

- Use `param()` block at script start
- Cmdlet naming: `Verb-Noun` (Get-, Set-, New-, Remove-)
- Error handling: `try { } catch { Write-Error; exit 1 }`
- Variables: `$camelCase` or `$PascalCase`
- Strings: double quotes for interpolation, single for literals
- Arrays: `@()` for explicit arrays
- Pipeline: prefer pipeline over loops when appropriate

### Help Comment Template

```powershell
<#
.SYNOPSIS
    Short one-liner description.

.DESCRIPTION
    Longer description of what the script does.

.PARAMETER ParamName
    Description of the parameter.

.EXAMPLE
    .\script.ps1 -ParamName Value
    Example usage with output.

.NOTES
    Author: Name
    Date: YYYY-MM-DD
#>
```

---

## 3. Content Quality

### Tiered Quality Model

| Level | Definition | Requirement |
|-------|------------|--------------|
| **Source-backed** | Links to authoritative external docs | Required for factual claims about tools |
| **Actionable** | Specific steps, commands, paths, examples | Required for "do this" advice |
| **Inference-based** | Derived from patterns, not explicit sources | Must be marked as inference |
| **Generic** | Universal truth (scope tightly, etc) | Fine as-is, common wisdom |

### Content Rules

- **If it's a fact about a tool**: link to official docs
- **If it's advice to act on**: include specific paths, commands, examples
- **If it's uncertain**: mark as "inference" or "likely"
- **Generic principles**: fine as-is (e.g., "scope tightly")

### Link Standards

- External links: must be valid and point to authoritative sources
- Internal links: relative paths preferred
- Placeholders: use `[PLACEHOLDER]` syntax, not `{{PLACEHOLDER}}` or `<PLACEHOLDER>`

### Writing Style

- Concise: avoid unnecessary words
- Specific: include file paths, commands, examples
- Actionable: user can act on the advice
- Scoped: don't ask for "everything" — be specific

---

## 4. Markdown Quality

### Structure

- Heading hierarchy: H1 → H2 → H3, no skipping levels
- Consistent heading style: sentence-case or title-case (pick one)
- Line length: soft-wrap at 100 chars for readability
- Code blocks: fenced with ``` for clarity

### Link Format

```markdown
[Link text](relative/path.md)
[External](https://example.com)
```

### Placeholder Syntax

```
[REPO_NAME]        # Replace this value
[PATH_TO_FILE]    # Path to replace
[COMMAND]         # Command to run
```

---

## 5. Template Quality

### Required Elements

Every template must have:

1. **Header** — description of what the template is for
2. **Placeholders** — clearly marked with `[PLACEHOLDER]`
3. **Usage** — how to use the template
4. **Example** — filled-out example

### Template Naming

- `*.template.md` for markdown templates
- `*.template.ps1` for script templates
- Include `_example.md` with filled values

---

## 6. Meta-Quality

### The Meta Principle

This folder must follow its own advice. Specifically:

- The audit script must pass its own audit
- AGENTS.md or README.md must reference these standards
- Propagation flow should include quality checks

### Self-Reference

If these standards describe "good" for a category, the files documenting those standards must exemplify it.

---

## 7. Audit Integration

These standards are enforced by `scripts/audit-folder-quality.ps1`.

The checker validates:

- Folder organization (naming, structure, orphans)
- Script quality (parameters, help, error handling)
- Content quality (source-backed links, actionable advice)
- Markdown quality (headings, links, placeholders)
- Template completeness
- Context budgets for hot-path files

Default audit scope:

- Root authored files
- `docs/`
- `research/`
- `scripts/`
- `propagate-templates/`
- personal-voice root files

Default exclusions:

- `archive/`
- `archive/raw/`
- generated workflow snapshots
- `personal-voice/samples/`

Use `-IncludeArchive` or `-IncludeGenerated` for wider scans.

Run the audit:

```powershell
.\scripts\audit-folder-quality.ps1
```

---

## Related Files

- [../AGENTS.md](../AGENTS.md) — operating contract
- [../README.md](../README.md) — navigation index

---

## 8. Information Compression Standards

These standards ensure compressed content maintains quality.

### Hot-Path Size Budgets

These are warning thresholds, not hard failures. Exceeding one means the file should probably become an index with deeper detail linked elsewhere.

| File | Warning Budget |
|------|----------------|
| `AGENTS.md` | 220 lines |
| `README.md` | 150 lines |
| `docs/workspace-system-overview.md` | 240 lines |
| `HISTORY.md` | 350 lines |
| `research/research-log.md` | 500 lines |
| `docs/prompt-templates.md` | 350 lines |

### Active vs Archive vs Generated

| Type | Purpose | Rule |
|------|---------|------|
| Active hot-path files | Fast orientation and current work | Keep compact; link out |
| Deep docs | Durable explanation and playbooks | Can be longer when needed |
| Archive files | Full historical/provenance records | Preserve; exclude from default audit |
| Generated workflow files | Script outputs and review queues | Regenerate from scripts when possible |
| Raw snapshots | Emergency recovery/provenance | Keep under `archive/raw/`; exclude from search/audit by default |

### For Markdown Content

| Criterion | Standard |
|-----------|----------|
| **Atomicity** | One idea per note/heading |
| **Standalone** | Understandable without source |
| **Linkability** | Connectable to related notes |
| **Source-ref** | Always cite origin |
| **Test retrieval** | Findable in ≤3 clicks |

### Compression Checklist

- [ ] Is this claim-based (not topic-based)?
- [ ] Does it stand alone without source context?
- [ ] Can other notes link to it?
- [ ] Is the source referenced?
- [ ] Would RAG retrieval return this for the right query?

### When Compression is Appropriate

| Situation | Approach |
|-----------|----------|
| Research log → Integration | Extract key pattern, link to source |
| Repo lessons → Knowledge base | Atomic note, source reference |
| Doc update | Rewrite in own words, keep source |
| Inline AGENTS.md | Core insight only, reference for deep-dive |

### When NOT to Compress

- When source reference is sufficient (just link)
- When the full doc is needed for edge cases
- When multiple related ideas need to stay together
- When actionability matters more than compression
- [../scripts/audit-folder-quality.ps1](../scripts/audit-folder-quality.ps1) — validates these standards
