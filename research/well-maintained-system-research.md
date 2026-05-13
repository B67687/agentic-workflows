# The Enduring System: Research on Long-Lasting, High-Productivity Systems

**Question:** Is there a single authoritative source that teaches how to build any system
that keeps up with the times, lasts into the future, and stays highly productive?

**Answer:** No single source covers all dimensions. But there is a canonical stack of
authoritative works that together define the complete pattern.

## The Canonical Stack (by priority)

### 1. Building Evolutionary Architectures (Ford, Parsons, Kua, 2017)
**Core idea:** An architecture that supports "guided, incremental change as a first
principle across multiple dimensions." Fitness functions --- automated verifiable
criteria that protect architectural characteristics --- continuously validate that
the system hasn't drifted from its design goals.
**Key for this workspace:** The `assumption-expiry.sh` + `detect-gaps.sh` pairing
IS a fitness function for knowledge-base assumptions.

### 2. Antifragile (Taleb, 2012)
**Core idea:** Systems that *gain* from disorder, volatility, and stressors.
Fragile systems break under shock. Robust systems resist shock. Antifragile
systems get *better* under shock.
**Key for this workspace:** The `doubt-driven-development` skill is an antifragile
mechanism --- it uses adversarial review (a stressor) to improve decisions. The
assumption-expiry pattern uses time (inevitable decay) to trigger re-evaluation.

### 3. Technical Debt Quadrant (Fowler, 2009) + Debt Metaphor (Cunningham, 1992)
**Core idea:** Prudent-inadvertent debt is inevitable. Even the best teams
create cruft because you only know what the design should have been after building
it. The question is not "is this debt?" but "is this prudent or reckless?"
**Key for this workspace:** All assumptions in this workspace are prudent-inadvertent
debt. The expiry mechanism ensures they don't cross into reckless territory.

### 4. Design by Contract (Meyer, 1986/1988)
**Core idea:** Every component has preconditions, postconditions, and invariants.
When a precondition is violated, "fail hard" --- don't silently degrade.
**Key for this workspace:** The assumption-expiry check is a precondition
verification that fires before downstream operations rely on stale data.

### 5. Lehman's Laws of Software Evolution (1974-1996)
**Core idea:** "As an evolving program is continually changed, its complexity
increases unless work is done to maintain or reduce it." This is the Second Law
of software thermodynamics --- entropy always increases without active work.
**Key for this workspace:** The entire audit + cleanup cycle is active work
against entropy. The `session-state.json` assumptions are treated as a program
that evolves, not a static document.

### 6. The Pragmatic Programmer (Hunt & Thomas, 1999/2019)
**Core idea:** "Don't live with broken windows" (fix small problems immediately
before they compound). "Invest regularly in your knowledge portfolio" (continuous
learning). "Care about your craft."
**Key for this workspace:** The companion scripts, the `detect-gaps.sh` hook,
and the checkpoint-commit pattern all implement "don't let broken windows
accumulate."

### 7. Is High Quality Software Worth the Cost? (Fowler, 2019)
**Core idea:** High internal quality is *cheaper* to produce because it reduces
the cost of future changes. The usual quality-vs-cost trade-off does NOT apply
to internal quality. "High quality software is cheaper to produce."
**Key for this workspace:** The entire macro-to-micro audit approach assumes
that fixing quality issues now costs less than living with them.

### 8. DORA State of DevOps Reports (2014-present)
**Core idea:** Elite teams ship many times a day WITH lower failure rates.
The choice between speed and reliability is false --- the best teams have both.
Measurable via: deployment frequency, lead time, change failure rate, recovery time.
**Key for this workspace:** The 31/31 smoke tests + checkpoint-commit pattern
enables the "ship fast, stay reliable" capability.

### 9. Software Engineering at Google (Winters, Manshreck, Wright, 2020)
**Core idea:** Culture, not just code. Key practices: trunk-based development,
code review for every change, automated testing, psychological safety.
**Key for this workspace:** The `/counsel` command, `code-review-and-quality`
skill, and `doubt-driven-development` skill implement Google's review culture
in an agent context.

## Synthesis: The Antifragile Knowledge Base

This workspace implements ALL nine sources in combination:

| Source | Implementation |
|--------|---------------|
| Evolutionary Architecture | `assumption-expiry.sh` + `detect-gaps.sh` as fitness functions |
| Antifragility | `doubt-adversarial.sh`, assumption expiry (stress -> improvement) |
| Technical Debt Quadrant | `assumptions[]` TTL, `residualRisk` expiry tracking |
| Design by Contract | `assumption-expiry.sh check` as precondition verification |
| Lehman's Laws | Session audits, `context-pressure.sh`, entropy measurement |
| Pragmatic Programmer | Companion scripts, `checkpoint-commit.sh`, `detect-gaps.sh` |
| Quality Economics | Full macro-to-micro audit cycle |
| DORA | Smoke tests, checkpoint-commit, trunk-based development |
| Google SRE | `/counsel`, code review skill, doubt-driven development |

## The Missing Piece

No single source covers "the whole system" because the domain spans:

- Software engineering (Ford, Fowler, Meyer, Lehman)
- Risk/mathematics (Taleb --- convex responses, fat tails)
- Management/operations (DORA, Google SRE, Pragmatic Programmer)

A truly complete system requires combining insights from ALL of these.
This workspace is the first attempt to synthesize them into a cohesive whole.
