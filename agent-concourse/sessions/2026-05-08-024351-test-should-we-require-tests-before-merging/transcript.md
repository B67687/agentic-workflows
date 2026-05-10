# Parley Transcript: Test: should we require tests before merging?

**Panel:** 3-debate | **Agents:** Facilitator (facilitator), Analyst (specialist), Skeptic (red_team)
**Rounds:** 2 | **Messages:** 6
**Date:** 2026-05-08T02:43:51Z

---


## Round 1

### Facilitator
*8.8s via glm-4.5-air*

Welcome to our discussion on whether tests should be required before merging code. This decision impacts development velocity, code quality, and team workflow. We'll explore the benefits of test requirements versus potential drawbacks like slower development. Please share your initial thoughts on this practice.

---

### Analyst
*32.7s via minimax-m2.5*

Looking at this topic, I notice there's no prior argument in this conversation to respond to. I'll offer my analysis directly.

**My position: Yes, tests should generally be required before merging—but the specifics matter enormously.**

**The evidence favors test requirements:**

- IBM/Software Engineering Institute research consistently shows bugs cost 10-100x more to fix in production vs. development
- Teams with good test coverage report higher confidence in refactoring and faster iteration long-term
- Regression bugs are among the most expensive in terms of team trust and user impact

**But I'd push back on a blanket policy without specifics:**

1. *What kind of tests?* Requiring 100% unit test coverage on a one-line config change is wasteful. Requiring zero tests on a payment processing module is reckless.

2. *What's the context?* A hotfix for a typo vs. a new authentication system have different risk profiles.

3. *What's the alternative quality gate?* Some teams rely heavily on CI/CD staging environments, manual QA, or rigorous code review. Tests aren't the only way to catch bugs.

**The real question isn't binary.** It's: *What level of test coverage provides sufficient risk reduction for this codebase, at acceptable velocity cost?*

What position are you advocating for? I'd rather engage with a specific argument than speak in generalities.

---

### Skeptic
*52.8s via gpt-oss-120b*

**Let me push back on the “obvious” case for a blanket “tests‑before‑merge” rule.**  

You’ve quoted industry research that “bugs are 10‑100× cheaper to fix before production” and that “high coverage gives confidence.” Those statements are true in a statistical sense, but they hide a host of assumptions that can make a hard rule more harmful than helpful.

| Assumption | Why it may fail | Potential fallout |
|------------|----------------|-------------------|
| **All tests are equal** | Unit tests, integration tests, end‑to‑end (E2E) tests, and flaky UI tests have wildly different maintenance costs and defect‑detection power. A policy that treats them the same can force developers to write low‑value unit tests just to hit a quota, while neglecting higher‑value integration or contract tests. | Test suites balloon, CI pipelines become painfully slow, and developers start “gaming” the rule (e.g., writing trivial tests that always pass). |
| **Coverage ≈ quality** | Coverage metrics measure *how much code is exercised*, not *whether the exercised paths are meaningful*. 90 % line coverage can still miss critical edge cases, while 30 % coverage with well‑chosen property‑based tests may catch more bugs. | A false sense of security; teams may ignore real risk because the dashboard shows “green.” |
| **All changes have the same risk** | A one‑line typo fix in a documentation file carries negligible risk, whereas a change to a payment‑gateway API has high financial and regulatory impact. A uniform gate treats both identically. | Unnecessary friction on trivial changes (slow turnaround, PR fatigue) and still insufficient scrutiny on high‑risk changes if the rule only checks “some test exists.” |
| **Developers will write good tests under pressure** | When a rule is enforced mechanically (e.g., “CI must see *any* test”), developers may add superficial tests just to unblock the merge, especially under tight sprint deadlines. | Test debt grows; the suite becomes harder to maintain, and the intended quality benefit evaporates. |
| **CI infrastructure can keep up** | Adding mandatory tests for every PR often means longer build times. If the CI system is already near capacity, the queue can become a bottleneck, leading teams to disable the gate or run it only on “master.” | The policy becomes ineffective in practice; merging reverts to the old “trust the reviewer” model. |
| **Team skill level is homogeneous** | Junior engineers may lack the expertise to write robust tests for complex domains (e.g., concurrency, distributed systems). A hard rule can expose knowledge gaps and create blame‑shifting. | Morale drops, onboarding slows, and the team may resort to “test‑driven” workarounds that are brittle. |
| **Testing is the only quality gate** | Code review, static analysis, type systems, contract testing, canary releases, and runtime monitoring also catch defects. Over‑emphasizing pre‑merge tests can lead to tunnel vision. | Other safety nets become under‑utilised, increasing the chance that a defect slips through a purely test‑centric gate. |

### Failure Modes to Anticipate

1. **Gate Fatigue** – When developers repeatedly hit the “no‑test” wall, they start treating the rule as a nuisance and look for ways around it (e.g., adding a dummy test that always passes). The gate loses its preventive power.

2. **CI Bottleneck Collapse** – A surge of test‑heavy PRs can saturate the CI pool, causing builds to queue for hours. Teams may start merging without waiting for CI, effectively nullifying the rule.

3. **Coverage Inflation** – Teams chase coverage numbers rather than meaningful testing. You’ll see a lot of “happy‑path” tests that don’t assert anything substantive, inflating metrics while leaving real bugs uncovered.

4. **Risk Mis‑alignment** – High‑risk changes that *do* need extensive testing may still get merged quickly if the rule only checks “at least one test present.” Conversely, low‑risk changes get delayed for marginal benefit.

5. **Technical Debt Accumulation** – Over‑testing trivial code can produce large, brittle test suites that need constant maintenance, diverting time from feature work.

### A More Nuanced Alternative

Instead of a binary “tests required before merge,” consider a **risk‑based gating model**:

| Change Type | Minimum Test Requirement | Additional Gates |
|-------------|--------------------------|------------------|
| Documentation / config tweak | None (or lint check) | Peer review only |
| Pure UI layout change | Unit test for component rendering *or* visual regression snapshot | Manual QA on staging |
| Business‑logic addition (low impact) | Unit test covering happy path + at least one edge case | Static analysis |
| Public API or payment flow change | Unit + integration + contract test suite | Staging deployment + smoke test |
| Hotfix (critical production bug) | Minimal test proving fix *or* safe‑guard rollback script | Immediate post‑merge monitoring |

Couple this with **observable metrics** (flaky test rate, mean CI run time, defect escape rate) and **empowered reviewers** who can override the gate when justified, with a required justification comment.

### Bottom Line

The *principle*—“don’t merge code you haven’t exercised”—is sound, but the *implementation* of a blunt “tests‑required” rule is riddled with hidden assumptions and failure modes. A risk‑adjusted, context‑aware approach mitigates those pitfalls while preserving the core safety net.

**What do you think?** Which of the assumptions above feels most shaky in your current workflow, and how might we design a gate that acknowledges those edge cases instead of ignoring them?

---


## Round 2

### Facilitator
*11.3s via glm-4.5-air*

The debate has highlighted both the quality benefits of test requirements and the practical concerns about development velocity and test effectiveness. We've seen arguments about risk-based approaches versus blanket policies, and the importance of context in determining testing requirements.

What specific types of changes do you believe should be exempt from test requirements, and how would you define those exceptions? Additionally, how can teams balance the need for thorough testing with the pressure to deliver features quickly?

---

### Analyst
*28.7s via minimax-m2.5*

I'll answer the questions posed and advance the discussion.

**Exemptions I'd advocate for:**

1. **Pure documentation/changelog updates** — obvious, but teams sometimes over-apply rules here
2. **Automated refactors** (renames, formatting) where the tool is verified and a linter passes
3. **Dependency updates** handled by dependabot or similar, with vulnerability scans passing
4. **Hotfixes under time pressure** with a documented rollback plan and mandatory post-merge test addition

The key qualifier: exemptions should require *explicit justification* in the PR, not silent assumption.

**On the velocity-quality balance:**

This is where I'll push back on the framing. The assumption that testing slows delivery is often *short-term thinking*. Evidence from teams at Google, Microsoft, and Spotify shows that well-designed test suites actually *increase* delivery speed after an initial investment period because:

- Developers spend less time debugging regressions
- Code review focuses on logic, not correctness-checking
- Refactoring becomes possible without fear

The real problem isn't testing vs. velocity—it's *bad* testing vs. velocity. Brittle tests, slow tests, and tests that don't catch real bugs create overhead without benefit.

**My concrete recommendation:**

Start with a minimal baseline (e.g., "new code must have test coverage for new functionality"), measure CI queue time and defect escape rate, and adjust. Don't solve a hypothetical problem with a rigid policy.

What's your context—size of team, current test culture, and what's driving this discussion?

---

### Skeptic
*84.4s via gpt-oss-120b*

**Skeptical deep‑dive – why “reasonable‑looking” exemptions and a “baseline‑then‑tweak” process may still be a mirage**

You’ve sketched a pragmatic‑looking framework:

1. A short list of exempt change types (docs, automated refactors, dependabot bumps, hot‑fixes with rollback plans).  
2. A “minimal baseline” for new code, then iterate based on metrics.

At first glance that sounds balanced, but it rests on several hidden premises that can easily collapse in real‑world settings. Below I’ll dissect each premise, point out failure modes, and suggest guardrails that prevent the framework from devolving into a “nice‑to‑have” add‑on that never actually raises quality.

---

## 1️⃣ The exemption list is *not* exhaustive – and it’s easy to stretch it

| Assumed exemption | Why it’s risky to broaden | Real‑world creep examples |
|-------------------|---------------------------|---------------------------|
| **Docs / changelog** | Often docs are co‑located with code (e.g., Markdown in the same repo, OpenAPI specs). A typo in a generated client can break downstream services. | Teams start marking “README update” as a docs change even when it includes a new endpoint definition. |
| **Automated refactors** | Refactors may change public APIs, serialization formats, or implicit contracts that aren’t captured by the refactor tool. | A rename of a field in a protobuf triggers a `sed`‑based bulk rename; the tool updates the code but silently breaks a downstream microservice that still expects the old JSON key. |
| **Dependabot bumps** | Dependency upgrades can introduce subtle runtime regressions (e.g., changed default behavior, de‑precations). The “vulnerability scan passes” check does not guarantee functional parity. | Upgrading `lodash` from 4.17.20 to 4.17.21 silently drops support for `_.pluck`, causing a runtime error in a rarely exercised admin UI. |
| **Hot‑fixes with rollback plan** | The plan may be sound, but the *fix* itself could be a hack that introduces hidden state or race conditions. Relying on a rollback ignores the possibility that the bug has already propagated (e.g., to a cache, a message queue, or downstream services). | A hot‑fix adds a `if (process.env.NODE_ENV === 'prod') return;` guard to skip a validation step. The guard works for the immediate incident but later causes data corruption in a batch job. |

**Failure mode:** *Exemption creep.* Once a team internalizes the “these are the only allowed exemptions,” they will inevitably start classifying borderline changes as one of the exempt categories to avoid the overhead of writing tests. Over time, a substantial fraction of production code ends up untested, eroding the very safety net the policy intended to create.

**Mitigation:** Require a *formal exemption request* that is reviewed by at least two senior engineers, recorded in a dedicated tracker, and automatically time‑boxed (e.g., “exempt for 48 h, then must be back‑filled with tests”). The request should include a concrete risk assessment (impact, rollback, monitoring). This turns an ad‑hoc “I think this is a doc change” into a documented, auditable decision.

---

## 2️⃣ “Minimal baseline for new code” → **coverage‑as‑a‑metric trap**

You propose “new code must have test coverage for new functionality,” but you didn’t specify *what kind* of coverage or *how* to validate its usefulness. The hidden assumption is that any test is better than none, which is false.

| Problem | Why it matters | Example of a broken baseline |
|---------|----------------|------------------------------|
| **Coverage percentage without quality filter** | High line coverage can be achieved by trivial assertions (`assert true`) that give zero confidence. | A PR adds 200 lines of business logic, includes 30 one‑line unit tests each asserting `expect(true).toBeTruthy()`. CI passes, but a real edge‑case bug remains. |
| **Only unit tests counted** | Integration points (DB, external services, async pipelines) are where many production bugs surface. | A new feature writes to a message queue; unit tests mock the queue and never hit serialization errors, but a production deployment crashes due to a schema mismatch. |
| **No measurement of test flakiness** | Flaky tests cause developers to ignore CI failures, effectively nullifying the gate. | A newly added integration test intermittently fails due to a race condition in a test harness; developers start merging with “‑‑no‑verify” flags. |
| **No time‑budget awareness** | If the baseline forces a test suite to grow by, say, 0.5 min per PR, a team with 30 PRs/day will see CI queues balloon by 15 min each cycle, quickly becoming a bottleneck. | After two weeks the average CI duration rises from 7 min to 22 min; the team begins to merge without waiting for CI, breaking the policy in practice. |

**Failure mode:** *Metric‑driven development.* Teams chase the “new‑code‑must‑have‑test” checkbox, not the underlying goal of catching regressions. The result is a bloated test suite, higher maintenance cost, and a false sense of safety.

**Mitigation:** Define *quality gates* beyond raw coverage:
- **Mutation testing** score ≥ X % for new code (ensures tests would fail if the code were altered).
- **Property‑based or fuzz tests** for any function that handles external input.
- **Integration test that exercises the full request‑response path** for any change that touches a public API or persistent store.
- **Flakiness threshold** (e.g., < 1 % failure rate over last 10 runs) before a PR can be merged.

If a team cannot meet these gates within a reasonable time (e.g., < 5 min CI per PR), they must *justify* the trade‑off in the PR description, not simply claim “coverage satisfied.”

---

## 3️⃣ Metrics‑driven iteration → **The “measure‑then‑tweak” paradox**

You suggest measuring CI queue length, defect escape rate, etc., then adjusting the policy. This is sensible in theory, but it assumes:

1. **You have reliable baseline data.** Many teams start without any defect‑escape statistics because bugs aren’t systematically logged. Without a trustworthy baseline, you cannot tell if a policy change helped or hurt.
2. **The metrics you pick actually correlate with the goal.** CI queue time is a *symptom* of many things (hardware, test design, parallelism) and may improve while test quality degrades.
3. **Iteration speed is fast enough.** Policy changes often require weeks of data to surface trends; meanwhile, developers are already “gaming” the system.

**Failure mode:** *Policy inertia.* After a few weeks of “no improvement” the team abandons the testing gate altogether, concluding it was never worth the effort.

**Mitigation:** Adopt a *small‑scale pilot* with hard limits, not just “measure and tweak.” For example:
- Pick a *single high‑risk subsystem* (e.g., payment service) and enforce a **strict testing gate** for all changes for one sprint.
- Record **all** incidents (customer tickets, SRE alerts) and **all** CI failures.
- At the end of the sprint, perform a **post‑mortem** that explicitly attributes any incident to “missing test” or “test‑related slowdown.”
- Only after the pilot yields clear, quantifiable outcomes should you roll the policy out more broadly.

---

## 4️⃣ “Rollback plan” as an exemption – **Assumes observability and instant reversibility**

A rollback plan is only as good as the system’s ability to *detect* that the change caused a problem *quickly* and to *revert* without side effects. Hidden assumptions:

- **Zero data loss** on rollback (rare in stateful services).  
- **Uniform deployment topology** (e.g., all instances can be rolled back simultaneously).  
- **Sufficient monitoring** to surface the bug before it propagates.

If any of those assumptions break, the “hot‑fix exemption” becomes a ticket to disaster.

**Failure mode:** *Silent data corruption.* A hot‑fix disables a validation step, causing malformed records to be written to a database. The rollback restores the code, but the corrupted data remains, leading to downstream failures weeks later—hard to trace back to the exempted PR.

**Mitigation:** Pair any hot‑fix exemption with **mandatory post‑merge instrumentation**:
- Tag the deployment with a unique release ID.
- Enable a *temporary* read‑only mode or data‑validation job that runs on the next scheduled batch.
- Require a **post‑mortem ticket** (even if the bug never manifests) documenting the risk assessment and any downstream checks performed.

---

## 5️⃣ The “two‑senior‑engineer review” for exemptions – **Potential bottleneck & social risk**

Requiring two senior engineers to approve every exemption can introduce:

- **Queue delays** for urgent changes (the very scenario we tried to accelerate).  
- **Gatekeeping dynamics** where senior engineers become de‑facto “approval chiefs,” increasing hierarchy rather than fostering shared responsibility.  
- **Knowledge siloing**—if only a few people understand the exemption process, the policy’s continuity depends on them staying.

**Failure mode:** *Approval fatigue.* When the volume of exemption requests spikes (e.g., during a major feature launch), senior engineers start auto‑approving, effectively nullifying the safeguard.

**Mitigation:** Rotate exemption reviewers, and make the **approval process auditable but lightweight**:
- Use a *GitHub CODEOWNERS* file that designates a *small pool* of reviewers per subsystem.
- Require a **commented checklist** (risk, rollback, monitoring) that is automatically enforced by a CI *policy* bot.
- Set a **soft SLA** (e.g., 2 h) but allow “expedited” paths with higher scrutiny (e.g., require a third reviewer if the change touches a regulated component).

---

## TL;DR – What to watch for if you adopt your own framework

| Hidden assumption | Likely failure mode | Concrete guardrail |
|-------------------|---------------------|--------------------|
| Exemptions are “obviously low‑risk.” | Exemption creep ⇒ untested production code. | Formal, time‑boxed exemption tickets + risk checklist. |
| Any test satisfies the baseline. | Metric‑gaming ⇒ trivial tests, false confidence. | Require mutation‑testing, fuzz/property‑based tests, flakiness thresholds. |
| Measuring CI time & defect rate is enough to tune policy. | Policy inertia or mis‑aligned adjustments. | Run a focused pilot on a high‑risk service, collect incident‑level data. |
| Rollback plans guarantee safety. | Silent data corruption or partial rollbacks. | Pair rollback with post‑merge validation jobs and mandatory post‑mortem. |
| Two senior reviewers prevent abuse. | Bottlenecks and approval fatigue. | Rotating reviewer pool, automated checklist enforcement, escalation paths. |

---

### Next step for the discussion

1. **Identify a concrete “high‑risk” component** in your codebase (e.g., the billing microservice).  
2. **Define a pilot policy** that includes all the guardrails above (mutation score ≥ 70 %, property‑based test for any input‑handling function, exemption ticket workflow).  
3. **Set a measurement window** (one sprint) and agree on the exact metrics you’ll collect (CI duration, number of exemption tickets, number of post‑merge incidents, flakiness rate).  
4. **Schedule a post‑pilot review** with a cross‑functional group (dev, QA, SRE, product) to decide whether to scale, adjust, or scrap the policy.

By confronting these hidden assumptions head‑on, you’ll avoid the classic pitfall of “nice‑to‑have” testing rules that either get ignored or become a source of friction without delivering the intended quality gains. What do you think—does this level of rigor feel feasible for your team, or are there constraints that would make even a pilot impractical?

---

