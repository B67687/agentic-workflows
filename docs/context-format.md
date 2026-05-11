# Domain Language Glossary (CONTEXT.md)

A shared vocabulary file that defines the project's domain terms. It lives at the repo root as `CONTEXT.md` and serves as the canonical reference for how the team (humans and agents) talks about the system.

## Why

Without a shared language, agents and humans use 20 words where 1 will do. Every session re-derives terminology that should be stable. Variables, files, and conversations drift apart because no one has agreed on what to call things.

A domain glossary fixes this by:

- **Reducing token usage** 20-30% per session — concise language replaces verbose descriptions
- **Aligning naming** — files, functions, and variables use consistent terms
- **Making codebases AI-navigable** — agents search for the right terms because they know what things are called
- **Preventing re-derivation** — "the thing that processes orders" becomes "OrderProcessor" and stays that way

## When to Create

Create `CONTEXT.md` when:
- You start a new project
- You find yourself explaining the same domain concept repeatedly
- The agent uses inconsistent terminology for the same concept
- Multiple people or agents work on the same codebase

## Format

```markdown
# {Project Name}

{One or two sentences describing the project's domain.}

## Language

**{Term}**:
{A concise definition — one sentence max. Define what it IS, not what it does.}
_Avoid_: {synonyms that should NOT be used}

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account

## Relationships

- An **Order** produces one or more **Invoices**
- An **Invoice** belongs to exactly one **Customer**

## Example Dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed."

## Flagged Ambiguities

- "account" was used to mean both **Customer** and **User** — resolved: these are distinct concepts.
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged Ambiguities" with a clear resolution.
- **Keep definitions tight.** One sentence max. Define what it IS, not what it does.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Only domain terms.** General programming concepts (timeouts, error types, utility patterns) don't belong. Before adding a term, ask: is this a concept unique to this project's domain, or a general programming concept?
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
- **Write an example dialogue.** A conversation that demonstrates how terms interact naturally and clarifies boundaries between related concepts.

## Maintenance

- **Add terms lazily** — only when a term comes up in conversation that needs defining
- **Update when understanding shifts** — if a term's meaning evolves, update the glossary
- **Review after significant features** — new features introduce new domain concepts
- **Do not couple to implementation details** — the glossary is for domain experts, not code structure

## Multi-Context Repos

For monorepos with multiple bounded contexts, use a `CONTEXT-MAP.md` at the root:

```markdown
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced` events; Billing consumes them
```

Each context has its own `CONTEXT.md` in its directory, and the map shows how they relate.

## Integration with Skills

The domain glossary feeds into:

- **Grill-with-docs**: During requirements alignment, the agent reads CONTEXT.md to use correct terminology and flags conflicts between the user's language and the glossary
- **Improve-codebase-architecture**: Architecture candidates are described using domain terms from the glossary
- **Documentation and ADRs**: ADRs reference domain terms consistently

## Relationship to ADRs

| Artifact | Purpose | When |
|---|---|---|
| **CONTEXT.md** | What things ARE — the shared vocabulary | Created early, updated as terms surface |
| **ADR** | Why decisions were made — the rationale | Created when a hard-to-reverse decision crystallizes |

The glossary names things. ADRs explain why things are the way they are.

## Related

- `docs/adr-format.md` — Lightweight Architecture Decision Record format
- `skills/grill-me/SKILL.md` — Structured requirements alignment
- `skills/documentation-and-adrs/SKILL.md` — Documentation and ADR workflow
