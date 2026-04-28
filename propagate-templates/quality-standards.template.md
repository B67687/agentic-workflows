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

---

## 2. Script Quality

### Required Elements

Every `.ps1` script must have:

1. **Parameter block** — named parameters, not positional
2. **Help comment** — synopsis, description, examples
3. **Error handling** — try/catch for risky operations
4. **Idempotent** — safe to run multiple times

### Best Practices

- No hardcoded paths: use `$PSScriptRoot` or parameters
- Exit codes: 0 for success, 1+ for failure

---

## 3. Content Quality

### Tiered Quality Model

| Level | Definition | Requirement |
|-------|------------|-------------|
| **Source-backed** | Links to authoritative external docs | Required for factual claims about tools |
| **Actionable** | Specific steps, commands, paths, examples | Required for "do this" advice |
| **Inference-based** | Derived from patterns, not explicit sources | Must be marked as inference |
| **Generic** | Universal truth (scope tightly, etc) | Fine as-is, common wisdom |

### Content Rules

- **If it's a fact about a tool**: link to official docs
- **If it's advice to act on**: include specific paths, commands, examples
- **If it's uncertain**: mark as "inference" or "likely"
- **Generic principles**: fine as-is (e.g., "scope tightly")

---

## 4. Markdown Quality

### Structure

- Heading hierarchy: H1 → H2 → H3, no skipping levels
- Code blocks: fenced with ``` for clarity
- Link format: `[Link text](relative/path.md)`

---

## 5. Meta-Quality

### The Meta Principle

This folder must follow its own advice. Specifically:

- The audit script must pass its own audit
- AGENTS.md must reference these standards

### Audit Integration

These standards are enforced by `audit-folder-quality.ps1`.

Run the audit:

```powershell
.\audit-folder-quality.ps1
```

---

## 6. Custom Extensions

Add topic-specific quality standards below this line. This section is preserved during propagation.

<!-- Custom-Section: Topic-Quality-Rules -->
## Topic-Specific Standards

Add your topic-specific quality rules here.

<!-- End-Custom-Section -->