# Rules

Always-follow guidelines for AI agent behavior, organized into language-agnostic common rules and language-specific extensions.

## Structure

```
rules/
  README.md           — This file
  common/             — Language-agnostic: install these everywhere
    coding-style.md   — Immutability, file organization, naming conventions
    git-workflow.md   — Commit format, branch strategy, PR process
    testing.md        — Test expectations, coverage targets, TDD enforcement
    security.md       — Mandatory security checks before commits
  typescript/         — TypeScript and JavaScript specific patterns
    patterns.md       — TS/JS patterns, tooling, and idioms
  python/             — Python specific patterns
    patterns.md       — Python patterns, tooling, and idioms
```

## How to use

These rules apply to the hub repo directly. For topic folder work, copy only the `common/` directory plus the language pack(s) you need into the target project's context.

```
# Minimal (always start here)
cp -r rules/common /path/to/project/

# Add language-specific pack
cp -r rules/typescript /path/to/project/
```

Do not copy all language packs — only the one(s) you actively use in that project.
