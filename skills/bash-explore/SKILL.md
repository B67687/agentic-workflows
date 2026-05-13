---
name: bash-explore
description: Use bash (find, grep, cat) for codebase exploration before falling back to Read/Grep tools. For bulk discovery bash is faster and more flexible. Switch to tools only after bash has narrowed the target.
trigger-phrases: find files, search codebase, explore repo, look for, where is, grep for, find in files
handoffs: context-engineering (to set up context), using-agent-skills (to pick a skill)
---

# Bash-Hybrid Exploration

## Overview

Modern LLMs know how to use Unix commands naturally --- `find`, `grep`, `cat`, `ls`,
`wc`, `sort`, `head`, `tail`.  Letting the agent use bash for *discovery* and then
switch to Read/Grep tools for *precision* gives the best of both approaches: fast
bulk traversal constrained by safety rails.

**Principle:** Bash for breadth, tools for depth.

```
┌──────────────────────────────────────────────────┐
│  1. Bash Discovery (find, grep, ls, cat)         │ <- bulk, fast, flexible
│     -> "find . -name '*.py' | head -20"           │
│     -> "grep -rl 'class.*Handler' src/"           │
├──────────────────────────────────────────────────┤
│  2. Tool Precision (Read, Grep, Glob)            │ <- targeted, safe, auditable
│     -> Read the identified file                   │
│     -> Grep for specific patterns within it       │
└──────────────────────────────────────────────────┘
```

## Directory Exclusion

Always exclude noise directories from bash searches (especially `.git/`):

```bash
# Good: excludes .git/
find . -name '*.py' -not -path './.git/*'
grep -rn 'pattern' --include='*.py' .          # --include auto-excludes .git in most configs
find . -name '*.py' -not -path './.git/*' | wc -l

# Avoid: searches .git/ unnecessarily
# find . -name '*.py' | wc -l                   # includes .git/
```

The companion `core/explore.py` script handles exclusion automatically via `_workspace_files.py`. When using ad-hoc bash, add `-not -path './.git/*'` explicitly.

## If a Command Fails

| Symptom | Fix |
|---|---|
| `Permission denied` errors | Add `2>/dev/null` to suppress: `find . -name '*.py' 2>/dev/null` |
| No matches found | Broaden the search — remove `--include` filters, lower `-maxdepth`, or use a simpler pattern |
| `command not found` | The tool isn't available in this environment. Fall back to **Grep** (content search) or **Glob** (file lookup) tools for this step. |
| Output is too large | Pipe through `head -20` or `grep -v` to filter noise. Re-run with tighter constraints. |

## When to Use

- **Starting exploration** of an unfamiliar codebase
- **Bulk file discovery** (find all `.tsx` files, find files with a certain import)
- **Quick content checks** (does this file contain X?)
- **Pattern matching** across many files
- **Statistics** (line counts, file sizes, directory shapes)
- **Narrowing down** a large search space before reading specific files

## When NOT to Bash (use tools instead)

- **Editing files** --- use Edit for precise, safe modifications
- **Reading a known file** --- use Read (syntax highlighting, line numbers)
- **Small, targeted searches** --- use Grep (pattern search with file context)
- **Writing code** --- use Write for structured output

## Quick Reference

| Goal | Command |
|---|---|
| Count files by extension | `find . -name '*.ext' -not -path './.git/*' \| wc -l` |
| Find files by name | `find . -name '*pattern*' -not -path './.git/*'` |
| Find content in files | `grep -rn 'pattern' --include='*.ext' .` |
| Find function/class defs | `grep -rn '^def \|^func \|^class \|^export function' --include='*.ext' .` |
| Find references to a symbol | `grep -rn 'symbol' --include='*.ext' .` |
| Largest files by line count | `find . -name '*.ext' -exec wc -l {} + \| sort -rn \| head -10` |
| Directory tree (top 2 levels) | `find . -maxdepth 2 -type d \| sort` |

Replace `.ext` with the target extension (`.py`, `.ts`, `.go`, etc.). For multiple extensions, pass multiple `--include` or use `-o` with find. Always add `-not -path './.git/*'` to exclude .git/ from find results.

## After Bash Discovery

Once bash has isolated the relevant files, switch to tools for precision:

1. **Read** the identified file for full context
2. **Grep** within it for specific patterns
3. **Glob** to verify file existence
4. **Edit** for modifications

## Companion Script: `core/explore.py`

Wraps common discovery with edge case and noise handling. Auto-excludes `.git/` and known noise directories.

```bash
python3 core/explore.py find-by-content 'pattern' --ext .py .ts
python3 core/explore.py file-stats
```

## Why Hybrid (Not Bash-Only)

Pure bash exploration (like mini-SWE-agent) removes all guardrails:

| Concern | Tool-Based | Bash-Only |
|---------|-----------|-----------|
| Safety | Commands are audited, scoped | Full shell access |
| Cost | Tool calls show token usage | Bash runs invisibly |
| Reproducibility | Tool calls are structured | Bash output varies |
| Error handling | Structured error responses | Raw stderr |

The hybrid approach keeps safety rails for dangerous operations while giving bash
for the high-value bulk discovery operations that tools handle poorly.
