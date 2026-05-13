---
description: Run the research phase — frame, discover, gather, synthesize, apply, preserve
---

This is research mode. The methodology below applies **automatically by default** to any
research-adjacent task — even without calling `/research`. See `AGENTS.md` "Default
Research Conduct" and `research/research-prompt.md` for the full methodology.

## The Agent Research Methodology (Default)

Research follows 6 phases. Each phase produces a clear output before advancing.

```
Phase 0: Frame the Question  →  Sharpened scope + "done" criteria
Phase 1: Discover Local      →  What's already known + gaps
Phase 2: Gather External     →  Raw claims with source URLs + dates
Phase 3: Triangulate         →  Coherent model with confidence per claim
Phase 4: Apply to Problem    →  What changes, what must be true
Phase 5: Preserve            →  Memory saved, docs updated, learnings logged
```

**Read the full methodology:** `research/research-prompt.md`

---

## Before Starting

1. Run the prompt contract:
   `bash ./scripts/prompt-contract.sh "$ARGUMENTS" --phase research`

2. If the topic is unfamiliar, run the repo map first:
   `bash ./scripts/repo-map.sh .`

3. Frame the research question using `skill` → `structured-questioning` (5W+H)

---

## Three Research Paths

### Path A: Architecture / System Research

For understanding, analyzing, or improving an architecture or system design:

1. Map the current system using the **macro-to-micro funnel**:
   - Level 1 (System): Components, connections, data flow — `repo-map`, `docs/`
   - Level 2 (Domain): Affected subsystem boundaries
   - Level 3 (Module): Key files and code paths
   - Level 4 (Root Cause / Analysis): Specific gaps or defects

2. Research best practices for this kind of system:
   - Reference architectures, documented patterns, case studies
   - Official docs and specs for relevant technologies
   - Industry standards and recommendations

3. Gap analysis: current → best practice with impact and effort

4. Transformation plan: phased, minimal viable step first

Return an architecture research note (see `research/research-prompt.md` for format).

### Path B: Code / Dependency Research

For understanding code, dependencies, or implementation details:

- Run `bash ./scripts/repo-map.sh .` for unfamiliar folders
- Run `bash ./scripts/search-index.sh "$ARGUMENTS"` for local context
- Use `grep` / `glob` for precise code location

Return a compact research note covering:
- the exact files involved
- the relevant flow or dependencies
- the main risks or edge cases
- what needs to be true before planning

### Path C: Domain / Web Research

For researching any topic, technology, trend, or approach:

- Apply the 6-phase methodology from `research/research-prompt.md`
- Use `webfetch` to gather authoritative sources
- Apply source triangulation and confidence levels to every claim
- Use `structured-questioning` to sharpen the research question before starting

Return a structured research note with:
- the research question (sharpened via 5W+H)
- key findings with confidence levels and sources
- what is confirmed vs plausible vs speculative
- integration recommendation
- what would need to be true before planning or acting

---

## Common to All Paths

- **Do not edit files yet.** Research is research, implementation is implementation.
- **Cite all sources** with URLs and authority ratings.
- **Flag all uncertainties** — unlabeled claims are silently treated as CONFIRMED.
- **Know when to stop** — see Scope Control in `research/research-prompt.md`.
- **Preserve durable findings** to memory and docs (Phase 5 of the methodology).

<rationalizations>
| Shortcut | Why It Fails |
|---|---|
| "I know this topic already" | Stale knowledge is worse than no knowledge. Verify current state. |
| "I'll research as I implement" | Research mixed with edits creates guesses that look like facts. |
| "One quick grep is enough" | Surface search misses edge cases, hidden deps, stale references. |
| "The architecture is obvious" | Obvious architectures hide implicit assumptions. Map it first. |
| "I don't need confidence levels" | Every unlabeled claim is treated as CONFIRMED, which is worse than SPECULATIVE. |
| "I know when to stop" | Agents naturally research too long or too little. Use the Scope Control table. |
</rationalizations>

<red_flags>
- Editing files before producing the research note
- Research note has no source URLs or confidence levels
- Skipping the question-framing phase (jumping straight to gathering)
- Skipping local knowledge discovery (re-researching what's already known)
- "I already know this" without recent evidence
- No explicit gaps or uncertainty section
- Claiming CONFIDENT without source citations
- Researching past the scope control signals
</red_flags>
