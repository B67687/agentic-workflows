---
description: Implement only after the plan is clear
---

This is implementation mode.

Only proceed if the task already has enough research and a clear plan. If not, stop and say whether `/research` or `/plan` should happen first.

Run the prompt contract:
`bash ./scripts/prompt-contract.sh "$ARGUMENTS" --phase implement`

Before implementation, run the deterministic preflight:
`bash ./scripts/implement-preflight.sh "$ARGUMENTS"`

If `Implement decision: block`, do not implement. Send the task back exactly one phase.

If `Implement decision: caution`, fix the checkout state first or move the work into a worktree before implementing.

### Phase Gate with Quality Checks

Before implementing, run the unified phase gate with all quality checks:

```bash
bash ./scripts/phase-gate.sh implement \
  --research-done --plan-done --scope-bounded --verification-known \
  --check-quality
```

The `--check-quality` flag auto-discovers gate plugins from `scripts/gates/implement/*.sh`.
Each plugin is a standalone check. Current plugins for the implement phase:
1. **State check**: research, plan, scope, and verification preconditions
2. **Comprehension**: verifies comprehension-gate evidence exists
3. **CATFISH reconcile**: checks plan challenges are addressed
4. **Decision log**: warns of unresolved decisions
5. **Autonomy assessment**: current autonomy level
6. **Preflight check**: repo health and task fit

New gate plugins can be added by creating `scripts/gates/implement/<name>.sh`.

### Comprehension Gate (Enforced Participation)

Before implementing any task, the agent must demonstrate comprehension of the relevant instructions by producing a structured evidence file:

```bash
# Extract the comprehension template from the primary instruction file
bash ./scripts/comprehension-gate.sh extract commands/implement.md

# Fill in each <!--REQUIRED--> section in .runtime/comprehension-evidence.md
# Then verify it passes:
bash ./scripts/comprehension-gate.sh verify .runtime/comprehension-evidence.md
```

This implements the Recognition model (Attaguile 2026): the system requires participation rather than suggesting it. The four required sections force the agent to extract:
1. **Verification target** --- what proves this task is done correctly
2. **Relevant anti-rationalization** --- which shortcut from the instructions applies to this specific task
3. **Red flag to avoid** --- which danger signal is most relevant
4. **Out of scope** --- what this task explicitly does not include

The quality gate checks for filled sections at commit time.

### Human-in-the-Loop Gate (12-Factor F7/F8)

For high-risk operations (production data, destructive commands, billing actions),
the preflight supports a `--risk high` flag that triggers a human approval gate:

```
bash ./scripts/implement-preflight.sh "$ARGUMENTS" --risk high
```

When `--risk high` is set, the preflight invokes `scripts/a2h-contact.sh approve`
to request deterministic human approval before allowing implementation. This
implements the **interrupt-between-selection-and-execution** pattern --- the
tool is selected but does not execute until a human explicitly approves.

If no human is available (non-interactive mode), the approval gate warns and
logs the request to `.runtime/a2h/` and `.runtime/notifications/` for later processing.

See: `scripts/a2h-contact.sh`

### Error Counter & Self-Healing (12-Factor F9)

When an implementation step fails, use the error counter pattern to track
consecutive failures and escalate to a human after the threshold:

```
# On failure: increment counter, feed error back into context
bash ./scripts/log-error.sh "operation-name" <<< "error output"
bash ./scripts/error-counter.sh inc operation-name "error output"

# Include error context in next LLM turn for self-healing
# The XML output is compact and attention-friendly
bash ./scripts/error-counter.sh context operation-name

# On success: reset counter
bash ./scripts/error-counter.sh reset operation-name

# Check current status
bash ./scripts/error-counter.sh check operation-name
```

This implements the **compact errors into context window** pattern:
1. Error captured deterministically (log-error.sh)
2. Counter tracks consecutive failures (error-counter.sh)
3. Error context fed back into LLM for self-healing (context command)
4. After N failures (default: 3), an A2H approval request is created
5. All errors are logged to `.runtime/triage/errors.log` for cross-session reference

Set the escalation threshold via environment:
```
export ERROR_THRESHOLD=5
```

See: `scripts/error-counter.sh`, `scripts/log-error.sh`

Keep the active context narrow. Execute in small verified slices. Review each change before moving to the next.

**Before each slice: construct the expectation.** State (even briefly) what you expect the output to contain --- the structure, the approach, the key decisions. When the AI output matches your expectation, you are calibrated. When it does not, you have a real decision to make: is your expectation wrong, or is the output wrong? That decision is the thing cognitive surrender skips.

**After each slice: run the calibration check.** Before committing, ask: *"Can I reconstruct this change's reasoning without the AI's help?"* If you cannot explain what changed and why, you did not review it; you ratified it. Do not commit verified-but-not-understood code. Go back and rebuild the mental model before proceeding.

For decisions with tradeoffs (architecture, design, risk), **ask the model to argue against its own answer** before accepting it. The first answer will be confident; the counter-argument is cheap and breaks the borrowed-confidence effect.

Do not silently expand the slice during implementation. If the current slice is no longer the right one, stop and go back to `/plan` or `/shape-milestone`.

After each verified phase:
- update `session-state.json`
- prefer a checkpoint commit
- recommend a new session if the next step changes phase or scope

<rationalizations>
| Shortcut | Why It Fails |
|---|---|
| "This is small enough to skip the preflight" | Preflights catch checkout dirt, missing research, and unclear scope that cause mid-implementation rework. |
| "I'll clean up adjacent code while I'm here" | Scope creep is the #1 cause of regressions. Note it, don't fix it. |
| "I'll commit everything at the end" | Large commits hide bugs and make rollback impossible. Commit each verified slice. |
| "The tests can wait until I'm done" | Untested code is unverified code. Tests written after the fact miss the intent. |
| "I don't need to construct an expectation --- I'll know if it's wrong" | Cognitive surrender feels identical to calibration from the inside. Without an explicit expectation, you have nothing to compare against. "Looks right" replaces "I know this is right." |
| "The output looks right, it must be correct" | Surface correctness is not systemic correctness. The gap between them is exactly where surrender hides. Verify independently. |
| "I can reconstruct the reasoning later if I need to" | Comprehension debt compounds. Each surrendered slice makes the next harder to evaluate. Reconstruct the understanding now or pay the interest later. |
</rationalizations>

<red_flags>
- Writing more than ~100 lines without running tests or committing
- Touching files outside the explicit scope list from the plan
- Preflight returned "caution" or "block" but proceeding anyway
- Skipping the checkpoint commit after a verified phase
- Scope silently expanding during implementation ("while I'm here I'll also...")
- Running a generative action without stating what you expect the output to contain
- Saying "I'll review it after" --- that is the surrender posture
- Approving output because it "looks right" without being able to explain why
- Accepting a confident-sounding answer for a design tradeoff without asking the model to argue against itself
- Committing code you cannot reconstruct the reasoning for
- Adding a complex solution when a simpler one would work --- consider: does this change make the system simpler or more complex? If the latter, the improvement must be proportional. (Simplicity criterion from karpathy/autoresearch.)
</red_flags>
