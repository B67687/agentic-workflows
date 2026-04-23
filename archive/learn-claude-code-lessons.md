# Lessons From `learn-claude-code`

This file distills the strongest transferable lessons from the repository below and explains how they should influence this workspace.

## Source Repo

- [shareAI-lab/learn-claude-code](https://github.com/shareAI-lab/learn-claude-code)
- [README.md](https://github.com/shareAI-lab/learn-claude-code/blob/main/README.md)
- [docs/en/s00-architecture-overview.md](https://github.com/shareAI-lab/learn-claude-code/blob/main/docs/en/s00-architecture-overview.md)
- [docs/en/s00f-code-reading-order.md](https://github.com/shareAI-lab/learn-claude-code/blob/main/docs/en/s00f-code-reading-order.md)
- [docs/en/teaching-scope.md](https://github.com/shareAI-lab/learn-claude-code/blob/main/docs/en/teaching-scope.md)
- [docs/en/data-structures.md](https://github.com/shareAI-lab/learn-claude-code/blob/main/docs/en/data-structures.md)
- [docs/en/team-task-lane-model.md](https://github.com/shareAI-lab/learn-claude-code/blob/main/docs/en/team-task-lane-model.md)
- [agents/s05_skill_loading.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s05_skill_loading.py)
- [agents/s06_context_compact.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s06_context_compact.py)
- [agents/s07_permission_system.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s07_permission_system.py)
- [agents/s10_system_prompt.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s10_system_prompt.py)
- [agents/s11_error_recovery.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s11_error_recovery.py)
- [agents/s18_worktree_task_isolation.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s18_worktree_task_isolation.py)
- [agents/s19_mcp_plugin.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s19_mcp_plugin.py)
- [agents/s_full.py](https://github.com/shareAI-lab/learn-claude-code/blob/main/agents/s_full.py)

## Scope Note

The observations below are partly source-backed and partly generalized.

- Source-backed: what the repo explicitly teaches, how it structures the curriculum, and how its example code expresses those ideas.
- Inference: how those ideas should change this workspace's prompting and knowledge-base design.

## What The Repo Is Really Good At

Its biggest strength is not merely explaining an agent harness.

It teaches the system in dependency order and keeps asking the learner to separate:

- core mechanism from peripheral detail
- durable state from runtime state
- coordination from execution
- the mainline from bridge or reference material

That is a meaningful upgrade over many prompt libraries, which often stay good at task framing but weaker at teaching system structure.

## Transferable Lessons

### 1. Teach and analyze by mechanism dependency, not by glamour

The repo's stages move from single-agent loop to hardening to runtime work to platform growth.

The transferable rule is:

- do not explain the advanced layer before the learner understands the dependency beneath it
- do not let the longest or flashiest file define the learning order

### 2. Stay highly faithful to the backbone, not every outer detail

The repo explicitly aims for high fidelity to the design trunk rather than product trivia.

That is a strong rule for this workspace too:

- preserve core operating model
- avoid letting packaging, release, telemetry, or product quirks dominate the teaching line

### 3. Start with the smallest correct version

This is one of the best habits in the repo.

Examples it uses:

- skills: cheap catalog first, full body later
- permissions: a short pipeline first, more policy later
- subagents: separate context first, advanced inheritance later

This should influence how we write prompts and teaching notes:

- ask for the smallest correct version first
- then ask what later iterations would add

### 4. Always ask where the state lives

The repo's `data-structures.md` is especially strong here.

When explaining a system, do not stop at naming components. Ask:

- what record owns the state
- which layer owns it
- whether it is content state or process-control state
- whether it is durable or runtime-only

### 5. Separate layers that sound similar

Its `team-task-lane-model.md` is an excellent example of disambiguation.

Important separation:

- teammate: who collaborates
- protocol request: tracked coordination exchange
- task: durable goal
- runtime task / execution slot: what is running
- worktree: isolated execution lane

This is a very transferable teaching pattern: separate similar-sounding layers before they blur.

### 6. Use bridge docs around the mainline

The repo has a strong pattern:

- main chapters teach the forward path
- bridge docs clarify cross-cutting confusion
- reference docs collect terms and records

This suggests a good knowledge-base pattern for this workspace too:

- keep main playbooks compact
- use side docs for cross-cutting clarification
- do not overload the mainline document with every edge case

### 7. Code reading order matters

The repo's code-reading guide is very practical:

1. file header
2. state structures or manager classes
3. tool list or registry
4. turn-advancing function
5. CLI entry last

This is worth preserving as a reusable repo-analysis technique.

### 8. Prompt assembly is a pipeline, not one blob

`s10_system_prompt.py` makes a strong architectural point:

- stable instructions
- tool listing
- skill metadata
- memory section
- instruction-chain files
- dynamic context

The key transfer:

- stable and dynamic prompt content should be separated deliberately
- per-turn reminders should not be mixed blindly into the stable prompt

### 9. Permissions are a pipeline, not a boolean

`s07_permission_system.py` teaches a clear flow:

1. deny rules
2. mode check
3. allow rules
4. ask user

That helps explain why permission systems should be legible and staged, not just "allowed/blocked."

### 10. Context compaction is relocation, not deletion

`s06_context_compact.py` teaches three useful context behaviors:

- persist large output elsewhere
- micro-compact older tool results
- summarize whole history only when needed

The transferable lesson:

- keep the active window small without destroying continuity

### 11. External capabilities should enter the same control plane

`s19_mcp_plugin.py` emphasizes that native tools and external tools should share:

- permission path
- normalization
- routing model

That is a strong architectural teaching principle: do not create a completely separate conceptual world for external capabilities if the agent should reason about them as tools.

## Contrast With The Current Knowledge Base

Before this integration, this workspace was stronger on:

- prompt structure
- acceptance criteria
- verification
- repo rollout and instruction-file propagation
- reasoning-effort guidance

It was weaker on:

- teaching-system design
- mainline vs bridge-doc structure
- state ownership as a teaching lens
- dependency-driven reading order
- separating goal, runtime execution, and execution lane

## What This Should Change Here

### Add to prompt strategy

The knowledge base should explicitly teach:

- mechanism-first explanation
- smallest-correct-version-first prompting
- asking where state lives
- dependency-driven repo reading order
- separating mainline docs from bridge docs

### Add to repo-analysis prompts

When analyzing a repo, prompts should ask for:

- the teaching spine or mechanism dependency order
- the key records and state ownership
- code reading order
- mainline vs bridge/reference docs
- the smallest correct version of the system before the advanced one

### Add to workspace behavior

This workspace should use its own knowledge base to prime future work.

That is why the local `AGENTS.md` now points future sessions toward the relevant files before substantial work begins.

## Best Short Summary

The most important lesson from `learn-claude-code` is this:

**A good agent or prompt knowledge base should not only tell you what to ask for. It should teach you how the system grows, where the state lives, and which layers must stay separate for the model and the human to keep a clean mental model.**
