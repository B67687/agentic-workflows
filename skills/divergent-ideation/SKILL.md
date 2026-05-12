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

A single LLM call converges to the most probable path. This skill forces divergence through **multiple methods** — constrained perspectives, lateral thinking techniques, and cross-domain forcing — then **cross-pollinates**, **evaluates**, and **converges** on the most promising hybrid.

```
Warm-up (play) → Diverge ──→ Cross-Pollinate ──→ Evaluate ──→ Converge
                   │               │                 │             │
                  varied          hybrids          scores        creative brief
                 methods
```

Research shows **positive mood and playfulness directly enhance divergent thinking** (Vosburg 1998, Lieberman 1965). The warm-up is not optional — it shifts from evaluative to generative mode.

---

## Step 0: Warm-up — Enter Play Mode

Before any serious ideation, do a 1-2 minute warm-up. This is not optional — research shows positive mood significantly improves divergent thinking performance.

Pick one:
- **Absurd improvement**: Take something unrelated to the problem (e.g. a toaster, a tree, a spoon) and list 5 ridiculous ways to improve it
- **Random connection**: Pick a random noun (look around the room). Force a connection to the problem. "How is this problem like a [lamp/backpack/cloud]?"
- **Reverse the problem**: State the exact opposite of your goal. "How would we make this as bad as possible?" Then invert each answer.
- **What would a child do?**: Without any knowledge of the domain, what's the simplest, most fun version?

The warm-up has one rule: **no judgment**. The goal is fluency, not quality.

---

## Step 1: Diverge — Generate N Deliberately Different Approaches

Use at least **two different divergence methods** from the options below. If all your ideas feel similar, you only used one method — add another.

### Method A: Constrained Perspectives

Generate 2-4 approaches, each from a **distinct perspective** with a **unique constraint**. Choose perspectives that pull in opposite directions along the tensions relevant to the problem.

Select from this catalog (or create your own). The constraint is what forces divergence, not the label:

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
| **Jester** | Nothing is sacred. Laugh at everything. | Absurdity, satire, breaking taboos |
| **Gardener** | Don't build — grow. Nurture conditions. | Organic systems, emergence, cultivation |
| **Detective** | Something was missed. Find the clue. | Hidden signals, overlooked details, anomalies |

Format each generation as a separate thought:

> "You are [Perspective]. Your constraint is: [Constraint]. Generate one approach to: [PROBLEM]. Do not produce a typical solution. Force yourself to think differently within your constraint."

If any two approaches are essentially the same, discard one and use a different perspective.

### Method B: De Bono's Lateral Thinking

Use these techniques instead of (or in addition to) perspectives. Each forces a different kind of divergence:

| Technique | How it works | Example |
|---|---|---|
| **Random entry** | Pick a random noun/object/image. Force a connection to the problem. Ask "How is this problem like a [random thing]?" | Random word "nose" → photocopier that smells like lavender when low on paper |
| **Provocation** | State something deliberately impossible or wrong. Then treat it as real and derive ideas. | "The factory is downstream of itself" → law requiring factories to take input from their own output |
| **Challenge** | Question why things are done the way they are, even if they seem obvious. | "Why do coffee cups need handles?" → insulated finger grips, cup holders, less hot coffee |
| **Concept extraction** | Take an existing idea and extract the concept behind it. Generate new ideas from that concept in a different context. | Shopping cart → "carrying multiple items" → apply to digital bookmarks, grocery lists, project management |
| **Disproving** | Take an obvious assumption and try to convincingly disprove it. | "The majority is always wrong" → question every default approach |

Run at least one lateral thinking technique alongside perspectives.

### Method C: Cross-Domain Forcing (Steve Jobs method)

Forcibly connect the problem to a completely unrelated domain. For at least 2 domains below, ask "How would this problem be solved in [domain]?" and extract the principle.

| Domain | What it teaches | Example connection |
|---|---|---|
| **Biology** | Evolution, symbiosis, ecosystems, emergence | How would a coral reef solve this? What self-organizes? |
| **Music** | Rhythm, harmony, tension/release, improvisation | What's the melody of this problem? Where's the silence? |
| **Games** | Feedback loops, scoring, difficulty curves, fun | How do you make this addictive? What are the levels? |
| **Architecture** | Structure, flow, light, boundaries, public/private | What's the floor plan of this problem? Where are the windows? |
| **Cooking** | Taste, timing, substitution, fermentation | What are the core ingredients? What if we let it ferment? |
| **Martial arts** | Leverage, momentum, positioning, timing | What's the least effort path? Where's the opponent's weight? |
| **Theater** | Narrative, staging, audience, timing, improvisation | Who's the audience for this? What's the third act twist? |
| **Sports** | Strategy, positioning, team dynamics, counters | What's the winning play? Where's the weak side? |

Extract at least 2 transferable principles from different domains and turn them into concrete approaches.

### Step 1 output

At the end of the diverge phase you should have:
- At least 1 approach from Method A (perspectives)
- At least 1 approach from Method B (lateral thinking)
- At least 1 approach from Method C (cross-domain)
- No two approaches should feel like variations of the same idea

If they do, you haven't used different enough methods — add another lateral thinking technique or cross-domain domain.

---

## Step 2: Cross-Pollinate — Create Hybrids

Combine approaches from **different divergence methods**, not from the same method. Hybrids produce more novelty when they bridge fundamentally different thinking modes (e.g. a perspective approach + a lateral thinking approach).

For each hybrid:

> "Combine the [Method A approach] with the [Method B approach]. They came from different thinking modes. Take the strongest element from each and merge them into something neither mode alone would produce. What emerges from this tension?"

### How to pair

| Pairing principle | Combine | Why it works |
|---|---|---|
| **Speed + polish** | Hacker perspective + Designer perspective | Both fast AND beautiful |
| **Feeling + systems** | Psychologist perspective + Provocation technique | Emotionally resonant AND counter-intuitive |
| **Cross-domain + perspective** | Biology principle + Hacker perspective | Evolutionary hacking |
| **Wild + lateral** | Cross-domain (Games) + Random entry | Playful surprise |
| **Inversion + history** | Contrarian perspective + Archaeologist perspective | Challenge assumptions by learning from the past |

Mix methods, not just content. The more different the origins, the more novel the hybrid.

Produce 2-3 hybrids. Label each with their origins and a short evocative name (e.g. **Hacker × Biology: "Evolutionary MVP"**, **Provocation × Psychology: "Adversarial Delight"**).

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

## Why This Works (Research Basis)

This skill is grounded in established creativity research:

| Finding | Source | How the skill applies it |
|---|---|---|
| **Playfulness directly predicts divergent thinking** | Lieberman (1965), confirmed by multiple replication studies | Step 0 warm-up primes generative mode. Play is not optional — it's cognitive preparation. |
| **Positive mood facilitates divergent performance** | Vosburg (1998), Murray et al. (1990) | The warm-up creates positive affect before ideation begins. Evaluating later keeps mood from blocking generation. |
| **Multidisciplinary breadth predicts innovation** | Steve Jobs, various innovation studies | Method C forces cross-domain transfer. The best ideas come from connecting disparate fields. |
| **Constraints force novelty** | De Bono (1967, 1992) | Perspectives aren't labels — they're binding constraints. Without a constraint, the model converges to the average. |
| **Lateral thinking ≠ vertical thinking** | De Bono (1967) | Method B (lateral thinking) deliberately breaks sequential reasoning patterns. Used alongside Method A (perspectives/vertical), they diverge in different dimensions. |
| **Hybridization produces genuine novelty** | Various creativity studies | Step 2 combines approaches from different methods, not just different labels. Method-level hybrids beat perspective-level hybrids. |

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

- All approaches look like variations of the same idea → you only used ONE divergence method. Every approach came from Method A (perspectives) alone. Force yourself to use Method B (lateral thinking) and Method C (cross-domain).
- Novelty scores are all below 5 → you didn't diverge in kind, only in degree. Add a method you haven't used yet.
- You skipped the warm-up → without play priming, your ideas will be safe and convergent. Go back and do Step 0.
- Hybrids are just rephrasing of existing approaches → you paired approaches from the SAME method. Cross-pollinate between different methods instead.
- You chose all similar perspectives (e.g. all technical) → you're converging before diverging. Force a perspective that can't use technical reasoning (Artist, Child, Jester).
- The final concept feels safe → convergent thinking took over. Restart with a more extreme method pair (e.g. Provocation + Cross-domain).
- You used only perspectives and called it done → perspectives are one method. You need at least two different methods for genuine divergence.
- You feel like you already know the answer → that's exactly when you need this skill.
- The warm-up produced better ideas than the main session → you're converging too fast in the main session. Spend more time in fan divergence.

## Relationship to Other Skills

This skill fills the **creative front-end** of the workflow:

```
[divergent-ideation] → [spec-driven-development] → [planning-and-task-breakdown] → [incremental-implementation]
  ↑ ideate                 ↑ specify                     ↑ plan                       ↑ build
```

Use this BEFORE `spec-driven-development` when the problem needs original thinking. If the path is clear, skip straight to spec.
