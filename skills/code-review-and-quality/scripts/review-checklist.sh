#!/usr/bin/env bash
# =============================================================================
# review-checklist.sh — Companion script for Code Review and Quality
#
# Generates a structured multi-axis review template. Use before any merge.
# Covers the five axes: correctness, readability, architecture, security,
# performance.
#
# Usage:
#   bash ./scripts/review-checklist.sh template
#     Output a blank review template for manual filling.
#
#   bash ./scripts/review-checklist.sh diff <file-or-commit-range>
#     Generate a review template pre-filled with git diff info.
#     Examples:
#       bash ./scripts/review-checklist.sh diff HEAD
#       bash ./scripts/review-checklist.sh diff HEAD~1
#       bash ./scripts/review-checklist.sh diff main..feature
#
#   bash ./scripts/review-checklist.sh check <file>
#     Quick verification: links to related security/perf skills.
# =============================================================================

set -euo pipefail

MODE="${1:-template}"
TARGET="${2:-}"

case "$MODE" in
  template)
    # Blank review template
    cat << "TEMPLATE"
# Code Review

## Change Summary
<!-- What does this change do? One paragraph. -->

## Files Changed
<!-- List files and their role in the change. -->

---

## 1. Correctness
<!-- Does the code do what it claims to do? -->
- [ ] Matches spec/task requirements
- [ ] Edge cases handled (null, empty, boundary)
- [ ] Error paths handled (not just happy path)
- [ ] Tests exist and test the right things
- [ ] No off-by-one, race conditions, state inconsistencies

## 2. Readability & Simplicity
<!-- Can another engineer understand this without help? -->
- [ ] Names are descriptive and consistent
- [ ] Control flow is straightforward
- [ ] No "clever" tricks that should be simplified
- [ ] Abstractions earn their complexity (don't generalize until 3rd use)
- [ ] Dead code artifacts removed (no-ops, shims, removed comments)

## 3. Architecture
<!-- Does the change fit the system's design? -->
- [ ] Follows existing patterns (or justifies new ones)
- [ ] Maintains clean module boundaries
- [ ] No code duplication that should be shared
- [ ] Dependencies flow in the right direction

## 4. Security
<!-- See security-and-hardening skill for depth. -->
- [ ] User input validated and sanitized
- [ ] Secrets kept out of code, logs, and version control
- [ ] Auth/authorization checked where needed
- [ ] SQL queries parameterized (no string concatenation)
- [ ] Outputs encoded to prevent XSS
- [ ] External data treated as untrusted

## 5. Performance
<!-- See performance-optimization skill for depth. -->
- [ ] No N+1 query patterns
- [ ] No unbounded loops or unconstrained data fetching
- [ ] Sync/async appropriate
- [ ] Pagination on list endpoints

---

## Findings

| Severity | File | Finding |
|----------|------|---------|
| Critical | | |
| Required | | |
| Consider | | |
| Nit | | |
| FYI | | |

**Severity guide:**
- *(no prefix)* = Required change — must address before merge
- **Critical:** = Blocks merge — security, data loss, broken functionality
- **Nit:** = Minor — formatting, style preferences
- **Consider:** = Suggestion worth considering
- **FYI** = Informational only

## Verification
- [ ] Build passes
- [ ] Tests pass
- [ ] Manual verification done
- [ ] Screenshots attached (for UI changes)

## Verdict
- [ ] Approve — improves overall code health
- [ ] Changes requested — address findings before merge
- [ ] Blocked — critical issues must be resolved
TEMPLATE
    ;;

  diff)
    # Pre-filled template from git diff
    if [ -z "$TARGET" ]; then
      echo "Usage: $0 diff <commit-or-range>" >&2
      echo "Example: $0 diff HEAD~1" >&2
      exit 1
    fi

    DIFF_STATS=$(git diff --stat "$TARGET" 2>/dev/null || git diff "$TARGET" --stat 2>/dev/null || echo "Could not get diff stats")
    DIFF_CONTENT=$(git diff "$TARGET" 2>/dev/null || git diff "$TARGET" 2>/dev/null || echo "")
    FILES_CHANGED=$(echo "$DIFF_STATS" | grep -v '^$' | wc -l | tr -d ' ')
    LINES_CHANGED=$(echo "$DIFF_STATS" | tail -1 | grep -oP '\d+' | head -1 || echo "?")

    # Sizing advice
    if [ "$LINES_CHANGED" -gt 1000 ] 2>/dev/null; then
      SIZE_WARN="⚠ VERY LARGE (>1000 lines). Consider splitting."
    elif [ "$LINES_CHANGED" -gt 300 ] 2>/dev/null; then
      SIZE_WARN="⚠ Large (>300 lines). Could this be split?"
    else
      SIZE_WARN="✓ Size looks reviewable."
    fi

    cat << TEMPLATE
# Code Review

## Change Summary

## Diff Info
- Files changed: ${FILES_CHANGED}
- Lines changed: ${LINES_CHANGED}
- ${SIZE_WARN}

## Files Changed
$(echo "$DIFF_STATS")

---

## 1. Correctness

- [ ] Matches spec/task requirements
- [ ] Edge cases handled
- [ ] Error paths handled
- [ ] Tests exist

## 2. Readability & Simplicity

- [ ] Names descriptive and consistent
- [ ] Control flow straightforward
- [ ] No "clever" tricks
- [ ] Dead code removed

## 3. Architecture

- [ ] Follows existing patterns
- [ ] Clean module boundaries
- [ ] No code duplication

## 4. Security

- [ ] Input validated
- [ ] Secrets in check
- [ ] Auth checked

## 5. Performance

- [ ] No N+1 queries
- [ ] No unbounded loops

---

## Findings
<!-- Move each finding row to the table as you review. -->

| Severity | File | Finding |
|----------|------|---------|
| ... | ... | ... |

## Verdict
- [ ] Approve
- [ ] Changes requested
- [ ] Blocked
TEMPLATE
    ;;

  check)
    # Quick quality check reference
    cat << "HELP"
Quality check reference for code-review-and-quality skill:

Skill dependencies for deeper analysis:
  security-and-hardening   → security/  skill
  performance-optimization → performance/ skill
  code-simplification      → simplify/  skill

Quick checks:
  Static analysis:  grep -rn "TODO\|FIXME\|HACK\|XXX" src/
  Secrets leak:     git diff HEAD | grep -i "password\|secret\|api.key\|token"
  Large files:      find src/ -type f -size +500k
  Test coverage:    npm test -- --coverage
HELP
    ;;

  *)
    echo "Usage: $0 {template|diff|check} [target]"
    echo ""
    echo "  template          — Output blank review template"
    echo "  diff <range>      — Generate review from git diff"
    echo "  check             — Quick quality check reference"
    exit 1
    ;;
esac
