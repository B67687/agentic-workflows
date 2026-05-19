# Determinism Framework

> **Core rule**: If the question has a verifiable right answer → make it
> **deterministic** (scripted, gated, automated). Otherwise → make it
> **non-deterministic** (deliberative, human + AI judgment).

**The litmus test**: *"If I ran this twice with the same input, would I get
the same result?"*
- Yes → **deterministic** — encode it in a script, gate, or workflow step
- No → **non-deterministic** — deliberative workflow step, human decision

**Default policy**: Deterministic by default. Every new gate or check starts
as a script. Only promote to deliberative when evidence proves judgment is
required.

---

## Gate Plugin Classification

All gates in `scripts/gates/` are run by `phase-gate.sh`.

### Implement Phase Gates

| Gate | Kind | Why |
|------|------|-----|
| `autonomy.sh` | **Deterministic** | Checks autonomy level against file complexity — math on known data |
| `cleanup-check.sh` | **Deterministic** | Measures disk usage, compares to threshold — pure arithmetic |
| `comprehension.sh` | **Deterministic** | Checks for comprehension evidence file — file exists check |
| `decisions.sh` | **Deterministic** | Scans decision log for pending items — text search |
| `decomposition.sh` | **Deterministic** | Validates milestone-ladder.json schema — JSON structure check |
| `preflight.sh` | **Deterministic** | Git state, branch, lane classification — all verifiable facts |
| `ambiguity-check.sh` | **Deterministic** | Greps for [NEEDS CLARIFICATION] markers — text search |

### Plan Phase Gates

| Gate | Kind | Why |
|------|------|-----|
| `catfish.sh` | **Deterministic** | Checks that CATFISH challenge was answered — evidence exists check |
| `scope-check.sh` | **Deterministic** | Validates scope is bounded — config or file check |
| `sufficiency.sh` | **Deterministic** | Validates research is sufficient — config or file check |

### Verify Phase Gates

| Gate | Kind | Why |
|------|------|-----|
| `quality-speed.sh` | **Deterministic** | Checks verification speed against threshold — timing data |

### Research Phase Gates

| Gate | Kind | Why |
|------|------|-----|
| `verification-gate.sh` | **Deterministic** | Checks research output for confidence labels, NEEDS_VERIFICATION flags, source citations, and timestamps — deterministic text pattern matching on the same input always produces the same result |

All **15 gate plugins are deterministic**. There are zero non-deterministic
gates — deliberate by design. Gates either pass/fail on verifiable data.

---

## Workflow Step Classification

### root.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `classify` | deliberative | **Non-deterministic** — classifying a user request requires human context and judgment. No script can determine intent from arbitrary text with 100% reliability. |

### research.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `formulate_questions` | deliberative | **Non-deterministic** — what questions to ask depends on user needs and task context. Requires judgment. |
| `parallel_research` | parallel | **Deterministic** — each sub-step runs a script (`explore.sh`). The fan-out is mechanical. |
| `review_findings` | deliberative | **Non-deterministic** — whether findings are sufficient requires human judgment. |

### design.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `current_state` | deterministic | **Deterministic** — maps codebase state via script. Same input = same output. |
| `design_discussion` | deliberative | **Non-deterministic** — design decisions are inherently judgment calls. |
| `structure_outline` | deliberative | **Non-deterministic** — implementation ordering depends on context and priority. |

### implement.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `decomposition_check` | deterministic | **Deterministic** — validates milestone ladder JSON structure. Same file = same result. |
| `slice_scope` | deliberative | **Non-deterministic** — what slices to make and their order requires task understanding. |

### verify.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `collect_diff` | deterministic | **Deterministic** — `git diff` output is deterministic for the same commit range. |
| `parallel_verify` | parallel | **Deterministic** — all sub-steps run deterministic scripts (LSP, tests, types). |
| `assess_quality` | deliberative | **Non-deterministic** — whether a change is correct and complete requires human judgment. |

### debug.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `reproduce` | deliberative | **Non-deterministic** — understanding a bug requires discussion. |
| `diagnose` | deterministic | **Deterministic** — grep for error patterns, trace call paths. Scriptable. |
| `propose_fix` | deliberative | **Non-deterministic** — fixing decisions depend on context. |

### review.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `collect_context` | deterministic | **Deterministic** — diff collection is mechanical. |
| `assess_quality` | deliberative | **Non-deterministic** — code quality assessment requires judgment. |

### docs.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `research_existing` | deliberative | **Non-deterministic** — what to research depends on doc needs. |
| `write_doc` | deliberative | **Non-deterministic** — writing is inherently creative/judgment. |

### propagate.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `select_targets` | deliberative | **Non-deterministic** — scope choice depends on user intent. |
| `preview_changes` | deterministic | **Deterministic** — dry-run output is a function of inputs. |
| `review_preview` | deliberative | **Non-deterministic** — approving changes requires judgment. |
| `apply_changes` | deterministic | **Deterministic** — file copy is mechanical. |
| `verify_sync` | deterministic | **Deterministic** — sync check compares file content. |

### refactor.yaml

| Step | Kind | Classification |
|------|------|---------------|
| `map_current` | deterministic | **Deterministic** — state mapping is scripted. |
| `design_target` | deliberative | **Non-deterministic** — target structure requires design judgment. |
| `execute_refactor` | deliberative | **Non-deterministic** — slice order and verification sequence. |
| `final_verify` | deterministic | **Deterministic** — test execution has pass/fail output. |

---

## Enforcement Scripts (tools/)

| Script | Kind | Why |
|--------|------|-----|
| `decomposition-gate.sh` | **Deterministic** | JSON schema validation |
| `workflow-check.sh` | **Deterministic** | State structure checks |
| `goal-tree.sh` | **Deterministic** | JSON read/write operations |
| `phase-gate.sh` | **Deterministic** | Prerequisite check + gate plugin dispatch |
| `decision-pipeline.sh` | **Deterministic** | Sequential gate runner |
| `checkpoint-commit.sh` | **Deterministic** | Git operations |
| `session-start.sh` | **Deterministic** | State reading + display |
| `propagate-to-all.sh` | **Deterministic** | File copy + sync check |

All enforcement scripts are deterministic. No enforcement script should
contain judgment calls.

---

## What Is and Is NOT Deterministic

### ✅ Deterministic (script it, gate it, automate it)

- File existence, JSON validity, schema validation
- Git state (branch, dirty files, commit history)
- Lint output, type errors, test pass/fail
- Disk usage, file counts, timing data
- Text search (grep for patterns, markers, pending items)
- Math (autonomy scoring, threshold checks)
- Phase ordering (state machine transitions)
- Decision log completeness (all required fields present)
- Configuration parsing (models, providers, paths)

### ❌ Non-Deterministic (deliberative step, human choice)

- **What to build next** — priority, scope, milestone selection
- **Architecture decisions** — which pattern, where to split
- **Code organization** — file structure, naming, module boundaries
- **Tradeoff resolution** — simplicity vs completeness, speed vs correctness
- **Error handling philosophy** — which errors to handle vs crash
- **Test coverage targets** — what to test, what to skip
- **Design quality** — is this good enough?
- **Bug reproduction scope** — what input causes the bug?
- **Code review approval** — is this change acceptable?

---

## How to Classify New Work

When adding a new gate, check, or workflow step:

1. Apply the litmus test: *"Same input → same output?"*
2. If **yes**: make it `kind: deterministic` with a script. Add it to the
   appropriate `scripts/` directory and `scripts/gates/<phase>/` if applicable.
3. If **no**: make it `kind: deliberative`. Keep the scope narrow — a
   deliberative step should answer one question, not ten.
4. If **unsure**: start deterministic. Ship it. If the script turns out to
   need judgment calls, promote to deliberative later. Going the other
   direction (deliberative → deterministic) requires unpicking human habits
   and is harder.

---

## Pi-Star Equivalents

| Pi-Star Component | Kind | Classification |
|-------------------|------|----------------|
| `set-phase` tool | **Deterministic** | Phase transition based on state machine rules + requires valid milestone ladder for plan→implement |
| `/phase` command | **Deterministic** | Same as set-phase |
| `/constitution check` | **Deterministic** | Article gates are deterministic checks |
| `/workflow-check` | **Deterministic** | State file validation |
| `/milestone-ladder validate` | **Deterministic** | JSON schema validation |
| `/goal-tree` commands | **Deterministic** | JSON read/write operations |
| `workflow-guard.ts` hooks | **Deterministic** | Pattern matching against known dangerous commands |
| `git-safe.ts` auto-commit | **Deterministic** | Git operations based on tool_call events |
| `tool_call` hook (edit block) | **Deterministic** | Block edits in research/plan phases |
| `before_agent_start` hook | **Deterministic** | Phase detection + prompt injection |
| Model selection | **Non-deterministic** | Which model fits which task is a routing decision |
| Architecture decisions | **Non-deterministic** | In Pi-Star, the deliberative workflow steps handle this |
| Agent routing | **Non-deterministic** | Which subagent for which task requires judgment |
