---
name: product-primitives
description: Break down complex products, features, or systems into fundamental primitives and building blocks from a software creator's perspective. Use when starting a new application, designing a large feature, or understanding a complex system's moving parts before building. Complements product-thinker (user perspective) with the builder's perspective (system-level connections).
trigger-phrases: break down, decompose this, what are the primitives, building blocks, map the architecture, what are the moving parts, analyze this system
handoffs: shaping-work (to shape individual primitives as work items), product-thinker (for user-perspective analysis alongside)
companion-script: scripts/decompose-primitives.sh
---

# Product Primitives

Break complex systems into fundamental primitives --- deep, information-hiding building blocks with clear boundaries and simple interfaces.

**Companion script:** `scripts/decompose-primitives.sh`
```bash
bash ./scripts/decompose-primitives.sh analyze "<system>"    # decompose a system
bash ./scripts/decompose-primitives.sh check "<primitive>"    # quality check
bash ./scripts/decompose-primitives.sh redflag "<text>"       # red flag check
bash ./scripts/decompose-primitives.sh lens <type>            # apply a lens
```

## How to Decompose

The quality of a decomposition depends on where you draw boundaries.

### Deep, not shallow
Each primitive should have a simple interface hiding significant functionality. If a primitive's interface is as complex as what it does internally, it's not useful --- it's indirection.

### Information hiding
Each primitive should encapsulate a design decision --- a piece of knowledge nothing outside it needs to know. When you can change a primitive's internals without affecting anything else, the boundary is right.

### Split by knowledge, not by time
Don't decompose by execution order. That's temporal decomposition --- it leaks information because operations at different times often share knowledge. Instead ask: what distinct pieces of knowledge does this system need? Each piece becomes a primitive.

### Bring together or split apart?
- **Merge** when two pieces share information or are always used together
- **Split** when pieces are truly independent
- **Test**: will developers need to read both to understand either?

### Pull complexity downward
Push unavoidable complexity into lower-level primitives so higher-level composition stays simple.

### Layer placement: I/O / Function / State
Each primitive should clearly belong to one layer:
- **I/O**: Boundary (network, files, time, webhooks)
- **Function**: Logic (pure computation, decisions, orchestration)
- **State**: Persistence (DB, caches, durable queues)

A primitive mixing layers is a decomposition smell --- split it.

## What Makes a Good Primitive

- **Deep** --- simple interface, powerful functionality behind it
- **Encapsulating** --- hides a design decision; internals can change without rippling outward
- **Composable** --- combines with other primitives through simple interfaces
- **Transferable** --- useful in multiple workflows, not one specific scenario

## Red Flags

- **Shallow** --- interface as complex as implementation
- **Information leakage** --- same knowledge in multiple primitives
- **Temporal decomposition** --- boundaries mirror execution order
- **Pass-through** --- does nothing but forward to another primitive
- **Conjoined** --- can't understand one without the other

## Output Format

```
## System: [Name]

## Primitives

### 1. [Primitive Name]
**Purpose**: What it does
**Encapsulates**: What knowledge/decisions it hides
**Interface**: What callers need to know (inputs -> outputs)

### 2. [Next Primitive]
...

## How They Fit Together

[ASCII diagram showing relationships and data flow]

## Composition Examples

[Show how 2-3 user workflows are composed from these primitives]
```

## Example

**Input**: "Break down an e-commerce marketing automation system"

```
## System: E-commerce Marketing Automation

Automate marketing campaigns for online stores --- segment, create campaigns, schedule, measure.

## Primitives

### 1. Audience Segmentation
**Purpose**: Group customers by behavior, demographics, or purchase history
**Encapsulates**: Segment rule evaluation, membership caching, refresh scheduling
**Interface**: (segment rules, customer data) -> named segments with member lists

### 2. Campaign Composition
**Purpose**: Assemble campaign from template, audience, and schedule
**Encapsulates**: Campaign state machine, validation, duplication logic
**Interface**: (template + segment + schedule) -> ready-to-send campaign

### 3. Content Rendering
**Purpose**: Produce personalized email/SMS from templates + product data
**Encapsulates**: Template engine, personalization tokens, product data lookup
**Interface**: (template + recipient + products) -> rendered content

### 4. Send Orchestration
**Purpose**: Execute campaign delivery respecting rate limits and timing
**Encapsulates**: Channel delivery, rate limiting, retry, bounce handling
**Interface**: (campaign + recipients + content) -> delivery receipts

### 5. Performance Measurement
**Purpose**: Track opens, clicks, conversions, revenue attribution
**Encapsulates**: Event aggregation, attribution, metric computation
**Interface**: (delivery events + interactions + orders) -> campaign metrics

## How They Fit Together

┌──────────────────┐
│    Audience      │──────────────────────┐
│  Segmentation    │                       │
└────────┬─────────┘                       │
         │ segments                        │ segment scores
         ▼                                 ▼
┌──────────────────┐    ┌───────────────┐
│    Campaign      │───▶│    Content    │
│   Composition    │    │   Rendering   │
└────────┬─────────┘    └───────┬───────┘
         │ campaign             │ content
         ▼                       ▼
      ┌──────────────────────────┐
      │   Send Orchestration     │
      └────────────┬─────────────┘
                   │ delivery events
                   ▼
      ┌──────────────────────────┐
      │ Performance Measurement  │──┘
      └──────────────────────────┘
        (feeds back into segmentation)
```

## Handoffs

- Pair with `product-thinker` for user-perspective analysis alongside decomposition
- Feed individual primitives into `shaping-work` to shape as work items

## Boundaries

- Does NOT produce implementation plans or code
- Does NOT make final architectural decisions --- proposes decompositions
- Analysis only --- human validates boundaries before building
