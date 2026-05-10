---
description: Subagent-driven pipeline — dispatch each plan task to an isolated @worker subagent
---

## When to use

Use this when a plan has 3+ well-defined, independent tasks that can be implemented in isolation. Each task gets its own fresh subagent context. The pipeline orchestrates: dispatch → implement → review → integrate.

Do NOT use for:
- Single-file changes (just use `/implement` directly)
- Tightly coupled tasks that share deep context (one `/implement` session is better)
- Exploration or research (use `/research` instead)

## How it works

```
1. You have a plan with explicit tasks (from /plan)
2. Run /pipeline to create the pipeline state
3. Agent spawns a @worker subagent per task
4. Each worker implements in isolation
5. Agent reviews worker output, updates state
6. After all tasks: completion summary
```

## Usage

**Step 1: Init (create pipeline state from plan)**

`bash ./scripts/pipeline-run.sh init "Plan title" "Task 1 description" "Task 2 description"`

Run this with the task descriptions from your `/plan` output.

Then for each task, **loop**:

**Step 2: Get next task**

`bash ./scripts/pipeline-run.sh next <pipeline-id>`

This marks the next pending task as "in-progress" and prints the task details.

**Step 3: Dispatch to subagent**

Use the `task` tool to spawn a `@worker` subagent:

```
Task(description="implement step N", prompt="...", subagent_type="worker")
```

The worker prompt must include:
- The task description (from the pipeline state)
- The files to modify (from the plan)
- The verification target (from the plan)
- Constraints: "Implement only this task. Do not expand scope."

**Step 4: Review and update**

After the worker returns:

1. Read the worker's output (files changed, verification results)
2. Verify against the plan's spec and verification target
3. Run: `bash ./scripts/pipeline-run.sh update <pipeline-id> <task-id> done|failed "notes"`

If the task failed, add detailed failure notes. The pipeline will enter "blocked" state.

**Step 5: Continue or resolve**

- If success: repeat from Step 2
- If failed: either fix the task and retry, or skip it

**Step 6: Pipeline complete**

When all tasks are done or resolved, report the completion summary with:
- Files created/modified per task
- Verification results per task
- Any tasks that were skipped or had issues
- Whether the pipeline was fully autonomous or needed intervention

## State management

Pipeline state lives in `.pipeline/<pipeline-id>.json`. Use these commands:

| Command | Function |
|---|---|
| `pipeline-run.sh list` | Show all pipelines |
| `pipeline-run.sh status <id>` | Show detailed pipeline status |
| `pipeline-run.sh update <id> <task> <status>` | Update task status |
| `pipeline-run.sh next <id>` | Get the next pending task |

## When it goes wrong

- **Worker returns bad code:** Set task status to "failed" with notes. Spawn a new worker or fix manually.
- **Task is no longer needed:** Set to "skipped" via update command.
- **Pipeline is blocked:** Investigate the failed task, fix, set status back to "pending", continue.
- **Context pressure in main session:** Use `/session checkpoint` to save before continuing the pipeline.
