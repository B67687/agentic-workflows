# Workflow Definition Schema (v1)

> A YAML-based state machine format for session-scoped workflow execution.
> Each file in `workflow.d/` defines one workflow as an ordered list of steps.
> The agent reads the current workflow at session start, advances through steps,
> and persists state to `workflow-state.json`.

---

## File Format

```yaml
# workflow.d/<name>.yaml

id: <string>              # unique workflow identifier
description: <string>     # what this workflow does
next: <path>              # optional — next workflow to propose on completion

steps:
  - id: <string>          # unique step identifier within this workflow
    kind: deterministic | deliberative | parallel
    script: <path>        # only for deterministic — path relative to repo root
    description: <string> # what this step does (for the agent)
    sub_steps:            # only for parallel — list of sub-steps to run concurrently
      - id: <string>      # unique sub-step identifier within this step
        script: <path>    # path to the script (deterministic only for now)
        description: <string>
    merge_with: <path>    # optional, only for parallel — script that combines sub-step results
    branches:             # optional — only for branching workflows
      <result>: <target>  # result → next step id or "workflow/<name>.yaml"
```

## Rules

1. **Linear by default.** If a step has no `branches`, the agent advances to the next step in the list on completion.
2. **Deterministic steps** run a script, capture stdout as `result`. The agent does not converse — it executes, reads, advances. Do not read the script first or second-guess it. If it fails, capture the error and let branches handle it.
3. **Deliberative steps** have no script. The agent reasons, proposes options, and goes back and forth with the user until consensus. The `result` is the agreed outcome. Do not advance without confirmation.
4. **Branches** replace the linear advance. The agent matches the step result against branch keys and follows the target (next step id or another workflow file).
5. **Parallel steps** fan out sub-steps concurrently. The agent calls `scripts/workflow/parallel-dispatch.sh` with the sub-step definitions as JSON. The dispatcher runs all sub-step scripts in parallel (`&` + `wait`), captures stdout per sub-step, and runs the `merge_with` script if specified. The merged output is the step result.
6. **Context passing.** The agent writes step results to `workflow-state.json` under `context`. Subsequent steps read from context to know what to do.
7. **Resume.** If `workflow-state.json` has an active workflow at session start, the agent resumes at the current step instead of reading root.
8. **Completion proposes next.** When all steps complete, check `next:`. If set, the agent proposes to the user: "X is done. Proceed to Y?" User authorizes or redirects. This keeps the cycle flowing without re-entering root.
9. **Default to the simpler approach.** When choosing between two implementations, pick the one with fewer moving parts. Add complexity only when evidence proves it's necessary. A POC with the simple approach always comes before generalizing.
10. **Prove it with a POC.** Before adding a new mechanism to the workflow schema, implement it for one phase as a concrete proof of concept. If it works, generalize it. If it doesn't, discard it. No speculative abstractions.

## Step Lifecycle

```
1. Agent reads current step from workflow-state.json
2. If deterministic: run script, capture output
   If deliberative: reason, propose, back-and-forth until consensus
   If parallel: run parallel-dispatch.sh with sub_steps JSON; capture merged output
3. Save result to workflow-state.json (context + trace entry)
4. If branches: follow matching branch
   Else: advance to next step in list
5. If no steps remain:
     If next: propose next workflow to user. User authorizes → load next.
     Else: mark workflow complete, report summary.
```

## Phase Cycle

The default cycle for complex tasks:

```
research  →  design  →  implement  →  verify  →  done
                ↑                              │
                └──────── needs_fixes ──────────┘
```

Each phase proposes the next. The user authorizes transitions. Unless the user rejects, the cycle completes naturally. The agent drives the process; the user steers.
