# Assumption Expiry --- Upwards Management Pattern

A mechanism for preventing stale assumptions from silently degrading agent quality by giving
every non-verifiable claim an expiry date and providing a downstream challenge process.

## Authority

This pattern synthesises four established principles in software engineering:

### 1. Technical Debt Quadrant --- Martin Fowler (2009)

> Fowler classifies debt as **prudent/reckless** × **deliberate/inadvertent**.
> The "prudent-inadvertent" quadrant is the key insight: even the best teams
> accumulate debt because you only know what the design should have been *after*
> building it. Assumptions made today are prudent; they become reckless if left
> unchecked as the environment changes.
>
> Source: [martinfowler.com/bliki/TechnicalDebtQuadrant.html](https://martinfowler.com/bliki/TechnicalDebtQuadrant.html)

Applied here: every `residualRisk` entry, every rule in AGENTS.md, and every
assumption in session-state.json is a **prudent-inadvertent debt** --- correct when
written, but with a half-life that depends on how fast the environment changes.

### 2. Lehman's Laws of Software Evolution --- Manny Lehman (1974)

> Lehman's Second Law (Increasing Complexity): "As an evolving program is
> continually changed, its complexity, reflecting deteriorating structure,
> increases unless work is done to maintain or reduce it."
>
> Source: Program Evolution: Processes of Software Change, Academic Press (1985)

Applied here: agent knowledge bases undergo the same entropy. The `session-state.json`,
AGENTS.md, and rule files must be treated as evolving programs --- not static documents.
Without active maintenance, their assumptions decay.

### 3. Software Rot / Active Rot --- Wikipedia

> Software that is being continuously modified may lose its integrity over time.
> Assumptions made by the original designers may be invalidated, thereby
> introducing bugs.
>
> Source: en.wikipedia.org/wiki/Software_rot

Applied here: separate *dormant rot* (unused assumptions that quietly decay) from
*active rot* (assumptions that are actively maintained but drift as context changes).
Detect-gaps.sh already tracks dormant rot (missing indexes). Assumption expiry
adds active-rot detection.

### 4. Design by Contract --- Bertrand Meyer (1986)

> Preconditions, postconditions, and invariants define a contract between
> client and supplier. The contract's assertions can be verified at runtime.
> The "fail hard" principle: when a precondition is violated, stop and report ---
> do not silently degrade.
>
> Source: Object-Oriented Software Construction, Prentice Hall (1988, 1997)

Applied here: `residualRisk` entries are **preconditions** that downstream operations
depend on. When a downstream operation (a new session, a `/implement` command) encounters
an expired assumption, it should "fail hard" --- flag it, don't silently accept it.

## The Pattern

### Core Idea

Every non-verifiable claim in the workspace carries an implicit `expiresAt` timestamp.
When a downstream operation encounters the claim, it checks the timestamp. If expired,
the operation:
1. Surfaces the expired claim
2. Recommends re-evaluation
3. Does NOT silently assume the claim still holds

### Assumption Tiers

| Tier | Examples | Default TTL | Mechanism |
|------|----------|-------------|-----------|
| P0 (hard) | Git config, file paths, tool paths | Never expires | Verified each session by hooks |
| P1 (stable) | Workspace structure rules, propagation contracts | 90 days | detect-gaps.sh checks expiry |
| P2 (contextual) | residualRisk, immediateNextSteps | 30-60 days | assumption-expiry.sh checks on each `/task` or session start |
| P3 (ephemeral) | Session-specific constraints, model preferences | 14 days | Logged to .learnings.jsonl, re-derived when needed |

### Where Assumptions Live

| File | Assumption Type | Current Problem | Fix |
|------|----------------|----------------|-----|
| `session-state.json` | `residualRisk`, `immediateNextSteps`, `resumeRules` | Static text that ages silently | Add `expiresAt` field to each block |
| `AGENTS.md` | Operating rules, Deep References | Rules written in one context may not apply later | Periodic review prompted by assumption-expiry.sh |
| `buglog.json` | Bug entries and fixes | Environment may have changed | Check each entry at session-start that it still applies |
| `docs/` | Guidelines and best practices | Version drift | assumption-expiry.sh flags docs older than their category TTL |

### Implementation

#### 1. `session-state.json` --- Add expiry metadata

```json
{
  "residualRisk": {
    "text": "agent-dispatch.sh only tested with pi (not codex/claude).",
    "expiresAt": "2026-06-12T00:00:00Z",
    "status": "active"
  },
  "assumptions": [
    {
      "claim": "Bubblewrap sandbox isolates network completely (no allowlist yet).",
      "expiresAt": "2026-07-12T00:00:00Z",
      "source": "session-73",
      "status": "active"
    }
  ]
}
```

If `expiresAt` is absent, defaults to:
- P2 entries created in the last 60 days: assumed active
- P2 entries older than 60 days: prompted for review
- P1 entries older than 90 days: prompted for review

#### 2. `scripts/assumption-expiry.sh` --- The checker script

```
Usage:
  bash ./scripts/assumption-expiry.sh check          # Check all assumptions
  bash ./scripts/assumption-expiry.sh review <id>     # Mark reviewed, reset expiry
  bash ./scripts/assumption-expiry.sh dismiss <id>    # Dismiss as still valid
  bash ./scripts/assumption-expiry.sh list            # List all with status
```

Output format:
```
OVERDUE: residualRisk (expired 2026-06-01) --- "agent-dispatch.sh only tested with pi..."
  -> Source: session-73
  -> Action: re-evaluate, update, or dismiss

EXPIRING SOON: assumptions[0] (expires 2026-07-12) --- "Bubblewrap sandbox..."
  -> Source: session-73
  -> Action: plan for review
```

#### 3. `detect-gaps.sh` integration

The existing `detect-gaps.sh` already checks:
- BM25 index freshness
- session-state.json staleness

Add a new check for expired assumptions.

#### 4. `.learnings.jsonl` integration

When an assumption is validated or overturned, log it as a learning:

```
{"ts":"2026-06-12","insight":"Assumption expired: agent-dispatch CLI tested \
 with pi, but codex is now installed. Updating."}
```

### Edge Cases

| Edge Case | Handling |
|-----------|----------|
| No expiry set | Default TTL from tier (P2 = 60d, P1 = 90d) |
| Multiple assumptions expire at once | Batch report, sorted by tier (P0 first) |
| Assumption re-verified early | Reset expiry to now + TTL |
| Assumption dismissed as no longer relevant | Move to `dismissed` status, keep in history |
| Session runs offline | Cache expiry check results; re-check on next online session |
| detect-gaps.sh runs daily | Expiry check is O(n) on assumption count; trivial cost |

### Verification

After implementing:
- [ ] `bash ./scripts/assumption-expiry.sh check` lists all assumptions with correct status
- [ ] Expired entries show OVERDUE with source and action
- [ ] Non-expired entries show no output (or "all assumptions current")
- [ ] `detect-gaps.sh` includes expired-assumption check
- [ ] Updating an assumption's `expiresAt` clears the OVERDUE status
- [ ] Agent correctly surfaces expired assumptions during normal work (not just script runs)

## References

1. Fowler, M. (2009). "Technical Debt Quadrant." martinfowler.com.
2. Lehman, M.M. (1985). *Program Evolution: Processes of Software Change*. Academic Press.
3. Meyer, B. (1988). *Object-Oriented Software Construction*. Prentice Hall.
4. Cunningham, W. (1992). "The WyCash Portfolio Management System." OOPSLA.
5. Wikipedia. "Software rot." --- Active rot vs dormant rot classification.
6. This workspace: `doubt-driven-development` skill --- adversarial review pattern.
7. This workspace: `docs/session-checkpoint.md` --- context pressure management.
