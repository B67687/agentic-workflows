---
name: bash-explore
description: Use bash (find, grep, cat) for codebase exploration before falling back to Read/Grep tools. For bulk discovery bash is faster and more flexible. Switch to tools only after bash has narrowed the target.
---

# Bash-Hybrid Exploration

## Overview

Modern LLMs know how to use Unix commands naturally — `find`, `grep`, `cat`, `ls`,
`wc`, `sort`, `head`, `tail`.  Letting the agent use bash for *discovery* and then
switch to Read/Grep tools for *precision* gives the best of both approaches: fast
bulk traversal constrained by safety rails.

**Principle:** Bash for breadth, tools for depth.

```
┌──────────────────────────────────────────────────┐
│  1. Bash Discovery (find, grep, ls, cat)         │ ← bulk, fast, flexible
│     → "find . -name '*.py' | head -20"           │
│     → "grep -rl 'class.*Handler' src/"           │
├──────────────────────────────────────────────────┤
│  2. Tool Precision (Read, Grep, Glob)            │ ← targeted, safe, auditable
│     → Read the identified file                   │
│     → Grep for specific patterns within it       │
└──────────────────────────────────────────────────┘
```

## When to Use

- **Starting exploration** of an unfamiliar codebase
- **Bulk file discovery** (find all `.tsx` files, find files with a certain import)
- **Quick content checks** (does this file contain X?)
- **Pattern matching** across many files
- **Statistics** (line counts, file sizes, directory shapes)
- **Narrowing down** a large search space before reading specific files

## When NOT to Bash (use tools instead)

- **Editing files** — use Edit for precise, safe modifications
- **Reading a known file** — use Read (syntax highlighting, line numbers)
- **Small, targeted searches** — use Grep (pattern search with file context)
- **Writing code** — use Write for structured output

## Exploration Patterns

### 1. Directory Structure

```bash
# Top-level shape
ls -la
find . -maxdepth 2 -type d | sort

# File counts by extension
find . -name '*.py' | wc -l
find . -name '*.ts' -o -name '*.tsx' | wc -l
```

### 2. Find Specific Files

```bash
# By name
find . -name '*handler*'
find . -name '*test*' -type f

# By content
grep -rl 'def handle_' --include='*.py' .
grep -rl 'interface.*Props' --include='*.ts' .
```

### 3. Find Key Symbols

```bash
# Functions/classes
grep -rn '^func ' --include='*.go' .
grep -rn '^class ' --include='*.py' .
grep -rn '^export function' --include='*.ts' .
```

### 4. Find References

```bash
# Who calls this function?
grep -rn 'findUser(' --include='*.py' .

# Who imports this module?
grep -rn 'from mymodule import' --include='*.py' .
```

### 5. Size Assessment

```bash
# Largest files
find . -name '*.py' -exec wc -l {} + | sort -rn | head -10

# Total lines of code
find . -name '*.py' -exec cat {} + | wc -l
```

## After Bash Discovery

Once bash has identified the relevant file(s), switch to tools for precision:

1. `Read` the identified file for full context
2. `Grep` within it for specific patterns
3. `Glob` to verify file existence
4. `Edit` for modifications

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
