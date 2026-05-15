---
version: "1.0"
constitution_gates: "plan implement"
articles:
  - "II"
  - "IV"
  - "V"
  - "VI"
  - "VIII"
type: "tasks"
---

# [PROJECT] — Task Decomposition

> **Phase**: Plan → Implementation
> **Source**: [Link to plan artifact or spec document]

## User Stories

<!-- Each story decomposes into 1+ parallel tasks. [P] marks dispatchable units. -->

### US-1: [Title]

- [ ] **[P] Task T1:** [description]
  - **Files:** `path/to/file`
  - **Verify:** [command or manual check]
  - **Depends on:** _none_

- [ ] **[P] Task T2:** [description]
  - **Files:** `path/to/file`
  - **Verify:** [command or manual check]
  - **Depends on:** _none_

### Checkpoint 1

- [ ] Verify US-1 works independently (all tasks pass their verification targets)

### US-2: [Title]

- [ ] **Task T3:** [description — sequential, depends on T1/T2]
  - **Files:** `path/to/file`
  - **Verify:** [command or manual check]
  - **Depends on:** `T1`, `T2`

### Checkpoint 2

- [ ] Verify US-2 integrates with US-1 output

### US-3: [Title]

- [ ] **[P] Task T4:** [parallel with T5]
  - **Files:** `path/to/file`
  - **Verify:** [command or manual check]
  - **Depends on:** `T3`

- [ ] **[P] Task T5:** [parallel with T4]
  - **Files:** `path/to/file`
  - **Verify:** [command or manual check]
  - **Depends on:** `T3`

### Checkpoint 3

- [ ] End-to-end verification: all user stories integrated and passing

## Constitution Gates

Before dispatching any task:

- [ ] **Article II: Verify Aggressively** — Every task has a verification target?
- [ ] **Article IV: CATFISH First** — Most likely failure mode task identified?
- [ ] **Article V: Comprehension Gate** — Task dependencies understood?
- [ ] **Article VI: Simplicity Criterion** — Is each task the minimal change needed?
- [ ] **Article VIII: Phase Gate** — Plan complete before decomposing?

---

*Generated from tasks-template.md (core)*
