---
name: research-deep
description: Perform authoritative deep research with source triangulation and confidence levels. Use when the user asks to research, investigate, find out about, or look into any topic. Also use for "what does X do?", "how does Y work?", or "compare Z".
---

# Deep Research with Authoritative Sources

Follow this methodology for every research request. Do not skip steps.

## Step 1: Understand the Question

Before researching, clarify:
- What exactly is being asked? (narrow the scope)
- What would constitute a satisfactory answer?
- How deep should the research go? (hierarchical analysis)

## Step 2: Source Hierarchy (Strict Priority)

Search and evaluate sources in this order. Never use a lower tier when a higher tier is available.

### Tier 1: Primary Official Sources
- **Vendor official docs**: API docs, model cards, specification pages
- **Academic papers**: Peer-reviewed, particularly arXiv/cs.AI/cs.CL
- **Official benchmarks**: SWE-bench, LiveCodeBench, HumanEval on official sites
- **Specification documents**: RFCs, standard body publications

### Tier 2: Recognized Expert Practitioners
- **Core maintainers of major repos**: Proven track records
- **Named expert blogs**: Simon Willison, Andrej Karpathy, etc.
- **Official tool documentation**: GitHub, Docker, etc.
- **Industry standards bodies**: OWASP, W3C, IETF

### Tier 3: High-Reputation Secondary Sources
- **GitHub repos with strong evidence**: High stars, active maintenance
- **Established newsletters**: Known authors, technical depth
- **Company engineering blogs**: Vercel, Stripe, etc.

### Tier 4: Community Aggregated Knowledge
- **Reddit/HN discussions**: Treat as leads, not facts
- **Medium posts**: Variable quality, verify against Tier 1

## Step 3: Verification Framework

For every significant claim:
1. **Triangulate**: Find 2+ independent sources confirming the same fact
2. **Check provenance**: Who said this? What's their expertise?
3. **Check recency**: Is this information still current?
4. **Flag uncertainty**: If only one source exists, mark as tentative

## Step 4: Confidence Levels

Label every finding:
- **Confirmed**: Multiple Tier 1-2 sources agree
- **Likely**: Single Tier 1 source or multiple Tier 2-3
- **Speculative**: Tier 4 only, or conflicting sources
- **Disputed**: Sources actively contradict each other

## Step 5: Synthesis and Output

Structure the response:
1. **Executive Summary**: 3-5 bullet points of key findings
2. **Detailed Findings**: Organized by sub-topic, with source citations
3. **Confidence Summary**: What we know for sure vs. what's uncertain
4. **Recommendations**: What to do with this information

## Step 6: Integration

If the user wants findings saved:
- Identify the correct target doc (don't create duplicates)
- Generalize specific examples into reusable patterns
- Add cross-references to related docs
- Update `workflow/session-state.json` with what was researched

## Rules
- Never present unverified claims as facts
- Prefer primary sources over interpretations
- When sources conflict, present both sides with confidence levels
- Keep responses concise unless the user asks for depth
