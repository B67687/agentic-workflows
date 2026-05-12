---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving branches of the decision tree one at a time. Use when requirements are ambiguous, the task could be costly to misunderstand, or the user says "grill me."
---

# Grill Me

Structured requirements alignment grounded in the **Socratic elenchus** (Plato's early dialogues:
*Euthyphro*, *Meno*, *Apology*). Socrates used iterative questioning to expose hidden assumptions
and reach shared understanding before committing to action. This skill does the same for modern
agentic workflows.

When a task is broad, ambiguous, or expensive to get wrong, stop and grill before planning.

> **Related skill**: Use `structured-questioning` to prepare your questions *before* entering a grill
> session. That skill decomposes any question into 5W+H + Socratic probe. This skill walks the
> decision tree with the other party.

## Phases

### Phase 1 — Set the Stage

State what you're about to do:

> "I'm going to interview you about this plan until we reach shared understanding on every branch of the decision tree. I'll go one question at a time. For each question, I'll provide a recommended answer. If a question can be answered by exploring the codebase, I'll explore instead of asking."

### Phase 2 — Walk the Decision Tree

Ask questions **one at a time**. Wait for the user's answer before continuing.

Each question should:
- Be specific and answerable
- Include your recommended answer
- Surface dependencies between decisions

Example flow:

```
Q1: "Who is the primary user of this feature — an end customer or an admin?"
    Recommended: "End customer, same as the existing checkout flow."

Q2: "Should this handle guest users (no account) or require authentication?"
    Recommended: "Guest users, since the current cart flow supports guest checkout."
```

### Phase 3 — Stress-Test with Scenarios

Once the outline is clear, probe edge cases with concrete scenarios:

> "What happens if the payment succeeds but the inventory API times out? Do we:
> 1. Refund the payment and notify the user
> 2. Retry the inventory update and reconcile later
> 3. Show a success page with a warning banner
>
> Recommended: Option 2 — we already have a reconciliation worker pattern."

### Phase 4 — Confirm Shared Understanding

Summarize the agreed plan in 3-5 bullets. Ask:

> "Is this correct? If so, I'll proceed to plan the first slice."

If the user corrects anything, go back to Phase 2 at the relevant branch.

## Ground Rules

| Rule | Why |
|---|---|
| One question at a time | Prevents overwhelming the user and ensures each branch is resolved |
| Recommend an answer | Gives the user something to react to instead of a blank page |
| Explore over ask | If the codebase or existing docs can answer it, don't make the user decide |
| No skipping branches | Every unresolved dependency will surface as a bug later |
| Stop after 2 refinements | If the plan isn't converging, pick the next verified slice and move forward |

## When Not to Grill

Don't use this for:
- Trivial, well-understood changes (typo fixes, config updates, obvious refactors)
- Tasks already specified in detail (PRD, spec, or issue with clear requirements)
- Pure exploration or research (no decision tree to walk)

Use `/grill-with-docs` instead when the project has a CONTEXT.md domain language file or ADRs that should inform the decisions.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I know what they want, I've done this before" | Every project is different. Yesterday's assumptions are today's bugs. |
| "Grilling slows me down" | It slows down the first hour. It saves the next 10 hours of rebuilding the wrong thing. |
| "The requirements are in the issue" | Issues describe symptoms, not the full decision tree. The hidden branches are where the cost lives. |
| "They'll correct me if I'm wrong" | They'll see the wrong output and correct you after you've built it. Much more expensive. |

## Red Flags

- Starting implementation with unanswered questions about the design
- Assuming requirements without confirming
- Skipping edge cases because they're "unlikely"
- The user saying "I don't know" — that means the branch needs more thought, not that it should be skipped

## Verification

After grilling:

- [ ] Every branch of the decision tree has been walked
- [ ] The user confirms the summary is correct
- [ ] No ambiguous or unresolved requirements remain
- [ ] You have enough clarity to write a plan or spec
- [ ] Remaining unknowns are explicitly flagged as deferred decisions
