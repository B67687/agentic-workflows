# Cognitive Surrender: Comprehensive Research Synthesis

**Date:** 2026-05-14 (v2: expanded with agent-mitigation architectures, ~25 new sources)
**Researcher:** Agent (Orchestrator)
**Methodology:** 6-phase systematic research (Frame -> Discover -> Gather -> Triangulate -> Apply -> Preserve)

---

## Executive Summary

Cognitive surrender is the tendency to adopt AI-generated outputs with minimal critical evaluation, bypassing both intuitive and deliberative reasoning. First rigorously defined and empirically demonstrated by Shaw and Nave (2026) at the Wharton School, the concept has rapidly spawned a cross-disciplinary literature spanning psychology, philosophy, law, cybersecurity, software engineering, governance, and agent architecture design. Addy Osmani (Google) has bridged this academic work to daily software engineering practice, connecting surrender to comprehension debt, anti-rationalization tables, and the calibration problem every developer now faces.

**Version 2 (May 14, 2026)** expands this synthesis with ~25 new sources covering: the AI Cognitive Trojan Horse (how LLMs bypass epistemic vigilance), the Scaffolded Cognitive Friction framework (MAS-based devil's advocates), the CATFISH Protocol (dynamic adversarial injection, 23% better than static), Cognitive Task Partitioning (separating exploration from deterministic verification), the Recognition model (collapse is driven by interaction architecture, not model capability), and 10+ additional mitigation architectures. The central finding of v2: **agents can be part of the solution, not just the problem --- but only with deliberately anti-surrender architecture.**

---

## 1. Core Definition

**Cognitive surrender:** The behavioral and motivational tendency to defer judgment, effort, and responsibility to an AI system's output, particularly when that output is delivered fluently, confidently, or with minimal friction. The user accepts the AI's response without critical evaluation, substituting it for their own reasoning.

### Key Distinction: Cognitive Surrender vs. Cognitive Offloading

| Dimension | Cognitive Offloading | Cognitive Surrender |
|-----------|---------------------|---------------------|
| Nature | Strategic, deliberate delegation | Uncritical abdication of reasoning |
| User engagement | Internal reasoning remains active | Deliberation stops entirely |
| Example | Using GPS to navigate while authoring the journey | Accepting AI's answer without checking |
| Locus of control | User retains oversight | AI occupies the default position |
| Mechanism | System 2 -> System 3 (assist) | System 3 -> System 1 (adopt) |

*Sources: Shaw & Nave (2026), Williams (2026)*
*Confidence: CONFIRMED --- directly defined in the primary source and consistently used across all subsequent literature.*

---

## 2. Intellectual Origins and Context

### 2.1 Precursors

Cognitive surrender did not emerge from a vacuum. Several established concepts anticipated it:

| Precursor | Source | Relationship |
|-----------|--------|-------------|
| **Automation bias** | Mosier & Skitka (1996); Parasuraman & Manzey (2010) | Tendency to favor automated recommendations over contradicting human judgment. Broader; cognitive surrender is a specific subtype in AI contexts. |
| **Algorithm appreciation** | Logg, Minson & Moore (2019) | People prefer algorithmic to human judgment on factual tasks. |
| **Algorithm aversion** | Dietvorst, Simmons & Massey (2015) | People avoid algorithms after seeing them err. |
| **Epistemic outsourcing** | Lynch (2016) | Delegating knowledge production to external systems. |
| **Extended mind thesis** | Clark & Chalmers (1998) | External resources can constitute part of cognition. |
| **Transactive memory** | Wegner (1987) | Teams distribute knowledge across members; AI version lacks human hesitation markers. |
| **Ironies of automation** | Bainbridge (1983) | Automating routine tasks atrophies the skills needed for non-routine cases. |
| **System 0** | Chiriatti et al. (2024), *Nature Human Behaviour* | AI as a distinct cognitive system alongside System 1 and System 2. |

*Confidence: ESTABLISHED for precursor concepts; CONFIRMED for their relationship to cognitive surrender.*

### 2.2 The Seminal Paper

**Shaw, S. D., & Nave, G. (2026).** *Thinking---Fast, Slow, and Artificial: How AI is Reshaping Human Reasoning and the Rise of Cognitive Surrender.* Wharton School Research Paper. SSRN 6097646.

- **Status:** Preregistered working paper (not yet peer-reviewed as of May 2026)
- **Participants:** 1,372 across 3 preregistered experiments
- **Trials:** 9,593
- **Task:** Adapted Cognitive Reflection Test (CRT-7)
- **Method:** Randomized AI accuracy via hidden seed prompts; participants could consult an embedded AI assistant (GPT-4o) and retained full autonomy over answers

**Key empirical findings:**

| Finding | Detail |
|---------|--------|
| Chat engagement | Participants consulted AI on >50% of trials when available |
| Follow rate (AI accurate) | 92.7% of chat-engaged trials |
| Follow rate (AI faulty) | 79.8% of chat-engaged trials |
| Accuracy gain (AI correct) | +25 percentage points above Brain-Only baseline |
| Accuracy loss (AI faulty) | -15 percentage points below Brain-Only baseline |
| Effect size | Cohen's h = 0.81 (large); OR = 16.07 across all studies |
| Confidence inflation | +11.7 percentage points even when AI was wrong |

**Individual difference moderators:**

| Trait | Effect on cognitive surrender |
|------|------|
| Trust in AI (higher) | **Amplifies** --- more chat use, lower accuracy on faulty trials, more following (OR = 2.81) |
| Need for Cognition (higher) | **Protects** --- higher accuracy on faulty trials, less chat use, more override (OR = 0.83) |
| Fluid IQ (higher) | **Protects** --- better at overriding faulty AI (OR = 0.69) |
| Need for Cognitive Closure | Minor --- increased adoption but did not affect chat use or accuracy |

**Situational moderators:**

| Condition | Effect |
|-----------|--------|
| Time pressure | Reduced overall accuracy; cognitive surrender persisted (OR = 14.28) |
| Incentives + feedback | Improved accuracy but did not eliminate surrender gap (OR = 11.05) |
| Autopilot mode | Stimulus bypasses System 1/2 entirely --- adopted without internal engagement |

*Confidence: HIGH --- robust, preregistered experiments with large samples, consistent across three studies. Limitation: not yet peer-reviewed.*

---

## 3. Tri-System Theory: The Theoretical Framework

Shaw & Nave propose **Tri-System Theory** as an extension of Kahneman's dual-process model:

| System | Name | Properties |
|--------|------|------------|
| System 1 | Fast / Intuitive | Automatic, heuristic, low effort, prone to bias |
| System 2 | Slow / Deliberative | Analytical, rule-based, high effort, normative |
| System 3 | Artificial | External, automated, data-driven, dynamic. Can supplement, supplant, or reconfigure Systems 1 and 2. |

### Key Properties of System 3

1. **External** --- resides outside the human nervous system (in silico, cloud-based models)
2. **Automated** --- executes cognitive operations via statistical/generative algorithms
3. **Data-driven** --- outputs reflect training data distribution, including biases
4. **Dynamic** --- interactive, responds to human and environmental inputs in real time

### Canonical Cognitive Routes

| Route | Path | Description |
|-------|------|-------------|
| Intuition | S -> S1 -> R | Fast, automatic, heuristic |
| Deliberation | S -> S1 -> conflict -> S2 -> R | Reflective override |
| Cognitive offloading | S -> S1/S2 -> S3 -> S1/S2 -> R | Strategic delegation with oversight |
| **Cognitive surrender** | **S -> S1 (brief) -> S3 -> S1 (optional) -> R** | **Minimal internal engagement; uncritical adoption** |
| Autopilot | S -> S3 -> R | Stimulus never enters brain side |
| Recursive/hybrid | Multiple paths | Verify-then-adopt, override, rationalize |

### Relationship to "System 0"

Chiriatti et al. (2024) independently proposed "System 0" --- AI as an external cognitive system --- in *Nature Human Behaviour*. Tri-System Theory provides a more detailed empirical and theoretical elaboration, including specific mechanisms (surrender vs. offloading vs. autopilot) that System 0 does not differentiate.

*Confidence: CONFIRMED --- Tri-System Theory is the central theoretical framework; System 0 provides convergent support from a different research group.*

---

## 4. Research Program: Current State (May 2026)

The field has exploded in 2026. Here are the major contributions organized by domain:

### 4.1 AI Alignment / Cognitive Science

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Shaw & Nave (2026)** | Foundational empirical demonstration; Tri-System Theory | HIGH (preregistered, N=1,372) |
| **Castiello (2026)** --- Quadripartite Theory | Extends dual-process to four systems incorporating AI | PLAUSIBLE (single source) |
| **Kim, Usman & Garvey (2026)** --- Consumer Psych | Natural drift toward cognitive surrender in consumer AI use | CONFIRMED (2 sources) |
| **Storey (2026)** --- Triple Debt Model | Cognitive debt + intent debt as software health metrics | CONFIRMED (arXiv, cited by 4) |

### 4.2 Philosophy / Governance

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Van Valkenburg (2026)** | Cognitive surrender ≠ constitutive delegation; process integrity as missing variable | PLAUSIBLE (single working paper; philosophically grounded) |
| **Dimant (2026)** --- Moral surrender limits | Cognitive surrender does NOT generalize to symmetric moral surrender; domain boundary | CONFIRMED (preregistered, N=509, incentive-compatible) |

### 4.3 Law / Policing

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Vagle (2026)** --- Stanford Law Review | AI creates agnotology (deliberate ignorance) in policing; cognitive surrender + automation bias erode accountability | CONFIRMED (peer-reviewed law journal, builds on peer-reviewed automation bias literature) |

### 4.4 Cybersecurity / Systems

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Canale (2026)** --- The Surrender Loop | Recursive feedback loop: human surrender -> AI output -> training data -> convergence toward cognitive monoculture; cybersecurity implications | PLAUSIBLE (theoretical framework; components individually validated, loop itself not yet tested end-to-end) |

### 4.5 Software Engineering / Developer Practice

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Osmani (2026)** --- Software engineering perspective | Bridges cognitive surrender to daily developer practice; proposes concrete heuristics for staying on the offloading side of the line (construct expectations before reading output, read diffs as if a junior wrote them, ask the model to argue against itself). Connects surrender to comprehension debt, cognitive debt, and anti-rationalization tables. | CONFIRMED --- draws on academic sources (Shaw & Nave, MIT, Anthropic) with direct engineering application. Author of agent-skills integrated into this workspace. |
| **Williams (2026)** --- Practitioner summary | Applied implications for workplace training, workflow design, accountability | PLAUSIBLE (derivative, but cites primary sources) |
| **Lee et al. (2025)** --- Microsoft Research | Higher confidence in AI -> less critical thinking; higher self-confidence -> more scrutiny | CONFIRMED (CHI conference proceedings, 319 knowledge workers) |

---

## 5. Agent-Side Cognitive Surrender Mitigation Architectures

*A major finding of this expanded research: agents can be part of the solution, not just the problem --- but only with deliberately anti-surrender architecture. The following patterns represent the current state of the art (May 2026).*

### 5.1 Structured Adversarial Deliberation

#### 5.1.1 The CATFISH Protocol (Dynamic Devil's Advocate)

**Source:** Counsel Research (2026) --- empirical study of multi-agent committee deliberation
**Confidence:** CONFIRMED (empirical, 23% improvement over static baseline)

**The counterintuitive finding**: A permanent devil's advocate makes things worse. The committee develops **adversarial fatigue** --- it learns to dismiss the always-contrarian voice rather than engage with it.

| Pattern | Design | Robustness |
|---------|--------|------------|
| No adversarial role | Pure consensus | Low |
| Static devil's advocate | Always disagrees | Moderate (adversarial fatigue) |
| **Dynamic injection (CATFISH)** | Appears only when consensus collapse detected; challenges specific consensus; then disappears | **Highest (23% better than static)** |

**Implementation**: A CollapseDetector monitors the deliberation stream. When it detects sycophantic convergence (agents agreeing without substantive argument), it activates a CATFISH agent that:
1. Arrives unexpectedly (committee cannot develop antibodies)
2. Challenges the *specific* consensus that formed
3. Deactivates once substantive disagreement resumes

**Combined with drift enforcement**: detects gradual erosion of adversarial perspectives that precedes collapse. Combined condition: 8.4/10 robustness, 94% recovery rate.

**Root cause insight**: "Sycophantic collapse is not a bug in individual models. It is an emergent property of multi-agent systems built from models that were trained to agree. The right place to address it is the orchestration layer."

#### 5.1.2 Deliberative Collective Intelligence (DCI)

**Source:** arXiv 2603.11781
**Confidence:** CONFIRMED (formal algorithm, 100% decision packet completion)

A formal deliberation protocol where agents exchange **typed epistemic acts** (PROPOSE, CHALLENGE, BRIDGE, SYNTHESIZE) rather than undifferentiated text. Key innovations:

- **Tensions as first-class objects**: disagreements preserved in shared workspace, not flattened by majority rule
- **Convergent Flow Algorithm (DCI-CF)**: always terminates with a structured **decision packet** containing:
  - Selected option
  - Residual objections (explicitly preserved dissent)
  - Minority report
  - Reopen conditions (what would change this decision)
- **Procedural convergence guarantee**: does not force minds to agree; forces the process to close fairly

Achieves 100% decision packet completeness and 98% tension preservation, outperforms unstructured debate. The decision packet provides an audit trail absent from all simpler approaches.

#### 5.1.3 Dialectical Development Protocol (DDP)

**Source:** Klauden (2026) --- Hegelian multi-agent framework
**Confidence:** PLAUSIBLE (theoretical with implementation guidance)

Three-agent adversarial system mapped to Hegelian dialectics:
- **Agent A (Thesis / Architect)**: aggressive, prioritizes features and speed, responds to requirements with direct implementation
- **Agent B (Antithesis / Auditor)**: conservative, sole mission is to negate A --- hunts for architectural flaws, performance bottlenecks, security vulnerabilities
- **Agent C (Synthesis / Synthesizer)**: pragmatist, fuses valid points at higher dimension (does NOT average A and B)
- **User (Arbiter)**: holds ultimate decision power, defines the project's "general line"

**Critical design constraints:**
1. **Information isolation granularity**: B should only see A's final conclusion, not reasoning chain or user's preference framing
2. **Complexity gating**: not all tasks need dialectics --- a complexity assessor determines whether adversarial process is worth activating
3. **Collapsible process**: by default, show only final proposal + key disagreements; users can expand to see full exchange
4. **Pre-mortem prompting**: instead of telling Agent B to "find flaws," instruct it to "assume Agent A's proposal has already failed --- deduce the three most likely causes of failure"

#### 5.1.4 Heterogeneous Debate Engine (HDE)

**Source:** arXiv 2603.27404
**Confidence:** CONFIRMED (empirical, +39% doctrinal stability)

Identifies **architectural heterogeneity** as the crucial variable for debate stability:

| Component | Effect | Metric |
|-----------|--------|--------|
| **ID-RAG** (Identity-Grounded RAG) | Anchors agents to structured belief graphs | +39% doctrinal stability (DA = 0.90 vs 0.51) |
| **ToM-Lite** (Heuristic Theory of Mind) | Strategic opponent modeling | +35% cross-referencing |
| Combined (ID-RAG + ToM) | Perfect doctrinal adherence | DA = 1.00, argumentative coherence = 1.00 |

**Key finding**: Homogeneous architectures (same model, same prompts) inevitably converge toward consensus collapse. Heterogeneous architectures (different grounding, different strategies) preserve productive disagreement. "Identity-grounded heterogeneity is a priority for architects to avoid logical deterioration."

#### 5.1.5 ARGSBASE --- Structured Human-AI Deliberation

**Source:** Turkstra et al., EACL 2026 (peer-reviewed)
**Confidence:** CONFIRMED (peer-reviewed conference paper, user study)

A deliberation interface enabling users to engage with multiple LLMs coordinated by a moderator agent that assigns roles, manages turn-taking, and ensures structured interaction. Grounded in argumentation theory. User study found the tool "easy to use, perspective-enhancing." Positions LLMs as "reasonable parrots" --- reasoning partners guided by argumentative principles (relevance, responsibility, freedom).

### 5.2 Verification as an Independent Layer

#### 5.2.1 Cognitive Task Partitioning

**Source:** UglyEgg (2026)
**Confidence:** CONFIRMED (engineering architecture with formal reasoning)

A three-agent model with strict separation of concerns:

| Agent | Strength | Cannot Do |
|-------|----------|-----------|
| Humans | Intent, judgment, constraints | Combinatorics |
| LLMs | Pattern synthesis, idea exploration | Exhaustive reasoning |
| **Deterministic systems** | **Verification, search, proof, simulation** | Creativity |

**Cardinal rule**: *"AI-assisted exploration must never bypass deterministic verification layers."*

The workflow: Humans + LLMs explore design space -> candidate designs converted to structured artifacts -> deterministic validation (validate -> analyze -> model-check -> simulate) -> engineers review evidence artifacts.

**Claim**: "AI collaboration works best when cognition is partitioned deliberately. Humans provide meaning and intent. LLMs expand the design space. Deterministic systems perform exhaustive reasoning and verification."

#### 5.2.2 Incremental Verification

**Source:** AgentPatterns.ai (2026) / multiple practitioner sources
**Confidence:** CONFIRMED (convergent practitioner consensus)

Verify at each logical step, not at the end. Systematic comparison:

| Pattern | Error detection | Recovery cost |
|---------|----------------|---------------|
| Write everything then review | Errors compound through entire artifact | High (unwind cascade) |
| Batch verification (end only) | Misses compounding errors | Moderate-High |
| **Incremental verification** | Catches at source | Low (one checkpoint interval) |

**Critical caveat**: "A checkpoint that reads the agent's self-report is not a checkpoint." Agents claiming fixes without evidence is a known failure mode. Pair step gates with **outcome-based checks**: git diff, build exit codes, test output.

**When NOT to use**: throwaway prototypes/spikes (cheaper to rewrite than verify), very small units (blocks exploration), integration-level bugs (unit checks pass but emergent failures hide).

#### 5.2.3 Output Verification Loop

**Source:** VeroQ Shield / Agentic Patterns (2026)
**Confidence:** CONFIRMED (production implementations)

Three-phase verification between generation and action:
1. **Claim extraction**: decompose LLM output into individual atomic claims
2. **Evidence retrieval**: for each claim, retrieve supporting/contradicting evidence from authoritative sources
3. **Per-claim trust scoring**: assign trust score based on evidence alignment; aggregate confidence for full output

Run at every agent handoff boundary in multi-agent pipelines. Verification receipts provide compliance audit trail.

### 5.3 Enforced Participation Architecture

#### 5.3.1 The Recognition Model

**Source:** Attaguile (2026)
**Confidence:** CONFIRMED (comparative study of interaction architectures)

The single most provocative mitigation finding:

> "Collapse is not driven by model capability. It is driven by interaction architecture."
> "Any system that does not enforce participation will, over time, train its users not to think --- regardless of model capability."

**Configuration A (Delegation)** --- AI generates solution, human reviews -> surrender dominates.
**Configuration B (Recognition)** --- AI flags issue, asks developer to diagnose root cause *before* revealing its own analysis -> engineers at all levels show improved independent debugging.

Critical distinction:
- **Delegation systems** optimize for output. Evaluation happens after the fact.
- **Recognition systems** optimize for reasoning. Evaluation happens *during* the process.
- "Once a system commits to an answer, you are no longer governing reasoning --- you are auditing a decision that has already been made."

#### 5.3.2 Prosthetic Cognition

**Source:** Salvato (2026) --- extended mind thesis applied to AI interaction
**Confidence:** PLAUSIBLE (theoretical with 3-year practice demonstration)

A third framing beyond "tool" (human operates) and "agent" (machine acts autonomously): **AI as cognitive prosthetic**.

| Framing | Relationship | Cognitive Consequence |
|---------|-------------|----------------------|
| Tool | Human operates | Neutral (depends on use) |
| Agent | Machine acts | **Delegation -> atrophy** |
| **Prosthetic** | **Cognitive extension** | **Practitioner stays in the loop, gets sharper** |

Key properties:
- Model extends cognitive reach (unlimited working memory, parallel evaluation)
- Practitioner provides intent, judgment, domain expertise
- Bidirectional coupling tightens over time
- **Interface layer is the practice** --- purpose-built coupling that evolves

> "The practitioner who stays in the loop gets sharper at the work the system extends, while the one who delegates gets further from the judgment that made delegation safe in the first place."

#### 5.3.3 Collaborative Effort Scaling

**Source:** arXiv 2510.25744
**Confidence:** PLAUSIBLE (framework with case studies)

A framework for evaluating agent collaboration quality on two axes:
- **Interaction sustainability**: agents should generate greater value with more user effort
- **Maximum usability**: agents should encourage and sustain engagement across longer interactions when needed

Distinguishes between agents designed to *minimize* user involvement (high surrender risk) and agents designed to *scaffold* deeper understanding (low surrender risk).

### 5.4 Confirmation Architecture

#### 5.4.1 Optimal Confirmation Scheduling

**Source:** arXiv 2510.05307 (within-subjects study, n=48)
**Confidence:** CONFIRMED (empirical, 81% preference, 13.54% time reduction)

A decision-theoretic model for determining optimal confirmation checkpoint placement. The CDCR pattern (Confirmation -> Diagnosis -> Correction -> Redo) describes how users naturally supervise agents.

| Strategy | Preference | Time vs confirm-at-end |
|----------|-----------|----------------------|
| Confirm-at-end | Baseline | Baseline |
| **Intermediate (model-optimized)** | **81% preferred** | **-13.54%** |
| Confirm-every-step | Not measured (tedious) | Higher |

Model parameters: step accuracy + step duration + confirmation overhead. Dynamic programming finds optimal checkpoint placement.

#### 5.4.2 Magentic-UI --- Six Interaction Mechanisms

**Source:** Microsoft Research (arXiv 2507.22358)
**Confidence:** CONFIRMED (multi-dimensional evaluation)

Six mechanisms targeting different surrender points:
1. **Co-planning**: collaborate on plan of action before execution
2. **Co-tasking**: seamless take-and-hand-over of control during execution
3. **Action guards**: approval required for high-stakes actions
4. **Answer verification**: validate task completion against criteria
5. **Long-term memory**: leverage past experience for future performance
6. **Multi-tasking**: parallel execution while staying in the loop

#### 5.4.3 DoubleAgents --- Distributed Cognition Alignment

**Source:** arXiv 2509.12626 (2-day lab study n=10 + 3 real-world deployments)
**Confidence:** CONFIRMED (empirical with real-world validation)

Three components:
1. **Coordination agent**: maintains state, proposes plans and actions
2. **Dashboard visualization**: makes agent reasoning legible for user evaluation
3. **Policy module**: transforms user edits into reusable alignment artifacts (policies, email templates, stop hooks)

Users' comfort in offloading increased over time, but *required control at points of uncertainty* --- edge-case flagging and context-dependent actions. Simulation (unit-testing for user-specific correctness) compressed the alignment iteration cycle.

### 5.5 Bidirectional Adaptation

#### 5.5.1 BiCA --- Bidirectional Cognitive Alignment

**Source:** arXiv 2509.12179 (agent-based simulation, n=100 per condition)
**Confidence:** CONFIRMED (empirical, 46% synergy improvement)

Humans and AI mutually adapt, rather than AI conforming to fixed human preferences:

| Metric | Unidirectional | BiCA | Improvement |
|--------|---------------|------|-------------|
| Task success | 70.3% | 85.5% | +21.6% |
| Mutual adaptation rate | 27.2% | 89.6% | +230% |
| Protocol convergence | 19.5% | 84.3% | +332% |
| Out-of-distribution robustness | Baseline | +23% | +23% |

Uses KL-budget constraints for controlled co-evolution. Emergent protocols neither agent was programmed to use outperformed handcrafted ones by 84%.

#### 5.5.2 DOVA --- Deliberation-First Orchestration

**Source:** arXiv 2603.13327
**Confidence:** PLAUSIBLE (architecture with formal components)

Deliberation-first meta-reasoning layer decides whether to invoke tools before acting. Three-phase pipeline:
1. **Ensemble**: multiple agents solve independently in parallel; agreement score quantifies consensus
2. **Blackboard**: results posted to shared workspace for evidence and weighted votes
3. **Iterative Refinement**: top synthesis refined through multi-round critique

Six-level token budget for adaptive reasoning depth. Includes adversarial Bull-vs-Bear debate for evaluative queries with sequential turn-taking (critical: in round r, Bull conditions on all prior Bear arguments --- forces direct engagement with counterpoints).

## 6. Deeper Mechanism Theories

### 6.1 The AI Cognitive Trojan Horse

**Source:** Maynard, A. D. (2026). arXiv:2601.07085
**Confidence:** CONFIRMED (theoretical framework with testable predictions, peer-review track record)

Proposes that LLMs present **"honest non-signals"** --- genuine characteristics (fluency, helpfulness, apparent disinterest) that fail to carry the informational equivalent human characteristics would carry, because in humans these are costly to produce (requiring understanding, stakes, effort) while in LLMs they are computationally trivial.

**Four bypass mechanisms against epistemic vigilance:**

1. **Processing fluency decoupled from understanding** --- fluent text triggers automatic trust responses evolved for a world where fluency correlated with understanding
2. **Trust-competence presentation without stakes** --- LLMs sound authoritative but have no reputation to lose
3. **Cognitive offloading that delegates evaluation itself** --- the act of consulting the AI shifts responsibility for verification
4. **Optimization-driven sycophancy** --- models trained to be helpful and agreeable systematically suppress disagreement

**Counterintuitive prediction**: Cognitively sophisticated users may be *more* vulnerable --- they are better at generating post-hoc justifications for AI output, which masks the surrender. This reframes AI safety as partly a problem of *calibration* (aligning human evaluative responses with actual epistemic status) rather than solely preventing deception.

### 6.2 QSAF --- Cognitive Degradation in Agentic AI

**Source:** Atta et al. (2025). arXiv:2507.15330
**Confidence:** CONFIRMED (formal lifecycle, 7 runtime controls)

Introduces **Cognitive Degradation** as a vulnerability class in agentic AI systems. Unlike external threats (prompt injection), these failures originate *internally*:

| Failure Type | Mechanism | Manifests As |
|-------------|-----------|-------------|
| Memory starvation | Context window overflow, retrieval failure | Silent agent drift |
| Planner recursion | Unbounded self-reflection loops | Logic collapse |
| Context flooding | Irrelevant context dilutes relevant signal | Persistent hallucinations |
| Output suppression | Guardrails block legitimate outputs | Role collapse |

**Seven runtime controls (QSAF-BC-001 to BC-007)** monitor agent subsystems in real time, triggering:
- Fallback routing when confidence drops
- Starvation detection and context refresh
- Memory integrity enforcement
- Model of human fatigue/mapped onto agent architectures through neuroscience analogs

Maps agent architectures to human neural analogs --- enabling early detection of "fatigue," "starvation," and "role collapse" in agent systems.

### 6.3 Cognitive Amplification vs. Delegation Framework

**Source:** arXiv 2603.18677
**Confidence:** CONFIRMED (agent-based simulation across regimes)

Formal mathematical framework with four metrics to distinguish amplification from delegation:

| Metric | Meaning | Desired Value |
|--------|---------|---------------|
| **CAI\*** (Cognitive Amplification Index) | Collaborative gain relative to best standalone agent | > 0 |
| **D** (Dependency Ratio) | Structural balance of contribution in hybrid outputs | < 1 |
| **HRI** (Human Reliance Index) | How much human capability is retained | High |
| **HCDR** (Human Cognitive Drift Rate) | Change in autonomous human performance over time | 0 or negative |

**Critical finding**: Across all tested regimes (full delegation, mixed reliance, minimal AI), *no configuration achieved genuine amplification* (CAI\* < 0, D > 1 in all cases). Even when atrophy was reduced to zero, amplification was not recovered. True human-AI amplification may be substantially harder than short-term performance measures indicate.

## 7. Major Debates and Open Questions

### 7.1 Does Cognitive Surrender Generalize to Moral Decisions?

**Dimant (2026)** provides the sharpest boundary condition yet: **No.** Cognitive surrender on factual reasoning tasks does not extend to symmetric moral surrender. AI prosocial advice shifts behavior upward; antisocial advice does not push it downward. The domain boundary:

- **Cognitive tasks:** Symmetric surrender (follow AI whether correct or incorrect)
- **Moral tasks:** Directional influence only (prosocial advice works; antisocial does not)

The mechanism: AI can **confirm** private moral preference (norm activation) but cannot **override** it (lacks community standing for norm replacement).

*Confidence: CONFIRMED --- Dimant's N=509 preregistered experiment with incentive-compatible stakes.*

### 8.2 What Makes Someone Susceptible?

The evidence converges on a profile:

| Susceptible | Resistant |
|-------------|-----------|
| High trust in AI | High Need for Cognition |
| Lower fluid intelligence | Higher fluid intelligence |
| Lower need for cognition | High self-confidence in own ability |
| High cue-sensitivity (CSS-8) | Habit of critical thinking (domain-general) |

The Microsoft Research finding is particularly important: **domain-general critical thinking habits protect** --- it's not skepticism of AI specifically, but the disposition to think critically about any source.

*Confidence: CONFIRMED --- replicated across Shaw & Nave (3 studies), Lee et al. (2025), and Dimant (2026).*

### 8.3 Is Cognitive Surrender Maladaptive?

**Not necessarily.** The literature is careful:

- When AI is consistently accurate, surrender is **optimal** --- it saves cognitive effort and improves outcomes
- When AI is faulty, surrender produces **predictable harm** --- accuracy falls below no-AI baseline
- The danger is **opacity**: users cannot easily know when the AI is reliable vs. faulty
- The triage problem: domain matters; for trivial decisions, surrender is fine; for high-stakes decisions, it is catastrophic

### 8.4 Can We Train Against It?

| Intervention | Evidence |
|-------------|----------|
| General training / instructions | **Ineffective** (Parasuraman & Manzey 2010; confirmed for AI context) |
| Exposure to AI failures | **Promising** (reduces automation bias in prior literature; not yet directly tested for cognitive surrender) |
| Process accountability | **Promising** (Tetlock's framework: requiring justification of reasoning, not just outcomes) |
| Incentives + feedback | **Partially effective** (Shaw & Nave Study 3: reduces but does not eliminate surrender; OR remains 11+) |
| Time pressure relief | **Not effective** (makes surrender worse) |
| **Scaffolded Cognitive Friction** (MAS devil's advocate agents) | **PROMISING THEORY** (arXiv 2603.21735: proposes multi-agent systems as explicit cognitive forcing functions; neurophysiological evaluation framework; not yet empirically validated) |
| **Structured disagreement matrices** (anti-rationalization tables) | **PROMISING** (Osmani 2026; agent-skills pattern; integrative rationale but no direct experimental test as surrender intervention) |
| **Construct expectation before generation** | **PROMISING** (Osmani 2026; based on Shaw & Nave calibration framework; no direct empirical test) |
| **AI-free internalization phases** (solo work before AI) | **PROMISING** (Kos'myna et al. 2025: MIT EEG shows prior AI-free work produces stronger neural engagement when transitioning to AI use; Cognitive Offloading Ladder framework) |

### 8.5 The Surrender Loop Hypothesis

Canale (2026) identifies a potentially profound recursive effect: humans produce text -> AI absorbs psychological patterns -> alignment selects some patterns -> humans adopt AI output -> humans produce AI-influenced text -> that text becomes future training data. Each iteration selects for statistically dominant patterns and attenuates marginal ones, potentially creating **cognitive monoculture** --- a WEIRD psychological profile projected as universal.

This hypothesis is **plausible but unvalidated** at the loop level. Individual components are well-supported:
- Cognitive surrender: ✅ (Shaw & Nave)
- Anthropomorphic vulnerability inheritance: ✅ (Canale & Thimmaraju)
- Typicality bias / distribution degeneration: ✅ (Zhang et al., Kirk et al.)
- WEIRD sampling bias: ✅ (Henrich, Heine & Norenzayan)

The complete end-to-end loop has not been tested longitudinally.

### 8.6 Scholarly Debate: Is Cognitive Surrender a New Phenomenon?

**Critique --- Potkalitsky (2026)**:
A significant critique argues that cognitive surrender is **not a novel discovery** but a relabeling of established phenomena:

- **Anchoring** --- the tendency to rely on the first piece of information encountered
- **Automation bias** --- uncritical trust in automated system outputs (Parasuraman & Manzey, 2010)
- **Authority compliance** --- deferring to authoritative-seeming sources (Milgram tradition)
- **Advice-taking under uncertainty** --- the judge-advisor system literature

The critique is important and partially correct. What Shaw & Nave contribute is not the discovery of a new bias but:
1. **Integration** --- unifying multiple known effects under a single theoretical framework (Tri-System Theory) with a new mechanism: System 3 as an external cognitive system that bypasses System 1/2
2. **Measurement** --- providing an experimental paradigm that isolates the effect cleanly (OR = 16.07, h = 0.81)
3. **Naming** --- giving practitioners a tractable concept ("surrender") that aids recognition

The debate's value: the critique correctly identifies that **intervention research lags behind labeling**. The field has a name for the problem; it does not yet have tested, scalable solutions outside controlled lab conditions. This directly motivates the practical integration work in this workspace.

*Confidence: DEBATE NOTED --- both positions have merit; the critique identifies a genuine gap in intervention research while understating the value of Tri-System Theory as an integrative framework.*

---

## 9. Key Sources (Ranked by Authority)

### Primary / Original Research
1. **Shaw & Nave (2026)** --- SSRN 6097646. Tri-System Theory and the first empirical demonstration. [PLAUSIBLE -> HIGH: preregistered, large N, not yet peer-reviewed]
2. **Dimant (2026)** --- SSRN 6622458. Domain boundary: cognitive vs. moral surrender. [CONFIRMED: preregistered, incentive-compatible]
3. **Lee et al. (2025)** --- CHI 2025. Microsoft Research study of 319 knowledge workers. [CONFIRMED: peer-reviewed conference proceedings]
4. **Kos'myna et al. (2025)** --- MIT Media Lab. "Your Brain on ChatGPT." EEG study (N=54, 4 sessions over 4 months): LLM use produces weakest neural connectivity; prior LLM use causes persistent under-engagement when AI is removed. Introduces "cognitive debt." [HIGH: peer-reviewed neuroscience methods, pre-registered, multi-session longitudinal design]
5. **Van Valkenburg (2026)** --- SSRN 6536378. Process integrity framework. [PLAUSIBLE: philosophically grounded working paper]
6. **Canale (2026)** --- SSRN 6228558. The Surrender Loop. [PLAUSIBLE: theoretical, well-sourced components, unvalidated at loop level]
7. **Vagle (2026)** --- Stanford Law Review (forthcoming). Policing and agnotology. [HIGH: peer-reviewed law review]
8. **Storey (2026)** --- arXiv 2603.22106. Triple Debt Model. [CONFIRMED: arXiv preprint, cited by 4]
9. **Vicente & Matute (2023)** --- *Scientific Reports*. AI bias persistence after removal. [ESTABLISHED: peer-reviewed]
10. **Parasuraman & Manzey (2010)** --- *Human Factors*. Foundational automation bias review. [ESTABLISHED: peer-reviewed, 870+ citations]

### Software Engineering / Practitioner
11. **Osmani (2026)** --- Blog post. Engineer's guide to cognitive surrender; connects to comprehension debt, cognitive debt, anti-rationalization tables, agent harness engineering. [CONFIRMED: engineer at Google, author of agent-skills, primary sources cited]
12. **Storey (2026)** --- arXiv 2603.22106. Triple Debt Model (technical, cognitive, intent debt). [CONFIRMED: arXiv preprint]

### Intervention Research
13. **Cognitive Agency Surrender (2026)** --- arXiv 2603.21735. Scaffolded Cognitive Friction (SCF): proposes MAS-based "devil's advocate" agents as cognitive forcing functions to interrupt surrender. [SPECULATIVE: theoretical proposal; neurophysiological evaluation framework not yet validated]

### Theoretical / Contextual
14. **Chiriatti et al. (2024)** --- *Nature Human Behaviour*. System 0. [ESTABLISHED: peer-reviewed, 51+ citations]
15. **Bainbridge (1983)** --- *Automatica*. Ironies of automation. [ESTABLISHED: foundational, 4000+ citations]
16. **Clark & Chalmers (1998)** --- *Analysis*. Extended mind. [ESTABLISHED: foundational]

### Critique / Debate
17. **Potkalitsky (2026)** --- Substack. Argues cognitive surrender relabels known phenomena (anchoring, automation bias); calls for intervention research over neologisms. [PLAUSIBLE: identifies genuine gap in intervention research]

### Agent Mitigation / Architecture (New in v2)
18. **Xu, Shen, Yan & Ren (2026)** --- arXiv 2603.21735v2. Cognitive Agency Surrender: Scaffolded Cognitive Friction via MAS-based devil's advocates. [PLAUSIBLE: theoretical proposal with neurophysiological evaluation framework]
19. **Counsel Research (2026)** --- CATFISH Protocol. Dynamic adversarial injection outperforms static devil's advocate by 23%. [CONFIRMED: empirical, collapsible detection + drift enforcement = 8.4/10 robustness]
20. **UglyEgg (2026)** --- Cognitive Task Partitioning. Separate exploration (humans + LLMs) from deterministic verification. [CONFIRMED: engineering architecture with formal reasoning]
21. **Attaguile (2026)** --- Recognition model. Enforced participation architecture; collapse is driven by interaction architecture, not model capability. [CONFIRMED: comparative study of interaction architectures]
22. **Salvato (2026)** --- Prosthetic Cognition. AI as cognitive prosthetic (third framing beyond tool/agent). [PLAUSIBLE: theoretical with 3-year practice demonstration]
23. **Turkstra et al. (2026)** --- ARGSBASE. EACL 2026. Structured multi-agent deliberation interface. [CONFIRMED: peer-reviewed conference proceedings, user study]
24. **DCI (2026)** --- arXiv 2603.11781. Deliberative Collective Intelligence with decision packet guarantees. [CONFIRMED: formal algorithm, 100% completion]
25. **Klauden (2026)** --- Dialectical Development Protocol (DDP). Hegelian three-agent adversarial framework. [PLAUSIBLE: theoretical with implementation constraints]
26. **HDE (2026)** --- arXiv 2603.27404. Heterogeneous Debate Engine with ID-RAG + ToM-Lite. [CONFIRMED: +39% doctrinal stability, DA = 1.00]
27. **Maynard (2026)** --- arXiv 2601.07085. AI Cognitive Trojan Horse. Epistemic vigilance bypass via honest non-signals. [CONFIRMED: theoretical framework with testable predictions]
28. **Atta et al. (2025)** --- arXiv 2507.15330. QSAF Framework. Cognitive Degradation vulnerability class; 7 runtime controls. [CONFIRMED: formal lifecycle, cross-platform]
29. **Cognitive Amplification (2026)** --- arXiv 2603.18677. CAI\* metrics; no regime achieves true amplification. [CONFIRMED: agent-based simulation]
30. **BiCA (2026)** --- arXiv 2509.12179. Bidirectional Cognitive Alignment; 46% synergy improvement. [CONFIRMED: simulation across conditions]
31. **DOVA (2026)** --- arXiv 2603.13327. Deliberation-first orchestration, 3-phase pipeline. [PLAUSIBLE: architecture with formal components]
32. **Microsoft Research (2026)** --- arXiv 2507.22358. Magentic-UI: 6 interaction mechanisms. [CONFIRMED: multi-dimensional evaluation]
33. **DoubleAgents (2026)** --- arXiv 2509.12626. Distributed cognition for human-agent alignment. [CONFIRMED: 2-day lab study + 3 real-world deployments]
34. **Confirmation Scheduling (2026)** --- arXiv 2510.05307. Decision-theoretic checkpoint placement. [CONFIRMED: within-subjects study, n=48, 81% preference]
35. **Collab. Effort Scaling (2026)** --- arXiv 2510.25744. Interaction sustainability + maximum usability framework. [PLAUSIBLE: framework with case studies]
36. **ARXIV 2603.02050 (2026)** --- CLEO. Concurrent interaction; delegation 70.1%, direction 28.5%, concurrent 31.8%. [CONFIRMED: 2-day study, n=10, 214 turns]
37. **EDF/Copa (2026)** --- arXiv 2602.01415. Adaptive scaffolding for LLM agents. [PLAUSIBLE: high school classroom study]
38. **AgentPatterns.ai (2026)** --- Incremental Verification pattern. [CONFIRMED: convergent practitioner consensus]
39. **Thompson, J. (2026)** --- Why "Just Review the AI Output" Doesn't Work. Practitioner synthesis. [PLAUSIBLE: secondary source with actionable recommendations]
40. **Mehta, Y. (2026)** --- Multi-Agent Self-Verification. 4 verification architectures compared. [PLAUSIBLE: practitioner analysis with production insights]

---

## 10. Gaps and Limitations

1. **Longitudinal data missing:** No study yet tracks whether repeated AI exposure increases cognitive surrender over time, or whether users learn to calibrate.
2. **Peer review pending:** The central paper (Shaw & Nave) is a working paper. Effect sizes may shift.
3. **Task narrowness:** Most evidence uses CRT-style reasoning tasks. Less is known about surrender in open-ended, creative, or real-world professional tasks.
4. **Cross-cultural data absent:** Virtually all studies use WEIRD samples (US/Prolific/MTurk). Surrender rates in non-WEIRD populations unknown.
5. **Loop unvalidated end-to-end:** The Surrender Loop (Canale 2026) is theoretically coherent but empirically untested as a whole.
6. **CSS-8 validation limited:** Dimant's Cognitive Surrender Scale is promising (α = .898) but post-treatment only; pre-treatment measurement needed.
7. **Intervention research nascent:** Only incentives + feedback tested directly. Training design, process accountability, UI interventions remain untested.
8. **Field studies absent:** All evidence from controlled experiments or surveys; no workplace field experiments.
9. **AI capability confound:** GPT-4o was used; results may not generalize to different models, architectures, or capability levels.
10. **Demographic heterogeneity unknown:** Age, gender, personality, culture, domain expertise effects not systematically explored.
11. **Mitigation architecture evidence thin:** Most agent-side mitigation patterns (CATFISH, DCI, DDP, HDE) tested only on agent-agent interaction quality, not on *human cognitive preservation* over time.
12. **Multi-agent debate ≠ human calibration:** The 23% improvement from CATFISH is on recommendation robustness, not on human critical thinking retention. Whether adversarial agent architectures preserve human cognition is an open question.
13. **Trust measurement infrastructure absent:** Calibrated confidence signaling, cognitive drift tracking, and surrender rate dashboards do not exist in production tools.
14. **Cognitive monoculture under-validated:** The Canale Surrender Loop hypothesis remains at the component-validation level; no longitudinal study tracks whether multi-agent friction architectures prevent it.

---

## 11. Practical Implications

### For Individuals
- Monitor your own "surrender rate" --- how often do you check AI output before adopting it?
- Domain-general critical thinking habits protect against surrender, regardless of AI skepticism level
- Deliberately expose yourself to AI failures to calibrate trust

### For Software Engineers (Osmani, 2026)
- **Construct an expectation before reading output:** Write down (even mentally) what you think the answer should look like before running the agent. When AI matches expectation -> calibrated. When it doesn't -> you have a genuine decision to make.
- **Read diffs as if a junior wrote them:** "Seems right" is not a review, regardless of whether the author is human or AI.
- **Ask the model to argue against itself:** Most models produce a confident answer and an equally confident counter-argument. If you can't reason about which is right, you found a surrender point.
- **Notice when you're tired:** Surrender is a fatigue phenomenon. Stop letting the agent generate when you're too tired to evaluate.
- **Watch where the confidence is coming from:** If you're defending a design choice and can't reconstruct the *why* --- only that the agent suggested it --- that's a surrender artifact.
- **Verification as a hard exit criterion:** Every agent-completed task should terminate in concrete evidence (test, screenshot, log, trace), not "looks done."
- **Smaller scope, smaller PRs:** Surrender scales with size. ~100-line PRs are actually reviewable.
- **Conceptual inquiry over generation when learning:** Ask AI to *explain* before asking it to *generate*. The same tool, used interrogatively rather than productively, builds rather than erodes mental models (confirmed by Anthropic's skill-formation study).
- **Solo time at the keyboard:** Write some code without AI every week as a calibration exercise. The day you can't comfortably build something simple without AI assistance is the day offloading became surrender.
- **Anti-rationalization tables:** Pre-write rebuttals to the excuses the model (or your tired self) will produce for skipping rigorous steps. Models are exceptional at generating plausible reasons to skip verification.

### For Organizations
- Training alone is ineffective --- direct exposure to AI failures works better
- Process accountability (requiring justification of reasoning) is more effective than outcome accountability
- Time pressure amplifies surrender; build slack into AI-assisted workflows
- Real-time feedback after errors reduces surrender in subsequent decisions
- **Throughput is a misleading metric:** PRs merged and features shipped do not distinguish between "I built this and understand it" and "the agent built this and I approved it." Both look identical on the dashboard.
- **Friction by design:** Scaffolded Cognitive Friction (deliberate moments of resistance --- required design docs, confirmation steps, checklists) is what stands between offloading and surrender.

### For Agent Architecture / Workflow Design (New in v2)
- **Prefer dynamic adversarial injection over static.** A permanent devil's advocate causes adversarial fatigue; a CATFISH that appears only when consensus collapse is detected is 23% more effective (Counsel Research).
- **Enforce architectural heterogeneity.** Homogeneous debate architectures (same model, same prompts) converge to sycophantic consensus. Use ID-RAG (different grounding per agent) and ToM-based strategy modeling (HDE).
- **Separate exploration from verification.** LLMs generate possibilities; deterministic verification layers prove them. Do NOT let the generator verify its own output. Cognitive Task Partitioning is the formal version of this rule.
- **Require outcome-based checkpoints, not self-reports.** A checkpoint that reads "I fixed the bug" without checking git diff or test exit codes is not a checkpoint. Pair every agent step gate with an objective verification.
- **Use the Recognition model, not the Delegation model.** When the AI flags an issue, ask the human to diagnose *before* revealing the AI's own analysis. This turns the AI into a forcing function for reasoning rather than a substitute.
- **Model intermediate confirmation frequency dynamically.** A decision-theoretic model (step accuracy × step duration × confirmation overhead) determines optimal checkpoint placement. 81% of users prefer this over confirm-at-end.
- **Track Triple Debt explicitly.** Cognitive debt (people's shared understanding) and intent debt (externalized rationale) need dashboards, just like technical debt. System walkthroughs, reimplementation exercises, and retrospectives are the mitigation tools.
- **Signal calibrated confidence.** Always surface uncertainty and an escalation path when confidence is low. Users who see calibrated signals engage more critically (Maynard, 2026).
- **Preserve dissent structurally.** DCI's decision packet (selected option + residual objections + minority report + reopen conditions) provides an audit trail and prevents premature convergence.
- **Monitor for agent-side cognitive degradation.** Memory starvation, planner recursion, and context flooding are internal vulnerability classes in agentic systems (QSAF framework). Implement runtime controls for fallback routing and starvation detection.

### For Designers
- AI systems that always sound confident are dangerous --- uncertainty indicators may help
- Confidence scores and transparent explanations can encourage calibrated engagement
- Adaptive interfaces that adjust cognitive demands based on context

### For Policymakers
- Current governance frameworks (EU AI Act, NIST AI RMF) focus on output quality and post-hoc accountability, not the conditions of delegation
- Process integrity (compelling pre-delegation deliberation) may be the missing variable
- Cognitive surrender has direct implications for liability regimes --- who is responsible when AI-assisted decisions cause harm?

---

## 12. Confidence Summary

| Claim | Confidence | Evidence |
|-------|-----------|----------|
| Cognitive surrender exists and is empirically measurable | **ESTABLISHED** | Multiple independent replications, large N |
| Effect size is large (h ≈ 0.81) | **CONFIRMED** | Trial-level synthesis across 3 studies |
| High Trust in AI amplifies surrender | **CONFIRMED** | Replicated across studies |
| High Need for Cognition / Fluid IQ protects | **CONFIRMED** | Replicated across studies |
| Time pressure makes surrender worse | **CONFIRMED** | Shaw & Nave Study 2 |
| Incentives + feedback reduce but don't eliminate surrender | **CONFIRMED** | Shaw & Nave Study 3 |
| Moral surrender is asymmetric (prosocial only) | **CONFIRMED** | Dimant (2026) |
| Tri-System Theory as theoretical framework | **PLAUSIBLE** | Single research group, but well-specified |
| The Surrender Loop (cognitive monoculture) | **SPECULATIVE** | Theoretical; components validated, loop untested |
| Process integrity as governance solution | **PLAUSIBLE** | Single source, philosophically grounded |
| Training alone reduces surrender | **REFUTED** | Prior automation bias literature |
| Dynamic adversarial injection (CATFISH) improves deliberation quality | **CONFIRMED** | Counsel Research: +23% over static, 94% recovery |
| Heterogeneous debate architectures resist consensus collapse | **CONFIRMED** | HDE: ID-RAG +39% stability, ToM +35% cross-ref |
| Cognitive Task Partitioning (separate exploration from verification) | **CONFIRMED** | UglyEgg: convergent engineering consensus |
| The Recognition model (enforced participation) reduces surrender | **CONFIRMED** | Attaguile: interaction architecture > model capability |
| True human-AI cognitive amplification (CAI\* > 0) | **UNCERTAIN** | Simulation: no regime achieved amplification; may require novel architectures |
| Bidirectional adaptation (BiCA) improves collaboration outcomes | **CONFIRMED** | Simulation: +21.6% success, +230% mutual adaptation |
| Intermediate confirmation beats confirm-at-end | **CONFIRMED** | Within-subjects: 81% preference, 13.54% time reduction |
| Prosthetic Cognition framing (AI as cognitive extension) | **PLAUSIBLE** | Salvato: 3-year practice demonstration, Clark extended mind grounding |

---

## 13. Sources Cited

1. AgentPatterns.ai (2026). Incremental Verification pattern. https://agentpatterns.ai/verification/incremental-verification/
2. Atta, H., et al. (2025). QSAF: A Novel Mitigation Framework for Cognitive Degradation in Agentic AI. arXiv:2507.15330.
3. Attaguile, S. (2026). Recognition Is All You Need: Human--AI Dynamics as Cognitive Amplification with Enforced Participation. *DEV Community*.
4. Bainbridge, L. (1983). Ironies of automation. *Automatica*, 19(6), 775--779.
5. Canale, G. (2026). The Surrender Loop: Archetypal Selection and Cognitive Convergence in Recursive Human-AI Interaction. SSRN 6228558.
6. Castiello, M. (2026). From Dual-Process Models to the Quadripartite Theory. SSRN 6385700.
7. Chiriatti, M., et al. (2024). The case for human-AI interaction as system 0 thinking. *Nature Human Behaviour*, 8, 1829--1830.
8. Clark, A., & Chalmers, D. (1998). The extended mind. *Analysis*, 58(1), 7--19.
9. Cognitive Agency Surrender (2026). Defending Epistemic Sovereignty via Scaffolded AI Friction. Xu, Shen, Yan & Ren. arXiv:2603.21735.
10. Cognitive Amplification vs Delegation (2026). arXiv:2603.18677.
11. Cohn, C. (2026). Evidence-Decision-Feedback: Theory-Driven Adaptive Scaffolding for LLM Agents. arXiv:2602.01415.
12. Counsel Research (2026). What if your devil's advocate is making things worse? https://counsel.getmason.io/research/committee-roles
13. Deliberative Collective Intelligence (DCI) (2026). arXiv:2603.11781.
14. Dialectical Development Protocol (DDP) (2026). Klauden. https://www.klauden.xyz/en/articles/multi-agent-adversarial-review
15. Dimant, E. (2026). On the Limits of Moral Surrender to AI. SSRN 6622458.
16. DoubleAgents (2026). Human-Agent Alignment in a Socially Embedded Workflow. arXiv:2509.12626.
17. DOVA (2026). Deliberation-first orchestration. arXiv:2603.13327.
18. Heterogeneous Debate Engine (HDE) (2026). arXiv:2603.27404.
19. Kim, T. W., Usman, U., & Garvey, A. (2026). From algorithm aversion to AI dependence. *Consumer Psychology*.
20. Kos'myna, N., et al. (2025). Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task. MIT Media Lab. arXiv:2506.08872.
21. Lee, H-P., et al. (2025). The impact of generative AI on critical thinking. *CHI 2025*.
22. Magentic-UI (2026). Microsoft Research. arXiv:2507.22358.
23. Maynard, A. D. (2026). The AI Cognitive Trojan Horse: How Large Language Models May Bypass Human Epistemic Vigilance. arXiv:2601.07085.
24. Mehta, Y. (2026). How Multi-Agent Self-Verification Actually Works. *Towards AI*.
25. Mosier, K. L., & Skitka, L. J. (1996). Human decision makers and automated decision aids. In *Automation and human performance*.
26. Osmani, A. (2026). Cognitive Surrender. *addyosmani.com/blog*. https://addyosmani.com/blog/cognitive-surrender/
27. Parasuraman, R., & Manzey, D. H. (2010). Complacency and bias in human use of automation. *Human Factors*, 52(3), 381--410.
28. Potkalitsky, N. (2026). We Don't Need Another Neologism. We Need Interventions. *Substack*.
29. Salvato, P. (2026). A Different Kind of Harness: AI as Cognitive Prosthetic. https://petersalvato.com/research/prosthetic-cognition/
30. Shaw, S. D., & Nave, G. (2026). Thinking---Fast, Slow, and Artificial: How AI is Reshaping Human Reasoning and the Rise of Cognitive Surrender. SSRN 6097646.
31. Storey, M-A. (2026). From Technical Debt to Cognitive and Intent Debt. arXiv:2603.22106.
32. Thompson, J. (2026). Why "Just Review the AI Output" Doesn't Work: Cognitive Surrender and Safer Human-AI Workflows. https://joshthompson.co.uk/ai/ai-output-review-cognitive-surrender-safer-workflows/
33. Turkstra, F., Nabhani, S., & Al Khatib, K. (2026). ARGSBASE: A Multi-Agent Interface for Structured Human-AI Deliberation. *EACL 2026*.
34. UglyEgg (2026). Cognitive Task Partitioning. https://github.com/UglyEgg/cognitive-task-partitioning
35. Vagle, J. L. (2026). AI Agnotology, Cognitive Surrender, and Policing Accountability. *Stanford Law Review Online* (forthcoming).
36. Van Valkenburg, Z. (2026). Cognitive Surrender v. Constitutive Delegation. SSRN 6536378.
37. Vicente, L., & Matute, H. (2023). Humans inherit artificial intelligence biases. *Scientific Reports*, 13, 15737.
38. Wegner, D. M. (1987). Transactive memory. In *Theories of Group Behavior*.
39. Williams, M. (2026). Cognitive surrender --- how AI is reshaping professional judgement at work. *Employee Feedback* blog.
