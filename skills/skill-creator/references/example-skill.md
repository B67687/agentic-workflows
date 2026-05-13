# Example: valid SKILL.md (code-review-and-quality)

This is a real skill from the agentic-workflows hub. It demonstrates all
spec-compliant fields including optional compatibility, allowed-tools,
and metadata custom fields.

## Frontmatter

```yaml
---
name: code-review-and-quality
description: Conducts multi-axis code review. Use before merging any change. Use when reviewing code written by yourself, another agent, or a human. Use when you need to assess code quality across multiple dimensions before it enters the main branch.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob, edit
metadata:
  companion-script: scripts/review-checklist.sh
  handoffs: debugging-and-error-recovery (to fix issues), code-simplification (to simplify)
  trigger-phrases: review this, code review, quality check, review my code, is this good, check for issues
  pattern: reviewer
  bundle: verify
---
```

## Body structure

```markdown
# Code Review and Quality

## Overview
Multi-dimensional code review with quality gates. Every change gets reviewed
before merge. Review covers five axes: correctness, readability, architecture,
security, and performance.

## When to Use
- Before merging any PR or change
- After completing a feature implementation
- When another agent or model produced code you need to evaluate
- After any bug fix (review both the fix and the regression test)

## The Five-Axis Review
Load the full checklist via L3 reference:
`bash ./scripts/skill-toolset.sh resource code-review-and-quality references/review-checklist.md`

## Review Process
### Step 1: Understand the Context
Before looking at code, understand the intent.

### Step 2: Review the Tests First
Tests reveal intent and coverage.

### Step 3: Review the Implementation
Walk through the code with the five axes in mind.

### Step 4: Categorize Findings
Label every comment with severity.

### Step 5: Verify the Verification

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| "It works, that's good enough" | Working code that's unreadable creates debt. |
| "The tests pass, so it's good" | Tests don't catch architecture or security issues. |
```

## Directory structure for this skill

```
code-review-and-quality/
├── SKILL.md                  # Frontmatter + orchestration instructions
├── references/
│   └── review-checklist.md   # L3: full 5-axis checklist
└── scripts/
    └── review-checklist.sh   # L3: companion automation
```
