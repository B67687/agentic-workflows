---
name: research-deep
description: Perform authoritative deep research with source triangulation and confidence levels. Use when the user asks to research, investigate, find out about, or look into any topic. Also use for "what does X do?", "how does Y work?", or "compare Z".
when_to_use: "User asks a question that requires external knowledge, verification, or exploration beyond the current workspace."
allowed-tools: webfetch Read
---

# Deep Research with Authoritative Sources

Research topic: `$ARGUMENTS`

Follow this methodology for every research request. Do not skip steps.

## Step 1: Understand the Question

Before researching, clarify:
- What exactly is being asked? (narrow the scope)
- What would constitute a satisfactory answer?
- How deep should the research go? (hierarchical analysis)

## Step 2: Source Hierarchy

Search and evaluate sources using the tier system in [references/source-hierarchy.md](references/source-hierarchy.md). Never use a lower tier when a higher tier is available.

## Step 3: Verification Framework

Apply the triangulation rules from [references/verification-framework.md](references/verification-framework.md):
1. Find 2+ independent sources for significant claims
2. Check provenance and recency
3. Flag uncertainty when only one source exists

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
