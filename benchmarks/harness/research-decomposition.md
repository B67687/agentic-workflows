---
id: harness-research-decomposition
name: First-principles decomposition of a harness design problem
type: harness
difficulty: medium
estimated_time: 5min
skills: [first-principles-methodology, structured-questioning]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for FP decomposition phases
  entities=$(grep -ciE '\b(entities|components|irreducible|fundamental)\b' "$output" 2>/dev/null || echo 0)
  axioms=$(grep -ciE '\b(reconstruct|axiom|fundamental truth|must be true)\b' "$output" 2>/dev/null || echo 0)
  gap=$(grep -ciE '\b(gap|divergence|reframe)\b' "$output" 2>/dev/null || echo 0)
  total=$(( entities + axioms + gap ))
  if [ "$total" -ge 5 ]; then
    echo "PASS: agent demonstrated FP decomposition ($total markers: entities=$entities axioms=$axioms gap=$gap)"
    exit 0
  else
    echo "FAIL: insufficient FP methodology markers ($total total, need >= 5)"
    exit 1
  fi
---

# Task

Apply first-principles (FP) decomposition to the following harness design problem.

## Problem

"The benchmark runner (`scripts/tools/skill-bench.sh`) requires a separate skill file to run benchmarks, but harness benchmarks don't correspond to any existing skill -- they test the agent's ability to use the harness itself. This creates a circular dependency: you need a skill to benchmark, but the benchmark tests whether you know how to use the harness without a skill."

## Instructions

Use the first-principles decomposition approach (from `AGENTS.md` and `docs/workflow.md`):

### Step 1: Core Entities
Identify the irreducible components of this problem. What are the primitives?

### Step 2: Strip to Fundamentals
What MUST be true for the benchmark system to work? What constraints are negotiable?

### Step 3: Reconstruct from Axioms
Design the simplest approach that satisfies the fundamentals. Don't be constrained by the current implementation.

### Step 4: Gap Analysis
Where does the current implementation diverge from your reconstructed design?

### Step 5: Reframe
What is the minimal change that closes this gap?

**Output format:**

```
## First-Principles Decomposition

### Step 1: Core Entities
- Entity 1: [description]
- Entity 2: [description]
...

### Step 2: Fundamentals
- Fundamental 1: [what must be true]
- Fundamental 2: [what must be true]
...

### Step 3: Reconstructed Design
[2-3 paragraph description of the simplest design that satisfies fundamentals]

### Step 4: Gap Analysis
[Description of where current implementation diverges]

### Step 5: Reframe
[Specific, minimal change proposal]
```

Output to `output.md`.
