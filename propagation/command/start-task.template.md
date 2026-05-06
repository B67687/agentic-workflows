---
description: Classify a task before starting and choose the right lane
---

Use this as the default first command for any serious task.

This command is the intake layer. For normal-language requests, prefer `/route` first so mapping and next-action selection happen together.

First run:
`bash ./task-intake.sh "$ARGUMENTS"`

Then respond compactly with:
- the recommended lane
- the goal horizon
- the iteration strategy
- the recommended git lane
- whether editing is safe now
- the next command to use

Prefer one next command or one immediate action. Do not return a menu unless the user needs to choose between materially different paths.

If the intake output looks too optimistic or too pessimistic, explain why briefly and correct it.

If the recommended lane is `grill`, return a compact grilling note.

If the goal horizon is `north-star`, route to `/shape-product` first so the intended product experience is grilled and compressed before milestone shaping.

If the recommended lane is `slice-first`, do not jump straight to a full plan. Return a compact slice note or recommend `/shape-milestone` when the task is a long-horizon goal.
