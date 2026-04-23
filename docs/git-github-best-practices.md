# Git & GitHub Best Practices

Principles for humans and AI agents to work effectively with Git and GitHub.

## Why This Matters for AI Agents

AI agents that don't understand repository state cause downstream problems:
- Working on stale branches causes merge conflicts
- Not checking remote changes leads to lost work
- Pushing without resolving conflicts pollutes history

These problems compound when multiple agents or humans work together.

---

## State Awareness

### Always Fetch Before Starting Work

Before making any changes:
1. Fetch the latest from remote to see what changed
2. Check your current branch against the remote
3. Understand if new commits exist that may affect your work

For AI agents: confirm the repo state is current before editing.

### Understand Remote Before Committing

Before committing:
1. Check `git status` to see current state
2. Review `git log` or diff to understand recent changes
3. Identify if rebasing or merging is needed

### Resolve Conflicts Before Pushing

Never push with unresolved conflicts. Either:
- Resolve them locally and complete the merge/rebase
- Leave the work uncommitted until resolved

---

## Commit Discipline

### Write Meaningful Messages

Good commit messages explain:
- **What** changed
- **Why** it changed (the context)
- **How** it addresses the issue

Bad messages: "fix", "update", "changes", "wip"

### Keep Commits Atomic

Each commit should represent one logical change:
- Don't mix refactoring with bug fixes
- Don't combine multiple features
- Keep it small enough to describe in one sentence

### Use Imperative Mood

```
✓ Add user authentication
✓ Fix login redirect loop
✗ Added user authentication
✗ Fixed the login bug
```

---

## Branch Strategy

### Prefer Trunk-Based Development

Work directly on the main branch or use short-lived feature branches:
- Main branch stays deployable
- Feature branches live for hours or days, never weeks

### Use Clear Branch Names

Names should describe the work:
- `feature/user-authentication`
- `fix/login-redirect-loop`
- `docs/readme-update`

Avoid: `work`, `tmp`, `fix1`, `branch`

### Delete Branches After Merge

Remove merged branches to keep the repo clean:
```bash
git branch -d branch-name
```

---

## Pull Request Craft

### Keep PRs Small and Focused

A good PR:
- Addresses one concern
- Fits in a few hundred lines of diff
- Can be reviewed in 10-15 minutes

### Write Descriptive PR Bodies

Include:
- What the change does
- Why it's needed
- Links to related issues
- Any testing done

### Respond to Reviews Promptly

- Address feedback directly
- Don't take criticism personally
- Ask for clarification when needed

---

## AI Agent Collaboration

### Rules for AI Agents

1. **Never auto-commit without approval** - show diffs first
2. **Always fetch before starting work** - confirm state is current
3. **Reference task context** - include issue/reason in commits
4. **Defer to human judgment** - especially on merge decisions
5. **Show meaningful diffs** - not whitespace-only changes

### When Working With Others

- Check for recent commits from others before making changes
- Communicate what you're working on to avoid collisions
- Don't assume you're the only one modifying the repo

---

## Repo Hygiene

### Maintain Thorough .gitignore

Keep the repo clean by ignoring:
- Build artifacts (`node_modules/`, `dist/`, `target/`)
- IDE files (`.vscode/`, `.idea/`)
- OS files (`.DS_Store`, `Thumbs.db`)
- Secrets and credentials (`*.env`, `secrets.json`)

### Avoid Committing Large Files

- Use Git LFS for binary assets
- Don't commit dependencies (use package managers)
- Keep the repo clone fast

### Never Commit Secrets

- Credentials belong in environment variables
- Use `.gitignore` to exclude config files with secrets
- Rotate exposed secrets immediately

---

## GitHub Features

### Branch Protection

Protect main branches by:
- Requiring review before merge
- Blocking force pushes
- Running CI checks

### Use GitHub Actions Wisely

- Keep workflows simple and fast
- Fail fast on important checks
- Cache dependencies when possible

### Use Copilot Instructions

Add repo-specific guidance in `.github/copilot-instructions.md` for code review and completion.

---

## Summary

1. **Always know the current state** - fetch before working
2. **Commit meaningfully** - explain why, not just what
3. **Keep branches short-lived** - merge quickly, delete after
4. **Resolve conflicts fully** - never push broken state
5. **For AI agents** - confirm state, show diffs, defer to humans