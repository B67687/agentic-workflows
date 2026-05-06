# Counsel Model Selection

This document defines how to choose models for counsel-style review.

Core rule:

> Counsel is role-based first, model-based second.

Do not hardcode a permanent panel. Model availability, free tiers, provider routing, and leaderboard positions change too quickly. Instead, choose the best currently available model for each role using a small evidence hierarchy.

## When Counsel Is Worth Using

Use counsel for:

- product shaping
- milestone choice
- architecture review
- optimization review
- expensive tradeoff decisions

Do not use counsel for ordinary implementation. Implementation should usually stay with one primary model and one verified slice.

## Evidence Hierarchy

Use sources in this order:

1. OpenRouter availability and free status
2. Independent broad capability benchmarks
3. Coding and agentic benchmarks for engineering roles
4. Speed, latency, context, and cost metrics
5. Local observed performance on this workspace

Current source meanings:

- OpenRouter free models: confirms which models are actually available at zero marginal cost through OpenRouter and gives useful category rankings and usage signals.
- Artificial Analysis: useful for broad intelligence, speed, latency, context window, and cost comparisons.
- LiveBench: useful because it is contamination-limited, frequently updated, and spans math, coding, reasoning, language, instruction following, and data analysis.
- SWE-rebench / SWE-bench style leaderboards: useful for coding and software-agent roles, but should not be the only source because harness quality and benchmark contamination matter.
- Scale-style private evals: useful when available because curated private datasets reduce benchmark gaming, but they may not cover all free models.
- Hugging Face leaderboards: useful for open-weight discovery and sanity checks, but not enough by themselves for agentic workflow selection.

## Role Set

### Facilitator

Purpose: keep the counsel structured, short, and decision-oriented.

Selection priorities:

- strong instruction following
- low latency
- low verbosity
- reliable structured output

### Product Framer

Purpose: extract the final user experience, fidelity anchors, and emotional target.

Selection priorities:

- strong language and instruction following
- good long-context synthesis
- good at simplifying complicated intent

### Systems Reviewer

Purpose: assess architecture, feasibility, implementation risks, and dependency boundaries.

Selection priorities:

- coding and software-engineering benchmark strength
- tool-use reliability
- long-context reasoning
- grounded risk assessment

### Red Team

Purpose: argue against the plan, expose hidden assumptions, and identify failure modes.

Selection priorities:

- different model family from the primary model
- strong reasoning
- willingness to challenge assumptions
- low tendency to simply agree with the prompt

### Secretary

Purpose: compress the independent views into one decision artifact.

Selection priorities:

- summarization quality
- structured output
- low verbosity
- faithful conflict compression

## Current Free-Model Candidate Pool

As of the May 2026 OpenRouter free-model page, useful candidates include:

- Tencent Hy3 preview
- NVIDIA Nemotron 3 Super
- inclusionAI Ling-2.6-1T
- Poolside Laguna M.1
- OpenAI gpt-oss-120b
- Z.ai GLM 4.5 Air
- MiniMax M2.5
- Google Gemma 4 variants

Treat this list as a snapshot, not a permanent truth.

## Default Counsel Groupings

### Lite Counsel

Use for milestone choice, architecture review, and high-cost framing decisions.

Roles:

- Facilitator
- Systems Reviewer or Product Framer
- Red Team
- Secretary

Model policy:

- choose one fast structured model for Facilitator or Secretary
- choose the strongest available role-specialist for Product Framer or Systems Reviewer
- choose a different-family model for Red Team

### Full Counsel

Use only for long-horizon product shaping or major architecture direction.

Roles:

- Facilitator
- Product Framer
- User Advocate
- Systems Reviewer
- Red Team
- Secretary

Model policy:

- maximize diversity across model families
- do not use more than one verbose reasoning model unless the decision is genuinely high stakes
- always compress the final output into one recommendation

## Selection Algorithm

1. Confirm which models are currently free and available through OpenRouter.
2. Exclude models with unreliable availability, missing context, or unacceptable logging/privacy behavior for the task.
3. Assign candidates by role, not by global rank.
4. Prefer model-family diversity for Red Team.
5. Prefer the strongest coding or agentic benchmark model for Systems Reviewer.
6. Prefer fast structured models for Facilitator and Secretary.
7. Run counsel only long enough to produce independent views.
8. Compress into one recommendation and continue the normal workflow.

## Anti-Patterns

- Do not use counsel because it feels impressive.
- Do not ask every model the same vague prompt and merge the noise.
- Do not let counsel replace user judgment.
- Do not use a model just because it is globally ranked high if its role fit is weak.
- Do not let a free model panel consume more time than the decision is worth.

## Output Contract

Every counsel run should end with:

- decision reviewed
- role views
- strongest support
- strongest objection
- missing facts
- compressed recommendation
- next workflow command

The output is successful only if the next command becomes clearer.
