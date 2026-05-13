---
description: Session lifecycle --- checkpoint, handoff, boundary, close, and finish
---

## Session Fork (isolated worktree for parallel work)

Use this before starting a new task. Creates an independent worktree directory + branch so you can work in multiple sessions without file conflicts.

Run:
`bash ./scripts/session-fork.sh "task-name"`

Creates a new branch `s<id>-<slug>` and worktree at `../.worktrees/<repo>/<branch>/`.
Copies session-state.json into the worktree.

Then `cd` to the worktree path and open a new OpenCode session there. The main checkout stays clean.

To close a worktree session:
`bash ./scripts/session-fork.sh --close` (run from inside the worktree)

To see active worktrees:
`bash ./scripts/session-fork.sh --list`

To prune closed/merged session branches:
`bash ./scripts/session-fork.sh --cleanup`

## Context Save (capture working state for resume)

Use this before ending a session mid-task, or when context pressure is high and you might lose state.

Run:
`bash ./scripts/context-save.sh "summary of current progress"`

Saves: git branch, dirty files, pending decisions, freeze restrictions. Later resume clears saved context automatically.

## Context Restore (resume from a saved snapshot)

Use this in a new session to restore working context saved by context-save.

Run:
`bash ./scripts/context-restore.sh $ARGUMENTS`

With no arguments, lists available contexts with timestamps and summaries. Pass a context ID to restore:
`bash ./scripts/context-restore.sh 20260510_143022`

Respond compactly with: saved branch, dirty files count, whether freeze is active, and the next recommended action.

## Session Boundary (decide continue, checkpoint, or restart)

Use the repo's session-boundary helper when you need to decide whether to continue, checkpoint, or restart.

Run:
`bash ./scripts/session-boundary.sh $ARGUMENTS`

If `$ARGUMENTS` is empty, infer from the current phase and recent thread state as best you can, then run the helper with explicit flags (`phase`, `turns`, `verified`, `phase-change`, `topic-shift`, `quality-drop`, `task-complete`).

Return only: the decision, the reason, and the next action.

## Handoff (when work continues in a new session)

Use this before a new session, after compaction pressure rises, or when a phase ends but work is not fully done.

Run:
`bash ./scripts/handoff.sh "$ARGUMENTS" --phase unknown --turns 0`

Return a compact handoff packet with: goal, current phase, verified so far, key decisions, open risks, exact files, next command.
Keep the packet short. Preserve only what the next session needs.

## Checkpoint (wrap up a verified phase)

Use this at the end of a phase. If the task is actually over, obsolete, or misframed, use Close Task first so the ending gets classified cleanly.

First, run the pre-compact snapshot to preserve working context:
`bash ./scripts/hooks/pre-compact.sh`

Then run the deterministic checkpoint review:
`bash ./scripts/checkpoint-review.sh $ARGUMENTS`

Then respond compactly with: what was completed, what must go into session-state.json, whether a checkpoint commit is appropriate now, and whether the next step should start in a new session.

If the review says `Checkpoint commit ready: yes`, run immediately:
`bash ./scripts/checkpoint-commit.sh -m "checkpoint summary"`

Do not ask. Commit is the default action after a verified phase, not a suggestion.

After checkpoint commit (or if deferring), run the post-compact restoration reminder:
`bash ./scripts/hooks/post-compact.sh`

## Close Task (classify and close a resolved task)

Use this when a task is effectively over and should be classified cleanly. Supported outcomes: `fixed`, `obsolete`, `not-reproducible`, `wrong-framing`, `parked`.

Run:
`bash ./scripts/close-task.sh $ARGUMENTS`

Then respond compactly with: the closure classification, what must go into session-state.json, what prior path is now dead or obsolete, and whether to archive, delete, or simply stop.

If the task is resolved or obsolete, prefer Close Task before the final Checkpoint.

## Finish Task (close + checkpoint in one step)

Use this when a task is truly over and you want both closure classification and checkpointing in one command.

Run:
`bash ./scripts/finish-task.sh $ARGUMENTS`

Then respond compactly with: the closure classification, what must go into session-state.json, what prior path is now obsolete, whether a checkpoint commit is appropriate now, and whether the next step should be archive, delete, or stop.

## Safety Scope (freeze edit boundaries)

Use these during debugging or sensitive work to prevent accidental edits outside scope.

**Freeze (restrict edits to one directory):**
`bash ./scripts/freeze.sh $ARGUMENTS`

If `$ARGUMENTS` is empty, ask for the allowed directory in one sentence. Creates `.gstack-freeze` at repo root. While this file exists, you MUST NOT edit files outside that directory.

**Unfreeze (remove the restriction):**
`bash ./scripts/unfreeze.sh`

Removes `.gstack-freeze`. Always confirm with the user before unfreezing if there are active edits in progress.

<rationalizations>
| Shortcut | Why It Fails |
|---|---|
| "I'll commit at the end" | Large commits hide bugs and make rollback impossible. Commit each verified phase. |
| "No need to checkpoint --- I'll remember" | Sessions degrade. session-state.json is the durable record. |
| "The task just faded out, no need to classify" | Unclassified tasks leave stale state. Always close or park explicitly. |
| "I can hand off by summarizing in chat" | Chat summaries degrade over handoffs. Use the structured handoff packet. |
</rationalizations>

<red_flags>
- Leaving the session without updating session-state.json
- Ending a task without classifying it as fixed/obsolete/wrong-framing
- Handing off without a structured packet
- Skipping the checkpoint commit because "it's just a small change"
</red_flags>
- Context degraded but continuing instead of restarting