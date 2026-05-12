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
  varied          hybrids          scores        creative brief
  perspectives
```

---

## Step 1: Diverge — Generate N Deliberately Different Approaches

Generate 3-6 approaches, each from a **distinct perspective** with a **unique constraint** that forces different thinking.

The number and choice of perspectives depends on the problem. Low complexity → 3 perspectives across the most relevant axes. High complexity or highly creative need → 5-6 perspectives including extreme ones.

### How to choose perspectives

Look at the problem and ask: **what are the most useful tensions here?**

Then select or create perspectives that pull in opposite directions along those tensions. For example, if the problem is technical but needs good UX, pull in a Hacker and a Designer. If the problem is about behavior change, pull in a Psychologist and an Economist.

### Perspective catalog

Select 3-6 from this catalog (or create your own):

| Perspective | Core constraint | Forces thinking toward |
|---|---|---|
| **Hacker** | Minimal resources, maximum speed. Build it now. | MVPs, shortcuts, unconventional stacks |
| **Designer** | Delight or bust. Start from the feeling. | Aesthetics, flow, craft |
| **Scientist** | First principles. Everything falsifiable. | Metrics, experiments, evidence |
| **Contrarian** | Invert every assumption. Opposite of default. | Counter-intuitive approaches |
| **Child** | No constraints. No fear. Just fun. | Naive innovation, playful exploration |
| **Economist** | Incentives drive everything. Optimize for leverage. | Market dynamics, game theory, efficiency |
| **Psychologist** | People don't do what's rational. | Cognitive biases, motivation, habit formation |
| **Artist** | Express something. Mean something. | Metaphor, emotion, cultural resonance |
| **Chef** | Constraints breed creativity. Limited ingredients. | Taste, combination, surprising pairings |
| **Archaeologist** | The past holds the answer. Find the pattern. | Historical precedent, forgotten approaches |
| **Alien** | Humanity solved this wrong. Start from zero. | Radical reframing, questioning fundamentals |
| **Oracle** | You know the future outcome. How did you get there? | Reverse-casting, working backward from success |

The same perspective should never be used twice in the same session. If a problem needs the same lens repeatedly (e.g. "Designer" for multiple problems), force a different expression of it — e.g. "Designer focused on accessibility" vs "Designer focused on delight."

### How to run each generation

For each perspective, generate the approach as a separate thought. The format:

> Approach [N]: [Perspective name] — [Short label]
>
> "You are [Perspective]. Your goal is to generate one approach to: [PROBLEM]. Your constraint is: [Constraint from catalog]. Do not produce a typical solution. Force yourself to think differently."
>
> 3-5 sentence description of the approach.

If any two approaches feel essentially the same, discard one and replace it with a different perspective.

### Can I create custom perspectives?

Yes. If the problem domain suggests a perspective not in the catalog, create it. The critical requirement is that it has a **specific, actionable constraint** that differs from all other perspectives chosen. A perspective without a binding constraint is just noise.

---

## Step 2: Cross-Pollinate — Create Hybrids

Combine the most contradictory perspectives. The best hybrids come from approaches that pull in opposite directions — that tension is where novelty lives.

For each hybrid:

> "Combine the [Perspective A] approach with the [Perspective B] approach. Take the strongest element from each and merge them into something neither would have created alone. What emerges from this tension?"

### How to pair

Don't pair similar perspectives (Designer + Artist = same direction). Pair opposites:

| Pairing principle | Example | Why it works |
|---|---|---|
| **Speed + polish** | Hacker + Designer | Forces solutions that are both fast AND beautiful |
| **Feeling + logic** | Psychologist + Scientist | Emotionally resonant AND rigorously tested |
| **Wild + structured** | Child + Economist | Playful ideas with real-world viability |
| **Inversion + evidence** | Contrarian + Archaeologist | Challenge assumptions by learning from the past |
| **Constraints + freedom** | Chef + Artist | Limits force creative expression |

Produce 2-3 hybrids. Fewer, more distinct hybrids beat many trivial ones.

If a hybrid is just a rephrasing of an existing approach, discard it and try a different pair.

Label each hybrid with the perspectives that created it and a short evocative name (e.g. **Hacker × Designer: "Rapid Polish"**, **Child × Economist: "Playful Value"**).

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
| Hacker × Designer: "Rapid Polish" | 7 | 8 | Fast to prototype, great UX |
| Scientist × Contrarian: "Prove the Opposite" | 9 | 4 | Novel but hard to validate |
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
| "I already generated N ideas, that's divergent" | N variations on the same approach is not divergence. Each perspective must produce a fundamentally DIFFERENT kind of solution. If you can't see a clear conflict between perspectives, they aren't divergent enough. |
| "The first idea was the best one" | The first idea is always the most probable path. Divergent thinking requires forcing past the first idea into unlikely territory. |
| "I'll skip cross-pollination, just pick the best" | Hybridization is where true novelty emerges. Pure approaches are rarely surprising; their combinations are. |
| "I'll just ask the LLM to be creative" | "Be creative" is an empty instruction. Without a specific constraint that blocks the default path, the model produces the most probable (and most boring) answer. The constraint is what forces divergence, not the request. |

## Red Flags

- All approaches look like variations of the same idea → you didn't pull from different enough perspectives. Choose perspectives that conflict.
- Novelty scores are all below 5 → you haven't diverged enough. Add an extreme perspective (Alien, Oracle, Child).
- Hybrids are just rephrasing of existing approaches → try pairing more contradictory perspectives.
- You chose all similar perspectives (e.g. all technical) → you're converging before diverging. Force a non-technical perspective.
- The final concept feels safe → convergent thinking took over; restart or force a more extreme hybrid.
- You feel like you already know the answer → that's exactly when you need this skill.
- You used only the first 3 perspectives from the catalog → you picked the easiest, not the most divergent. Scrolling further in the catalog yields more unusual perspectives.

## Relationship to Other Skills

This skill fills the **creative front-end** of the workflow:

```
[divergent-ideation] → [spec-driven-development] → [planning-and-task-breakdown] → [incremental-implementation]
  ↑ ideate                 ↑ specify                     ↑ plan                       ↑ build
```

Use this BEFORE `spec-driven-development` when the problem needs original thinking. If the path is clear, skip straight to spec.
