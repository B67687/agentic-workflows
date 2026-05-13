# Tool Selection Decision Frameworks: Research Synthesis

**Date:** 2026-05-13
**Question:** Is "highest quality + local + simplest + lowest resource" the right set of criteria for choosing tooling solutions, or is there a better way to frame this?

---

## Executive Summary

After researching 7 established decision frameworks across operations research, software engineering, philosophy, and systems design, the answer is: **the user's 4 criteria are sensible but incomplete and partially overlapping.** The best framework for this workspace is a **weighted, context-aware approach** built from ATAM utility trees, Gall's law, and Occam's razor, not a flat checklist. The critical missing elements are: **maintainability**, **friction-to-adopt**, and **the distinction between essential and accidental complexity.** A flat "4 criteria" list also creates a false equivalence between criteria that should be weighted differently depending on context.

---

## 1. The User's 4-Criteria Heuristic: Analysis

| Criterion | Strengths | Blind Spots | Overlaps With |
|-----------|-----------|-------------|---------------|
| **High quality** | Anchors on fitness for purpose | "Quality" is ambiguous --- does it mean correctness, coverage, reliability, or user experience? Without unpacking, it's a black box. | Contains all other criteria implicitly (a low-resource tool can be high quality in resource-constrained contexts) |
| **Local** | Eliminates network dependencies, API keys, service disruptions | Overlooks total cost of ownership --- a local solution that requires heavy setup/config is "local" but not practical. Confuses *where it runs* with *what it depends on*. | Partially conflicts with "simplest" (local often requires more infrastructure) |
| **Simplest implementation** | Good instinct --- aligns with Occam's razor and Gall's law | "Simple" for whom? Simple to write vs simple to use vs simple to maintain are *different* kinds of simplicity. A script is simple to write but may be fragile to maintain. | Most aligned with Occam's razor; can conflict with "high quality" (the highest quality tool may not be the simplest) |
| **Lowest resource** | Practical for constrained environments (4GB WSL2) | Resource usage is context-dependent --- idle RSS vs peak CPU vs install size vs runtime overhead are different metrics. Pure bash wins this until you need structured output. | |

### The Fundamental Problem

The 4 criteria are **not orthogonal**. They trade off against each other, and the tradeoffs are context-dependent. A flat checklist treats them as equal dimensions when they should be weighted differently depending on the decision context.

---

## 2. Established Frameworks Surveyed

### 2.1 ATAM (Architecture Tradeoff Analysis Method) --- SEI/Carnegie Mellon

**Origin:** Software Engineering Institute, Carnegie Mellon University (1990s)
**Core idea:** Evaluate architectural decisions against *utility trees* --- a prioritized hierarchy of quality attributes with explicit scenarios.

**Key concepts:**
- **Utility tree:** Root -> Quality attribute -> Attribute refinement -> Scenario (with importance & difficulty ratings)
- **Sensitivity points:** Where a parameter variation measurably affects a quality attribute
- **Tradeoff points:** Where improving one attribute degrades another

**Strengths for this use case:**
- Forces explicit prioritization (not flat criteria)
- Makes tradeoffs visible and discussable
- Scenarios ground abstract attributes in concrete measurements

**Weaknesses:**
- Heavy process for small decisions (overkill for choosing a search tool)
- Requires domain expertise to build good utility trees
- Less suited to single-tool evaluation than to architecture comparison

**Relevance: ⭐⭐⭐⭐** --- The utility tree pattern is the best way to replace the flat 4-criteria list with a weighted, context-sensitive framework.

### 2.2 MCDA/MCDM (Multi-Criteria Decision Analysis)

**Origin:** Operations research (1950s+)
**Core idea:** Explicitly evaluate multiple conflicting criteria using structured methods (weighted sum, AHP, PROMETHEE, TOPSIS, etc.)

**Key variants:**
- **AHP (Analytic Hierarchy Process):** Pairwise comparison -> weights -> scores
- **Weighted Sum Model:** Assign weights to criteria, score options, sum
- **PROMETHEE/ELECTRE:** Outranking methods (French school)

**Strengths:**
- Formal, repeatable process
- Handles conflicting criteria explicitly
- Large body of academic validation

**Weaknesses:**
- Complex for quick decisions (pairwise comparisons, consistency ratios)
- False precision: weights look objective but are usually subjective
- Overkill for 2-3 option decisions

**Relevance: ⭐⭐⭐** --- The weighted-score approach is useful but the formality is excessive for most tool decisions in this workspace. The *principle* (weight criteria, score options) is valuable.

### 2.3 Occam's Razor / Principle of Parsimony

**Origin:** William of Ockham (14th century)
**Core idea:** Among competing hypotheses with equal explanatory power, prefer the one with the fewest assumptions.

**Key variants:**
- **Original:** "Entities must not be multiplied beyond necessity"
- **Einstein's constraint:** "As simple as possible, but no simpler"
- **Minimum description length (Solomonoff):** Formal mathematical version for model selection

**Strengths:**
- Universal applicability
- Prevents over-engineering and overfitting
- Matches "simplest implementation" well

**Weaknesses:**
- Only applies when explanatory power is *equal* (rare in practice)
- "Simple" is subjective --- what's simple in syntax may be complex in semantics
- Anti-razors exist (Leibniz's plenitude, Menger's law) for good reason

**Relevance: ⭐⭐⭐⭐** --- Essential as a pruning heuristic, but requires the "equal power" caveat to be useful. Best combined with a quality-first evaluation, then parsimony to break ties.

### 2.4 Gall's Law

**Origin:** John Gall, *Systemantics* (1975)
**Core idea:** "A complex system that works evolved from a simple system that worked. A complex system designed from scratch never works and cannot be patched to make it work."

**Strengths:**
- Validated by decades of software engineering practice
- Strong argument for incremental, simple-first approaches
- Directly supports the "simplest implementation" criterion

**Weaknesses:**
- Descriptive, not prescriptive --- doesn't tell you *how* to find the simple system
- Can be used to justify underspecification
- Doesn't account for systems that *must* be complex (safety-critical, etc.)

**Relevance: ⭐⭐⭐** --- A useful cautionary principle but not a decision framework by itself.

### 2.5 The UNIX Philosophy / Rule of Least Power

**Origin:** Bell Labs / Tim Berners-Lee (1970s-1990s)
**Core idea (Rule of Least Power):** Use the least powerful language/tool that can solve the problem. More powerful tools increase complexity and reduce constraint.

**Key principles (from Peter Salus, *A Quarter-Century of UNIX*):**
1. Make each program do one thing well
2. Expect the output of every program to become the input to another
3. Use software tools in preference to unskilled help
4. Build a prototype as soon as possible

**Strengths:**
- Proven track record of producing maintainable systems
- Naturally favors composable, simple tools
- "Less power = more constraint = fewer bugs" is deeply insightful

**Weaknesses:**
- Less suited to tool *selection* than tool *design*
- "Least power" can lead to overly constrained implementations
- The modern answer to "spit and duct tape" interfaces (the UNIX way) is structured MCP schemas

**Relevance: ⭐⭐⭐⭐** --- The Rule of Least Power is directly applicable to the "simplest" criterion, but critically reframes it.

### 2.6 The Iron Triangle (Good, Fast, Cheap)

**Origin:** Project management (classic)
**Core idea:** Pick two: good, fast, cheap. The third is impossible.

**Paraphrased for tool selection:** **Quality, Simplicity, Resource-efficiency --- pick the minimum viable combination, then iterate.**

**Relevance: ⭐⭐** --- Too simplistic to be useful alone but captures the unavoidable tension in the 4-criteria heuristic.

### 2.7 Essential vs Accidental Complexity (Brooks)

**Origin:** Fred Brooks, *No Silver Bullet* (1986)
**Core idea:** Essential complexity is inherent to the problem. Accidental complexity is introduced by the solution. The goal is to minimize accidental complexity, not essential complexity.

**Strengths:**
- Distinguishes between necessary and unnecessary complexity
- Directly applicable to "simplest implementation" --- simplify the accidental, accept the essential
- Explains why some "simple" solutions are actually complex (they try to reduce essential complexity that can't be reduced)

**Weaknesses:**
- The line between essential and accidental is often unclear until after implementation
- Requires domain understanding to apply correctly

**Relevance: ⭐⭐⭐⭐** --- The most important distinction missing from the 4-criteria heuristic.

---

## 3. Comparative Analysis

### What the 4-Criteria Heuristic Gets Right

1. **Quality-first orientation** matches the workspace's quality-standards.md tiered model
2. **Resource consciousness** is necessary for 4GB WSL2 constraints
3. **Simplicity preference** aligns with Occam's razor and repo-tooling.md's "fastest tool" rule
4. **Local-first** respects the workspace's security and autonomy values

### What It Misses

| Missing | Why It Matters | Framework That Covers It |
|---------|---------------|-------------------------|
| **Essential vs accidental complexity** | Not all complexity is bad; some is inherent | Brooks |
| **Maintainability** | A simple script you don't understand is worse than a documented tool | ATAM |
| **Friction-to-adopt** | Setup time, API key signup, learning curve | ATAM utility tree |
| **Composability** | Does the tool work with others? | UNIX philosophy |
| **Time horizon** | Quick fix vs sustained tool --- different criteria apply | ATAM scenario |
| **Weighting/prioritization** | Not all criteria are equal --- depends on context | ATAM utility tree, MCDA |

### Why "Local" Is Tricky

"Local" conflates two separate things:
1. **Where the code runs** (on this machine vs cloud)
2. **What services it depends on** (self-contained vs external API)

A bash script calling Brave Search API is "local" in sense 1 but not sense 2. A SearXNG Docker container is "local" in sense 2 (self-hosted) but requires significant infrastructure. The right question is: **what dependencies are acceptable in this context?**

---

## 4. Recommendation: The Composite Framework for This Workspace

**For routine tool decisions (the common case):** Use a lightweight **utility tree** with context-weighted scores.

### The 3-Question Gate

Before any tool decision, answer:

1. **What job must it do?** (Functional requirement --- not "search the web" but "return ranked results with titles, URLs, and snippets from a free web search")
2. **What context constraints apply?** (Time pressure? API keys available? Internet? Resource limits?)
3. **What is the time horizon?** (One-off research? Repeated workspace tool? Production deployment?)

### The Weighted Utility Tree

Replace the flat 4-criteria list with this tree, where weights depend on context:

```
Root: Solution fitness
├── Functional quality (weight: high always)
│   ├── Correctness: Does it produce accurate results?
│   └── Coverage: Does it handle the range of inputs needed?
├── Operational harmony (weight: context-dependent)
│   ├── Dependencies: What does it require to run? (API keys, services, packages)
│   ├── Resource profile: Memory/CPU at runtime (bash=1, node=2, docker=3+)
│   └── Reliability: Does it work consistently or flake?
├── Long-term viability (weight: high for permanent tools, low for one-offs)
│   ├── Maintainability: Can someone else fix it?
│   ├── Composability: Does it work with existing tools/scripts?
│   └── Evolution path: Can it be upgraded without replacement?
└── Cost of adoption (weight: inverse of urgency)
    ├── Setup time: Minutes to first working result
    ├── Learning curve: How much new knowledge required
    └── Friction: Signups, config, approval gates
```

### Practical Application

**For the web-search fix (situational example):**

| Criterion | Weight (this context) | Brave+MCP | Bash+DDG | Bash+Brave |
|-----------|----------------------|-----------|----------|------------|
| Correctness | High | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ (DDG blocks bots) | ⭐⭐⭐⭐⭐ |
| Coverage | High | ⭐⭐⭐⭐⭐ (5 search types) | ⭐⭐ (web only) | ⭐⭐⭐⭐ (web only with script) |
| Dependencies | High (wants simplicity) | ⭐⭐ (npm+API key) | ⭐⭐⭐⭐⭐ (curl only) | ⭐⭐⭐⭐ (curl+jq+API key) |
| Resource profile | High (4GB WSL2) | ⭐⭐⭐ (node daemon) | ⭐⭐⭐⭐⭐ (bash, zero daemon) | ⭐⭐⭐⭐⭐ (bash, zero daemon) |
| Maintainability | Medium | ⭐⭐⭐⭐⭐ (upstream) | ⭐⭐ (fragile scraping) | ⭐⭐⭐⭐ (stable API, your script) |
| Setup time | Low (you're forking anyway) | ⭐⭐ (npm install + API key) | ⭐⭐⭐⭐⭐ (immediate) | ⭐⭐⭐⭐ (API key only) |

### When to Use Which Framework

| Decision type | Framework | Why |
|--------------|-----------|-----|
| Choose between 2-3 similar tools | **Utility tree** (lightweight) | Fast, comparative, makes tradeoffs visible |
| Evaluate a single architecture | **ATAM** (full) | Systematic sensitivity/tradeoff analysis |
| Break a tie between equal options | **Occam's razor** | Prefer simpler |
| Design a new tool/script | **UNIX philosophy + Gall's law** | Composability + evolve from simple |
| Formal procurement decision | **MCDA (AHP or weighted sum)** | Repeatable, defensible, auditable |
| Quick gut check in a session | **Brooks distinction** | Essential vs accidental complexity |

---

## 5. Conclusion

The 4-criteria heuristic ("high quality + local + simplest + lowest resource") is **a reasonable starting instinct but an incomplete framework.** Its main problems:

1. **"Quality" is overloaded** --- it tries to carry correctness, coverage, reliability, and user experience in one word
2. **"Local" conflates code location with dependency profile** --- a script that needs a cloud API key is not more "local" than an MCP server in terms of self-containment
3. **The criteria are not weighted** --- treating them as equal when context demands prioritization
4. **Missing criteria** --- maintainability, friction-to-adopt, essential vs accidental complexity
5. **No time horizon** --- what's right for a one-shot script differs from what's right for a permanent tool

**The better approach for this workspace:** Replace the flat 4-criteria list with a lightweight **context-weighted utility tree** that captures the same instincts but forces explicit weighting based on the specific decision context. The tree above covers the same values (quality, simplicity, local-ness, resource consciousness) but adds maintainability and adoption friction, and makes tradeoffs visible rather than hidden.

---

## Sources

1. Bass, L., Clements, P., & Kazman, R. (2003). *Software Architecture in Practice* (ATAM description). SEI/Addison-Wesley.
2. Belton, V., & Stewart, T. J. (2002). *Multiple Criteria Decision Analysis: An Integrated Approach*. Kluwer.
3. Brooks, F. (1986). "No Silver Bullet: Essence and Accidents of Software Engineering." *Proceedings of the IFIP 10th World Computer Congress.*
4. Gall, J. (1975). *Systemantics: How Systems Really Work and How They Fail.*
5. Salus, P. (1994). *A Quarter-Century of UNIX.* Addison-Wesley.
6. Saaty, T. L. (1980). *The Analytic Hierarchy Process.* McGraw-Hill.
7. Simon, H. A. (1969). *The Sciences of the Artificial* (essential vs accidental complexity origins).
8. Sober, E. (2015). *Ockham's Razors: A User's Manual.* Cambridge University Press.
9. Wikipedia: Multiple-criteria decision analysis, Occam's razor, Gall's law.
10. Workspace context: `docs/repo-tooling.md`, `docs/quality-standards.md`, `docs/model-selection-guide.md`, `docs/mcp-architecture.md`.
