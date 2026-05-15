---
description: >
  Turn the researched task into an explicit implementation plan.
  Includes optional CATFISH-style adversarial challenge (plan-challenge.sh)
  to detect premature convergence and inject structured dissent.
---

This is planning mode only.

Use the existing research context if it is already good. If not, say that research is incomplete and stop.

Run the prompt contract:
`bash ./scripts/prompt-contract.sh "$ARGUMENTS" --phase plan`

Before planning, run:
`bash ./scripts/plan-guard.sh "$ARGUMENTS"`

If the guard says `Plan decision: go-back`, stop and send the task back exactly one phase.

If the guard says `Plan decision: first-slice-only` or `Plan decision: stop-refining`, do not produce a giant end-to-end plan. Produce only:
- a coarse milestone ladder with at most 5 milestones
- one detailed next slice
- at most 5 steps for that slice
- the verification target for that slice
- the next command to use

Do not implement yet.

Return a compact plan with:
- the exact files that should change
- the step-by-step sequence
- the verification command or check for each step
- what is explicitly out of scope
- where to checkpoint or restart between phases

### Phase Gate with Quality + Constitution Checks

Run the unified phase gate with quality checks and constitution compliance before planning:

```bash
bash ./scripts/phase-gate.sh plan --research-done --check-quality --constitution
```

The `--check-quality` flag auto-discovers gate plugins from `scripts/gates/plan/*.sh`.
Each plugin is a standalone check. Current plugins for the plan phase:
1. **State check**: research must be done (--research-done flag)
2. **Research sufficiency**: if a research note exists, checks for red flags (source URLs, confidence levels, gaps section)
3. **Scope check**: task scope boundedness before implementation
4. **CATFISH**: plan challenge data checked (if available)

The `--constitution` flag runs Article I (Macro-to-Micro) gates:
- Research note with system understanding exists
- Relevant source files have been read

If sufficiency check or constitution gate BLOCKs, go back to `/research`.
New gate plugins can be added by creating `scripts/gates/plan/<name>.sh`.

### Plan Challenge (CATFISH Protocol)

After producing the plan and saving it to `.runtime/plan.json`, re-run the plan guard with the challenge flag:

`bash ./scripts/plan-guard.sh "$ARGUMENTS" --challenge`

This checks for collapse signals (premature convergence, missing risks, vague verification).
If the challenge is required, the guard will print instructions to dispatch a @worker subagent with structured dissent.

The challenge uses **counterfactual post-mortem framing**:
> "Assume this plan has already failed catastrophically --- what caused it?"

This is NOT a "find flaws" review. It surfaces risks that a same-context review would miss.

After the challenge response is collected, run:
`bash ./scripts/plan-challenge.sh reconcile --plan .runtime/plan.json --response .runtime/challenge-response.json`

- **PASS** -> proceed with implementation
- **FAIL** (blocking findings) -> address each before proceeding
- **WARN** (significant findings) -> address or document as residual risk

The quality gate will also check for unaddressed blocking findings at commit time.

<rationalizations>
| Shortcut | Why It Fails |
|---|---|
| "I know the codebase well enough" | Stale assumptions cause wrong file choices. Use /repo-map and /research first. |
| "I can plan as I go" | Plans written mid-implementation skip dependency ordering and create rework. |
| "The plan is obvious" | "Obvious" plans hide implicit assumptions that the plan guard would catch. |
| "I already researched this" | Research notes aren't a plan --- plans need exact file list, steps, and per-step verification.
</rationalizations>

<red_flags>
- More than 5 broad milestones without a detailed first slice
- Plan guard blocked but proceeding anyway
- Verification target is vague ("make it work") instead of specific ("tests pass + build succeeds + endpoint returns 200")
- No explicit "out of scope" section
</red_flags>
