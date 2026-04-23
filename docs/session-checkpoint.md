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

### Part A — Session State File (`workflow/session-state.json`)

**On every resume**: Read `workflow/session-state.json` first. Always. Before touching any other file.

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

Checkpoint (update `workflow/session-state.json`) when:

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
2. **Identify** specialist agent (Explorer/Drafter/Debugger/Reviewer)
3. **Spawn** subsession with compressed context + specific task
4. **Receive** result from specialist
5. **Synthesize** and present to user
6. **Discard** subsession context

**User experience:** Seamless. You talk to one agent. Routing happens internally.

### Why This Works

- **Prevents degradation** — Fresh context each subtask
- **Saves tokens** — Specialist models are cheaper for their domain
- **Maintains momentum** — Compressed summary preserves continuity

---

## Checkpoint Workflow

### Starting a New Multi-Phase Task

1. Read `workflow/session-state.json` (orient)
2. Write updated `workflow/session-state.json` (checkpoint)
3. Start work
4. Update `session-state.json` after each phase
5. BEFORE any heavy operation → write state

### After an Interrupt

1. Read `workflow/session-state.json` FIRST (not AGENTS.md, not docs)
2. Review state — understand where work stopped
3. Update status + interrupted_count
4. Continue from next_action

### Completing a Session

1. Update `session-state.json` with final status
2. Add any durable learnings to key_context
3. Leave status as "complete" — next session sees it and starts fresh

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

- `workflow/session-state.json` — active session state (always exists during work)
- `workflow/session-state.template.json` — blank template for new sessions