---
name: divergent-ideation
description: Generates genuinely novel ideas using LLMs. Use when tackling open-ended problems, when existing approaches feel stale, or when you need originality over predictability. Also applies when the
  situation would benefit from exploration, creative play, or divergent thinking --- even if the path forward seems clear, a detour into alternative approaches often reveals better solutions. Do NOT use
  for well-defined implementation tasks where correctness matters more than novelty.
compatibility: claude-code, cursor, opencode, gemini-cli, codex-cli
allowed-tools: bash, read, grep, glob
metadata:
  companion-script: scripts/ideate.sh
  handoffs: idea-refine (to refine ideas), spec-driven-development (to spec)
  trigger-phrases: brainstorm, ideate, generate ideas, come up with, creative ideas, alternatives
  bundle: define
---
# Divergent Ideation

**Companion script:** `scripts/ideate.sh` --- structured ideation prompts and idea capture.
```bash
bash ./scripts/ideate.sh prompt "<topic>"   # generate ideation prompt
bash ./scripts/ideate.sh capture "<idea>"   # capture an idea
```

Generate genuinely novel ideas using LLMs, when convergent thinking would produce predictable results.

Use when: open-ended problems, stale approaches, need for originality. Do NOT use for well-defined implementation tasks where correctness matters more than novelty.

## How It Works

A single LLM call converges to the most probable path. This skill forces divergence through **multiple methods** (not just one), then cross-pollinates across methods, evaluates, and converges.

```
Warm-up -> Diverge (3 methods) -> Cross-pollinate -> Evaluate -> Converge
```

## Step 0: Warm-up --- Play Mode

Do this first. Playfulness directly predicts divergent thinking performance. Pick one, spend 1-2 minutes, no judgment:

- **Absurd improvement**: Take an unrelated object. List 5 ridiculous ways to improve it.
- **Random connection**: Pick a random noun. Force a connection to the problem.
- **Reverse**: State the worst possible outcome, then invert each answer.
- **Child**: What would someone with no domain knowledge build for fun?

## Step 1: Diverge --- Use at Least 2 Different Methods

Use the warm-up session's mode to run the actual divergence. If all ideas feel similar, you only used one method.

### A: Constrained Perspectives
Generate 2-3 approaches, each from a distinct perspective with a unique constraint. The constraint forces divergence --- not the label.

Pick perspectives that pull in opposite directions along the problem's tensions:

| Perspective | Constraint |
|---|---|
| **Hacker** | Minimal resources, maximum speed |
| **Designer** | Delight first, everything else second |
| **Scientist** | First principles, everything falsifiable |
| **Contrarian** | Invert every assumption |
| **Child** | No constraints, no fear, just fun |
| **Alien** | Humanity solved this wrong, start from zero |

Or create your own. The only requirement: a specific, binding constraint.

### B: Lateral Thinking (De Bono)
Pick one technique to use alongside perspectives:

| Technique | How |
|---|---|
| **Random entry** | Pick a random noun -> force connection to the problem |
| **Provocation** | State something impossible -> treat it as real -> derive ideas |
| **Challenge** | Question why things are done this way, even obvious things |
| **Concept extraction** | Extract the core concept from an existing idea -> apply it elsewhere |

### C: Cross-Domain Forcing
Ask "How would this be solved in [domain]?" for at least 2 of:

| Domain | Extract principle of |
|---|---|
| **Biology** | Evolution, symbiosis, emergence |
| **Music** | Rhythm, tension/release, improvisation |
| **Games** | Feedback loops, difficulty curves, addiction |
| **Architecture** | Structure, flow, light, boundaries |
| **Cooking** | Taste, timing, substitution, fermentation |

Turn each extracted principle into a concrete approach.

## Step 2: Cross-pollinate

Pair approaches from **different methods** (e.g. a Hacker approach + a Provocation approach). Method-level hybrids produce more novelty than perspective-level ones.

Produce 2 hybrid concepts. If a hybrid is just a rephrasing, discard it and try a different pair.

## Step 3: Evaluate

Score each hybrid on:

| Axis | 1 | 5 | 10 |
|---|---|---|---|
| **Novelty** | Seen before | Somewhat fresh | Genuinely surprising |
| **Viability** | Impossible | Could work | Straightforward |

Mark the most promising with ★. If nothing scores above 5 on novelty, rerun Step 1 with different methods.

## Step 4: Converge

Develop the ★ hybrid into a creative brief:

1. **Concept:** One sentence
2. **Core tension:** What makes this interesting (e.g. "fast but beautiful --- those usually trade off")
3. **One bet:** The single assumption that must be true
4. **Smallest proof:** Cheapest way to test if it has merit
5. **Risks:** What could go wrong

Output feeds into `spec-driven-development`.

## Common Rationalizations

| Shortcut | Why It Fails |
|---|---|
| "Higher temperature will make it creative" | Temperature adds noise, not novel structure. The model still converges --- just sloppily. |
| "I generated N ideas, that's divergent" | N variations on one approach is not divergence. Use at least 2 different methods. |
| "The first idea was the best" | The first idea is always the most probable path. Divergent thinking requires forcing past it. |
| "I'll just ask the LLM to be creative" | Empty instruction. Without a binding constraint, the model produces the average of its training data. |
| "I'll skip cross-pollination" | Hybridization is where novelty emerges. Pure approaches are rarely surprising. |

## Red Flags

- All ideas feel the same -> you used only one method. Add a different one.
- Warm-up produced better ideas than the main session -> you converged too fast. Spend longer in Step 1.
- You used only perspectives -> perspectives are one method. You need at least two methods.
- The final concept feels safe -> divergent thinking stopped too early. Run Step 1 again with more extreme pairings.
