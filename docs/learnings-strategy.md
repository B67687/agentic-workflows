# Learnings Strategy: Memory Convergence

Three storage formats serve different purposes. This doc explains the boundaries so you know which to read/write.

## The Three Stores

| Store | Format | Purpose | Created by | When to read |
|-------|--------|---------|------------|--------------|
| `buglog.json` | JSON (structured) | Track bugs and their root causes | Agent debugging | Before fixing a bug --- check for same error |
| `.learnings.jsonl` | JSONL (append) | Durable cross-session insights, patterns, decisions | `learnings-save.sh` | At session start --- recall prior context |
| `.tap/learnings.md` | Markdown (append) | Retrospective learnings focused on agent autonomy | `retrospective` skill | Before starting work in a repo --- check past failures |

## Boundary Rules

| If you want to... | Write to... |
|---|---|
| Record a bug fix (error + root cause + file) | `buglog.json` |
| Save a durable pattern, preference, or decision | `.learnings.jsonl` (via `learnings-save.sh`) |
| Capture what blocked agent autonomy this session | `.tap/learnings.md` (appended by `retrospective`) |
| Search past learnings | `bash ./scripts/learnings-search.sh <query>` (searches .learnings.jsonl) |
| Check for prior bug occurrences | `buglog.json` (grep for error message) |

## DO NOT

- Do NOT duplicate entries across stores
- Do NOT write to `.tap/learnings.md` from the `tighten-loop` skill (it only appends if the file already exists)
- Do NOT overwrite any of these files --- all three are append-only
- Do NOT create `.tap/learnings.md` from outside the `retrospective` skill
