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

Keep the active context narrow. Execute in small verified slices. Review each change before moving to the next.

**Before each slice: construct the expectation.** State (even briefly) what you expect the output to contain — the structure, the approach, the key decisions. When the AI output matches your expectation, you are calibrated. When it does not, you have a real decision to make: is your expectation wrong, or is the output wrong? That decision is the thing cognitive surrender skips.

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
| "I don't need to construct an expectation — I'll know if it's wrong" | Cognitive surrender feels identical to calibration from the inside. Without an explicit expectation, you have nothing to compare against. "Looks right" replaces "I know this is right." |
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
- Saying "I'll review it after" — that is the surrender posture
- Approving output because it "looks right" without being able to explain why
- Accepting a confident-sounding answer for a design tradeoff without asking the model to argue against itself
- Committing code you cannot reconstruct the reasoning for
</red_flags>
