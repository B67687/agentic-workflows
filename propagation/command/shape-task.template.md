---
description: Combine intake and grilling into one task-shaping entrypoint
---

Use this only if you explicitly want a shaping-focused answer. In normal work, `/start-task` should already do this job.

Pass the plain task on the same line, like:
`/shape-task figure out the right fix for Tutanota aria2 support in Scoop`

First run:
`bash ./task-intake.sh "$ARGUMENTS"`

Then:
- if the recommended lane is `grill`, return a compact grilling note
- if the goal horizon is `north-star`, return a compact north-star note
- if the recommended lane is `slice-first`, return a compact slice note
- otherwise return the same compact routing output that `/start-task` would give

When you recommend the next command, reuse only the plain task text.
