---
id: harness-workflow-steps
name: Identify and report workflow step structure
type: harness
difficulty: easy
estimated_time: 2min
skills: [workflow-execution, harness-orientation]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for at least 5 step references (the self-improve workflow has 6 steps)
  steps=$(grep -ciE '\b(Step|step|measure_baseline|detect_gaps|generate_proposal|test_on_bench|verify_score_change|decide)\b' "$output" 2>/dev/null || echo 0)
  if [ "$steps" -ge 5 ]; then
    echo "PASS: agent identified $steps workflow elements"
    exit 0
  else
    echo "FAIL: agent identified $steps workflow elements (need >= 5)"
    exit 1
  fi
---

# Task

Read the file `workflow.d/self-improve.yaml` and analyze its workflow structure.

## Instructions

1. Open and read `workflow.d/self-improve.yaml` to understand the self-improving framework workflow.
2. Identify and list all 6 steps in the workflow, describing each step's purpose.
3. Note which steps are `deterministic` vs `deliberative`.
4. Identify the branching logic in the `decide` step.
5. Explain what the `next: null` field means in terms of workflow lifecycle.

**Output format:**

```
## Workflow: self-improve

### Step 1: [step_id] ([kind])
[1-2 sentence description of purpose]

### Step 2: [step_id] ([kind])
...

### Branching: decide step
- keep -> [what happens]
- discard -> [what happens]
- iterate -> [what happens]

### Terminal behavior
[next: null means ...]
```

Output to `output.md`.
