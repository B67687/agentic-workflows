---
description: Create a compact continuation packet for a new session or phase handoff
---

Use this before a new session, after compaction pressure rises, or when a phase is ending but the work is not fully done.

Pass the plain task on the same line, like:
`/handoff recreate Elemental Battlegrounds faithfully enough to preserve the nostalgia and play feel`

First run:
`bash ./handoff.sh "$ARGUMENTS" --phase unknown --turns 0`

Then return a compact handoff packet with:
- goal
- current phase
- verified so far
- key decisions
- open risks
- exact files
- next command

Keep the packet short. Preserve only what the next session needs.
