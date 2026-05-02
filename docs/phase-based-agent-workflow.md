# Phase-Based Agent Workflow

This workspace uses one default execution shape for non-trivial tasks:

**Research -> Plan -> Implement**

Default entrypoint:

- start with `/grill your task` when the request is broad, underspecified, or high-cost to misunderstand
- start with `/start-task your task`
- use direct handling only when the task is truly small and obvious

## Phase 1: Research

Goal: understand the system before changing it.

During research:

- read the startup files first
- prefer `/research your task` when command shortcuts are available
- use `bash ./scripts/retrieve-context.sh "query"` to pull only relevant local context
- identify exact files, dependencies, and edge cases
- do not implement yet

Expected output:

- the exact files involved
- the important lines or functions
- the data flow or dependency flow
- the main risks and edge cases

## Phase 2: Plan

Goal: turn research into explicit steps.

During planning:

- prefer `/plan your task` when command shortcuts are available
- define the exact files that will change
- define the tests or verification for each step
- define what should not change
- define rollback or recovery points when relevant

Expected output:

- a step-by-step plan
- verification commands
- clear scope boundaries

## Phase 3: Implement

Goal: execute the plan in small verified slices.

During implementation:

- prefer `/implement your task` when command shortcuts are available
- run `bash ./scripts/phase-gate.sh implement ...` or let `/implement` enforce the same gate
- follow the plan instead of improvising broadly
- keep the active context narrow
- review each change before moving on
- commit after verified phases

Expected behavior:

- small reversible edits
- frequent checkpointing
- new session when the phase changes or context quality drops

## Task Intake Rule

Use a compact intake before non-trivial work:

- what is the goal
- what is in scope
- what kind of change is this
- what proves success
- what lane should this start in

Use direct handling only when all of these are true:

- the request is clear
- the scope is small
- the files are obvious
- verification is simple
- the task does not need a deeper system read first

Otherwise, start in research.

## Grill Rule

Use `/grill` before research when:

- the request has multiple possible interpretations
- wrong assumptions would create a lot of wasted code
- the task is expensive, architectural, or upstream-facing

The goal is to sharpen scope, expose hidden assumptions, and reduce waste before deeper execution starts.

## Phase Gate Rule

Implementation should stop and refuse to proceed when:

- the key files are still unclear
- verification is still unclear
- the scope is still mixed or changing
- the plan is still missing
- contribution guidance has not been read for upstream-facing work

When blocked, go back exactly one phase instead of improvising forward.

## Session Boundary Rule

One task per session is the default.

Use `bash ./scripts/session-boundary.sh` to decide when to:

- or use `/session-boundary` for the shortcut form

- continue
- checkpoint now
- checkpoint and restart in a new session

Restart when:

- the phase changes
- the topic shifts
- quality drops
- the thread gets long
- context meter is clearly too full

Do not keep trying to rescue a degraded thread if a fresh one would be cleaner.

## Checkpoint Rule

After a verified phase:

- update `session-state.json`
- use `/checkpoint` when you want a compact wrap-up
- prefer a checkpoint commit before a risky next phase
