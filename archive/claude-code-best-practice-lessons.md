# Lessons From `claude-code-best-practice`

This file distills the strongest transferable lessons from the repository below and explains how they should change this workspace.

## Source Repo

- [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)
- [README.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/README.md)
- [CLAUDE.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/CLAUDE.md)
- [best-practice/claude-memory.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/best-practice/claude-memory.md)
- [reports/claude-global-vs-project-settings.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/reports/claude-global-vs-project-settings.md)
- [reports/claude-agent-command-skill.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/reports/claude-agent-command-skill.md)
- [best-practice/claude-skills.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/best-practice/claude-skills.md)
- [best-practice/claude-subagents.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/best-practice/claude-subagents.md)
- [development-workflows/cross-model-workflow/cross-model-workflow.md](https://github.com/shanraisshan/claude-code-best-practice/blob/main/development-workflows/cross-model-workflow/cross-model-workflow.md)

## Scope Note

The observations below are partly source-backed and partly generalized.

- Source-backed: what the repo explicitly documents about commands, agents, skills, memory loading, scope hierarchy, and workflow shape.
- Inference: how those ideas should change this workspace's prompting, rollout, and knowledge-base design.

## What The Repo Is Really Good At

Its biggest strength is not merely having many examples.

It makes three things explicit that many prompt libraries leave blurry:

- which execution lane should handle which kind of work
- where instructions and state should live by scope
- how context budget should shape workflow design

That is highly transferable.

## Transferable Lessons

### 1. Choose the lightest execution lane that still fits the work

The repo's `agents vs commands vs skills` comparison is valuable because it shows that not every task deserves the heaviest mechanism.

Source-backed pattern:

- commands are user-invoked workflow entrypoints
- skills are reusable inline procedures or knowledge units
- agents are separate autonomous workers with isolation, tool controls, and optional memory

Transferable rule for this workspace:

- use inline work for small, local tasks
- use reusable prompt files or skills for repeated procedures
- use a separate worker, fresh thread, or isolated lane when the task is autonomous, multi-step, or likely to pollute the main context
- use a second tool or model for independent review when skepticism is the point

### 2. Separate entrypoints, workers, and knowledge units

The repo's `Command -> Agent -> Skill` pattern is more than a Claude-specific trick.

It captures a durable systems idea:

- the entrypoint starts or sequences the workflow
- the worker performs autonomous multi-step work
- the knowledge unit packages reusable procedure or domain guidance

This is a strong cleanup rule for prompt systems too.

Do not blur:

- start the workflow
- do the work
- provide reusable know-how

### 3. Put instructions where the owning state belongs

The repo's global-vs-project report and memory guide are especially useful here.

Source-backed split:

- personal state and cross-project coordination live globally
- team-shareable project config can live in the repo
- descendant instruction files load only when work reaches that subtree

Transferable rule:

- keep personal preferences, private credentials, and personal memory in a personal/global layer
- keep repo-shared commands, checks, conventions, and workflow rules in repo-local files
- keep component-specific instructions close to the component
- keep personal repo-local overrides git-ignored

This matches the best practical answer to "how do all projects benefit from one library without copying everything everywhere?"

The answer is not one giant shared file.
It is a scope hierarchy.

### 4. Context budgeting should shape the workflow, not only the prompt

The repo's `CLAUDE.md` recommends manual compaction around 50 percent context usage and keeping subtasks small enough to finish well before the context window gets stressed.

That exact threshold is repo guidance, not a universal law.

The portable lesson is:

- compact before pain
- split work before the thread gets muddy
- keep reusable rules outside the hot path
- store specific instructions near the code they apply to

This strengthens the token-efficiency guidance already in this workspace.

### 5. Use cross-model review as a real workflow, not an afterthought

The repo's cross-model workflow is simple but strong:

1. one tool plans
2. another tool reviews the plan against the codebase
3. implementation happens phase by phase
4. a fresh verification pass checks the result against the plan

The transferable lesson is not "always use two tools."

It is:

- independent review is most useful at plan review and post-implementation verification
- the reviewer should add findings, not flatten the original plan
- a fresh session is often better than carrying the whole old context forward

This is especially relevant in this workspace because it already supports multi-tool prompting and rollout.

### 6. Keep instruction files short enough to be obeyed

The repo's `CLAUDE.md` explicitly recommends staying under about 200 lines per file.

That exact limit is repo-specific guidance.

The portable rule is:

- high-signal instruction files outperform encyclopedic ones
- if the file becomes long, split mainline guidance from bridge or reference material
- store detail where it can be loaded only when relevant

### 7. Prefer locality over giant root-level instruction dumps

The monorepo memory-loading explanation is useful beyond Claude-specific behavior.

If only the relevant subtree should matter, do not front-load every detail into the root instructions.

Instead:

- root file for repo-wide rules
- local files for local complexity
- bridge docs for cross-cutting confusion
- reference docs for field tables and capability maps

That is both cleaner and more token-efficient.

## What Not To Import As General Doctrine

Some repo practices are useful locally but should not become this workspace's default rule.

Examples:

- one commit per file
- product-specific frontmatter field dumps in the mainline guidance
- exact context-percentage thresholds presented as universal truth

Those are either repo-specific or tool-specific.

The knowledge base should keep the transferable pattern, not copy every local habit.

## Contrast With The Current Knowledge Base

Before this integration, this workspace was already strong on:

- prompt structure
- verification and done-when framing
- reasoning-effort choice
- token-efficient prompting
- repo rollout through local instruction files

It was weaker on:

- explicit execution-lane selection
- explicit instruction-scope hierarchy
- locality as a context-management strategy
- cross-model review as a formal workflow

## What This Should Change Here

### Add to prompt strategy

The knowledge base should explicitly teach:

- choose the lightest execution lane that fits
- separate workflow entrypoint from worker from reusable knowledge
- place rules at the correct scope
- use fresh review passes for plan and verification when quality matters

### Add to token efficiency

The efficiency guidance should explicitly include:

- compact before pain
- keep instructions local to the work they govern
- move durable rules out of the hot path
- prefer scope hierarchy over giant shared prompt blocks

### Add to rollout

The rollout docs should distinguish:

- central canonical library
- personal global layer
- repo-local team layer
- component-local layer
- git-ignored local overrides

## Best Short Summary

The most important lesson from `claude-code-best-practice` is this:

**Good prompt systems do not just tell the model what to do. They decide which lane should do the work, where the instructions should live, and when the context should be compacted or reviewed by a fresh independent pass.**
