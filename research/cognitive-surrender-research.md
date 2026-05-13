# Cognitive Surrender: Comprehensive Research Synthesis

**Date:** 2026-05-13
**Researcher:** Agent (Orchestrator)
**Methodology:** 6-phase systematic research (Frame → Discover → Gather → Triangulate → Apply → Preserve)

---

## Executive Summary

Cognitive surrender is the tendency to adopt AI-generated outputs with minimal critical evaluation, bypassing both intuitive and deliberative reasoning. First rigorously defined and empirically demonstrated by Shaw and Nave (2026) at the Wharton School, the concept has rapidly spawned a cross-disciplinary literature spanning psychology, philosophy, law, cybersecurity, software engineering, and governance. Addy Osmani (Google) has recently bridged this academic work to daily software engineering practice, connecting surrender to comprehension debt, anti-rationalization tables, and the calibration problem every developer now faces. This document synthesizes the primary sources, key findings, theoretical frameworks, debates, and open questions as of May 2026.

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
| Mechanism | System 2 → System 3 (assist) | System 3 → System 1 (adopt) |

*Sources: Shaw & Nave (2026), Williams (2026)*
*Confidence: CONFIRMED — directly defined in the primary source and consistently used across all subsequent literature.*

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

**Shaw, S. D., & Nave, G. (2026).** *Thinking—Fast, Slow, and Artificial: How AI is Reshaping Human Reasoning and the Rise of Cognitive Surrender.* Wharton School Research Paper. SSRN 6097646.

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
| Trust in AI (higher) | **Amplifies** — more chat use, lower accuracy on faulty trials, more following (OR = 2.81) |
| Need for Cognition (higher) | **Protects** — higher accuracy on faulty trials, less chat use, more override (OR = 0.83) |
| Fluid IQ (higher) | **Protects** — better at overriding faulty AI (OR = 0.69) |
| Need for Cognitive Closure | Minor — increased adoption but did not affect chat use or accuracy |

**Situational moderators:**

| Condition | Effect |
|-----------|--------|
| Time pressure | Reduced overall accuracy; cognitive surrender persisted (OR = 14.28) |
| Incentives + feedback | Improved accuracy but did not eliminate surrender gap (OR = 11.05) |
| Autopilot mode | Stimulus bypasses System 1/2 entirely — adopted without internal engagement |

*Confidence: HIGH — robust, preregistered experiments with large samples, consistent across three studies. Limitation: not yet peer-reviewed.*

---

## 3. Tri-System Theory: The Theoretical Framework

Shaw & Nave propose **Tri-System Theory** as an extension of Kahneman's dual-process model:

| System | Name | Properties |
|--------|------|------------|
| System 1 | Fast / Intuitive | Automatic, heuristic, low effort, prone to bias |
| System 2 | Slow / Deliberative | Analytical, rule-based, high effort, normative |
| System 3 | Artificial | External, automated, data-driven, dynamic. Can supplement, supplant, or reconfigure Systems 1 and 2. |

### Key Properties of System 3

1. **External** — resides outside the human nervous system (in silico, cloud-based models)
2. **Automated** — executes cognitive operations via statistical/generative algorithms
3. **Data-driven** — outputs reflect training data distribution, including biases
4. **Dynamic** — interactive, responds to human and environmental inputs in real time

### Canonical Cognitive Routes

| Route | Path | Description |
|-------|------|-------------|
| Intuition | S → S1 → R | Fast, automatic, heuristic |
| Deliberation | S → S1 → conflict → S2 → R | Reflective override |
| Cognitive offloading | S → S1/S2 → S3 → S1/S2 → R | Strategic delegation with oversight |
| **Cognitive surrender** | **S → S1 (brief) → S3 → S1 (optional) → R** | **Minimal internal engagement; uncritical adoption** |
| Autopilot | S → S3 → R | Stimulus never enters brain side |
| Recursive/hybrid | Multiple paths | Verify-then-adopt, override, rationalize |

### Relationship to "System 0"

Chiriatti et al. (2024) independently proposed "System 0" — AI as an external cognitive system — in *Nature Human Behaviour*. Tri-System Theory provides a more detailed empirical and theoretical elaboration, including specific mechanisms (surrender vs. offloading vs. autopilot) that System 0 does not differentiate.

*Confidence: CONFIRMED — Tri-System Theory is the central theoretical framework; System 0 provides convergent support from a different research group.*

---

## 4. Research Program: Current State (May 2026)

The field has exploded in 2026. Here are the major contributions organized by domain:

### 4.1 AI Alignment / Cognitive Science

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Shaw & Nave (2026)** | Foundational empirical demonstration; Tri-System Theory | HIGH (preregistered, N=1,372) |
| **Castiello (2026)** — Quadripartite Theory | Extends dual-process to four systems incorporating AI | PLAUSIBLE (single source) |
| **Kim, Usman & Garvey (2026)** — Consumer Psych | Natural drift toward cognitive surrender in consumer AI use | CONFIRMED (2 sources) |
| **Storey (2026)** — Triple Debt Model | Cognitive debt + intent debt as software health metrics | CONFIRMED (arXiv, cited by 4) |

### 4.2 Philosophy / Governance

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Van Valkenburg (2026)** | Cognitive surrender ≠ constitutive delegation; process integrity as missing variable | PLAUSIBLE (single working paper; philosophically grounded) |
| **Dimant (2026)** — Moral surrender limits | Cognitive surrender does NOT generalize to symmetric moral surrender; domain boundary | CONFIRMED (preregistered, N=509, incentive-compatible) |

### 4.3 Law / Policing

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Vagle (2026)** — Stanford Law Review | AI creates agnotology (deliberate ignorance) in policing; cognitive surrender + automation bias erode accountability | CONFIRMED (peer-reviewed law journal, builds on peer-reviewed automation bias literature) |

### 4.4 Cybersecurity / Systems

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Canale (2026)** — The Surrender Loop | Recursive feedback loop: human surrender → AI output → training data → convergence toward cognitive monoculture; cybersecurity implications | PLAUSIBLE (theoretical framework; components individually validated, loop itself not yet tested end-to-end) |

### 4.5 Software Engineering / Developer Practice

| Paper | Key Claim | Confidence |
|-------|-----------|------------|
| **Osmani (2026)** — Software engineering perspective | Bridges cognitive surrender to daily developer practice; proposes concrete heuristics for staying on the offloading side of the line (construct expectations before reading output, read diffs as if a junior wrote them, ask the model to argue against itself). Connects surrender to comprehension debt, cognitive debt, and anti-rationalization tables. | CONFIRMED — draws on academic sources (Shaw & Nave, MIT, Anthropic) with direct engineering application. Author of agent-skills integrated into this workspace. |
| **Williams (2026)** — Practitioner summary | Applied implications for workplace training, workflow design, accountability | PLAUSIBLE (derivative, but cites primary sources) |
| **Lee et al. (2025)** — Microsoft Research | Higher confidence in AI → less critical thinking; higher self-confidence → more scrutiny | CONFIRMED (CHI conference proceedings, 319 knowledge workers) |

---

## 5. Major Debates and Open Questions

### 5.1 Does Cognitive Surrender Generalize to Moral Decisions?

**Dimant (2026)** provides the sharpest boundary condition yet: **No.** Cognitive surrender on factual reasoning tasks does not extend to symmetric moral surrender. AI prosocial advice shifts behavior upward; antisocial advice does not push it downward. The domain boundary:

- **Cognitive tasks:** Symmetric surrender (follow AI whether correct or incorrect)
- **Moral tasks:** Directional influence only (prosocial advice works; antisocial does not)

The mechanism: AI can **confirm** private moral preference (norm activation) but cannot **override** it (lacks community standing for norm replacement).

*Confidence: CONFIRMED — Dimant's N=509 preregistered experiment with incentive-compatible stakes.*

### 5.2 What Makes Someone Susceptible?

The evidence converges on a profile:

| Susceptible | Resistant |
|-------------|-----------|
| High trust in AI | High Need for Cognition |
| Lower fluid intelligence | Higher fluid intelligence |
| Lower need for cognition | High self-confidence in own ability |
| High cue-sensitivity (CSS-8) | Habit of critical thinking (domain-general) |

The Microsoft Research finding is particularly important: **domain-general critical thinking habits protect** — it's not skepticism of AI specifically, but the disposition to think critically about any source.

*Confidence: CONFIRMED — replicated across Shaw & Nave (3 studies), Lee et al. (2025), and Dimant (2026).*

### 5.3 Is Cognitive Surrender Maladaptive?

**Not necessarily.** The literature is careful:

- When AI is consistently accurate, surrender is **optimal** — it saves cognitive effort and improves outcomes
- When AI is faulty, surrender produces **predictable harm** — accuracy falls below no-AI baseline
- The danger is **opacity**: users cannot easily know when the AI is reliable vs. faulty
- The triage problem: domain matters; for trivial decisions, surrender is fine; for high-stakes decisions, it is catastrophic

### 5.4 Can We Train Against It?

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

### 5.5 The Surrender Loop Hypothesis

Canale (2026) identifies a potentially profound recursive effect: humans produce text → AI absorbs psychological patterns → alignment selects some patterns → humans adopt AI output → humans produce AI-influenced text → that text becomes future training data. Each iteration selects for statistically dominant patterns and attenuates marginal ones, potentially creating **cognitive monoculture** — a WEIRD psychological profile projected as universal.

This hypothesis is **plausible but unvalidated** at the loop level. Individual components are well-supported:
- Cognitive surrender: ✅ (Shaw & Nave)
- Anthropomorphic vulnerability inheritance: ✅ (Canale & Thimmaraju)
- Typicality bias / distribution degeneration: ✅ (Zhang et al., Kirk et al.)
- WEIRD sampling bias: ✅ (Henrich, Heine & Norenzayan)

The complete end-to-end loop has not been tested longitudinally.

### 5.6 Scholarly Debate: Is Cognitive Surrender a New Phenomenon?

**Critique — Potkalitsky (2026)**:
A significant critique argues that cognitive surrender is **not a novel discovery** but a relabeling of established phenomena:

- **Anchoring** — the tendency to rely on the first piece of information encountered
- **Automation bias** — uncritical trust in automated system outputs (Parasuraman & Manzey, 2010)
- **Authority compliance** — deferring to authoritative-seeming sources (Milgram tradition)
- **Advice-taking under uncertainty** — the judge-advisor system literature

The critique is important and partially correct. What Shaw & Nave contribute is not the discovery of a new bias but:
1. **Integration** — unifying multiple known effects under a single theoretical framework (Tri-System Theory) with a new mechanism: System 3 as an external cognitive system that bypasses System 1/2
2. **Measurement** — providing an experimental paradigm that isolates the effect cleanly (OR = 16.07, h = 0.81)
3. **Naming** — giving practitioners a tractable concept ("surrender") that aids recognition

The debate's value: the critique correctly identifies that **intervention research lags behind labeling**. The field has a name for the problem; it does not yet have tested, scalable solutions outside controlled lab conditions. This directly motivates the practical integration work in this workspace.

*Confidence: DEBATE NOTED — both positions have merit; the critique identifies a genuine gap in intervention research while understating the value of Tri-System Theory as an integrative framework.*

---

## 6. Key Sources (Ranked by Authority)

### Primary / Original Research
1. **Shaw & Nave (2026)** — SSRN 6097646. Tri-System Theory and the first empirical demonstration. [PLAUSIBLE → HIGH: preregistered, large N, not yet peer-reviewed]
2. **Dimant (2026)** — SSRN 6622458. Domain boundary: cognitive vs. moral surrender. [CONFIRMED: preregistered, incentive-compatible]
3. **Lee et al. (2025)** — CHI 2025. Microsoft Research study of 319 knowledge workers. [CONFIRMED: peer-reviewed conference proceedings]
4. **Kos'myna et al. (2025)** — MIT Media Lab. "Your Brain on ChatGPT." EEG study (N=54, 4 sessions over 4 months): LLM use produces weakest neural connectivity; prior LLM use causes persistent under-engagement when AI is removed. Introduces "cognitive debt." [HIGH: peer-reviewed neuroscience methods, pre-registered, multi-session longitudinal design]
5. **Van Valkenburg (2026)** — SSRN 6536378. Process integrity framework. [PLAUSIBLE: philosophically grounded working paper]
6. **Canale (2026)** — SSRN 6228558. The Surrender Loop. [PLAUSIBLE: theoretical, well-sourced components, unvalidated at loop level]
7. **Vagle (2026)** — Stanford Law Review (forthcoming). Policing and agnotology. [HIGH: peer-reviewed law review]
8. **Storey (2026)** — arXiv 2603.22106. Triple Debt Model. [CONFIRMED: arXiv preprint, cited by 4]
9. **Vicente & Matute (2023)** — *Scientific Reports*. AI bias persistence after removal. [ESTABLISHED: peer-reviewed]
10. **Parasuraman & Manzey (2010)** — *Human Factors*. Foundational automation bias review. [ESTABLISHED: peer-reviewed, 870+ citations]

### Software Engineering / Practitioner
11. **Osmani (2026)** — Blog post. Engineer's guide to cognitive surrender; connects to comprehension debt, cognitive debt, anti-rationalization tables, agent harness engineering. [CONFIRMED: engineer at Google, author of agent-skills, primary sources cited]
12. **Storey (2026)** — arXiv 2603.22106. Triple Debt Model (technical, cognitive, intent debt). [CONFIRMED: arXiv preprint]

### Intervention Research
13. **Cognitive Agency Surrender (2026)** — arXiv 2603.21735. Scaffolded Cognitive Friction (SCF): proposes MAS-based "devil's advocate" agents as cognitive forcing functions to interrupt surrender. [SPECULATIVE: theoretical proposal; neurophysiological evaluation framework not yet validated]

### Theoretical / Contextual
14. **Chiriatti et al. (2024)** — *Nature Human Behaviour*. System 0. [ESTABLISHED: peer-reviewed, 51+ citations]
15. **Bainbridge (1983)** — *Automatica*. Ironies of automation. [ESTABLISHED: foundational, 4000+ citations]
16. **Clark & Chalmers (1998)** — *Analysis*. Extended mind. [ESTABLISHED: foundational]

### Critique / Debate
17. **Potkalitsky (2026)** — Substack. Argues cognitive surrender relabels known phenomena (anchoring, automation bias); calls for intervention research over neologisms. [PLAUSIBLE: identifies genuine gap in intervention research]

---

## 7. Gaps and Limitations

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

---

## 8. Practical Implications

### For Individuals
- Monitor your own "surrender rate" — how often do you check AI output before adopting it?
- Domain-general critical thinking habits protect against surrender, regardless of AI skepticism level
- Deliberately expose yourself to AI failures to calibrate trust

### For Software Engineers (Osmani, 2026)
- **Construct an expectation before reading output:** Write down (even mentally) what you think the answer should look like before running the agent. When AI matches expectation → calibrated. When it doesn't → you have a genuine decision to make.
- **Read diffs as if a junior wrote them:** "Seems right" is not a review, regardless of whether the author is human or AI.
- **Ask the model to argue against itself:** Most models produce a confident answer and an equally confident counter-argument. If you can't reason about which is right, you found a surrender point.
- **Notice when you're tired:** Surrender is a fatigue phenomenon. Stop letting the agent generate when you're too tired to evaluate.
- **Watch where the confidence is coming from:** If you're defending a design choice and can't reconstruct the *why* — only that the agent suggested it — that's a surrender artifact.
- **Verification as a hard exit criterion:** Every agent-completed task should terminate in concrete evidence (test, screenshot, log, trace), not "looks done."
- **Smaller scope, smaller PRs:** Surrender scales with size. ~100-line PRs are actually reviewable.
- **Conceptual inquiry over generation when learning:** Ask AI to *explain* before asking it to *generate*. The same tool, used interrogatively rather than productively, builds rather than erodes mental models (confirmed by Anthropic's skill-formation study).
- **Solo time at the keyboard:** Write some code without AI every week as a calibration exercise. The day you can't comfortably build something simple without AI assistance is the day offloading became surrender.
- **Anti-rationalization tables:** Pre-write rebuttals to the excuses the model (or your tired self) will produce for skipping rigorous steps. Models are exceptional at generating plausible reasons to skip verification.

### For Organizations
- Training alone is ineffective — direct exposure to AI failures works better
- Process accountability (requiring justification of reasoning) is more effective than outcome accountability
- Time pressure amplifies surrender; build slack into AI-assisted workflows
- Real-time feedback after errors reduces surrender in subsequent decisions
- **Throughput is a misleading metric:** PRs merged and features shipped do not distinguish between "I built this and understand it" and "the agent built this and I approved it." Both look identical on the dashboard.
- **Friction by design:** Scaffolded Cognitive Friction (deliberate moments of resistance — required design docs, confirmation steps, checklists) is what stands between offloading and surrender.

### For Designers
- AI systems that always sound confident are dangerous — uncertainty indicators may help
- Confidence scores and transparent explanations can encourage calibrated engagement
- Adaptive interfaces that adjust cognitive demands based on context

### For Policymakers
- Current governance frameworks (EU AI Act, NIST AI RMF) focus on output quality and post-hoc accountability, not the conditions of delegation
- Process integrity (compelling pre-delegation deliberation) may be the missing variable
- Cognitive surrender has direct implications for liability regimes — who is responsible when AI-assisted decisions cause harm?

---

## 9. Confidence Summary

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

---

## 10. Sources Cited

1. Bainbridge, L. (1983). Ironies of automation. *Automatica*, 19(6), 775–779.
2. Canale, G. (2026). The Surrender Loop: Archetypal Selection and Cognitive Convergence in Recursive Human-AI Interaction. SSRN 6228558.
3. Chiriatti, M., et al. (2024). The case for human-AI interaction as system 0 thinking. *Nature Human Behaviour*, 8, 1829–1830.
4. Clark, A., & Chalmers, D. (1998). The extended mind. *Analysis*, 58(1), 7–19.
5. Cognitive Agency Surrender (2026). Defending Epistemic Sovereignty via Scaffolded AI Friction. arXiv:2603.21735.
6. Dimant, E. (2026). On the Limits of Moral Surrender to AI. SSRN 6622458.
7. Kim, T. W., Usman, U., & Garvey, A. (2026). From algorithm aversion to AI dependence. *Consumer Psychology*.
8. Kos'myna, N., et al. (2025). Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task. MIT Media Lab. arXiv:2506.08872.
9. Lee, H-P., et al. (2025). The impact of generative AI on critical thinking. *CHI 2025*.
10. Mosier, K. L., & Skitka, L. J. (1996). Human decision makers and automated decision aids. In *Automation and human performance*.
11. Parasuraman, R., & Manzey, D. H. (2010). Complacency and bias in human use of automation. *Human Factors*, 52(3), 381–410.
12. Osmani, A. (2026). Cognitive Surrender. *addyosmani.com/blog*. https://addyosmani.com/blog/cognitive-surrender/
13. Potkalitsky, N. (2026). We Don't Need Another Neologism. We Need Interventions. *Substack*.
14. Shaw, S. D., & Nave, G. (2026). Thinking—Fast, Slow, and Artificial: How AI is Reshaping Human Reasoning and the Rise of Cognitive Surrender. SSRN 6097646.
15. Storey, M-A. (2026). From Technical Debt to Cognitive and Intent Debt. arXiv:2603.22106.
16. Vagle, J. L. (2026). AI Agnotology, Cognitive Surrender, and Policing Accountability. *Stanford Law Review Online* (forthcoming).
17. Van Valkenburg, Z. (2026). Cognitive Surrender v. Constitutive Delegation. SSRN 6536378.
18. Vicente, L., & Matute, H. (2023). Humans inherit artificial intelligence biases. *Scientific Reports*, 13, 15737.
19. Wegner, D. M. (1987). Transactive memory. In *Theories of Group Behavior*.
20. Williams, M. (2026). Cognitive surrender — how AI is reshaping professional judgement at work. *Employee Feedback* blog.
21. Castiello, M. (2026). From Dual-Process Models to the Quadripartite Theory. SSRN 6385700.
