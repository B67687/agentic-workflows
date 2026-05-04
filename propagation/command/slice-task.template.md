---
description: Break an oversized task into a milestone ladder and first executable slice
---

Use this when the task is too large for one efficient cycle.

Pass the plain task on the same line, like:
`/slice-task recreate a mechanically faithful elemental battlegrounds vertical slice`

First run:
`bash ./task-slice.sh "$ARGUMENTS"`

Then return a compact slice note with:
- a coarse milestone ladder with at most 5 milestones
- the first milestone in enough detail to execute next
- the stop line for what must wait
- the verification target for the first slice
- the next command to use

If the slice output says normal planning is enough, say so briefly and recommend `/start-task $ARGUMENTS` or `/plan $ARGUMENTS`.
