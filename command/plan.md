---
description: Turn the researched task into an explicit implementation plan
---

This is planning mode only.

Use the existing research context if it is already good. If not, say that research is incomplete and stop.

Before planning, run:
`bash ./scripts/plan-guard.sh "$ARGUMENTS"`

If the guard says `Plan decision: go-back`, stop and send the task back exactly one phase.

If the guard says `Plan decision: first-slice-only` or `Plan decision: stop-refining`, do not produce a giant end-to-end plan. Produce only:
- a coarse milestone ladder with at most 5 milestones
- one detailed next slice
- at most 5 steps for that slice
- the verification target for that slice
- the next command to use

Do not implement yet.

Return a compact plan with:
- the exact files that should change
- the step-by-step sequence
- the verification command or check for each step
- what is explicitly out of scope
- where to checkpoint or restart between phases
