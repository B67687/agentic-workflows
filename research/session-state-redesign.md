---
title: Session State Redesign
date: 2026-05-16
status: proposed
author: B67687
---

## Problem

The current `session-state.json` is a single mutable JSON file at the repo root. It has three fundamental design flaws:

### 1. One file, one session — doesn't match reality

When working across multiple worktrees (e.g., one feature branch + one bugfix branch + one research exploration), there's exactly one state file. Each agent session overwrites the same path. There is no way to ask "what is the active session in worktree X?"

```
# Today: one file for everything
session-state.json  # was session 107, now session 108, history lost

# Needed: one file per session
.runtime/sessions/
  sess-feature-auth-20260516.json
  sess-fix-ci-20260516.json
  current-feature-auth -> sess-feature-auth-20260516.json  # per-worktree pointer
```

### 2. No enforcement — purely voluntary

Nothing enforces that state gets updated. The session lifecycle hooks (`hooks.json`, `session-start.sh`) *could* create and update state, but today they don't. The file is narrative metadata written by the agent as a courtesy — not a system boundary that anything depends on.

### 3. Narrative, not referential

`whatChanged` and `verification` are hand-written text. There's no enforced link to the actual git commits, branches, or PRs that were created. This means:
- It's unreliable for audit
- It can't be verified programmatically
- After a crash/resume, the agent has to re-derive what happened from git history anyway

## Proposed Architecture

### Per-session files

```
.runtime/sessions/
  sess-<id>.json            # created by git-agent.sh start, immutable after end
  active/                    # directory of symlinks per worktree path
    <hash-of-worktree-path> -> ../sess-<id>.json
```

Each session file is created at `git-agent.sh start` time with a stable session ID (already exists: `sess-${NAME}-${TIMESTAMP}`). It tracks:
- `id`, `name`, `branch`, `base_branch`, `worktree_path` (already in `sessions.json`)
- `commits`: populated by `git-agent.sh commit` hook — append the commit SHA after each commit
- `pr_url`: populated by `git-agent.sh end --pr`
- `started_at`, `ended_at`

### Lifecycle hook enforcement

The `hooks.json` already defines `SessionStart`, `PostToolUse`, `SubagentStart/Stop` events. Wire these to create/update the session state file automatically — no agent action required.

### Replace session-state.json with a lightweight index

```
session-state.json → .runtime/sessions/README.md  (or just delete it)
```

The root-level file becomes unnecessary when each session tracks itself.

### Git coupling

After `git-agent.sh end`, the session file records:
- Final commit SHA (the squash/merge commit)
- PR number
- Number of checkpoint commits made during session

This makes `archive/history-index.md` derivable from the session files rather than hand-written.

## Migration Path

1. Create `.runtime/sessions/` directory structure
2. Modify `git-agent.sh start` to write the session file (alongside `sessions.json`)
3. Add a `PostCommit` lifecycle hook that appends the commit SHA to the active session file
4. Modify `git-agent.sh end` to finalize the session file (add PR URL, end timestamp)
5. Update `session-start.sh` to look for an active session in the current worktree
6. After migration, deprecate `session-state.json`
