# Research Prompt

Run this to research what's new in any domain, then analyze and integrate into this workspace.

## Context

This workspace is an **AI Prompting Knowledge Base** covering:
- Prompt engineering excellence
- Agent workflow optimization
- Building products with AI agents
- Token efficiency
- Human-AI cognitive partnership

Research goal: Find, analyze, and integrate significant findings into the knowledge base.

## Available Models for Research

| Model | Provider | Best For |
|-------|----------|----------|
| **MiniMax M2.7 Free** | OpenCode Zen | Latest — unlimited tokens, $0 |
| **Claude Sonnet 4.6** | GitHub Copilot | Complex reasoning (200k tokens/day) |

**Note:** Use MiniMax M2.7 Free for high-volume research (unlimited). Escalate to Claude Sonnet for complex analysis.

## Research Phase

### 1. Passive Research (always run)
Search for:
- Trending GitHub repos in AI agents/engineering
- Token efficiency breakthroughs
- New agent frameworks and tools
- MCP ecosystem developments

### 2. Focused Research (user-provided URLs)
When user provides URLs, fetch and analyze deeply:
- Extract actionable patterns
- Compare to existing workspace knowledge
- Note integration points

### 3. Model Benchmark Updates
Monthly verification:
- SWE-bench leaderboard (openrouter.ai/rankings)
- BenchLM.ai for coding benchmarks
- Anthropic/OpenAI release blogs

## Verification Framework

**Before any claim enters the knowledge base, apply this framework.**

### Source Triangulation

```
Single source → MEDIUM confidence (verify before integrating)
+ 1 official source → HIGH confidence
+ 2+ independent sources → VERY HIGH confidence
+ Contradicted by other sources → DISCARD or FLAG
```

**Authority Weighting:**

| Source Type | Weight | Examples |
|-------------|--------|----------|
| Official source | HIGH | Hugging Face model card, official docs, GitHub repo README |
| Primary benchmark aggregator | MEDIUM-HIGH | BenchLM, OpenRouter rankings (for benchmarks) |
| Industry blog/analysis | MEDIUM | Anthropic blog, OpenAI blog, research papers |
| Third-party blog | LOW-MEDIUM | Engineering blogs, tutorials |
| Social media / anecdotal | LOW | Twitter/X claims, Reddit posts |

### Confidence Levels

Use this instead of binary "verified/unverified":

| Level | Label | Meaning |
|-------|-------|---------|
| 1 | **SPECULATIVE** | Single source, anecdotal, or low-authority |
| 2 | **PLAUSIBLE** | Single authoritative source, no contradiction |
| 3 | **CONFIRMED** | 2+ independent sources agree |
| 4 | **ESTABLISHED** | Repeatedly confirmed over time, industry standard |

### Claim Encoding

Format claims with inline confidence + source:

```
## YYYY-MM-DD

### Finding: [claim]

**Confidence**: [LEVEL] — [reason]
**Sources**:
- [Source 1] (authority: [high/medium/low])
- [Source 2] (authority: [high/medium/low])

**Status**: [CONFIRMED / PLAUSIBLE / NEEDS_VERIFICATION / CONTRADICTED]
```

### Uncertainty Encoding

When a claim cannot be fully verified, encode it directly:

```
- [Model X]: [PLAUSIBLE — official source claims, Hugging Face not yet verified]
- [Tool Y]: [SPECULATIVE — single blog source, needs official docs]
- [Pattern Z]: [CONFIRMED — 3 independent sources, industry standard]
```

### Error Impact Audit

Before marking integration complete, ask:

| Question | If YES → |
|----------|----------|
| If this claim is wrong, does it affect safety? | Flag as NEEDS_VERIFICATION |
| If this claim is wrong, does it affect cost? | Flag as NEEDS_VERIFICATION |
| If this claim is wrong, does it affect legal/license? | Flag as NEEDS_VERIFICATION |
| If this claim is wrong, does it break other knowledge? | Decompose into smaller claims |
| Can this be independently verified in <5 min? | Verify before integrating |

## Hierarchical Analysis

For each finding, decide depth:

### Level 1: Medium Analysis (Apply to ALL findings)
- **What is it**: 1 sentence description
- **Why it matters**: Compare to alternatives
- **Confidence**: What level and why?
- **Workspace connection**: Which doc it could improve

### Level 2: Deep Analysis (Only if "worth it")
- Threshold: Directly improves a documented method, or introduces new paradigm
- Confidence: Must be Level 3+ to proceed
- Compare to 2-3 similar tools/approaches
- Extract actionable pattern
- State integration recommendation

**"Worth digging deeper" criteria**:
- Revolutionary (new paradigm, self-improving)
- Directly applicable to this workspace
- Contradicts or significantly improves existing guidance
- Confidence Level 3+ (not just speculative)

## Integration Check

After research, before adding entry, classify each significant finding:

| Category | Target Doc | When to Add |
|----------|------------|-------------|
| Prompt Engineering | daily-prompts.md, prompt-templates.md | New prompt shapes |
| Agent Workflows | core-agent-doctrine.md | New patterns |
| Product Building | ai-product-building.md | New tools/methods |
| Token Efficiency | token-efficient-prompting.md | Compression/caching |
| Model Selection | model-selection-guide.md | New benchmarks, quotas |
| New Knowledge | core-agent-doctrine.md or new doc | Paradigm shifts |

**Integration gate**: Only integrate claims at Confidence Level 2+. Level 1 claims get archived as "pending verification."

## Output Format

```
## YYYY-MM-DD

### User Requests (if any)
- [URL/focus]: [what to extract] — [confidence level]

### Trending Repos
- [repo]: [stars] — [confidence: PLAUSIBLE/CONFIRMED]

### Analysis (Medium)
- [Synthesis: why this matters] — [confidence level]

### Integration Check
- [Target doc, if significant and confidence >= 2]
- [Level 1 claims: archive as pending verification]
```

## Constraints

- Include star counts when available
- Keep analysis to 2-3 sentences per finding
- Deep analysis only for significant finds (confidence >= 3)
- Verify claims with sources — never integrate Level 1 claims directly
- Cross-check model properties against official sources (Hugging Face, model card)
- Time-stamp all claims: `[YYYY-MM-DD]`
- When uncertain: flag as "NEEDS_VERIFICATION" rather than assume

## Manual Research (User-Provided URLs)

When user provides URLs:
1. Use webfetch to get content
2. Apply verification framework
3. Extract key patterns with confidence levels
4. Map to existing knowledge base
5. Note integration points with confidence

## Done when

- Entry added to research-log.md with analysis
- All claims have confidence levels and sources
- Integration recommendation noted (with confidence gate)
- Level 1 claims segregated as "pending verification"
- If 3-day cycle: Full integration pass

## Anti-Patterns to Avoid

- **Benchmark contamination**: A model scoring high on a benchmark ≠ it has that capability in production
- **Correlation = causation**: Trending repos ≠ actually better
- **Single-source fallacy**: One blog post ≠ industry consensus
- **Latest = best**: New models may have regressions
- **Filling gaps**: Don't invent claims to complete the research
