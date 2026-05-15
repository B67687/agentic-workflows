# Agent Research Methodology

A systematic methodology for researching **any** topic, technology, pattern, architecture, or
approach. Not specific to any domain --- this is a general-purpose research engine for agents.

Applied **automatically by default** to any research-adjacent task. See `AGENTS.md` Operating
Contract "Default research conduct."

---

## Core Principles (Always Apply)

### Source Triangulation

```
Single source                -> MEDIUM confidence (verify before integrating)
+ 1 official source          -> HIGH confidence
+ 2+ independent sources     -> VERY HIGH confidence
+ Contradicted by sources    -> DISCARD or FLAG with contradiction note
```

### Authority Weighting

| Source Type | Weight | Examples |
|-------------|--------|----------|
| Official / canonical | HIGH | Spec, RFC, official docs, standard body, original paper |
| Primary aggregator | MEDIUM-HIGH | Benchmark aggregators, curated lists, package registries |
| Industry analysis | MEDIUM | Engineering blogs, conference talks, vendor docs |
| Third-party | LOW-MEDIUM | Tutorials, community guides, Stack Overflow |
| Social / anecdotal | LOW | Social media, forums, chat logs, rumors |

### Confidence Levels

| Level | Label | Meaning |
|-------|-------|---------|
| 1 | **SPECULATIVE** | Single source, anecdotal, or low-authority |
| 2 | **PLAUSIBLE** | Single authoritative source, no contradiction |
| 3 | **CONFIRMED** | 2+ independent sources agree |
| 4 | **ESTABLISHED** | Repeatedly confirmed over time, industry standard |

### Uncertainty Encoding

When a claim cannot be fully verified, encode it directly:

```
- [Pattern X]: [PLAUSIBLE --- single source, needs official docs]
- [Tool Y]: [CONFIRMED --- docs + independent verification]
- [Architecture Z]: [SPECULATIVE --- vendor claim only]
```

### Error Impact Audit

Before integrating any claim:

| Question | If YES -> |
|----------|----------|
| If wrong, does it affect safety/security? | Flag as NEEDS_VERIFICATION |
| If wrong, does it affect cost or performance? | Flag as NEEDS_VERIFICATION |
| If wrong, does it affect legal/license? | Flag as NEEDS_VERIFICATION |
| If wrong, does it invalidate other knowledge? | Decompose into smaller claims |
| Can it be independently verified in <5 min? | Verify before integrating |

---

## The Research Phases

Research follows a **funnel** just like debugging --- start wide, then narrow. Every phase
produces a clear output before advancing.

```
┌─────────────────────────────────────────────────────────┐
│ Phase 0: Frame the Question                             │
│ Output: Sharpened scope + "done" criteria               │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ Phase 1: Discover Local Knowledge                       │
│ Output: Everything already known + gaps                 │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ Phase 2: Gather External Sources                        │
│ Output: Raw claims with source URLs + dates             │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ Phase 3: Triangulate & Synthesize                       │
│ Output: Coherent model with confidence per claim        │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ Phase 4: Apply to the Problem                           │
│ Output: What changes, what must be true, next steps     │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ Phase 5: Preserve                                       │
│ Output: Memory saved, docs updated, learnings logged   │
└─────────────────────────────────────────────────────────┘
```

---

### Phase 0: Frame the Question

Do not start gathering information until the question is sharp. A vague question produces
vague findings.

**Steps:**

1. **State the topic** in one sentence
2. **Apply 5W+H** --- use the `structured-questioning` skill
   - **Who** is involved / who knows about this?
   - **What** exactly do I need to know? What kind of knowledge is this? (pattern, fact,
     comparison, tutorial, reference)
   - **When** was this last relevant / updated? (recency matters)
   - **Where** would the answer live? (official docs, source code, papers, forums)
   - **Why** do I need this? What decision depends on it?
   - **How** will I use the answer? (inform design, validate approach, compare options)
3. **Define "done"** --- what does successful research look like?
   ```
   Done when: I can confidently [decide X / implement Y / recommend Z]
   ```
4. **Scope the funnel** --- how deep is needed?
   - *Shallow*: Confirm a known fact, check a date, find a URL
   - *Medium*: Understand a concept, compare 2-3 options, learn a pattern
   - *Deep*: Master a domain, design an architecture, evaluate tradeoffs
5. **Check what you already know** --- write down current assumptions. This makes bias
   explicit and helps later triangulation.

**Output:** Sharpened research question + scope + "done" criteria + known assumptions.

### Phase 1: Discover Local Knowledge

Before fetching external sources, search what is already known in this workspace.
This is faster and avoids re-researching what we already found.

**Search in this order:**

1. **Agentmemory** --- `memory_smart_search` for related past sessions
   ```
   memory_smart_search(query="<research topic>", limit=5)
   ```
2. **BM25 index** --- `bash ./scripts/search-index.sh "<query>"`
   Ranked search across all text files in the workspace.
3. **Relevant docs** --- Check `docs/`, `research/`, `skills/`, `references/`,
   `rules/` for existing knowledge on the topic.
4. **Buglog** --- `buglog.json` for past issues related to the topic.
5. **Learnings** --- `bash ./scripts/learnings-search.sh "<query>"` for past learnings.

**Triangulate local sources** the same way as external ones. A finding from
agentmemory + a doc = CONFIRMED (locally). A finding from one doc only = PLAUSIBLE.

**Output:** Summary of what's already known, with local confidence levels + explicit gaps.

### Phase 2: Gather External Sources

Only once local knowledge is exhausted, fetch external sources.

**Source priority (fetch in this order):**

1. **Official documentation** --- specs, RFCs, READMEs, official guides
2. **Original research** --- papers, whitepapers, technical reports
3. **Authoritative references** --- language specs, API docs, standards bodies
4. **Industry analysis** --- engineering blogs, conference talks, vendor docs
5. **Independent verification** --- benchmarks, comparisons, reviews
6. **Community knowledge** --- guides, tutorials, forums (lowest priority)

**Techniques:**

- `webfetch` to get page content as markdown
- Multiple independent sources on the same topic
- For code: fetch actual source, not just docs
- For architecture: fetch multiple implementations / case studies

**Capture raw data:**

```
Source: <URL>
Date: <date fetched>
Authority: HIGH / MEDIUM / LOW
Key claims (bullet points, one per claim):
```

**Do not filter yet.** Gather first, synthesize later. Premature filtering misses
connections between sources.

**Output:** Raw claim collection with source URLs, dates, and authority ratings.

### Phase 3: Triangulate & Synthesize

Now process the raw claims into a coherent model.

**Steps:**

1. **Cross-reference** --- For each claim, check how many sources support it
   - 3+ independent sources -> CONFIRMED or ESTABLISHED
   - 2 sources with high authority -> CONFIRMED
   - 1 high-authority source -> PLAUSIBLE
   - 0-1 low-authority sources -> SPECULATIVE

2. **Identify conflicts** --- Where do sources disagree?
   - If authoritative sources conflict, note the disagreement explicitly
   - If a low-authority source conflicts with high-authority, discard the low
   - If multiple high-authority sources conflict, research deeper

3. **Identify gaps** --- What is still unknown? Be explicit:
   ```
   Gaps:
   - No source addresses [specific concern]
   - Recent developments after <date> not captured
   - Only vendor documentation available (no independent verification)
   ```

4. **Form the model** --- What is the coherent picture across all claims?
   - Describe the topic, concept, or architecture in your own words
   - Include key properties, constraints, relationships
   - Note which parts are well-understood vs uncertain

**Output:** Coherent research model with confidence per claim, explicit gaps,
and conflict notes.

### Phase 4: Apply to the Problem

Map the research findings to the specific problem or decision at hand.

**Answer these questions:**

- How does this change my understanding of the current system?
- What would need to be true for this knowledge to be actionable?
- What is the specific recommendation based on this research?
- What are the tradeoffs I now understand?
- What should I do differently?

**If the research was architecture-focused** (see Architecture Analysis below):
- Map findings to current architecture components
- Identify mismatches between current and best practice
- Rank changes by impact and effort

**Decision gate:** Is the research sufficient for the "done" criteria from Phase 0?
- YES -> proceed to Phase 5, then implement
- NO -> loop back to Phase 2 with a narrower question

**Output:** Specific implications, recommended actions, and what must be true.

### Phase 5: Preserve & Cite

Durable knowledge should outlive this session.

- **Cite every source** --- Every claim, pattern, and integration point must cite its source
  at minimum as `[Title](URL)`. Follow the full workflow in `workflow/source-citation.md`.
  This is not optional. Uncited claims degrade to SPECULATIVE.
- **Save to memory**: `memory_save(type="research", concepts="<tags>", files="<paths>")`
  for findings that:
  - Contradict or update existing knowledge
  - Are durable patterns (won't be stale in a week)
  - Modify or expand the workspace's understanding
- **Update docs**: If the finding belongs in an existing doc, add it. If it's a new
  paradigm, create or recommend a new doc.
- **Log learning**: `bash ./scripts/learnings-save.sh "insight" tags` for things that
  would be useful to remember in future sessions.
- **Link to sources**: Ensure every claim in the final output has its source and date noted.

**Do NOT save**: Task progress, temporary state, session outcomes, or things that will
be stale in a week.

**Output**: Memory entries, doc updates, learnings logged, and every claim sourced.

---

## Architecture Analysis Specialization

When researching an **architecture, design, or system** (not just a fact or tool), apply
this specialization on top of the general methodology.

### Architecture Research Questions (Phase 0 --- Frame)

Instead of generic 5W+H, ask:

| Dimension | Questions |
|-----------|-----------|
| **Structure** | What are the components? How do they connect? What data flows between them? |
| **Properties** | What are the non-functional requirements? (perf, scale, reliability, security) |
| **Decisions** | What design decisions were made? Why were they chosen? What was rejected? |
| **Context** | What domain is this in? What are the constraints? (team, budget, timeline, regulations) |
| **Evolution** | How did the architecture get here? What changes are planned? |
| **Best practice** | What would an ideal version of this look like? What patterns apply here? |

### Architecture Analysis (Phase 3 --- Synthesize)

After gathering sources about the current architecture and best practices:

1. **Current-State Mapping**: Document the actual architecture (components, interfaces,
   data flow, deployment) --- this is the "as-is" model. Use the macro-to-micro funnel
   from `skills/debugging-and-error-recovery/SKILL.md` to drill through levels.

2. **Best-Practice Research**: Gather authoritative sources on what "good" looks like
   for this kind of system --- reference architectures, documented patterns, case studies
   of similar systems.

3. **Gap Analysis**: Compare current state to best practice:
   ```
   | Concern | Current | Best Practice | Gap | Impact | Effort |
   |---------|---------|--------------|-----|--------|--------|
   | [security] | [what we do] | [what's recommended] | [delta] | [high/med/low] | [estimate] |
   ```

4. **Tradeoff Evaluation**: For each gap, evaluate:
   - Is the gap real? (some gaps exist for valid reasons)
   - What's the cost of fixing? (time, complexity, risk)
   - What's the cost of not fixing? (tech debt, future friction)
   - Is there a middle ground?

5. **Transformation Plan**: Phased plan to go from current to target:
   - What changes first? (foundations before features)
   - What's the smallest meaningful step?
   - What can stay as-is? (scope discipline)

### Architecture Output

```
## Architecture Research: [Title]

### Current State
[Architecture map, key components, data flow]

### Best Practices Considered
- [Pattern A] --- source, confidence
- [Pattern B] --- source, confidence

### Gap Analysis
| Concern | Current | Best Practice | Gap | Impact |
|---------|---------|--------------|-----|--------|

### Recommended Changes
1. [Change] --- [rationale, confidence, effort]

### What Must Be True
[Preconditions for this to be a good approach]

### Risks & Tradeoffs
[What could go wrong, what we're accepting]
```

---

## Output Format (General)

```
## YYYY-MM-DD

### Topic: [clear description]

### Research Question (Phase 0)
Sharpened scope + "done" criteria.

### Local Knowledge (Phase 1)
What was already known, with confidence levels.

### Key Findings (Phase 2-3)
Each finding with:
- Confidence level and reason
- Source(s) with authority rating
- Date of source

### Application (Phase 4)
What changes, what decisions hinge on this, what must be true.

### Gaps & Uncertainty
What is still unknown, what would change the recommendation.

### Preserved (Phase 5)
Memory saved, docs updated, learnings logged.
```

---

## Scope Control (When to Stop)

One of the hardest parts of research --- for agents and humans --- is knowing when to stop.

| Signal | Action |
|--------|--------|
| "Done" criteria from Phase 0 are met | Stop and output |
| 3+ independent sources agree on key claims | High confidence --- move to apply |
| No new information after 2-3 searches per Phase 2 | The well is dry --- synthesize what you have |
| The last 2 sources only confirm what earlier sources said | Saturation --- stop gathering |
| Confidence on key claims is Level 2+ and answers the question | Sufficient --- stop |
| Key claims are still Level 1 after reasonable effort | Output SPECULATIVE --- flag for human review |
| You've spent more time researching than you expect to spend implementing | **Stop and apply** --- perfect knowledge is rarely needed |
| The research question keeps shifting (scope creep) | Go back to Phase 0 and sharpen |

**The 80/20 rule:** 80% of the value comes from the first 20% of research effort.
After you have a coherent model and Level 2+ confidence on key claims, apply what
you know and learn from doing.

---

## Integration Rules

- Only integrate claims at Confidence Level 2+ into decision-making
- Level 1 claims get flagged as "pending verification" and not used for design decisions
- If a decision depends on a Level 1 claim, escalate to human review
- Time-stamp all claims: `[YYYY-MM-DD]`
- Link to specific sources, not just "research says"

---

## Anti-Patterns

| Anti-pattern | Why it fails |
|---|---|
| **Single-source dependency** | One blog post ≠ industry consensus |
| **Latest = best** | New releases have unknown stability and edge cases |
| **Correlation = causation** | Trending things aren't necessarily better |
| **Filling gaps with guesses** | Don't invent claims to complete the model |
| **Researching forever** | Perfect knowledge is the enemy of good implementation |
| **Ignoring local knowledge** | Re-researching what's already known wastes time |
| **No confidence labels** | Unlabeled claims are silently treated as CONFIRMED |
| **Web-only research** | For code topics, source code is the ultimate authority |
