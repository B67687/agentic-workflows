---
description: Run the research phase only, with no file edits
---

This is research mode. The quality framework below also applies **automatically by default** to any research-adjacent task (exploring, investigating, comparing, learning, understanding a system) — even without calling `/research`. See AGENTS.md "Default Research Conduct."

## Quality Framework (Default — Always Apply)

Every research action applies the quality standards from `research/research-prompt.md`:

1. **Source Triangulation** — Single source = MEDIUM confidence, 1+ official = HIGH, 2+ independent = VERY HIGH, contradictory = DISCARD
2. **Authority Weighting** — Official docs > Primary benchmarks > Industry analysis > Third-party > Social/anecdotal
3. **Confidence Levels** — Every claim gets one: SPECULATIVE, PLAUSIBLE, CONFIRMED, or ESTABLISHED
4. **Uncertainty Encoding** — When a claim can't be fully verified, label it explicitly (PLAUSIBLE / NEEDS_VERIFICATION)
5. **Depth Tiers** — Level 1 (medium) for all findings, Level 2 (deep) only for significant/actionable findings
6. **Cite Sources** — Full URLs, deep links with anchors where possible, relevant quote for non-obvious decisions
7. **Error Impact Audit** — If a wrong claim would affect safety/cost/legal/license, flag as NEEDS_VERIFICATION

**Do not wait for `/research` or quality qualifiers like "authoritative" or "thorough" — those are redundant; this is already how research works here.**

## Before Starting

First, read the normal startup files for the repo.

Run the prompt contract:
`bash ./scripts/prompt-contract.sh "$ARGUMENTS" --phase research`

If the prompt contract output shows `Rigor: high`, the research depth expectation is already escalated — proceed accordingly.

## Two Research Paths

### Path A: Codebase Research (pre-implementation)

If researching code, dependencies, or architecture:

- Run `bash ./scripts/repo-map.sh .` for unfamiliar folders
- Run `bash ./scripts/retrieve-context.sh "$ARGUMENTS"` for local context

Return a compact research note covering:
- the exact files involved
- the relevant flow or dependencies
- the main risks or edge cases
- what needs to be true before planning

### Path B: Domain / Web Research

If researching a topic, technology, trend, or competitive landscape:

- Run `bash ./research/research-prompt.md` for the full research workflow
- Use `webfetch` to gather authoritative sources
- Apply source triangulation and confidence levels to every claim
- Use structured-questioning (`skill tool`) to sharpen the research question before starting

Return a structured research note covering:
- the research question (sharpened via 5W+H)
- key findings each with confidence level and source
- what is confirmed vs plausible vs speculative
- integration recommendation (target doc, or "pending verification")
- what would need to be true before planning or acting on these findings

## Common to Both Paths

Do not edit files yet.

<rationalizations>
| Shortcut | Why It Fails |
|---|---|
| "I know this repo already" | Repos change between sessions. Stale assumptions cause wrong file choices. |
| "I'll research as I implement" | Research mixed with edits creates confusion about what's fact vs guess. |
| "One quick grep is enough" | Surface-level search misses edge cases, hidden dependencies, and stale references. |
| "I can skip the repo map" | Unfamiliar folders need structural orientation before deep reading — otherwise you read the wrong files first. |
| "The confidence template is for special cases" | Every claim without a confidence level is silently treated as CONFIRMED, which is worse than SPECULATIVE. Default to labeling. |
| "I know what thorough research looks like" | Your training data averages toward shallow. The quality framework forces depth on every finding regardless of how the request is phrased. |
</rationalizations>

<red_flags>
- Starting to edit files before producing the research note
- Research note has no file paths or only guesses at dependencies
- Skipping repo-map on an unfamiliar folder
- "I already know this" without recent evidence
- Returning findings without confidence levels or source citations
- Using "I think" or "probably" instead of uncertainty encoding ("PLAUSIBLE — single source")
</red_flags>
