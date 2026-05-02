# Phase-Based Agent Workflow

This workspace uses one default execution shape for non-trivial tasks:

**Research -> Plan -> Implement**

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
- follow the plan instead of improvising broadly
- keep the active context narrow
- review each change before moving on
- commit after verified phases

Expected behavior:

- small reversible edits
- frequent checkpointing
- new session when the phase changes or context quality drops

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
