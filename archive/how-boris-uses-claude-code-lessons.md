# Lessons From `How Boris Uses Claude Code`

This file distills the strongest transferable lessons from Boris Cherny's practical workflow guide and explains how they should influence this workspace.

## Source Guide

- [How Boris Uses Claude Code](https://howborisusesclaudecode.com/)

## Scope Note

The observations below are partly source-backed and partly generalized.

- Source-backed: what the site says Boris and the Claude Code team do in daily practice.
- Inference: how those patterns should change this workspace's prompting and knowledge-base design across tools.

## What The Guide Is Really Good At

Its biggest strength is that it is not a theory doc.

It shows what a strong daily operating loop looks like when:

- multiple sessions are normal
- shared instructions are edited continuously
- planning is a real control surface
- repeated workflows are promoted into reusable assets
- verification is treated as the main quality engine

## Transferable Lessons

### 1. Parallelism is a first-class workflow, not an edge case

The guide repeatedly treats parallel sessions and worktrees as the main productivity unlock, not a special trick.

Source-backed patterns:

- multiple sessions in parallel
- separate checkouts or worktrees for isolation
- named tabs, colors, status lines, and notifications to manage them
- dedicated analysis lanes for logs or analytics

Transferable rule:

- parallelism works best when each lane has clear isolation and purpose
- keep one lane for implementation, one for analysis, one for review when needed
- do not pile every concern into one giant session

### 2. Plan mode is not just the start, it is the recovery path

The guide strongly reinforces a control-loop pattern:

- start complex tasks in plan mode
- refine the plan until it is solid
- when things go sideways, go back to plan mode and re-plan
- sometimes put verification steps into plan mode too

Transferable rule:

- planning is not a ceremony before coding
- it is the mechanism you return to when the current execution path degrades

### 3. Shared repo memory should compound after mistakes and reviews

This is one of the most important lessons in the guide.

Source-backed pattern:

- when Claude does something wrong, add the correction to `CLAUDE.md`
- update shared instructions from PR review feedback
- keep notes directories for project or task learnings and point the main instruction file at them

Transferable rule:

- do not merely fix the immediate mistake
- update the repo memory so the same correction compounds

This is very closely aligned with the existing lessons-file model in this workspace.

### 4. If you do something more than once a day, promote it

The guide gives a sharp threshold:

- if you do something more than once a day, turn it into a skill or command

The exact mechanism is Claude-specific.
The transferable lesson is not.

Transferable rule:

- repeated workflows should become reusable prompts, commands, skills, scripts, or automations
- stop paying full prompt and setup cost for work that clearly recurs

### 5. Give rich evidence, then stop micromanaging

The guide's bugfix advice is practical:

- hand over the bug thread, CI failure, or logs
- say "fix"
- do not oversteer the implementation path

Transferable rule:

- give the agent high-quality evidence
- then avoid drowning it in unnecessary "how" instructions if the task is straightforward
- once the context is strong, over-micromanagement can make the result worse

### 6. Challenge the first answer

One of the strongest prompting moves on the site is not about initial phrasing.
It is about second-pass pressure.

Source-backed examples:

- "Grill me on these changes and don't make a PR until I pass your test."
- "Prove to me this works."
- "Knowing everything you know now, scrap this and implement the elegant solution."

Transferable rule:

- do not assume the first acceptable answer is the best answer
- use challenge prompts to turn the agent into its own reviewer
- ask for proof, not just confidence

### 7. Verification is the real quality engine

The guide treats verification as Boris's most important tip.

Source-backed pattern:

- quality jumps when the agent has a feedback loop
- verification should match the domain: tests, browser interaction, commands, logs, simulators, and so on

Transferable rule:

- verification is not the end of the workflow
- verification is what turns the whole loop into something trustworthy

### 8. Safer automation beats permission fatigue

The guide prefers:

- pre-allowed common safe permissions
- auto mode
- sandboxing

over indiscriminate skip-permission behavior.

Transferable rule:

- remove friction by making the safe path smoother
- do not remove guardrails just because prompts are annoying

### 9. Configure the tool to teach when the goal is learning

The guide's learning section is worth keeping because it treats explanation as a configurable mode.

Source-backed ideas:

- explanatory or learning output styles
- ASCII diagrams
- generated walkthroughs or presentations
- spaced-repetition style learning loops

Transferable rule:

- when the goal is learning, make the output mode explicitly teaching-oriented
- do not expect a default execution-oriented answer to also be the best teaching artifact

## What Not To Import As General Doctrine

Some items on the site are useful but should not become this workspace's default rule.

Examples:

- Ghostty-specific terminal preferences
- voice input as a default workflow
- Claude-specific feature flags or product commands
- raw enthusiasm for parallelism without isolation and verification discipline

The knowledge base should keep the transferable operating model, not every product-specific habit.

## Contrast With The Current Knowledge Base

Before this integration, this workspace was already strong on:

- verification
- repo-local lessons and instruction files
- execution-lane isolation
- plan-first prompting
- tests-first and TDD patterns

It was weaker on:

- re-enter plan mode when execution goes sideways
- using challenge prompts for second-pass quality
- a simple threshold for promoting repeated work into reusable assets
- explicit "rich evidence, low micromanagement" prompting
- compounding repo memory from PR review as an operating loop

## What This Should Change Here

### Add to prompt strategy

The strategy docs should explicitly teach:

- switch back to planning when execution degrades
- give rich evidence, then avoid unnecessary micromanagement
- challenge mediocre first answers
- promote repeated work into reusable assets quickly

### Add to rollout

The rollout docs should reinforce:

- review feedback should update instruction files and lessons
- shared repo memory is a compounding asset, not just documentation

### Add to reasoning guidance

The guide provides a useful practitioner signal:

- Boris uses `high` for everything in Claude Code

The cross-tool takeaway is not that one vendor's setting maps perfectly to another.
It is that, if you want one lazy default and do not want to tune every task, `high` is often a better "always-on" default than the maximum setting.

## Best Short Summary

The most important lesson from Boris's workflow guide is this:

**Strong agent use is not just better prompting. It is a compounding operating loop: plan hard, isolate work, verify aggressively, and turn every repeated fix or workflow into shared reusable memory.**
