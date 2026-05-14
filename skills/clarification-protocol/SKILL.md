---
name: clarification-protocol
description: A systematic protocol for agents to detect when user intent is ambiguous, decide whether to ask or proceed, and manage the clarification interaction. Use when the agent needs to verify
  understanding before acting, when user requests are vague or underspecified, or when the cost of misunderstanding is high. This is the formal decision framework behind the Question Gate.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob
metadata:
  companion-script: scripts/clarify.sh
  handoffs: structured-questioning (question formulation), grill-me (deep decision trees), spec-driven-development (assumption surfacing)
  trigger-phrases: clarify intent, verify understanding, ask the user, question gate, ambiguity detection, clarification protocol
  pattern: thick
  bundle: define
---

# Clarification Protocol

> **Formal decision framework for agent-to-human clarification.**
> Built on 12 research sources: Modexa Question-First, AgentPatterns.ai interactive clarification,
> MUXI clarification system, CLAM/INTENT-SIM (Kuhn et al.), ECLAIR (Adobe, EACL 2026),
> MAC multi-agent clarification (IWSDS 2026), Claude Code AskUserQuestion, Spring AI,
> Fazm ask_followup, MCP Elicitation spec, Prism (ACL 2026), and OntoAgent.

A systematic protocol for detecting ambiguity, deciding whether to ask clarification or proceed, designing effective questions, and managing the multi-turn clarification flow. This is the engine behind the Question Gate in `docs/workflow.md`.

**Audience:** This skill is written for the agent itself. The agent follows these phases automatically when ambiguity is detected. You do not invoke this skill manually — the Question Gate triggers it.

**Companion script:** `scripts/clarify.sh` — ambiguity analysis, question generation, and gate decision automation.

## When the Protocol Activates

| Trigger | What happens |
|---------|-------------|
| User request is vague or underspecified | Agent auto-activates the protocol (Question Gate) |
| Agent confidence in interpretation < 0.7 | Protocol kicks in before tool calls |
| Action is irreversible (delete, deploy, overwrite) | Protocol requires confirmation even if confident |
| Multiple equally valid interpretations | Protocol forks with options |
| User asks "do you understand?" or similar | Agent runs the protocol's understandability check |

## The Six Phases

```
┌────────────┐   ┌──────────┐   ┌────────────┐
│ 1. DETECT  │──>│ 2. ASSESS│──>│ 3. EXPLORE │
│ ambiguity  │   │ risk &   │   │ what we can │
│ level      │   │ confidence│   │ find first  │
└────────────┘   └──────────┘   └──────┬─────┘
                                       │
                  ┌────────────────────┘
                  ▼
          ┌──────────────┐
          │ 4. DECIDE    │
          │ Act / Ask /  │
          │ Offer Options│
          └──────┬───────┘
                 │
         ┌───────┴───────┐
         ▼               ▼
  ┌────────────┐  ┌──────────────┐
  │ 5. ASK &   │  │ 6. LOOP     │
  │ INTEGRATE  │  │ bounded max │
  │            │  │ 2-3 rounds  │
  └────────────┘  └──────────────┘
```

---

### Phase 1 — Detect Ambiguity

Before anything else, classify the user request. Do not rely on intuition — use structured criteria.

#### Ambiguity Types

| Type | Description | Example | Resolution |
|------|-------------|---------|------------|
| **Referential** | "it", "that", "the file" — what exactly? | "Fix the bug in the API" (which API? which bug?) | Fork: name the candidates |
| **Entity** | Multiple entities match | "Update the user" (which user?) | Ask for specific identifier |
| **Temporal** | When? which time? | "Run the report for March" (which year?) | Clarify timeframe |
| **Scope** | How much? which parts? | "Clean up the codebase" (all files? just one module?) | Define boundaries |
| **Missing Input** | Required params absent | "Deploy to production" (which service? which version?) | Ask for missing key |
| **Conflicting** | Contradictory requirements | "Make it fast but also feature-rich" (tradeoff needed) | Surface the conflict |
| **Vague Action** | Non-specific verb | "Improve the dashboard" (performance? UX? data?) | Fork: name the dimension |
| **Preference** | Multiple valid approaches | "Pick a database" (Postgres? MySQL? SQLite?) | Offer options only if material |

#### Detection Heuristic

Quick pre-check before deeper analysis (runs in <50ms, no LLM call):

```bash
bash ./skills/clarification-protocol/scripts/clarify.sh analyze "your request"
```

Outputs: structured analysis of which ambiguity dimensions are present, which are clear, and a verdict.

#### Deeper LLM Analysis (when heuristic flags uncertainty)

```
Run the LLM analysis against these criteria:
1. Are there 2+ plausible interpretations? → REFERENTIAL / ENTITY
2. Are critical parameters missing? → MISSING INPUT
3. Could the action affect multiple targets? → SCOPE
4. Are there implicit tradeoffs? → CONFLICTING
5. Is the action vaguely described? → VAGUE ACTION
6. Is a meaningful choice between valid options? → PREFERENCE

If any of 1-4: proceed to Phase 2 (ASSESS)
If only 5-6: proceed to Phase 3 (EXPLORE) before asking
If none: proceed directly to execution
```

---

### Phase 2 — Assess Risk & Confidence

Not every ambiguity needs a question. The decision to ask depends on three factors:

#### Factor A: Confidence

| Confidence | What it means | Action |
|-----------|---------------|--------|
| > 0.85 | High confidence — one clear interpretation | Proceed without asking (for reversible actions) |
| 0.7 – 0.85 | Moderate confidence — likely correct but uncertain | Proceed with stated assumptions |
| 0.3 – 0.7 | Low confidence — multiple plausible interpretations | Ask or offer options |
| < 0.3 | Very low confidence — guess is unreliable | Always ask |

#### Factor B: Reversibility

| Action type | Examples | Protocol |
|-------------|----------|----------|
| **Reversible** | Read, search, display, format, suggest, draft | Can proceed with assumptions + implicit confirmation |
| **Costly but reversible** | Edit a file, commit, push to feature branch | Ask if confidence < 0.7 |
| **Irreversible** | Delete, merge to main, deploy to prod, send email | Always ask or confirm, even at high confidence |
| **High-cost** | Schema migration, billing change, API key rotation | Always confirm explicitly |

#### Factor C: Cost of Wrong Action

| Cost level | Examples | Threshold |
|-----------|----------|-----------|
| **Trivial** | Wrong search result, irrelevant suggestion | Proceed without asking regardless |
| **Medium** | Wrong file edited, wrong branch committed | Ask if confidence < 0.7 |
| **High** | Data loss, production outage, sent communication | Always ask, even at 0.95 confidence |
| **Critical** | Security exposure, financial error, legal | Always confirm with explicit approval |

#### Combined Decision Matrix

```
                  REVERSIBLE          IRREVERSIBLE
CONFIDENCE HIGH   → Act + state       → Confirm ("Doing X — ok?")
CONFIDENCE MED    → Act + state       → Ask (fork options)
CONFIDENCE LOW    → Ask (fork)        → Ask (explicit)
CONFIDENCE V.LOW  → Always ask        → Always ask
```

---

### Phase 3 — Explore First

**Critical rule: resolve what you can before asking the user.** The best agents explore the codebase, docs, and past conversations to resolve navigational gaps, then ask only about informational gaps (business rules, design intent, expected behavior). Research shows this recovers up to 74% of underspecified task performance.

#### Navigational Gaps (explore, don't ask)

| Gap | What to check | Resolution |
|-----|--------------|------------|
| "the file" — which file? | Grep for patterns, check recent commits | Find and name it |
| "the API" — which endpoint? | Read routes, check OpenAPI spec | Identify the endpoint |
| "the bug" — which bug? | Check recent git log, error logs, failing tests | Locate the issue |
| "the config" — which config? | List config files, check env vars | Point to the right one |
| "that function" — which function? | LSP or grep for function names | Disambiguate |

Flow for navigational gaps:

```
1. User says: "Fix the authentication bug in the API"
2. Agent explores: searches auth-related files, finds `auth/token_validator.py`
   has a regression where expired tokens bypass validation
3. Agent now knows: WHICH file, WHAT bug (expired tokens accepted)
4. Agent identifies: the FIX could be 401 response or silent refresh — business rule
5. Agent asks ONE question about the business rule only
```

#### Informational Gaps (ask the user)

| Gap | Examples | Must ask? |
|-----|----------|-----------|
| Business rules | "Should expired tokens return 401 or refresh silently?" | Yes — code can't answer this |
| Design intent | "Should this be a modal or an inline error?" | Yes — unless a pattern exists |
| Priority | "Should I optimize for speed or readability?" | Only if tradeoff is material |
| Expected behavior | "What should happen when the payment fails?" | Yes — unless documented |
| User preference | "Light mode or dark mode?" | Only if no existing UI pattern |
| Hard constraints | "Any performance target or deadline?" | Only if work would exceed defaults |

#### The One-Question Test

Before asking anything, ask yourself: **"Can I answer this by looking at code, docs, past conversations, or the environment?"**

- If yes → explore, don't ask
- If no → proceed to Phase 4

---

### Phase 4 — Decide: Act, Ask, or Offer Options

This is the core triage decision. Based on Phases 1-3, choose exactly one path.

```
                 ┌─────────────────────────────────────┐
                 │         THE TRIAGE DECISION          │
                 ├─────────────────────────────────────┤
                 │                                     │
    Confidence    Risk          Cost            →       │
    > 0.85    +  Reversible  +  Trivial        →  ACT  │
    > 0.7     +  Reversible  +  Medium         →  ACT  │
    (explore done, assumptions stated)                  │
                 │                                     │
    > 0.7     +  Irreversible                 →  ASK  │
    < 0.7     +  Any                           →  ASK  │
    < 0.3     +  Any                           →  ASK  │
    Missing required input                     →  ASK  │
                 │                                     │
    Multiple valid options, low cost           →  OFFER│
    Preference matters, no clear default       →  OFFER│
    User exploring possibilities               →  OFFER│
                 └─────────────────────────────────────┘
```

#### Path A: Act

**When:** High confidence + reversible + low/medium cost.

**How:**
1. State your understanding briefly
2. List the key assumptions you're making
3. Proceed with execution

```
"I'll optimize the search query in products_controller.rb.
I'm assuming:
- The bottleneck is the N+1 in variant lookup (confirmed by the EXPLAIN plan mentioned)
- You want eager loading over caching (standard pattern in this codebase)
- No API contract changes

Proceeding. If any assumption is wrong, tell me and I'll redirect."
```

#### Path B: Ask

**When:** Low confidence, irreversible action, missing required input.

**How:**
1. State what you know
2. Ask ONE question (the One Good Question — see Phase 5)
3. Follow the structured format (header, question, options, recommendation)
4. End your turn with the question — do not proceed to tools yet

#### Path C: Offer Options

**When:** Multiple valid paths, preference needed, user is exploring.

**How:**
1. Frame the choice clearly
2. List 2-4 options with brief descriptions
3. Mark a recommendation if one path is clearly better
4. Let the user pick

---

### Phase 5 — Design & Ask the One Good Question

#### The One Good Question Principle

Ask the single question that maximizes information gain. A good question:

- **Is specific** — "Which service: web-api or admin-panel?" not "Which one?"
- **Reduces branching** — a forking question collapses 2+ possibilities into 1 answer
- **Unlocks the next step** — answering it removes the main blocker
- **Is easy to answer** — one line, one choice, or one value
- **Includes your recommendation** — gives the user something to react to

#### Question Templates

| Template | When | Example |
|----------|------|---------|
| **Forking** | 2+ plausible interpretations | "Do you mean updating the pricing numbers, or the copy/layout?" |
| **Missing Key** | One critical param unknown | "What's the file path / user ID / date / environment?" |
| **Constraint** | Need hard limits | "Any deadline, budget, or performance target?" |
| **Risk Confirm** | Irreversible action | "Confirm: deploy web-api to production?" |
| **Preference** | Material choice with no default | "Should this be a modal or inline error?" |
| **Scope** | Vague boundary | "Should this apply to all accounts or just this one?" |

#### Structured Question Format

Every clarifying question should follow this structure (based on Claude Code AskUserQuestion, Fazm ask_followup, Spring AI patterns):

```
Header: [Short label, max 12 chars — shown as category tag]

Question: [Full question text — what you need to know]

Options:
  A) [Option label] — [1-line description of what this means]
  B) [Option label] — [1-line description] (Recommended)
  C) [Custom — user types freely]

Why I'm asking: [1 line — context for the user]

What happens next: [1 line — what you'll do after they answer]
```

#### Question Design Rules

1. **One question at a time** — never batch 3+ questions in one turn
2. **Specific, not open-ended** — "Which service?" over "What do you mean?"
3. **Offer options + recommendation** — reduces cognitive load
4. **Order by impact** — ask about the highest-stakes ambiguity first
5. **Explain why you're asking** — context prevents frustration
6. **Say what comes next** — the user should know what happens after they answer
7. **Include "custom" always** — the user can always type free text
8. **Do NOT also write the question as plain text** — the structured format IS the question

#### Anti-Duplication Rule

After asking a structured question, **do not generate any additional text, tool calls, or content.** Your turn ends when the question is delivered. Generating extra text after the question creates confusion (the user doesn't know what to respond to) and wastes context.

---

### Phase 6 — Bounded Loop

Clarification is a multi-turn protocol with guardrails. This phase handles the flow after you ask.

#### Step 1: Receive Response

When the user responds, detect what type of response it is:

| Response type | What it means | Action |
|--------------|---------------|--------|
| **Answer** | Direct answer to your question | Integrate and proceed to execute |
| **Partial answer** | Answered some but not all | Ask follow-up (one more question) |
| **New request** | Changed topic entirely | Abandon clarification, start fresh on new topic |
| **Clarification of question** | User needs you to explain | Re-frame the question more clearly |
| **"I don't know"** | User uncertain | Surface assumptions and proceed with best guess |
| **Correction** | User corrects your assumption | Update understanding, continue |

#### Step 2: Context Switch Detection

If the user's response doesn't relate to your question, treat it as a new request:

```
You asked: "Which service should I deploy: web-api or admin-panel?"
User replied: "Also, can you check the logs for errors?"

→ This is a topic switch. Abandon the clarification.
→ Process the new request. Do NOT resume clarification afterward unless the user circles back.
```

#### Step 3: Integrate Answer

When the user answers directly:
1. Update your understanding with the new information
2. If the answer resolves all ambiguity → proceed to execution
3. If partial ambiguity remains → ask ONE more question (go to Step 4)

#### Step 4: Bounded Loop — Max Questions Guard

**Hard limit: 2-3 clarifying questions per topic.** Research consistently shows more questions degrade user experience.

| Round | Action |
|-------|--------|
| 1st question | Ask the highest-impact question |
| 2nd question (if needed) | Ask the next highest-impact question |
| 3rd question (rare) | Only if the action is irreversible and high-cost |
| After max rounds | Surface assumptions, proceed with best guess |

**After max rounds:**

```
"I've asked a few questions and I have a reasonable understanding now.
Here's what I'm assuming:
1. You want X (not Y) — based on your mention of [context clue]
2. The deadline is [default] — same as last sprint's pattern
3. No special constraints beyond what's in the issue

I'll proceed with these assumptions. If anything's wrong, tell me and I'll adjust.
```

#### Step 5: State Tracking

Within a session, track what's been clarified to avoid re-asking:

```
Session Clarification Log (implicit — maintained by the agent):
- Asked about: deployment target → answered: staging
- Asked about: branch → answered: feature/auth-fix
- Asked about: database migration → answered: not needed

Do NOT re-ask these unless the topic explicitly changes.
```

---

## Integration with Other Skills

| Skill | How they connect |
|-------|-----------------|
| **structured-questioning** | Use Phase 5 (Question Design) of this protocol to formulate the question, then structured-questioning's 5W+H/Socratic to verify the question IS the right one |
| **grill-me** | Use this protocol's Detect-Assess-Explore phases before entering a deep grill session. The protocol determines WHETHER to grill; grill-me determines HOW to grill. |
| **spec-driven-development** | After clarification resolves ambiguity, channel into spec-driven-development's Phase 1 (Specify) to formalize the clarified requirements |
| **shaping-work** | Use the protocol's Detect phase to classify ambiguity level, then shaping-work to define work if the idea is still rough |
| **doubt-driven-development** | Use for high-stakes clarifications where the answer could be wrong — doubt-driven-development validates the integration of the answer |
| **context-engineering** | Use the protocol's State Tracking advice to maintain clarification context across agent turns |

## Companion Script

```bash
# Analyze a request for ambiguity
bash ./skills/clarification-protocol/scripts/clarify.sh analyze "fix the bug"

# Run the full decision gate
bash ./skills/clarification-protocol/scripts/clarify.sh gate "deploy to production"

# Generate a structured question template
bash ./skills/clarification-protocol/scripts/clarify.sh question "which database"

# Pre-flight check: is this request clear enough?
bash ./skills/clarification-protocol/scripts/clarify.sh check "add pagination to /api/users"
```

## Verification

After using this protocol:

- [ ] Ambiguity was detected through structured criteria (not gut feel)
- [ ] Risk was assessed: reversible vs. irreversible, cost of wrong action
- [ ] Exploration was attempted: codebase/docs/context checked before asking
- [ ] A decision was made: Act / Ask / Offer Options (not default "ask")
- [ ] If asking: one question, specific, with options + recommendation
- [ ] Max questions respected: ≤ 2-3 per topic
- [ ] After loop: assumptions surfaced + best guess made
- [ ] Clarification context tracked (no re-asking in same session)

## Anti-Rationalization Table

| Rationalization | Reality |
|----------------|---------|
| "This is obvious, I know what they want" | "Obvious" != "verified". State assumptions. If wrong, user corrects. If right, no harm. |
| "Asking questions makes me look uncertain" | Right answer to wrong question is worse than asking. Users prefer clarity to guessing. |
| "I'll ask about everything at once to save time" | Multiple questions in one turn overwhelm and reduce answer quality. One at a time. |
| "The user said X, so they must mean X precisely" | Users speak imprecisely. "Fix the bug" could mean any of 3 things. Verify. |
| "I can figure it out from the codebase" | Only navigational gaps. Business rules, design intent, and preferences are not in code. |
| "Asking more questions = better understanding" | 3+ questions degrades experience. After 2-3, assume and proceed. |
| "They'll tell me if I'm wrong" | Users often don't notice wrong assumptions until they see wrong output. Surface assumptions proactively. |
| "This tool is fast, so it doesn't matter if I guess wrong" | Wrong output = rework + trust loss. The cost of one question is less than the cost of fixing. |

## Red Flags

- Starting implementation without verifying your understanding matches the user's intent
- Asking questions you could answer by reading code, docs, or git history
- Asking 4+ questions in a session about the same topic
- Making assumptions without stating them explicitly
- Ignoring context when the user changes the subject
- Re-asking what was already clarified in the session
- Asking preference questions when there's a clear default or existing pattern
- Ending your turn with a question AND additional text/tool calls (anti-duplication rule violation)

## References

1. Modexa, "When Agents Should Ask First" (Feb 2026) — Question-First pattern, gates, One Good Question
2. Vijayvargiya et al., "Interactive Clarification for Underspecified Tasks" (ICLR 2026) — Explore-first, navigational vs. informational gaps, 74% recovery rate
3. AgentPatterns.ai — Clarification patterns, reversibility table, confidence thresholds
4. Kuhn, Gal, Farquhar, "CLAM: Selective Clarification" (2023) — INTENT-SIM uncertainty estimation
5. Nandi et al., "Scaling Intent Understanding: Classification with Clarification" (EACL 2026) — 8× cost reduction with lightweight LLM clarifiers
6. ECLAIR Framework (Adobe, EACL 2026) — Multi-agent ambiguity detection, enterprise deployment
7. MAC Framework (Acikgoz et al., IWSDS 2026) — Multi-agent clarification, 7.8% task success gain
8. MUXI Documentation (2026) — Clarification system, context switch detection, multi-turn flow
9. Portia Labs (2025) — Clarification states (pending/awaiting/resolved/cancelled), serialization
10. PraisonAI Clarify Tool (2026) — Tool-based clarification, fallback handling, progressive clarification
11. Claude Code AskUserQuestion Tool (2025-2026) — Structured question format, anti-duplication, SDK integration
12. Fazm ask_followup (2025) — Tool-based Q&A, button rendering, end-of-turn rule, prefer-lookup-before-ask
13. Spring AI AskUserQuestionTool (2026) — Multi-choice questions, portable handler pattern
14. MCP Elicitation Spec (2025-2026) — Form mode + URL mode, three response actions, security rules
15. Prism Framework (ACL 2026) — Logical clarification via intent decomposition, Cognitive Load Theory
16. Socratic Questioning (Kee et al., 2023) — Recursive thinking, top-down exploration, bottom-up backtracking
