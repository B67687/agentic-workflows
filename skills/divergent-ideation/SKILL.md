# Divergent Ideation

A structured workflow for generating genuinely novel ideas using LLMs, when conventional convergent thinking would produce predictable results.

## When to Use

- The problem is open-ended and has many possible solutions
- Existing approaches feel stale or obvious
- You need a genuinely original product, feature, or strategy
- The user says "be creative" or "think outside the box"
- You're stuck in a rut generating the same kind of ideas

Do NOT use for: well-defined implementation tasks, bug fixes, translations, or anything where correctness matters more than novelty.

## How It Works

A single LLM call converges to the most probable path. This skill forces divergence by using **multiple constrained perspectives**, then **cross-pollinating** the results, then **evaluating for novelty**, then **converging** on the most promising hybrid.

```
Diverge ──→ Cross-Pollinate ──→ Evaluate ──→ Converge
  │               │                 │             │
  5 personas      hybrids          scores        creative brief
```

---

## Step 1: Diverge — Generate 5 Deliberately Different Approaches

Generate exactly 5 approaches, each from a distinct persona with a unique constraint. Each generation is a separate thought, not a list.

For each persona, explicitly instruct:

> "You are a [PERSONA]. Your goal is to generate one approach to: [PROBLEM]. You must obey your constraint. Do not produce a typical solution. Force yourself to think differently."

### Persona 1: Hacker

**Constraint:** Minimal resources, maximum speed. Build something rough and functional fast using clever shortcuts. Elegance is not the goal — working is.

**Forces thinking toward:** MVP-first, creative workarounds, unconventional tech stacks, "good enough" solutions.

### Persona 2: Designer

**Constraint:** The user experience is everything. If it's not delightful, it doesn't matter how well it works. Start from the feeling you want the user to have.

**Forces thinking toward:** Aesthetics, flow states, emotional response, simplicity, craft.

### Persona 3: Scientist

**Constraint:** First principles. Break the problem down to its fundamental truths. Hypothesize, measure, iterate. Everything must be falsifiable.

**Forces thinking toward:** Systematic reasoning, metrics, controlled experiments, evidence over intuition.

### Persona 4: Contrarian

**Constraint:** Do the opposite of what everyone else does. Identify the conventional wisdom for this problem and invert every assumption.

**Forces thinking toward:** Counter-intuitive approaches, neglected angles, "what if everyone is wrong about X?"

### Persona 5: Child

**Constraint:** You have no knowledge of existing solutions. No budget limits. No technical constraints. No fear of being wrong. What would you build just because it's fun?

**Forces thinking toward:** Naive innovation, playful exploration, blue-sky thinking, removing artificial constraints.

### What to produce

For each persona, write a 3-5 sentence approach description. Label it clearly (e.g. **H1: Hacker approach**, **D2: Designer approach**).

If any two approaches feel essentially the same, discard one and force a new generation from a different angle.

---

## Step 2: Cross-Pollinate — Create Hybrids

Now take the most promising pairs of approaches and synthesize them. Force unexpected combinations.

For each hybrid, explicitly instruct:

> "Combine the [PERSONA1] approach with the [PERSONA2] approach. Take the strongest element from each and merge them into something neither persona would have created alone. What emerges?"

### Suggested Pairings

| Hybrid | Combine | Why |
|---|---|---|
| H-D | Hacker + Designer | Speed + polish. Build fast but make it beautiful. |
| S-C | Scientist + Contrarian | Systematic inversion. Rigorously test the opposite. |
| D-K | Designer + Child | Playful delight. What's fun AND well-crafted? |
| H-K | Hacker + Child | No-limits building with creative shortcuts. Just make it exist. |
| C-S | Contrarian + Scientist | Challenge assumptions systematically. Prove the inverted approach. |

At minimum, produce 3 hybrids. Each should be genuinely different from the 5 original approaches and from each other. Label them clearly (e.g. **H-D Hybrid: "Rapid Delight"**, **S-C Hybrid: "Prove the Opposite"**).

If a hybrid is just a rephrasing of an existing approach, discard it and try a different pair.

---

## Step 3: Evaluate — Score Each Hybrid

Score each hybrid on two axes:

| Axis | 1 | 5 | 10 |
|---|---|---|---|
| **Novelty** | I've seen this before | Somewhat fresh | Genuinely surprising |
| **Viability** | Impossible or impractical | Could work with effort | Straightforward to build |

Produce a small table:

| Hybrid | Novelty | Viability | Notes |
|---|---|---|---|
| H-D: "Rapid Delight" | 7 | 8 | Fast to prototype, great UX |
| S-C: "Prove the Opposite" | 9 | 4 | Novel but hard to validate |
| ... | | | |

Mark the **most promising hybrid** with ★.

If no hybrid scores above 5 on novelty, you haven't diverged enough. Repeat Step 1 with different persona constraints.

---

## Step 4: Converge — Develop the Chosen Direction

Take the ★ hybrid and develop it into a concrete creative brief:

1. **Concept:** One sentence that captures the idea
2. **Why it's different:** What makes this novel compared to conventional approaches
3. **Core tension:** The interesting conflict at the heart of the idea (e.g. "it's fast but also beautiful, and those usually trade off")
4. **One bet:** The single assumption that must be true for this to work
5. **Smallest proof:** The cheapest way to test if this has merit
6. **Risks:** What could go wrong, specifically

This creative brief becomes the input for the next workflow phase (typically `spec-driven-development`).

---

## Common Rationalizations

| Shortcut | Why It Fails |
|---|---|
| "Higher temperature will make it creative" | Temperature adds noise, not novel structure. The model still converges to probable token sequences — it just does it sloppily. |
| "I already generated 5 ideas, that's divergent" | 5 variations on the same approach is not divergence. Each persona must produce a fundamentally DIFFERENT kind of solution. |
| "The first idea was the best one" | The first idea is always the most probable path. Divergent thinking requires forcing past the first idea into unlikely territory. |
| "I'll skip cross-pollination, just pick the best" | Hybridization is where true novelty emerges. Pure approaches are rarely surprising; their combinations are. |
| "Creativity prompts aren't needed — I'm already creative" | The LLM defaults to convergence. Without structural forcing, it will produce the average of all training data. |

## Red Flags

- All 5 approaches look like variations of the same idea → restart from Step 1 with stronger constraint differences
- Novelty scores are all below 5 → you haven't diverged enough
- Hybrids are just rephrasings of existing approaches → try different pairings
- The final concept feels safe → convergent thinking took over; restart or force a more extreme hybrid
- You feel like you already know the answer → that's exactly when you need this skill

## Relationship to Other Skills

This skill fills the **creative front-end** of the workflow:

```
[divergent-ideation] → [spec-driven-development] → [planning-and-task-breakdown] → [incremental-implementation]
  ↑ ideate                 ↑ specify                     ↑ plan                       ↑ build
```

Use this BEFORE `spec-driven-development` when the problem needs original thinking. If the path is clear, skip straight to spec.
