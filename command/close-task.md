---
description: Classify and close a resolved, obsolete, or misframed task
---

Use this command when a task is effectively over and should be classified cleanly instead of just fading out.

Pass the outcome and plain task on the same line, like:
`/close-task fixed Tutanota aria2 works with the current Scoop manifest`

Supported outcomes:
- `fixed`
- `obsolete`
- `not-reproducible`
- `wrong-framing`
- `parked`

First run:
`bash ./scripts/close-task.sh $ARGUMENTS`

Then respond compactly with:
- the closure classification
- what must go into `session-state.json`
- what prior path is now dead or obsolete
- whether to archive, delete, or simply stop

If the task is resolved or obsolete, prefer `/close-task` before the final `/checkpoint`.
