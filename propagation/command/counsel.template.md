---
description: Decide whether a multi-perspective review should help before committing to a direction
---

Use this for product shaping, milestone selection, architecture review, optimization review, or decisions that are expensive to misunderstand.

Pass the plain decision or task on the same line, like:
`/counsel decide the first playable milestone for the Elemental Battlegrounds recreation`

First run:
`bash ./counsel-gate.sh "$ARGUMENTS"`

If counsel is needed and the user asks about model choice, run:
`bash ./counsel-model-select.sh lite`

Then return a compact counsel note with:
- whether counsel is needed
- the roles to use if needed
- the decision being reviewed
- the strongest supporting view
- the strongest objection
- the missing facts
- the compressed recommendation
- the next command to use

Do not use counsel for ordinary implementation unless the work is already split into separate bounded worktree tasks.
