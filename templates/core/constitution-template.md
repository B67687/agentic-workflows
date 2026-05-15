---
version: "1.0"
ratified: "RATIFICATION_DATE"
articles: 9
amendments: 0
---

# [WORKSPACE] Constitution

> **Purpose**: This constitution encodes the immutable principles governing how work proceeds in this workspace.

---

## Preamble

This workspace exists to [PURPOSE]. The following articles establish the non-negotiable principles that govern all work within it.

Each article defines:
- **Principle** — the core rule
- **Gate** — the specific check that enforces it (BLOCKING or ADVISORY)
- **Enforcement** — when and how the gate runs
- **Rationale** — why this principle exists

---

## Article I: Macro-to-Micro

> **Understand the system before changing it.**

### Section 1.1: Principle
Before any implementation, the agent must understand the system at four levels: architecture, domain, module, root cause.

### Section 1.2: Gate — System Understanding (BLOCKING)
- `[ ]` Research note exists identifying the affected system architecture
- `[ ]` Relevant source files have been read (not just searched)
- `[ ]` The specific failure or change point is localized before any edit

### Section 1.3: Enforcement
`phase-gate.sh plan --constitution` checks for research note with architecture section. `phase-gate.sh implement --constitution` checks that relevant files were read.

### Section 1.4: Rationale
Skipping system understanding is the #1 cause of wrong-file edits and regression-inducing changes.

---

## Article II: Verify Aggressively

> **Verification is the quality engine. Every change must prove itself.**

### Section 2.1: Principle
No change is complete without verification. "Looks right" is not verification.

### Section 2.2: Gate — Verification Required (BLOCKING)
- `[ ]` Every task has a verification target defined before implementation
- `[ ]` Verification is specific, not vague ("make it work")
- `[ ]` Manual verification steps are documented when automated tests are not possible

### Section 2.3: Enforcement
`phase-gate.sh implement --constitution` checks that verification targets exist.

### Section 2.4: Rationale
Without explicit verification, "done" is subjective.

---

## Article III: Checkpoint Discipline

> **Commit after every verified phase.**

### Section 3.1: Principle
After every verified phase, create a checkpoint commit. Large commits hide bugs.

### Section 3.2: Gate — Checkpoint Required (ADVISORY)
- `[ ]` After each verified phase, a checkpoint commit was created
- `[ ]` Commit messages describe what changed and why
- `[ ]` No more than one phase of work is uncommitted at any time

### Section 3.3: Enforcement
`checkpoint-commit.sh` is the required commit path.

### Section 3.4: Rationale
Uncommitted work is at risk. Checkpoints enable surgical rollback.

---

## Article IV: CATFISH First

> **Challenge the plan with structured dissent before implementing.**

### Section 4.1: Principle
Before any non-trivial implementation, the plan must be subjected to adversarial challenge using counterfactual post-mortem framing.

### Section 4.2: Gate — Dissent Required (BLOCKING for non-trivial work)
- `[ ]` Plan guard was run with `--challenge` flag
- `[ ]` Challenge findings were reconciled (PASS, FAIL, or WARN with residual risk documented)
- `[ ]` No unaddressed blocking findings remain before implementation

### Section 4.3: Enforcement
`phase-gate.sh implement --constitution` checks for reconciled challenge response.

### Section 4.4: Rationale
Fresh-context dissent catches 23% more failure modes than same-context review.

---

## Article V: Comprehension Gate

> **Enforced participation before action.**

### Section 5.1: Principle
Before implementing, the agent must demonstrate comprehension by producing structured evidence.

### Section 5.2: Gate — Evidence Required (BLOCKING)
- `[ ]` Comprehension evidence file exists at `.runtime/comprehension-evidence.md`
- `[ ]` All required sections are filled with task-relevant content
- `[ ]` Evidence includes: verification target, anti-rationalization, red flag, out-of-scope

### Section 5.3: Enforcement
`phase-gate.sh implement --constitution` runs `comprehension-gate.sh verify`.

### Section 5.4: Rationale
Without enforced participation, agents fill gaps with plausible defaults.

---

## Article VI: Simplicity Criterion

> **All else equal, simpler is better.**

### Section 6.1: Principle
Does this make the system simpler or more complex? If more complex, the improvement must be proportional.

### Section 6.2: Gate — Simplicity Check (ADVISORY)
- `[ ]` No speculative or "might need" features were added
- `[ ]` No over-engineered solutions when simpler alternatives exist
- `[ ]` If complexity was added, the rationale is documented

### Section 6.3: Enforcement
`phase-gate.sh implement --constitution` checks for simplicity rationale.

### Section 6.4: Rationale
Complexity is the dominant cost of software over time.

---

## Article VII: Error Escalate

> **After 3 consecutive failures, escalate. Do not silently repeat.**

### Section 7.1: Principle
When the same operation fails 3 consecutive times, stop and escalate.

### Section 7.2: Gate — Escalation Required (BLOCKING)
- `[ ]` Error counter is tracking consecutive failures for in-progress operations
- `[ ]` After 3 consecutive failures, approach was changed or human was consulted

### Section 7.3: Enforcement
`error-counter.sh check` is called before retrying. After threshold, escalate.

### Section 7.4: Rationale
After 3 failures, you need new information, not more persistence.

---

## Article VIII: Phase Gate

> **Do not skip phases.**

### Section 8.1: Principle
Work proceeds through phases: intake -> research -> plan -> implement -> verify.

### Section 8.2: Gate — Phase Order Required (BLOCKING)
- `[ ]` Research phase produced a note before planning
- `[ ]` Plan phase produced a plan before implementation
- `[ ]` Scope was bounded before implementation
- `[ ]` Verification was defined before implementation

### Section 8.3: Enforcement
`phase-gate.sh <phase>` checks prerequisites before transition.

### Section 8.4: Rationale
Phase skipping is the fastest path to wrong implementation.

---

## Article IX: Recognition

> **Construct the expectation before every generative action.**

### Section 9.1: Principle
Before every generative action, construct an explicit expectation of what the output should contain. Verify independently afterward.

### Section 9.2: Gate — Expectation Required (ADVISORY)
- `[ ]` Before generating, state what the output should look like
- `[ ]` After output, verify expectation was met or identify the gap
- `[ ]` For decisions with tradeoffs, ask the model to argue against itself

### Section 9.3: Enforcement
Self-enforced through `commands/implement.md`.

### Section 9.4: Rationale
Cognitive surrender is the central quality risk in agent-assisted development.

---

## Governance

### Amendment Process
1. **Proposal**: Document change, rationale, and impact
2. **Review**: Must be reviewed by a maintainer
3. **Ratification**: Recorded in amendments table
4. **Version bump**: MINOR for amendments; MAJOR for article changes

### Amendments

| # | Date | Article | Change | Rationale | Author |
|---|------|---------|--------|-----------|--------|
| | | | | | |

### Version History

| Version | Date | Change |
|---------|------|--------|
| 1.0 | RATIFICATION_DATE | Initial ratification |

---

*Managed by `scripts/constitution.sh`.*
