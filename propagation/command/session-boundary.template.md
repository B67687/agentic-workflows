---
description: Decide whether to continue, checkpoint, or restart the current task
---

Use the repo's session-boundary helper.

Treat `$ARGUMENTS` as the shorthand form for:
- phase: `research`, `plan`, `implement`, or `review`
- turns: a number like `9`
- flags: `verified`, `phase-change`, `topic-shift`, `quality-drop`, `task-complete`, `meter-over-50`

Run:
`bash ./session-boundary.sh $ARGUMENTS`

Return only:
- the decision
- the reason
- the next action

If `$ARGUMENTS` is empty, infer from the current phase and recent thread state as best you can, then run the helper with explicit flags.
