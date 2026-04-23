# Codex Reasoning Guide

This file explains when to use `low`, `medium`, `high`, or `xhigh` reasoning effort in Codex-style work.

## What Is Officially Confirmed

As of April 10, 2026, current OpenAI model pages confirm that recent Codex-oriented models support configurable reasoning effort, including `low`, `medium`, `high`, and `xhigh` for current Codex-class models such as GPT-5.2-Codex and GPT-5.3-Codex.

Sources:

- [OpenAI Codex best practices](https://developers.openai.com/codex/learn/best-practices)
- [GPT-5.3-Codex model page](https://developers.openai.com/api/docs/models/gpt-5.3-codex)
- [GPT-5.2-Codex model page](https://developers.openai.com/api/docs/models/gpt-5.2-codex)
- [How OpenAI uses Codex](https://openai.com/business/guides-and-resources/how-openai-uses-codex/)

OpenAI also recommends using Codex on well-scoped tasks, and its own usage guide says Codex works especially well on tasks that would take roughly about an hour for a teammate or involve a few hundred lines of code.

## Important Note

The exact "use `low` for X, `high` for Y" mapping below is an inference.

OpenAI's docs confirm the settings and the general best-practice patterns, but they do not provide a strict official lookup table for every task type.

So this guide is:

- source-backed on what settings exist and how Codex is intended to be used
- inferred for how to choose among those settings in real work

## Default Rule

If you are unsure, use `medium`.

That is usually the safest default for everyday repo work because it balances speed and care.

## Important Clarification About Higher Effort

Setting a session to a higher reasoning level does not create a perfect built-in "auto from low to xhigh" controller for each prompt.

The more practical mental model is:

- `high` means the session is biased toward thinking harder
- `xhigh` means the session is biased toward thinking hardest

So a higher setting usually means more reasoning on average for the same task, not a magical per-prompt optimizer that perfectly scales itself all the way down when unnecessary.

This means:

- `xhigh` is not "best answer mode" for everything
- `high` is often the safer lazy default if you do not want to think about the setting each time
- `xhigh` is best reserved for work where extra depth materially changes the outcome

## A Useful Lazy Default

If you do not want to tune reasoning effort for every task, `high` is often the best one-setting default.

This is not an official OpenAI rule.
It is an inference supported by practical agent usage and reinforced by Boris Cherny's publicly shared Claude Code workflow, where he says he uses `high` for everything there.

Cross-tool takeaway:

- if you want one default, prefer `high`
- escalate to `xhigh` only when the task is broad, ambiguous, or expensive to get wrong

## Recommended Use By Effort

### `low`

Use `low` when the task is small, local, and easy to verify.

Good fit:

- small copy edits
- renames
- simple formatting cleanup
- updating one obvious file
- adding a straightforward test case
- grabbing repo facts or locating files

Avoid `low` when:

- there are multiple plausible root causes
- the task spans several systems
- the repo is unfamiliar
- a wrong change could create hidden regressions

### `medium`

Use `medium` for normal day-to-day engineering work.

Good fit:

- most bug fixes
- CI failures with decent logs
- moderate refactors
- onboarding and repo walkthroughs
- PR reviews
- adding or adjusting tests
- updating docs with repo context

This should usually be your default.

### `high`

Use `high` when the task needs deeper planning, tradeoff analysis, or multi-step debugging.

Good fit:

- ambiguous CI or environment failures
- non-trivial refactors across modules
- understanding a large unfamiliar subsystem
- fixes that touch architecture, release flow, or cross-cutting behavior
- tasks where you want stronger root-cause confidence before edits
- work that mixes coding, validation, and explanation

This is a strong setting when the task is important but not extreme.

### `xhigh`

Use `xhigh` for expensive thinking tasks where being more careful is worth extra latency.

Good fit:

- long-horizon debugging with several interacting causes
- planning a migration or major refactor
- synthesizing many sources into a durable playbook
- designing repo-wide instruction systems
- tricky investigation where you want fewer shallow mistakes
- tasks that combine research, implementation, verification, and policy/convention handling

Do not use `xhigh` by default for routine chores. It is best when deeper reasoning materially changes the outcome.

## Quick Heuristic

Use this ladder:

- `low`: obvious and local
- `medium`: normal engineering task
- `high`: important and ambiguous
- `xhigh`: hard, broad, or expensive-to-get-wrong

## Task Examples

### CI failed after a dependency bump

- Start with `medium`
- Move to `high` if logs are noisy, symptoms are downstream, or the environment mismatch is subtle

### Teach me what you just did

- `medium` is usually enough
- `high` if you also want a strong mental model, tradeoff explanation, and structured teaching

### Teach me this repo

- `medium` for a small or familiar repo
- `high` for a large or confusing repo

### Resume a long-running audit or campaign

- `high` by default
- `xhigh` if there is a lot of prior state, subtle conventions, and a high cost to repeating or drifting

### Repo culture / PR convention alignment

- `high` is often appropriate
- `medium` if the repo is simple and the conventions are already well documented

## The Best Real-World Rule

Increase reasoning effort when any of these go up:

- ambiguity
- scope
- unfamiliarity
- hidden-regression risk
- cost of a wrong answer
- amount of synthesis required

If those are low, lower the reasoning effort.

## For This Round

Using `xhigh` for this conversation was reasonable.

Reason:

- you asked for strategy design, not just one answer
- we synthesized your scenarios, outside examples, and official docs
- we created reusable docs, templates, bootstrap scripts, and sync scripts
- the work mixed research, system design, implementation, and practical rollout guidance

For a normal single-repo bug fix, I would usually prefer `medium` or `high`, not `xhigh`.
