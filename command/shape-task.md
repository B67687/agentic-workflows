---
description: Combine intake and grilling into one task-shaping entrypoint
---

Use this when you are not sure whether a task needs grilling or can move straight into the normal lane.

Pass the plain task on the same line, like:
`/shape-task figure out the right fix for Tutanota aria2 support in Scoop`

First run:
`bash ./scripts/task-intake.sh "$ARGUMENTS"`

Then:
- if the recommended lane is `grill`, return a compact grilling note
- if the recommended lane is `slice-first`, return a compact slice note
- otherwise return the same compact routing output that `/start-task` would give

When you recommend the next command, reuse only the plain task text.
