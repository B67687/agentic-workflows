# Authoritative Research Methodology for AI Agents

Use this when researching to ensure sources are authoritative, not random.

## The Core Problem

AI agents can surface sources that look plausible but aren't genuinely authoritative. This happens because:
- Search rankings don't equal credibility
- A source can be popular without being accurate
- Individual opinions masquerade as expert consensus
- Official documentation is often buried under secondary sources

## Source Hierarchy (Most to Least Authoritative)

### Tier 1: Primary Official Sources
- **Vendor official docs**: OpenAI API docs, Anthropic docs, Google AI docs, model card pages
- **Academic papers**: Peer-reviewed, particularly from arXiv/cs.AI/cs.CL
- **Official benchmarks**: SWE-bench, LiveCodeBench, HumanEval on official sites
- **Specification documents**: RFCs, standard body publications

Why trusted: These are the authoritative record. Everything else interprets them.

### Tier 2: Recognized Expert Practitioners
- **Core maintainers of major repos**: Open source authors with proven track records
- **Named expert blogs**: Simon Willison, Andrej Karpathy, etc. with clear domain expertise
- **Official tool documentation**: GitHub, GitLab, Docker docs
- **Industry standards bodies**: OWASP, W3C, IETF

Why trusted: Domain expertise, track record, accountability.

### Tier 3: High-Reputation Secondary Sources
- **GitHub repos with strong evidence**: High stars, active maintenance, many contributors
- **Established newsletters**: LLM engineering newsletters with known authors
- **Technical blogs**: Company engineering blogs (Vercel, Stripe, etc.)

Why trusted: Useful but one level removed from primary record. Verify key claims against Tier 1.

### Tier 4: Community Aggregated Knowledge
- **Reddit/HN discussions**: Can surface useful info but treat as leads, not facts
- **Medium posts**: Variable quality, even popular ones
- **Generic tutorials**: Often outdated or oversimplified

Why not fully trusted: No accountability, often secondhand, may propagate errors.

### Tier 5: Anonymous or Low-Credibility
- **Unverified blog posts**: No named author, no verifiable expertise
- **Spammy comparison sites**: Created for SEO, not accuracy
- **Individual tweets/X posts**: Can be useful lead but verify before trusting

## Source Evaluation Checklist

Before trusting any source, verify:

```
Source Credibility Check:
1. Who is the author/maintainer? (Named expert or anonymous?)
2. Is this their primary domain? (Generalist post vs. specialist domain)
3. When was this written? (Currency check - AI moves fast)
4. Is there a primary source I can cross-check?
5. Do other authoritative sources cite this?
6. Does the source have a known agenda or bias?
```

## Topic-Specific Source Guidance

### Model Benchmarks
- Start with: Official model card benchmarks, SWE-bench official site
- Cross-check: arXiv papers for methodology details
- Avoid: Blog posts citing "internal testing" without verification

### Agent Tool Best Practices
- Start with: Vendor official docs (OpenAI Codex best practices, Claude Code docs)
- Cross-check: Named expert practitioners (Simon Willison, Andrej Karpathy)
- Avoid: Generic "AI productivity" blogs without technical depth

### Code/Technical Decisions
- Start with: Language/framework official docs, RFCs, core library source
- Cross-check: Major OSS project conventions (style guides, contributing docs)
- Avoid: StackOverflow answers without cross-reference to official docs

### Research on AI Behavior
- Start with: Academic papers from arXiv/cs.AI/cs.CL with citations
- Cross-check: Vendor research blog posts
- Avoid: Individual speculation presented as fact

## Triangulation Rule

For significant claims, require at minimum:
- **2 independent Tier 1 or 2 sources** agreeing, OR
- **1 Tier 1 source** with strong direct evidence

Single-source claims, even from Tier 1, should be flagged as needing verification when used for major decisions.

## Source Documentation Practice

When using a source, record:
1. **URL** (exact link)
2. **Author/Organization** (named or anonymous)
3. **Date** (written/published)
4. **Tier** (1-5 above)
5. **What it supports** (specific claim)
6. **Confidence** (high/medium/low and why)

This makes it easy to audit which claims are well-sourced vs. weakly sourced.

## Anti-Patterns to Avoid

| Anti-Pattern | Why It's Wrong |
|---|---|
| Trust highest-ranking search result | SEO gaming is rampant |
| Use "official" in quotes loosely | Only actual primary sources are truly official |
| Cite a blog post for a primary fact | Find the original source instead |
| Accept "internal testing" benchmarks | No verification possible |
| Use anonymous comparisons as authorities | No accountability for accuracy |
| Trust sources with obvious product bias | Check who funds them |
| Use outdated docs as current truth | AI tooling especially moves fast |

## Hierarchical Research Strategy (from CONTEXT.md)

When the user asks to "research X":
- Use **Medium analysis** for all cases
- Use **Deep analysis** only if "worth it" (significant decision, high cost of error)
- Apply **verification framework** (source triangulation, confidence levels)
- Integrate into target docs

## AI-Specific Source Pitfalls

- **Model names as relevance signals**: "Kimi K2.6" appearing in results doesn't mean Kimi K2.6 benchmarks are accurate
- **Promotional content as technical depth**: A sponsor's blog post can read as technical
- **Aggregated comparisons without methodology**: Many comparison sites don't explain how they tested
- **Old documentation on new features**: Official docs can be outdated after recent releases

Always check the date. In AI, 6 months can make a large difference.

## Source Quality Signal Quick Reference

| Signal | High Quality | Low Quality |
|--------|-------------|-------------|
| Author | Named expert, clear credentials | Anonymous or generic |
| Date | Recent (within 3 months for AI topics) | No date or clearly old |
| Citations | Links to primary sources | No citations or only other blogs |
| Domain | Official vendor, academic, core OSS | Generic blog host |
| Agenda | Discloses funding/conflicts | Hidden commercial interest |
| Depth | Explains methodology | Just claims without evidence |

## Integration With This Workspace

This workspace already has strong source discipline in:
- `docs/authoritative-agent-best-practices.md` — vendor official docs as the foundation
- `docs/codex-reasoning-guide.md` — explicitly distinguishes "officially confirmed" from "inferred"
- `AGENTS.md` — requires sources to be cited

Use this doc to reinforce that discipline and fill any gaps in research practice.

## Related Files

- `docs/authoritative-agent-best-practices.md` — vendor doc cross-reference
- `docs/codex-reasoning-guide.md` — source/inference distinction methodology
- `research/research-log.md` — campaign research logging with source tracking
- `docs/token-efficient-prompting.md` — cost-aware research efficiency