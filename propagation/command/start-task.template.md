---
description: Classify a task before starting and choose the right lane
---

Use this command before non-trivial work.

First run:
`bash ./task-intake.sh "$ARGUMENTS"`

Then respond compactly with:
- the recommended lane
- the iteration strategy
- the recommended git lane
- whether editing is safe now
- the next command to use

If the intake output looks too optimistic or too pessimistic, explain why briefly and correct it.

If the recommended lane is `slice-first`, do not jump straight to a full plan. Recommend `/slice-task` and say the task should be broken into a fast first slice.
