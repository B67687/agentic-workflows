---
description: Wrap up a verified phase and decide whether to restart
---

This command is for the end of a phase.

First, decide whether the phase should continue or restart by using:
`bash ./session-boundary.sh $ARGUMENTS`

Then inspect the current diff with:
`git status --short`

Then respond compactly with:
- what was completed
- what must go into `session-state.json`
- whether a checkpoint commit is appropriate now
- whether the next step should start in a new session

If the phase is verified and the diff is coherent, recommend or run:
`bash ./checkpoint-commit.sh -m "checkpoint summary"`
