---
description: Break a large goal into a coarse domain, milestone, and slice tree
---

Use this when the goal is too large to hold in one line and needs a map of workstreams before choosing the first milestone.

Pass the plain goal on the same line, like:
`/task-tree recreate Elemental Battlegrounds faithfully enough to preserve the nostalgia and play feel`

First run:
`bash ./scripts/task-tree.sh "$ARGUMENTS"`

Then return a compact decomposition tree with:
- the one-line goal
- the major domains
- first milestone candidates per domain
- dependency order
- the recommended first milestone
- the recommended first slice
- the next command to use

Keep the tree coarse. Detail only the recommended first slice.
