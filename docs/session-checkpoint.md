# Session Checkpoint System

## The Problem

Any multi-step task in this workspace hits a recurring wall:

1. Complex task starts
2. Hits context limit mid-execution
3. Has to resume — re-reads the world (~110k tokens)
4. Hits limit again faster
5. Repeat

Session state file + proactive checkpointing breaks this cycle.

---

## The Solution: Two-Part System

### Part A — Session State File (`session-state.json`)

**On every resume**: Read `session-state.json` first. Always. Before touching any other file.

```
Cost: ~500 tokens
vs re-reading all docs: ~110k tokens
```

The state file tells you:
- What was being worked on
- What phase
- What comes next
- Files created/modified
- Decisions made

### Part B — Proactive Checkpointing

**Rule**: Before starting any multi-phase task OR any operation that generates large context (bulk fetches, large analyses):

> Write session-state.json BEFORE. Not after.

---

## Checkpoint Trigger Conditions

Checkpoint (update `session-state.json`) when:

| Condition | Why |
|-----------|-----|
| Before multi-phase task | Ensures recovery point exists |
| Before bulk fetches (5+ parallel) | Fetches are high-context; interrupts are likely |
| After completing any phase | Marks progress recoverable |
| At 50% context estimate | Proactive — before you feel pressure |
| After interrupt | Don't skip — state is now stale |
| **Every 10 turns** | **Prevent quadratic token growth in long threads** |
| **Topic shift detected** | **Fresh context for new domain** |

---

## Warm Handoff Protocol (Session 42)

For agentic workflows: when context pressure builds, compress and handoff to a fresh subsession.

### Handoff Triggers

| Signal | Action |
|--------|--------|
| 10+ turns in thread | Proactively suggest handoff |
| Topic shifts | Compress + spawn fresh subsession |
| Model repeats itself | Immediate handoff |
| Output quality drops | Compress + restart |

### Compression Template

```
Previous work summary (5 lines max):
1. [Accomplished]
2. [Decisions]
3. [Current state]
4. [Blockers]
5. [Next task]

Continue with: [specific next step]
```

### Subsession Spawning

When the Orchestrator detects a subtask:

1. **Compress** current context to 5-line summary
2. **Identify** the lane (direct, Explorer, Worker, or specialized model)
3. **Spawn** subsession with compressed context + specific task
4. **Receive** result from specialist
5. **Synthesize** and present to user
6. **Discard** subsession context

**User experience:** Seamless. You talk to one agent. Routing happens internally.

### Why This Works

- **Prevents degradation** — Fresh context each subtask
- **Saves tokens** - Fresh packets avoid replaying stale context
- **Maintains momentum** — Compressed summary preserves continuity

---

## Runtime-Style Health Probe

After resume, compaction, or a fresh-context handoff, do a small read-only probe before risky work.

Good probes:

- `git status --short` to confirm the worktree shape
- `rg --files` or `rg "known-pattern"` to confirm expected files are visible
- a targeted test discovery command, not a full expensive suite
- reading the exact state or handover file that should govern the next action

Stop and re-plan if the probe shows:

- expected files are missing or moved
- the worktree has unexpected conflicting edits
- the shell/tool environment is broken
- the next action no longer matches the recorded state

The point is simple: never make the first post-compaction action a delete, bulk move, broad rewrite, or permission expansion.

---

## Checkpoint Payload Standard

A useful checkpoint preserves the runtime facts needed to continue without re-reading the world:

- task name and current phase
- files changed or intentionally left untouched
- commands/tests already run and their result
- active assumptions and decisions
- allowed write scope or destructive boundary
- next concrete action
- residual risk and what would prove it wrong

For long or automated work, also record:

- whether the last phase was discovery, implementation, verification, or cleanup
- any deferred artifacts or large-output paths
- any permission/tooling constraint that affected the result
- whether a fresh-context handoff is recommended

---

## Checkpoint Workflow

### Starting a New Multi-Phase Task

1. Read `session-state.json` (orient)
2. Run the repo probe if this is a code repo: `bash ./scripts/git-session-start.sh`
3. Write updated `session-state.json` (checkpoint)
4. Start work
5. Update `session-state.json` after each phase
6. BEFORE any heavy operation → write state

### After an Interrupt

1. Read `session-state.json` FIRST (not AGENTS.md, not docs)
2. Review state — understand where work stopped
3. Update status + interrupted_count
4. Continue from next_action

### Completing a Session

1. Update `session-state.json` with final status
2. Add any durable learnings to key_context
3. Leave status as "complete" — next session sees it and starts fresh

### Closure Classification

When a task ends, do not leave the outcome vague.

Use `/close-task` to classify the result as one of:

- `fixed`
- `obsolete`
- `not-reproducible`
- `wrong-framing`
- `parked`

This should record:

- what the real question turned out to be
- what answer was reached
- what prior branch or implementation path is now dead
- whether the leftovers should be archived, deleted, or just left alone

If the task is truly over, you can use `/finish-task` to run closure classification and checkpoint review together in one step.

### Verified-Phase Commit Cadence

Checkpoint files are not enough when the worktree stays dirty for hours. After a meaningful phase is both implemented and verified:

1. Review the diff
2. Make one small logical commit
3. Update `session-state.json` with the commit boundary and what comes next

If you deliberately do **not** commit yet, record why:

- waiting for one more verification pass
- mixed unrelated changes still need to be split
- user explicitly asked to avoid commits for now

Best practice:

- commit after a verified fix or completed phase
- do not mix unrelated changes in one commit
- do not leave a huge dirty worktree as the default operating mode
- if a session ends with uncommitted work, the next session should immediately know why
- use `bash ./scripts/checkpoint-commit.sh -m "checkpoint summary"` in the hub or `bash ./checkpoint-commit.sh -m "checkpoint summary"` in a managed topic repo when the phase is ready
- if the next phase is risky or separate, checkpoint first and then move it into a worktree branch

### After Two Failed Attempts

If the same fix path or investigation loop fails twice:

1. Stop making edits
2. Update session state with what failed
3. Rebuild the hypothesis list from evidence
4. Either narrow the task, switch to fresh context, or ask for a higher-quality review lane

### After Two Planning Rounds

If the same task has already gone through two planning refinements:

1. Stop asking for a broader or more perfect plan
2. Record the current slice boundary in `session-state.json`
3. Choose one next executable slice
4. Either research the one missing fact or implement the ready slice

The point is to preserve fast iteration. Planning is there to unblock execution, not replace it.

---

## Quick Reference

| Situation | Action |
|-----------|--------|
| Starting fresh | Read session-state.json |
| Starting multi-phase work | Write state BEFORE |
| After each phase | Update state |
| At 50% context | Update state |
| After interrupt | Read state → update status → continue |
| Session done | Write final state |
| Lost / confused | Read session-state.json |

---

## Context Pressure Signs

Even without token counts, these signal rising pressure:

- **Low (~20%)**: Normal output, fluent responses
- **Medium (~40%)**: Responses getting slightly more generic
- **High (~60%)**: Repeating explanations, losing track of done items
- **Critical (~80%)**: Output quality drops noticeably

**Checkpoint trigger**: Write state at medium. Heavy operations only after writing state.

**Recovery shortcut**: Instead of re-reading many files, run:
- `bash ./scripts/search-index.sh "task keywords"` — ranked retrieval of relevant docs
- `bash ./scripts/repo-map.sh --max-tokens 512` — quick orientation map

---

## Anti-Patterns

- ❌ Waiting until context is critical to checkpoint
- ❌ Writing state after the problem instead of before
- ❌ Re-reading full workspace docs on every resume
- ❌ Not updating state after an interrupt (stale state is worse than no state)

---

## Template: Session State Update

```
## Session State Update — YYYY-MM-DD HH:MM

**Task**: [brief name]
**Phase**: [phase X of Y]
**Status**: [in_progress | complete | interrupted]

**What just happened**:
- [Completed step]

**What comes next**:
- [Next step]

**Context pressure**: [low | medium | high | critical]
**Files modified**: [list]

**Risks / Notes**:
- [Anything the next session needs to know]
```

---

## Files

- `session-state.json` — active session state (always exists during work)
- `workflow/session-state.template.json` — blank template for new sessions
