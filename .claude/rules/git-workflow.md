---
description: Git workflow conventions for this project.
paths:
  - "**/*"
---

# Git Workflow

## Commit discipline

- Commit after every meaningful change automatically
- Use `bash ./scripts/checkpoint-commit.sh -m "summary"` — never raw `git commit`
- For push: use `/home/namikaz/.local/bin/git-safe-push`
- For PR creation: use `/home/namikaz/.local/bin/gh-safe-pr-create`

## Branch strategy

- Quick fixes: commit directly on main
- Multi-file tasks: use `session-fork.sh` to create isolated worktrees
- Always close dead branches explicitly with `/session close-task`

## Identity

- Global Git identity: `B67687 <111849193+B67687@users.noreply.github.com>`
- Never set `GIT_AUTHOR_*` or `GIT_COMMITTER_*` environment variables
- Never use `git commit --author`
