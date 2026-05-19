---
id: harness-workflow-state
name: Manage workflow state through a multi-step scenario
type: harness
difficulty: hard
estimated_time: 6min
skills: [workflow-execution, state-management]
verification: |
  output="$RUN_DIR/output.md"
  if [ ! -f "$output" ]; then echo "FAIL: no output file at $output"; exit 1; fi
  # Check for state management understanding
  workflow_ref=$(grep -ciE '\b(workflow-state\.json|workflow\.d|state|trace|step)\b' "$output" 2>/dev/null || echo 0)
  scenario_ref=$(grep -ciE '\b(startup|resume|fresh|stale|classify|root)\b' "$output" 2>/dev/null || echo 0)
  decision=$(grep -ciE '\b(decision|branch|deterministic|deliberative)\b' "$output" 2>/dev/null || echo 0)
  total=$(( workflow_ref + scenario_ref + decision ))
  if [ "$total" -ge 8 ]; then
    echo "PASS: agent demonstrated workflow state management ($workflow_ref state refs, $scenario_ref scenario refs, $decision decision refs)"
    exit 0
  else
    echo "FAIL: insufficient state management analysis ($total markers, need >= 8)"
    exit 1
  fi
---

# Task

Simulate managing workflow state through a complex multi-step scenario.

## Scenario

You are an agent managing the `self-improve` workflow defined in `workflow.d/self-improve.yaml`. The session plays out as follows:

1. **Session A  --  Morning**: You start a fresh session. You run the startup gate, classify the request as "run self-improve cycle", and start the workflow.
2. **Step 1 (measure_baseline)** completes  --  output saved to context.
3. **Step 2 (detect_gaps)**  --  you present the gap analysis to the user. They say "focus on coverage gaps." The step is deliberative so you reach consensus.
4. **Session B  --  Afternoon**: You come back after lunch. The session is fresh.
5. **Step 3 (generate_proposal)**  --  you generate a proposal for the coverage gaps.
6. **Step 4 (test_on_bench)**  --  you run the proposal. It fails because the benchmark runner can't find the benchmark path.
7. The user says "fix the path and retry."
8. **Step 5 (verify_score_change)**  --  the fix works. Scores are unchanged.
9. **Step 6 (decide)**  --  scores are unchanged -> iterate. You loop back to step 2.

## Instructions

For each stage, describe:

### a) Workflow State
What would `workflow-state.json` contain? What step is active? What's in the trace?

### b) Startup Behavior (Session B)
When Session B starts fresh, what happens? How does the workflow runtime detect and resume the active workflow? What does the stale check detect?

### c) Branching & Transitions
For each step transition, identify whether it's deterministic or deliberative. What triggers advancement?

### d) Edge Cases
- What happens if the user exits mid-deliberation (during Step 2, before consensus)?
- What happens if `test_on_bench` fails with a non-zero exit code?
- After the `decide` step branches to `iterate: detect_gaps`, how does the workflow runtime handle the loop?

**Output format:**

```
## Workflow State Management Simulation

### Stage 1: End of Session A (after Step 2 consensus)
- Active step: [step_id]
- Trace: [step1, step2]
- Context: [...]

### Stage 2: Session B Startup
- Fresh detection: [how runtime detects fresh session]
- Resume mechanism: [how workflow restores active workflow]
- Stale check: [whether context is stale and why/why not]

### Stage 3: Through the Pipeline
[Step-by-step progression through steps 3-6]

### Stage 4: Edge Cases
- Early exit: [handling]
- Script failure: [handling]
- Branch loop: [handling]

### Summary: Key Principles
[3-4 key takeaways about workflow state management]
```

Output to `output.md`.
