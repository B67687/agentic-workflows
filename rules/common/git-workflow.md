---
description: Git workflow conventions --- commit format, branch strategy, PR process, and safety rules.
globs: []
alwaysApply: true
---

# Git Workflow

## Commit Format

Use conventional commits:

```
<type>: <short description>

<optional body --- why this change was made, not what it does>
```

**Types:**

| Type | When to use |
|------|-------------|
| `feat` | New feature or user-facing capability |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `docs` | Documentation only |
| `test` | Adding or modifying tests |
| `chore` | Build, config, dependencies, tooling |
| `perf` | Performance improvement |
| `ci` | CI/CD configuration |

## Branch Strategy

- **Main branch** is `main` --- always deployable
- **Feature branches:** `feat/<short-description>` --- for new features
- **Fix branches:** `fix/<short-description>` --- for bug fixes
- **Chore branches:** `chore/<short-description>` --- for tooling, config, cleanup

## Safety Rules

- **Never force push to `main`** or any shared branch
- **Never commit secrets** --- check for API keys, tokens, passwords before every commit
- **Never commit large binary files** (>1MB) --- use Git LFS or exclude them
- **Never commit `node_modules/`, `.next/`, `dist/`, `build/`** --- these are in `.gitignore`
- **Never rewrite published history** on shared branches

## PR Process

1. Verify all tests pass locally
2. Write a concise PR summary focused on the "why"
3. Review your own diff before requesting review
4. Respond to all review comments
5. Squash commits on merge (keep the branch history clean during development)

## Tooling

- Use `$HOME/.local/bin/git-safe-commit` (or equivalent) instead of raw `git commit`
- Use `$HOME/.local/bin/git-safe-push` (or equivalent) instead of raw `git push`
- Use `$HOME/.local/bin/gh-safe-pr-create` (or equivalent) instead of raw `gh pr create`
