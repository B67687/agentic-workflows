---
name: code-review-and-quality
description: Conducts multi-axis code review. Use before merging any change. Use when reviewing code written by yourself, another agent, or a human. Use when you need to assess code quality across multiple
  dimensions before it enters the main branch.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob, edit, lsp
metadata:
  companion-script: scripts/review-checklist.sh
  handoffs: debugging-and-error-recovery (to fix issues), code-simplification (to simplify)
  trigger-phrases: review this, code review, quality check, review my code, is this good, check for issues
  pattern: reviewer
  bundle: verify
---
# Code Review and Quality

Companion script: `scripts/review-checklist.sh`

## Overview

Multi-dimensional code review with quality gates. Every change gets reviewed before merge --- no exceptions. Review covers five axes: correctness, readability, architecture, security, and performance.

**The approval standard:** Approve a change when it definitely improves overall code health, even if it isn't perfect. Perfect code doesn't exist --- the goal is continuous improvement. Don't block a change because it isn't exactly how you would have written it. If it improves the codebase and follows the project's conventions, approve it.

## When to Use

- Before merging any PR or change
- After completing a feature implementation
- When another agent or model produced code you need to evaluate
- When refactoring existing code
- After any bug fix (review both the fix and the regression test)

## The Five-Axis Review

Every review evaluates code across these dimensions. See the full checklist at
`references/review-checklist.md` (L3) --- load with:
`bash ./scripts/skill-toolset.sh resource code-review-and-quality references/review-checklist.md`

The five axes are:
1. **Correctness** --- spec match, edge cases, error paths, test quality
2. **Readability & Simplicity** --- clear names, straightforward flow, no dead code
3. **Architecture** --- pattern fit, module boundaries, dependency direction
4. **Security** --- input validation, secrets, auth, injection prevention
5. **Performance** --- N+1 queries, unbounded ops, sync/async correctness

Before the manual five-axis review, run automated AST analysis (Step 3.5) to catch
structural issues the manual review might miss.

## Change Sizing

Small, focused changes are easier to review. Target ~100 lines; split anything over 300. Keep refactoring and feature work in separate changes.

## Review Process

### Step 1: Understand the Context

Before looking at code, understand the intent:

```
- What is this change trying to accomplish?
- What spec or task does it implement?
- What is the expected behavior change?
```

### Step 2: Review the Tests First

Tests reveal intent and coverage:

```
- Do tests exist for the change?
- Do they test behavior (not implementation details)?
- Are edge cases covered?
- Do tests have descriptive names?
- Would the tests catch a regression if the code changed?
```

### Step 3: Review the Implementation

Walk through the code with the five axes in mind:

```
For each file changed:
1. Correctness: Does this code do what the test says it should?
2. Readability: Can I understand this without help?
3. Architecture: Does this fit the system?
4. Security: Any vulnerabilities?
5. Performance: Any bottlenecks?
```

### Step 3.5: Automated Analysis (AST Pattern Detection)

Augment manual review with automated pattern detection. These commands work
without a full language server and catch structural issues the eye misses.

```bash
# 1. Deeply nested conditionals (complexity indicator)
grep -rn 'if.*if.*if' --include='*.py' --include='*.ts' --include='*.js' .

# 2. Function length indicators (excessive lines)
for f in $(find . -name '*.py' -not -path './.*'); do
  grep -n '^def \|^class ' "$f" | while IFS=: read linenum name; do
    nextline=$(tail -n +$((linenum+1)) "$f" | grep -n '^def \|^class \|^$' | head -1 | cut -d: -f1)
    [ -n "$nextline" ] && [ "$nextline" -gt 60 ] && echo "LONG: $f:$linenum ($nextline lines)"
  done
done

# 3. Hardcoded configuration (magic numbers/strings)
grep -rnE '\b[0-9]{4,}\b' --include='*.py' --include='*.ts' --include='*.js' . | grep -v '__pycache__\|node_modules'

# 4. Unused imports (single-file check)
for f in $(find . -name '*.py' -not -path './.*'); do
  for imp in $(grep '^import \|^from ' "$f" 2>/dev/null | sed 's/^import //;s/^from \([^ ]*\) import.*/\1/' | tr -d ' '); do
    mod=$(echo "$imp" | sed 's/\..*$//')
    grep -q "$mod\." "$f" 2>/dev/null || echo "UNUSED: $mod in $f"
  done
done

# 5. Structure overview via repo-map (uses tree-sitter AST if installed)
if [ -f "scripts/repo-map.py" ]; then
  python3 scripts/repo-map.py --max-tokens 512 --scope "$(pwd)" 2>/dev/null || true
fi
```

**Source pattern:** AST-based code analysis inspired by [tree-sitter/tree-sitter](https://github.com/tree-sitter/tree-sitter)
and the code understanding approaches in Aider's repo-map ([Aider-AI/aider](https://github.com/Aider-AI/aider)).

### Step 4: Categorize Findings

Label every comment with its severity (see severity table in `references/review-checklist.md`).
This prevents authors from treating all feedback as mandatory and wasting time on
optional suggestions.

### Step 5: Verify the Verification

Check the author's verification story:

```
- What tests were run?
- Did the build pass?
- Was the change tested manually?
- Are there screenshots for UI changes?
- Is there a before/after comparison?
```

## Multi-Model Pattern

For critical reviews: one model writes, another reviews (correctness + architecture), human makes the final call.

## Dead Code Hygiene

After refactoring, check for orphaned code. Identify it, list it, and ask before deleting --- but don't leave dead code behind.

## Review Speed

Respond within one business day. Fast individual responses matter more than quick approval. Ask the author to split large changes.

## Handling Disagreements

When resolving review disputes, apply this hierarchy:

1. **Technical facts and data** override opinions and preferences
2. **Style guides** are the absolute authority on style matters
3. **Software design** must be evaluated on engineering principles, not personal preference
4. **Codebase consistency** is acceptable if it doesn't degrade overall health

**Don't accept "I'll clean it up later."** Experience shows deferred cleanup rarely happens. Require cleanup before submission unless it's a genuine emergency. If surrounding issues can't be addressed in this change, require filing a bug with self-assignment.

## Honesty in Review

When reviewing code --- whether written by you, another agent, or a human:

- **Don't rubber-stamp.** "LGTM" without evidence of review helps no one.
- **Don't soften real issues.** "This might be a minor concern" when it's a bug that will hit production is dishonest.
- **Quantify problems when possible.** "This N+1 query will add ~50ms per item in the list" is better than "this could be slow."
- **Push back on approaches with clear problems.** Sycophancy is a failure mode in reviews. If the implementation has issues, say so directly and propose alternatives.
- **Accept override gracefully.** If the author has full context and disagrees, defer to their judgment. Comment on code, not people --- reframe personal critiques to focus on the code itself.

## Dependency Discipline

When reviewing new dependencies: does the existing stack solve this? Is it maintained? Any known vulnerabilities? Prefer standard library over new dependencies.

## Review Checklist Template

Use the companion script for a full structured template: `scripts/review-checklist.sh`

Key review axes to verify: correctness (spec match, edge cases, error paths), readability (clear naming, straightforward logic), architecture (existing patterns, no unnecessary coupling), security (secrets, input validation, injection), performance (N+1 queries, unbounded ops).

## See Also

- Detailed 5-axis checklist: `references/review-checklist.md` (L3)
- For security review: `bash ./scripts/skill-toolset.sh resource security-and-hardening references/security-checklist.md`
- For performance checks: `bash ./scripts/skill-toolset.sh resource performance-optimization references/performance-budget.md`

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It works, that's good enough" | Working code that's unreadable, insecure, or architecturally wrong creates debt that compounds. |
| "I wrote it, so I know it's correct" | Authors are blind to their own assumptions. Every change benefits from another set of eyes. |
| "We'll clean it up later" | Later never comes. The review is the quality gate --- use it. Require cleanup before merge, not after. |
| "AI-generated code is probably fine" | AI code needs more scrutiny, not less. It's confident and plausible, even when wrong. |
| "The tests pass, so it's good" | Tests are necessary but not sufficient. They don't catch architecture problems, security issues, or readability concerns. |
| "I read the diff, it looks fine" | Reading surface tokens is not reviewing. Read the diff like a junior engineer wrote it --- would you approve it on the strength of "looks right"? If you did not evaluate correctness, edge cases, architecture, and security independently, you ratified, not reviewed. |

## Red Flags

- PRs merged without any review
- Review that only checks if tests pass (ignoring other axes)
- "LGTM" without evidence of actual review
- Security-sensitive changes without security-focused review
- Large PRs that are "too big to review properly" (split them)
- No regression tests with bug fix PRs
- Review comments without severity labels --- makes it unclear what's required vs optional
- Accepting "I'll fix it later" --- it never happens

## Verification

After review is complete:

- [ ] All Critical issues are resolved
- [ ] All Important issues are resolved or explicitly deferred with justification
- [ ] Tests pass
- [ ] Build succeeds
- [ ] The verification story is documented (what changed, how it was verified)
