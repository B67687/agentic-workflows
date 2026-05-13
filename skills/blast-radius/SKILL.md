---
name: blast-radius
description: "Analyze the impact surface of a PR or set of changes before merging. Maps what changed, what else is affected, what could break, assigns risk level, and generates a manual verification checklist. The human gate for mixed human-agent teams. NOT for: code review (→ code-review-and-quality), running tests, or suggesting code changes."
trigger-phrases: blast radius, review this PR, what does this change affect, is this safe to merge, impact analysis, impact surface
handoffs: code-review-and-quality (for code quality review), qa-test / browser-testing-with-devtools (for browser verification)
companion-script: scripts/blast-radius.sh
---

# Blast Radius

Map the impact surface of changes. Help humans focus their limited attention on what matters before merging.

**Companion script:** `scripts/blast-radius.sh`
```bash
bash ./scripts/blast-radius.sh diff [pr]       # get the diff
bash ./scripts/blast-radius.sh intent "<text>"   # summarize intent
bash ./scripts/blast-radius.sh map <files...>    # map impact surface
bash ./scripts/blast-radius.sh risk <level>      # assess risk level
bash ./scripts/blast-radius.sh blindspots        # identify blind spots
bash ./scripts/blast-radius.sh checklist         # verification checklist
```

## Process

### 1. Get the Diff

- PR number → `gh pr diff <number>`
- Branch → `git diff main...<branch>`
- Nothing → `git diff main...HEAD`

### 2. Summarize Intent

In 1-2 sentences, state what the change is TRYING to do.

### 3. Map Impact Surface

**Direct changes:**
- What files changed, what functions/components modified
- What the behavioral change is

**Dependents (ripple effects):**
- What imports/calls/extends the changed code
- Trace 2 levels deep

**Shared state:**
- DB schema changes
- API contract changes
- Shared config, env vars, feature flags
- Global state, context providers, stores
- CSS/style changes affecting multiple components

**Test coverage gaps:**
- Which changed paths have tests?
- What's NOT tested that could break?

### 4. Assess Risk Level

| Level | When |
|-------|------|
| **LOW** — Merge confidently | Cosmetic, isolated leaf, new code, full coverage |
| **MEDIUM** — Test specific flows | Shared utilities, API routes, 3+ files, partial coverage |
| **HIGH** — Test everything | Auth/payments, DB migrations, API contracts, zero coverage |

### 5. Identify Blind Spots (MEDIUM/HIGH only)

Surface what static analysis CAN'T see:

- **Obscurity** — env vars, feature flags, runtime values, conditional logic by external state
- **Hidden dependencies** — event emitters, pub/sub, webhooks, dynamic dispatch, reflection
- **Change amplification** — external API consumers, shared DB tables, unknown subscribers

### 6. Generate Verification Checklist

```
□ [page/flow] — [what to verify] — [why it might break]
```

Include: happy paths, edge cases, regressions, blind spot items.

### 7. Flag Suspicious Patterns

- **Scope creep**: changes unrelated to stated intent
- **Orphaned code**: deleted exports possibly used dynamically
- **New dependencies**: necessary? Maintained? Secure?
- **Missing migrations**: schema changes without migration files
- **Hardcoded values**: magic numbers, URLs, credentials
- **Test gaps**: modified behavior without test updates

### 8. Present Findings

```
`★ Blast Radius ──────────────────────────────────`
Risk: [LOW/MEDIUM/HIGH]
Intent: [1-2 sentence summary]
  ├─ [top impact finding]
  └─ [key verification needed]
`─────────────────────────────────────────────────`
```

## Boundaries

- Read-only analysis — does NOT modify code
- Does NOT run tests (→ test scripts or qa-test)
- Does NOT assess code quality or style (→ code-review-and-quality)
- Does NOT re-implement or suggest code changes
- Only maps impact and helps humans decide
