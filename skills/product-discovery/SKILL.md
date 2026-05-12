---
name: product-discovery
description: Validate whether a product idea is worth building before committing engineering investment. Use when someone says "should we build this", "validate this idea", "run an experiment", "test this hypothesis", "is this worth building", or when you sense high uncertainty about a feature. Sits between product-thinker (should we?) and shaping-work (what exactly?) — answers "will this actually work?" with evidence gates.
trigger-phrases: should we build, validate this idea, run an experiment, test this hypothesis, is this worth building, feasibility check, discovery
handoffs: shaping-work (to define after validation), product-thinker (to analyze before discovery)
companion-script: scripts/product-discover.sh
---

# Product Discovery

Figure out whether an idea is worth building before committing engineering time. The goal is sufficient evidence that the solution will work.

70-90% of features built without validation fail to deliver. Discovery exists to catch failures early and cheap.

**Companion script:** `scripts/product-discover.sh`
```bash
bash ./scripts/product-discover.sh risk "<idea>"         # assess four product risks
bash ./scripts/product-discover.sh hypothesis             # hypothesis template
bash ./scripts/product-discover.sh experiment <type>      # experiment design
bash ./scripts/product-discover.sh gate                   # evidence gate template
bash ./scripts/product-discover.sh plan "<idea>"          # full discovery plan
```

## Core Principle

Every idea tested in discovery should cost at least one order of magnitude less than building the real thing.

## Process

### 1. Understand the Idea

Restate as **problem to solve** and **desired outcome**:
- Problem: what's broken or missing?
- Outcome: what measurable change would success look like?

If input is a solution ("build a self-service portal"), reverse-engineer the problem.

### 2. Assess the Four Product Risks

| Risk | Question |
|------|----------|
| **Value** | Will customers choose to use this? Is there evidence of demand? |
| **Usability** | Can users figure out how to use it? Novel or familiar interaction? |
| **Feasibility** | Can we build and scale this? Unknown technical challenges? |
| **Viability** | Does this work for the business? Legal, compliance, operational? |

Rate each **low / medium / high**. Medium/high risks need experiments.

### 3. Identify What You Don't Know

For each medium/high risk, write a testable hypothesis:

```
We believe [specific assumption].
We'll know we're right if [observable evidence].
We'll know we're wrong if [observable evidence].
```

### 4. Design Experiments

Cheapest experiment first. Match type to risk:

| Risk | Best experiment types |
|------|----------------------|
| Value | Customer interviews, fake door test, landing page test, competitor analysis |
| Usability | Prototype test, Wizard of Oz, concierge test |
| Feasibility | Technical spike, proof of concept |
| Viability | Stakeholder review, unit economics analysis |

### 5. Define Evidence Gates

```
### Gate: [hypothesis being tested]
Experiment: [what you'll do]
Timeline: [timeline]
Proceed if: [specific evidence threshold]
Pivot if: [evidence suggests different approach]
Stop if: [evidence kills the idea]
```

### 6. Write the Discovery Plan

Output a structured plan. Save to `research/` with date prefix.

```
# Discovery: [idea name]

## Problem & Desired Outcome
**Problem:** [what's broken]
**Outcome:** [measurable success]

## Risk Assessment
| Risk | Level | Key uncertainty |
|------|-------|-----------------|

## Hypotheses
1. We believe [X]. Evidence for: [Y]. Evidence against: [Z].

## Experiments
### Experiment 1: [name]
- Tests: [which hypothesis]
- Method: [what you'll do]
- Timeline: [how long]
- Gate: Proceed if [X]. Pivot if [Y]. Stop if [Z].

## Sequence
[Which experiments to run first, what can run in parallel]
```

## Relationship to Other Skills

```
product-thinker → product-discovery → shaping-work → implementation-planning
"should we?"      "will it work?"     "what exactly?"  "how technically?"
```

- product-thinker analyzes problems. It answers "should we explore this?"
- product-discovery validates. It answers "do we have evidence this will work?"
- shaping-work defines. It answers "what exactly are we building?"

## What This Skill Does NOT Do

- Does NOT make the build/kill decision — presents evidence, team decides
- Does NOT produce implementation plans
- Does NOT design the full solution
- Does NOT run the experiments — plans them for execution
- Does NOT replace talking to customers — strongly recommends it

## Test Responsibly

For established companies with existing customers: protect revenue, reputation, and customers. Use conservative techniques — smaller samples, internal users first, feature flags.
