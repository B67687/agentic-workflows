---
description: Wrap up a verified phase and decide whether to restart
---

This command is for the end of a phase.

First, run the deterministic checkpoint review:
`bash ./scripts/checkpoint-review.sh $ARGUMENTS`

Then respond compactly with:
- what was completed
- what must go into `session-state.json`
- whether a checkpoint commit is appropriate now
- whether the next step should start in a new session

If the review says `Checkpoint commit ready: yes`, recommend or run:
`bash ./scripts/checkpoint-commit.sh -m "checkpoint summary"`
