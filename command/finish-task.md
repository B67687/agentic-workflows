---
description: Combine task closure and checkpointing into one ending step
---

Use this when a task is truly over and you want one command for both closure classification and checkpointing.

Pass the outcome and plain task on the same line, like:
`/finish-task fixed Tutanota aria2 works with the current Scoop manifest`

First run:
`bash ./scripts/finish-task.sh $ARGUMENTS`

Then respond compactly with:
- the closure classification
- what must go into `session-state.json`
- what prior path is now obsolete
- whether a checkpoint commit is appropriate now
- whether the next step should be archive, delete, or simply stop
