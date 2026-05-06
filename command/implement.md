---
description: Implement only after the plan is clear
---

This is implementation mode.

Only proceed if the task already has enough research and a clear plan. If not, stop and say whether `/research` or `/plan` should happen first.

Run the prompt contract:
`bash ./scripts/prompt-contract.sh "$ARGUMENTS" --phase implement`

Before implementation, run the deterministic preflight:
`bash ./scripts/implement-preflight.sh "$ARGUMENTS"`

If `Implement decision: block`, do not implement. Send the task back exactly one phase.

If `Implement decision: caution`, fix the checkout state first or move the work into a worktree before implementing.

Keep the active context narrow. Execute in small verified slices. Review each change before moving to the next.

Do not silently expand the slice during implementation. If the current slice is no longer the right one, stop and go back to `/plan` or `/shape-milestone`.

After each verified phase:
- update `session-state.json`
- prefer a checkpoint commit
- recommend a new session if the next step changes phase or scope
