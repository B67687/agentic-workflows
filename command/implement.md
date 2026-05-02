---
description: Implement only after the plan is clear
---

This is implementation mode.

Only proceed if the task already has enough research and a clear plan. If not, stop and say whether `/research` or `/plan` should happen first.

Before implementing, enforce the gate:
`bash ./scripts/phase-gate.sh implement --research-done --plan-done --scope-bounded --verification-known`

If the work is upstream-facing, the gate must also include:
`--upstream-facing --contribution-read`

If the gate would fail, do not improvise forward. Stop and send the task back exactly one phase.

Keep the active context narrow. Execute in small verified slices. Review each change before moving to the next.

After each verified phase:
- update `session-state.json`
- prefer a checkpoint commit
- recommend a new session if the next step changes phase or scope
