# Phase-Based Agent Workflow

This workspace uses one default execution shape for non-trivial tasks:

**Think big -> bet medium -> execute tiny**

```mermaid
flowchart LR
    A["North Star"] --> B["Milestone Bet"]
    B --> C["Next Executable Slice"]
    C --> D["Research"]
    D --> E["Plan"]
    E --> F["Implement"]
    F --> G["Verify"]
    G --> H["Checkpoint"]
    H --> C
```

Default entrypoint:

- start with `/grill your task` when the request is broad, underspecified, or high-cost to misunderstand
- start with `/start-task your task`
- start with `/north-star your goal` when the task is a long-horizon dream or preservation target
- start with `/shape-milestone your goal` when the big goal is known but the next meaningful bet is not
- start with `/slice-task your task` when the task is obviously too large for one fast cycle
- use direct handling only when the task is truly small and obvious

## Iteration Strategy

The default strategy is fast iteration with feedback, not giant one-shot execution.

For oversized tasks:

- build a coarse milestone ladder
- detail only the next executable slice
- verify that slice
- checkpoint
- repeat

Do not try to fully finish a broad system in one plan or one session by default.

## Planning Levels

There are three planning levels, and they should not be mixed.

```mermaid
flowchart TD
    A["North Star"] --> A1["Why this large goal matters"]
    A --> A2["What must feel faithful or true"]
    A --> A3["What success would prove"]

    B["Milestone Bet"] --> B1["One meaningful bounded capability"]
    B --> B2["1-3 slice appetite"]
    B --> B3["What is explicitly not now"]

    C["Next Slice"] --> C1["3-5 concrete steps"]
    C --> C2["One verification target"]
    C --> C3["One checkpoint boundary"]
```

North Star should stay large. Milestone should stay bounded. Slice should stay concrete.

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
- for large tasks, prefer milestone ladder plus first-slice planning instead of full end-to-end detail
- define the exact files that will change
- define the tests or verification for each step
- define what should not change
- define rollback or recovery points when relevant

Expected output:

- a step-by-step plan
- verification commands
- clear scope boundaries

## Anti-Paralysis Rule

Planning should not loop forever.

If the same task has already gone through two planning refinements:

- stop broadening the plan
- choose the next verified slice
- move back toward `/research` for the missing fact or `/implement` for the ready slice

The plan only needs to be good enough for the next fast cycle, not perfect for the whole project.

```mermaid
flowchart LR
    A["Ask for a better plan"] --> B{"Already refined twice?"}
    B -->|No| C["Refine once more"]
    B -->|Yes| D["Stop broadening"]
    D --> E["Choose next slice"]
    E --> F["Research missing fact or implement"]
```

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

For serious tasks, treat `/start-task` as the implicit default even if the user does not explicitly ask for task shaping first.

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

## Optimization Lane

Optimization is a separate lane, not casual cleanup.

```mermaid
flowchart TD
    A["Optimization idea"] --> B{"Evidence?"}
    B -->|Aesthetic discomfort only| C["Wait"]
    B -->|Observed bottleneck| D["Optimize at smallest useful level"]
    B -->|Predicted hard-to-reverse architectural risk| E["Do bounded architecture review"]

    D --> F["Measure before/after"]
    E --> G["Shape explicit architecture bet"]
```

Use `/optimize` when the task is really about performance, efficiency, or architecture cost.
