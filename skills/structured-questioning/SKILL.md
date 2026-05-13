---
name: structured-questioning
description: Formulate complete, well-structured questions by applying the Five Ws framework (Aristotle), the Socratic method (Plato), and ACI (Agent-Computer Interface) principles. Use when you need to
  ask a question --- of a human, an agent, or yourself --- and want to ensure nothing essential is missed. Use before starting a research task, before asking for help, or whenever you sense you might not
  be asking the right question.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read
metadata:
  companion-script: scripts/question-framework.sh
  handoffs: grill-me (to probe requirements), idea-refine (to explore)
  trigger-phrases: ask a question, formulate question, how to ask, what should I ask, structured question, probe
  pattern: inversion
  bundle: define
---
# Structured Questioning

A skill for asking better questions --- grounded in three authoritative traditions:
Aristotle's Five Ws (complete coverage), the Socratic *elenchus* (iterative depth),
and modern ACI (Agent-Computer Interface) principles from Anthropic's agent research.

> **This skill is now automatic.** The Question Gate in `docs/workflow.md` ensures that
> every vague request auto-triggers structured probing before implementation. You don't
> need to invoke this skill manually --- the agent will do it by default.
>
> - If your request is vague -> the agent auto-probes (Direction A)
> - If the agent needs info from you -> it uses ACI format (Direction B)

## When to Use This Skill

| Situation | Apply |
|---|---|
| You're about to ask someone for help | Run the **Pre-Flight Checklist** first |
| You're researching a topic | Use **5W+H Decomposition** |
| You got an answer that doesn't help | Use **Socratic Iteration** |
| You're giving a task to an agent | Apply **ACI Principles** to the prompt |
| The question feels vague or incomplete | The agent will auto-probe --- or you can run **Full Structured Workflow** manually |

## Framework Overview

**Sequence:** 5W+H -> Socratic probes -> ACI optimization -> Self-verification.

## Phase 1 --- Pre-Flight Checklist (5W+H)

Source: Aristotle, *Nicomachean Ethics* III (the original *Septem Circumstantiae*).
Ask each explicitly before any question leaves your mouth or keyboard:

| Question | What it Uncovers |
|---|---|
| **Who** is involved? | Stakeholders, subject, audience, agent persona |
| **What** is needed? | The deliverable, the content, the format |
| **When** is it needed? | Deadline, sequence, blocking dependencies |
| **Where** does this apply? | Context, environment, scope boundaries |
| **Why** does this matter? | Motivation, priority, trade-off weight |
| **How** should it be done? | Method, constraints, preferred approach |

**Script usage:**
```bash
bash ./skills/structured-questioning/scripts/question-framework.sh checklist "your question"
```

### Example

**Bad question:**
> "How do I make this faster?"

**After 5W+H decomposition:**
> "**Who** --- the frontend team **What** --- needs to reduce Time to First Paint **When** --- before the sprint ends Thursday **Where** --- in the product search page on mobile Chrome **Why** --- because Lighthouse scores dropped 20 points after last week's image change **How** --- we prefer lazy-loading over CDN changes since we can't touch DNS."

## Phase 2 --- Socratic Iteration

Source: Plato's *Euthyphro*, *Meno*, *Apology*; Vlastos, "The Socratic Elenchus" (1983).

After forming your question, probe it for hidden assumptions, unstated premises, and branching implications.

### The Six Socratic Question Types

Adapted from Paul & Elder, *The Thinker's Guide to the Art of Socratic Questioning* (Foundation for Critical Thinking, 2006):

| Type | Example |
|---|---|
| **Clarification** | "What do you mean by 'better'? What specifically would improve?" |
| **Assumptions** | "What are you assuming about the user's environment? About the data?" |
| **Evidence** | "Why do you believe this approach will work? What supports that?" |
| **Perspectives** | "How would someone with a different stack approach this?" |
| **Implications** | "If we do this, what else changes? What breaks?" |
| **Meta (about the question)** | "Is this the most useful question to ask right now?" |

### Self-Socratic Protocol

When you catch yourself thinking "I'm not sure this is the right question":

```
1. Write down the question as-is
2. For each of the 6 types above, ask yourself once
3. Revise the question
4. If you revised more than 2 types, repeat from step 2
5. Stop after 2 iterations --- ship the question
```

## Phase 3 --- ACI Optimization (Agent-Ready Framing)

Source: Anthropic, "Building Effective Agents" (Dec 2024); Anthropic ACI tool design principles.

When asking an **agent** rather than a human, apply these ACI principles:

### ACI Principles for Question Formulation

| Principle | Apply |
|---|---|
| **Give room to think** | Don't compress --- let the model reason. State the context fully. |
| **Natural format** | Keep the structure close to what models see in training data. Don't over-format. |
| **No overhead** | Avoid requiring the model to count lines, escape strings, or reconstruct implicit context. |
| **Poka-yoke** | Phrase to make misunderstanding hard. "If X, then Y" is clearer than "please handle X appropriately." |

### Good vs. ACI-Optimized

**Human-style:**
> "Optimize the search. It's slow."

**ACI-optimized:**
> "The product search endpoint (`/api/products?q=`) averages 2.3s on p95. Target: <800ms. The bottleneck is an N+1 in the variant lookup (confirmed via pg_stat_statements). Apply eager loading to `product.variants` and `product.variants.images`. Do not change the API contract or the cache layer."

## Phase 4 --- Self-Verification

Before sending the question, check:

- [ ] **5W+H complete** --- I can answer each of the six questions about my own request
- [ ] **Hidden assumption flagged** --- I explicitly stated what would otherwise be assumed
- [ ] **ACI-ready** --- The question gives the receiving agent room to think, uses natural structure, avoids format overhead
- [ ] **Smallest slice** --- This question asks for the minimum needed to unblock the next step
- [ ] **Escalation path** --- I know what I'll do with the answer: confirm, dig deeper, or escalate

## Integration with Other Hub Skills

| Skill | How They Connect |
|---|---|
| **grill-me** | Use this skill to *prepare* your questions before going into a grill session. The grill's decision tree is stronger when your opening questions are already decomposed. |
| **research-prompt** | The 5W+H decomposition feeds directly into the research prompt's Hierarchical Analysis section. Use Phase 1 before starting research to sharpen scope. |
| **idea-refine** | Use Socratic Iteration (Phase 2) during the convergent thinking phase to stress-test ideas before selecting. |
| **debugging-and-error-recovery** | The 5W+H framework maps naturally to bug triage: Who (affected users), What (error), When (first seen), Where (component), Why (root cause hypothesis), How (to fix). |
| **context-engineering** | Use the ACI Optimization phase when writing agent instructions or rules files. |

## Anti-Rationalization Table

| Rationalization | Reality |
|---|---|
| "I know what I mean, they'll figure it out" | They won't. The effort of decomposing is less than the cost of clarifying. |
| "This is too urgent for a checklist" | Urgent questions answered wrong cost more than 30 seconds of structure. |
| "The model is smart, it can read my mind" | Models follow the text, not your intention. If the question is vague, the answer will be too. |
| "I've asked this before --- same framing works" | New context changes everything. Run the checklist anyway (15 seconds). |
| "Good questions come naturally to me" | Even Socrates used a method. Structured questioning is a skill, not a talent. |

## Companion Script

A `question-framework.sh` script is available with both interactive and non-interactive modes.

### Auto-Call Modes (for AI + Pipeline Use)

These modes require no stdin and output structured text. The AI calls them automatically
when the Question Gate detects a vague request:

```bash
# All three are non-interactive --- no stdin needed
bash ./skills/structured-questioning/scripts/question-framework.sh analyze "optimize the search"
# Output: JSON-style analysis of which 5W+H dimensions are present/missing

bash ./skills/structured-questioning/scripts/question-framework.sh probe "optimize the search"
# Output: Structured probe questions for each missing dimension

bash ./skills/structured-questioning/scripts/question-framework.sh aci "optimize the search"
# Output: ACI-optimized rewrite template
```

### Interactive Modes (for Human Use)

```bash
# Show the 5W+H checklist for a question
bash ./skills/structured-questioning/scripts/question-framework.sh checklist "How should I optimize the search query?"

# Run the full structured workflow
bash ./skills/structured-questioning/scripts/question-framework.sh full "How should I optimize the search query?"
```

## Verification

After using this skill:

- [ ] The question is decomposable into all 5W+H dimensions
- [ ] At least 2 Socratic probe types were applied
- [ ] The question is framed in ACI-optimized language (for agent targets)
- [ ] The receiver can answer without asking clarifying questions
- [ ] You know what the answer will unblock next

## References

1. Aristotle, *Nicomachean Ethics* Book III (c. 340 BCE) --- the original *Septem Circumstantiae*
2. Plato, *Euthyphro*, *Meno*, *Apology* (c. 399--387 BCE) --- Socratic elenchus in practice
3. Vlastos, G. "The Socratic Elenchus", *Oxford Studies in Ancient Philosophy* I (1983)
4. Paul, R. & Elder, L. *The Thinker's Guide to the Art of Socratic Questioning*, Foundation for Critical Thinking (2006)
5. Anthropic, "Building Effective Agents" (Dec 2024) --- ACI tool design principles
6. A2A Protocol Specification v1.0 (March 2026) --- `INPUT_REQUIRED` and `AUTH_REQUIRED` task states
