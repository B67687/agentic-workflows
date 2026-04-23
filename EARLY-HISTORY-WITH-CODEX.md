# Early History With Codex

High-fidelity handover for the origin and early evolution of the AI Prompting workspace.

This document is meant for a future coding agent that needs to understand not only what files exist, but why they exist, what the user was trying to achieve, what the agent improved, what the user corrected, and what was finally implemented.

## How To Read This

Read this when:

- You need the full origin story of this workspace.
- You are about to change `AGENTS.md`, propagation templates, history, research workflow, model routing, or cross-project memory.
- You are trying to understand why this workspace is a hub rather than a normal code repo.
- You are taking over from a different agent and need the hidden session context.

Use this together with:

- `workflow/session-state.json` for current active state.
- `AGENTS.md` for current operating rules.
- `docs/workspace-system-overview.md` for the system map.
- `HISTORY.md` for compact session ledger.
- `archive/history-2026-04.md` for full archived April history.

## Timestamp Policy

There are three kinds of timestamps in this document:

| Label | Meaning |
|---|---|
| Exact artifact timestamp | Timestamp from filesystem creation or last-write time. Highest confidence. |
| Archived session window | Approximate time range preserved in `archive/history-2026-04.md`. Medium confidence. |
| Prompt-order reconstruction | Reconstructed from the order of user prompts in the long session. Useful for rationale, but exact clock time is unavailable unless a file timestamp corroborates it. |

Timezone is Asia/Singapore unless otherwise stated.

## Executive Summary

The first major Codex session began as a simple request: the user wanted to learn how to prompt AI properly for practical scenarios such as fixing CI, learning from agent work, understanding repos, continuing long-running repo campaigns, and aligning with repo culture.

Codex expanded that into a durable workspace:

- a prompt library,
- a reasoning-level guide,
- a repo onboarding and CI debugging playbook,
- a cross-project instruction propagation system,
- a lessons/memory system,
- a research integration workflow,
- a TDD and verification doctrine,
- a teaching-while-building framework,
- a Windows tooling baseline,
- project-level `AGENTS.md` propagation,
- OpenCode configuration guidance,
- handover/session recovery,
- and eventually a hub-and-topic-folder architecture for all work under `M:\M-Namikaz-Others`.

The key evolution was:

```text
User intent:
I want better prompts and less lost context.

Codex improvement:
Turn prompts into reusable workflows, templates, scripts, and docs.

User improvement:
Make it concise, practical, project-wide, culturally aware, and safe from context loss.

Final agreement:
This should become a living hub that learns, compresses, verifies, propagates, and records history.

Implementation:
AI Prompting became the central knowledge hub with docs/, scripts/, workflow/, propagate-templates/, archive/, personal-voice/, and project instructions pushed outward to topic folders.
```

## Current Situation At Time Of This Handover

As of 2026-04-23:

- The hub is now a Git repo with recent commits.
- `workflow/session-state.json` is the first file future agents must read.
- `docs/CONTEXT.md` was intentionally deleted and replaced by `AGENTS.md` plus `docs/workspace-system-overview.md`.
- `archive/early-history.md` is still a placeholder, but this file now preserves the early Codex-specific narrative.
- `HISTORY.md` is the compact active ledger. Older full details live in `archive/history-2026-04.md`.
- The hub now has OpenCode agent definitions, skill files, and propagation templates, but the early story began before that system existed.

Important live evidence:

| File | Exact timestamp evidence | Why it matters |
|---|---:|---|
| `README.md` | Created 2026-04-10 15:48:33, modified 2026-04-23 13:54:18 | One of the first hub entry files; later rewritten into learning paths. |
| `docs/daily-prompts.md` | Created 2026-04-10 16:02:19 | Early reusable prompt layer. |
| `docs/project-rollout-template.md` | Created 2026-04-10 16:02:19 | Early answer to "how do every project use this?" |
| `propagate-templates/AGENTS.template.md` | Created 2026-04-10 16:06:42, modified 2026-04-23 12:50:38 | Main outward instruction template. |
| `docs/codex-reasoning-guide.md` | Created 2026-04-10 18:36:28 | Early reasoning-level guidance. |
| `archive/learn-claude-code-lessons.md` | Created 2026-04-11 10:41:40 | External source integration began. |
| `docs/token-efficient-prompting.md` | Created 2026-04-11 12:17:10 | Token efficiency became a first-class concern early. |
| `docs/tdd-with-agents.md` | Created 2026-04-12 12:04:34 | TDD became a core agent workflow pattern. |
| `docs/learning-while-building-with-agents.md` | Created 2026-04-12 16:03:02 | User's fear of outrunning understanding became durable guidance. |
| `scripts/propagate-to-all.ps1` | Created 2026-04-13 21:54:36, modified 2026-04-23 00:41:56 | Main propagation engine. |
| `research/research-prompt.md` | Created 2026-04-14 13:22:29 | Research workflow became formal. |
| `docs/git-github-best-practices.md` | Created 2026-04-15 13:33:43 | Repo culture and Git/GitHub workflow guidance. |
| `docs/cognitive-identity.md` | Created 2026-04-16 14:54:12 | Major learning/cognition thread. |
| `docs/agent-context-handover.md` | Created 2026-04-17 22:32:51 | Response to context loss and model switching concerns. |
| `workflow/cross-domain-registry.md` | Created 2026-04-19 10:53:06 | Cross-domain knowledge flow became concrete. |
| `personal-voice/VOICE-PROFILE.md` | Created 2026-04-20 00:39:30 | Personal voice system emerged. |
| `workflow/session-state.json` | Created 2026-04-22 14:16:21, modified 2026-04-23 13:58:28 | Current session-resume source of truth. |

## The Core Human Intent

The user's underlying intent was not simply "make better prompts."

The actual intent was:

- Make AI agents useful without requiring perfect prompt-writing skill.
- Turn repeated prompting patterns into reusable assets.
- Keep agents from losing context between threads or models.
- Let every project benefit from the same hard-won lessons.
- Move quickly, but not so quickly that the user stops understanding.
- Respect real repo culture, not just stale written rules.
- Prefer practical scripts and markdown over abstract advice.
- Keep instructions concise enough that agents actually follow them.

This is why the workspace evolved into a hub rather than a single prompt document.

## Origin Timeline

### 2026-04-10 15:48:33 - Hub Begins As A Prompting Workspace

**Evidence:** `README.md` created 2026-04-10 15:48:33.

**User intent:** Learn how to prompt AI properly for real coding and repo situations.

**Codex improvement:** Instead of answering only with one-off prompts, Codex started shaping a reusable knowledge base.

**User improvement:** The user supplied concrete scenarios and compared another model's answers, pushing Codex to learn from good prompt structure rather than dismiss it.

**Final agreement:** Build reusable markdown strategies and prompt templates.

**Implemented:**

- `README.md`
- early `docs/` structure
- early prompt and rollout docs

**Why it mattered:** This is the turning point from "answer my prompting question" to "create a persistent AI Prompting workspace."

### 2026-04-10 16:02:19 - Daily Prompts And Project Rollout Become First-Class

**Evidence:** `docs/daily-prompts.md` and `docs/project-rollout-template.md` created 2026-04-10 16:02:19.

**User intent:** Have ready prompts for repeated scenarios, especially CI failures, teaching summaries, repo onboarding, and continuing long campaigns.

**Codex improvement:** Split the problem into reusable prompt categories instead of one mega-prompt.

**User improvement:** Asked how to make this available across projects, not only inside the current folder.

**Final agreement:** Stable patterns belong in docs; project setup belongs in rollout/sync guidance.

**Implemented:**

- `docs/daily-prompts.md`
- `docs/project-rollout-template.md`

**Important decision:** The prompt library should be practical and copy-pasteable, but not make the user micromanage every agent step.

### 2026-04-10 16:03:05 to 17:55:11 - Bootstrap And Sync Scripts Start

**Evidence:**

- `scripts/bootstrap-project-instructions.ps1` created 2026-04-10 16:03:05.
- `scripts/sync-project-instructions.ps1` created 2026-04-10 16:06:42.
- `scripts/sync-all-project-instructions.ps1` created 2026-04-10 17:55:11.

**User intent:** Avoid manually copying instruction files into every project.

**Codex improvement:** Proposed project bootstrap/sync scripts.

**User improvement:** Clarified that existing repos also need syncing, not just new repo bootstrap.

**Final agreement:** Use local per-project instruction files, generated from a central hub.

**Implemented:**

- early bootstrap and sync scripts
- propagation template folder

**Later correction:** This early system eventually evolved into `scripts/propagate-to-all.ps1`, `workflow/sync-state.json`, and template-based propagation.

### 2026-04-10 16:06:42 - `AGENTS.template.md` Is Born

**Evidence:** `propagate-templates/AGENTS.template.md` created 2026-04-10 16:06:42.

**User intent:** Make Codex and similar agents automatically know the project's best practices.

**Codex improvement:** Use `AGENTS.md` as the local project instruction file.

**User improvement:** Asked whether there is a global alternative and how existing repos receive it.

**Final agreement:** Codex relies on local `AGENTS.md`; central hub generates or syncs those files. OpenCode can also use global/project config, but Codex project behavior should be made explicit through local files.

**Implemented:**

- `propagate-templates/AGENTS.template.md`
- later propagation to topic folders

**Do not misunderstand:** `AGENTS.md` is not meant to contain every deep explanation. It should be concise and link to deeper docs.

### 2026-04-10 18:36:28 - Reasoning-Level Guidance Added

**Evidence:** `docs/codex-reasoning-guide.md` created 2026-04-10 18:36:28.

**User intent:** Understand whether to use low, medium, high, or extra-high reasoning for different tasks.

**Codex improvement:** Turned reasoning choice into a routing guide, not a vibe guess.

**User improvement:** Asked whether higher reasoning smartly scales down or mostly uses more effort.

**Final agreement:** Higher reasoning is a ceiling and tends to use more on average; choose the lightest level that preserves correctness, but use high or extra-high for integration, architecture, and ambiguous high-impact work.

**Implemented:**

- `docs/codex-reasoning-guide.md`
- later model-routing material in `docs/model-selection-guide.md`

**Key lesson:** Reasoning level is a cost-quality control, not a moral ranking.

### 2026-04-11 10:41:40 - Learn Claude Code Lessons Absorbed

**Evidence:** `archive/learn-claude-code-lessons.md` created 2026-04-11 10:41:40.

**User intent:** Analyze `learn-claude-code` and integrate useful knowledge into the hub.

**Codex improvement:** Treated external repos as source material to evaluate, compress, and integrate rather than copy wholesale.

**User improvement:** Asked for comparison, contrast, compression, and cleanup.

**Final agreement:** External sources should be archived or distilled, not pasted into hot-path instructions.

**Implemented:**

- archived lessons file
- distilled guidance in core docs

**Important decision:** Keep source context, but compress the operational rule.

### 2026-04-11 12:17:10 - Token Efficiency Becomes A Core Concern

**Evidence:** `docs/token-efficient-prompting.md` created 2026-04-11 12:17:10.

**User intent:** Do more with fewer tokens and avoid bloated prompting.

**Codex improvement:** Converted that into a doctrine: high-signal context, compact handoffs, avoid stable instruction repetition, and route by task.

**User improvement:** Later added sources such as `caveman` and asked whether "less words" should be integrated.

**Final agreement:** Be concise, but not blindly terse. Compress stable context, preserve decisive evidence, and verify output.

**Implemented:**

- `docs/token-efficient-prompting.md`
- later agentic token-efficiency system in Session 42

**Key lesson:** Token efficiency is not "short at all costs"; it is "least context that preserves correctness."

### 2026-04-12 11:01:53 to 12:58:51 - Claude, Simon Willison, Boris, And Other Sources

**Evidence:**

- `archive/claude-code-best-practice-lessons.md` created 2026-04-12 11:01:53.
- `archive/simon-willison-agentic-engineering-lessons.md` created 2026-04-12 11:57:58.
- `archive/how-boris-uses-claude-code-lessons.md` created 2026-04-12 12:58:51.

**User intent:** Bring in serious external best practices, not just Codex's internal assumptions.

**Codex improvement:** Created a research-and-integration cycle: evaluate authority, extract durable patterns, integrate into the smallest correct doc.

**User improvement:** Repeatedly asked whether sources were relevant or too far from topic, and asked Codex to state the reasoning level needed before integration.

**Final agreement:** Evaluate first, integrate only if useful, compress after integration, and keep source archives out of the hot path.

**Implemented:**

- source-specific archive files
- updates to doctrine, TDD, token efficiency, learning, and agent workflow docs

**Key lesson:** A source can be high quality but still not belong in `AGENTS.md`.

### 2026-04-12 12:04:34 - Red-Green TDD Elevated

**Evidence:** `docs/tdd-with-agents.md` created 2026-04-12 12:04:34.

**User intent:** Check whether red-green TDD might be "the star of the show."

**Codex improvement:** Recognized TDD as more than testing. It is a shared steering mechanism between user and agent.

**User improvement:** Asked Codex to double-check the importance rather than simply accept the idea.

**Final agreement:** When behavior changes, prefer red-green TDD or the closest available verification loop.

**Implemented:**

- `docs/tdd-with-agents.md`
- TDD references in operating doctrine

**Why it mattered:** Tests became both quality control and a way for the user to learn while the agent builds.

### 2026-04-12 13:12:53 - Core Doctrine Consolidates

**Evidence:** `docs/core-agent-doctrine.md` created 2026-04-12 13:12:53.

**User intent:** Stop repeating the same prompt advice over and over.

**Codex improvement:** Consolidated recurring patterns into durable doctrine.

**User improvement:** Asked for strategies and prompts in markdown, and wanted the agent itself to use the knowledge base to improve future prompts.

**Final agreement:** The hub should be recursive: it stores prompt knowledge and also uses that knowledge to improve new user prompts automatically.

**Implemented:**

- `docs/core-agent-doctrine.md`
- later `AGENTS.md` rule: supply missing structure when safe

**Key rule born here:** The user should not need to prompt perfectly; the agent should add missing structure when safe.

### 2026-04-12 13:55:40 to 15:56:32 - Cross-Project Memory Loop Starts

**Evidence:**

- `docs/cross-project-memory-loop.md` created 2026-04-12 13:55:40.
- `scripts/harvest-topic-insights.ps1` created 2026-04-12 13:55:40.
- `scripts/build-cross-domain-candidates.ps1` created 2026-04-12 14:03:25.
- `workflow/cross-domain-review-state.json` created 2026-04-12 15:56:32.

**User intent:** If one project learns something valuable, other projects should benefit.

**Codex improvement:** Proposed a lesson flow: local lesson capture, harvest, candidate review, promotion, propagation.

**User improvement:** Clarified that every project should be able to update its own local instructions and later merge durable lessons back to the main hub.

**Final agreement:** Topic folders get `topic-insights.md`; the hub harvests and promotes cross-domain lessons.

**Implemented:**

- cross-project memory loop doc
- harvest/build candidate scripts
- review state

**Later correction:** `repo-lessons.md` became `topic-insights.md` to avoid repo-only framing.

### 2026-04-12 16:03:02 - Learning While Building Captured

**Evidence:** `docs/learning-while-building-with-agents.md` created 2026-04-12 16:03:02.

**User intent:** The user noticed AI-assisted work was moving faster than their understanding and found that scary.

**Codex improvement:** Turned this into a workflow problem: learning checkpoints, macro-to-micro explanations, retrieval practice, and teaching mode.

**User improvement:** Said some practices are under "what the prompter should do," but the agent should do them when the user is not practiced enough.

**Final agreement:** The agent should help manage learning load, not just execute tasks.

**Implemented:**

- `docs/learning-while-building-with-agents.md`
- teaching rules in `AGENTS.md`
- later session checkpointing and handover docs

**Key lesson:** Speed without understanding is not success for this user.

### 2026-04-13 21:54:36 - Main Propagation Script Created

**Evidence:** `scripts/propagate-to-all.ps1` created 2026-04-13 21:54:36.

**User intent:** Make syncing instructions to many projects practical.

**Codex improvement:** Created a central propagation script.

**User improvement:** Asked what "sync a few existing repos" and "sync all repos" meant, and clarified that existing repos need direct placement too.

**Final agreement:** Propagation should work for existing folders, not just future bootstrap.

**Implemented:**

- `scripts/propagate-to-all.ps1`
- later dynamic template discovery and sync state

**Important decision:** Do not rely on the user manually editing a `repos.txt` forever; maintain a registry/state system.

### 2026-04-13 22:33:17 - Session Recovery Guidance Added

**Evidence:** `docs/session-recovery-guide.md` created 2026-04-13 22:33:17.

**User intent:** Understand whether moving folders or opening new threads loses chat memory.

**Codex improvement:** Explained that chat memory does not move with folder paths and introduced handover/recovery practices.

**User improvement:** Asked whether chat memory can be transferred and later requested high-fidelity handovers.

**Final agreement:** Durable context must be written to files. The agent should produce handovers when context transfer matters.

**Implemented:**

- `docs/session-recovery-guide.md`
- later `docs/agent-context-handover.md`
- later `workflow/session-state.json`

**Key lesson:** Repository facts are not enough; session rationale must be preserved.

### 2026-04-14 00:04:27 - Quality Standards Created

**Evidence:** `docs/quality-standards.md` created 2026-04-14 00:04:27.

**User intent:** Keep the growing workspace from becoming messy or low-quality.

**Codex improvement:** Added quality/audit expectations.

**User improvement:** Repeatedly requested cleanup, compression, and making sure useless temporary files are removed.

**Final agreement:** Growth needs audits, cleanup rules, and preservation rules.

**Implemented:**

- `docs/quality-standards.md`
- later `scripts/audit-folder-quality.ps1`
- later repo-quality analysis protocol

**Important nuance:** Cleanup should remove junk, but not delete historical or provenance material just because it is old.

### 2026-04-14 13:21:18 - AI Product Building Doc Created

**Evidence:** `docs/ai-product-building.md` created 2026-04-14 13:21:18.

**User intent:** Expand beyond prompting into using agents to build products and repos.

**Codex improvement:** Integrated agent architecture, product-building workflows, PR communication patterns, and later sequence diagrams.

**User improvement:** Kept pushing for practical repo work, not just theory.

**Final agreement:** Product-building guidance belongs in its own doc, not in prompt templates.

**Implemented:**

- `docs/ai-product-building.md`

### 2026-04-14 13:22:22 to 13:22:41 - Research System Formalized

**Evidence:**

- `research/README.md` created 2026-04-14 13:22:22.
- `research/research-prompt.md` created 2026-04-14 13:22:29.
- `docs/research-findings.md` created 2026-04-14 13:22:41 from earlier research material.

**User intent:** Find serious, authoritative sources and integrate them.

**Codex improvement:** Created a research workflow with evaluation, analysis, integration, and logging.

**User improvement:** Asked to "find more authoritative sources" and later to make sure agents do not use random sources.

**Final agreement:** Research should not be collection for its own sake. It must become operational guidance or be archived.

**Implemented:**

- research folder
- research prompt
- research/findings/integration workflow
- later `docs/research-methodology.md`

### 2026-04-15 13:33:43 - Git/GitHub Best Practices Added

**Evidence:** `docs/git-github-best-practices.md` created 2026-04-15 13:33:43; `propagate-templates/git-github-best-practices.template.md` created 2026-04-15 13:34:16.

**User intent:** Keep agents aligned with real repo conventions, especially PRs, issues, maintainer tone, and unwritten norms.

**Codex improvement:** Added Git/GitHub best-practice docs and propagated templates.

**User improvement:** Provided a Scoop lessons file and emphasized that actual maintainer consensus beats stale written rules.

**Final agreement:** Before PR/issue work, agents should inspect templates, recent PRs/issues, maintainer comments, and local lessons.

**Implemented:**

- `docs/git-github-best-practices.md`
- `propagate-templates/git-github-best-practices.template.md`

**Key lesson:** A technically correct PR can still be wrong if it does not fit maintainer culture.

### 2026-04-15 18:05:56 - Cleanup Protection Added

**Evidence:** `propagate-templates/.cleanup-protect.template.md` created 2026-04-15 18:05:56.

**User intent:** Clean up useless files without accidentally deleting important propagated instructions.

**Codex improvement:** Added a protection marker/template and cleanup rules.

**User improvement:** Repeatedly asked for cleanup but also wanted history preserved.

**Final agreement:** Cleanups need protected files, quality checks, and explicit classification before deletion.

**Implemented:**

- `.cleanup-protect` template
- later propagated cleanup protection

### 2026-04-16 14:54:12 - Cognitive Identity Becomes A Major Theme

**Evidence:** `docs/cognitive-identity.md` created 2026-04-16 14:54:12.

**User intent:** Understand how to learn and think while using powerful AI agents without becoming dependent or deskilled.

**Codex improvement:** Turned this into a cognitive identity and learning-risk framework.

**User improvement:** Wanted the agent to help the user learn efficiently without forcing full manual learning.

**Final agreement:** The workspace should optimize for cognitive partnership, not just output volume.

**Implemented:**

- `docs/cognitive-identity.md`
- later executive summary and learning-path integration

### 2026-04-17 22:32:51 - Handover System Created

**Evidence:** `docs/agent-context-handover.md` created 2026-04-17 22:32:51.

**User intent:** Avoid losing chat memory when switching threads or models.

**Codex improvement:** Created handover templates and procedures.

**User improvement:** Later asked for a high-fidelity handover that preserves hidden project history, decisions, rejected paths, preferences, risks, and continuation prompts.

**Final agreement:** Handover files must preserve rationale and non-obvious context, not just file changes.

**Implemented:**

- `docs/agent-context-handover.md`
- history reconstruction prompts
- later `workflow/session-state.json`

**Key lesson:** "Scan the repo" is not enough. A new agent needs session knowledge.

### 2026-04-19 08:00 to 10:00 - Folder Structure Standardization

**Evidence:** Archived session window in `archive/history-2026-04.md`; related files include cross-domain registry created 2026-04-19 10:53:06 and merge log created 2026-04-19 10:53:11.

**User intent:** Clean up many folders and make every project consistently usable by agents.

**Codex improvement:** Introduced `meta/`, standardized `HANDOVER.md`, renamed lesson files, and built a cross-domain system.

**User improvement:** Asked whether all projects should rescan folders and how to manually copy instructions into out-of-drive projects.

**Final agreement:** Each topic folder should have local instructions and a predictable layout; hub scripts handle propagation.

**Implemented:**

- `topic-insights.md` concept
- cross-domain registry
- merge log
- harvest/build/merge scripts
- bulk cleanup of stale artifacts

**Later correction:** `meta/` eventually became optional rather than always created.

### 2026-04-19 10:00 to 12:00 - Research Verification Framework

**Evidence:** Archived session window in `archive/history-2026-04.md`; `research/research-prompt.md` modified 2026-04-19 10:13:08.

**User intent:** Make research more reliable and current.

**Codex improvement:** Added source triangulation, confidence levels, and error impact audits.

**User improvement:** Corrected the agent's model knowledge and emphasized current best practices.

**Final agreement:** Agents must verify model/tool claims against current sources when facts may have changed.

**Implemented:**

- research prompt verification rules
- model selection corrections

### 2026-04-19 14:00 to 17:00 - Full Repository Sweep

**Evidence:** Archived session window in `archive/history-2026-04.md`.

**User intent:** Clean up the project and remove useless temporary files.

**Codex improvement:** Distinguished independent repos, stubs, stale analysis files, and propagated instruction files.

**User improvement:** Pushed for cleanup but wanted safe handling of meaningful folders.

**Final agreement:** Clean aggressively only after classification. Independent repos and meaningful artifacts stay.

**Implemented:**

- deleted stub folders
- kept independent git repos as exceptions
- fixed old template markers
- regenerated harvest data

### 2026-04-19 18:00 to 18:30 - Teaching While Doing Added

**Evidence:** Archived session window in `archive/history-2026-04.md`.

**User intent:** Learn from what the agent does without slowing every task down.

**Codex improvement:** Added teaching triggers and explanation patterns.

**User improvement:** Wanted efficient teaching, not exhaustive tutorials.

**Final agreement:** Teach deliberately: macro first, then key concept, then only the details needed.

**Implemented:**

- teaching guidance in `AGENTS.md`
- later learning and onboarding prompt library split

### 2026-04-19 19:00 to 23:30 - Writing, Voice, And Detection Thread

**Evidence:** Archived sessions 5 to 11 in `archive/history-2026-04.md`; `personal-voice/` files later created 2026-04-20 00:39 to 00:44.

**User intent:** Understand personal writing style, beginner reasoning, human voice, Chinese/English writing differences, and detection risks.

**Codex improvement:** Built a personal voice system and writing guidance.

**User improvement:** Kept pushing from surface style toward genuine reasoning, beginner cognition, personal voice, and language-specific patterns.

**Final agreement:** The durable useful part is authentic voice support and style transfer from the user's own samples. Future agents should avoid turning this into dishonest academic bypass work.

**Implemented:**

- `personal-voice/`
- voice profile and style injection files
- prompt-library voice/humanization material

**Important risk:** Future agents must treat this as personal voice and authorship support, not as a license to produce deceptive work.

### 2026-04-20 00:39:16 to 00:40:34 - Personal Voice System Created

**Evidence:**

- `personal-voice/README.md` created 2026-04-20 00:39:16.
- `personal-voice/VOICE-PROFILE.md` created 2026-04-20 00:39:30.
- `personal-voice/STYLE-INJECT.md` created 2026-04-20 00:39:38.
- `personal-voice/CORRECTIONS.log.md` created 2026-04-20 00:39:44.
- `scripts/extract-voice-profile.ps1` created 2026-04-20 00:40:34.

**User intent:** Have AI learn the user's writing style continuously, not through one-shot prompting.

**Codex improvement:** Created a voice profile, samples folder, style injection prompt, correction log, and extraction script.

**User improvement:** Supplied or pointed to source writing samples and wanted a system, not a single rewrite.

**Final agreement:** Personal voice is a maintained subsystem.

**Implemented:**

- `personal-voice/`
- extraction script
- `AGENTS.md` reference to read voice profile before writing as the user

### 2026-04-20 20:02:45 - Propagated Audit Script Template Added

**Evidence:** `propagate-templates/audit-folder-quality.template.ps1` created 2026-04-20 20:02:45.

**User intent:** Make each folder able to check its own quality.

**Codex improvement:** Added a propagated audit script rather than keeping audit only at the hub.

**User improvement:** Wanted cleanup and quality to be repeatable across current and future projects.

**Final agreement:** Topic folders should receive not only instructions but also local validation tools.

**Implemented:**

- audit template
- later propagated `audit-folder-quality.ps1` to topic folders

### 2026-04-20 22:23:38 - Repo Quality Analysis Protocol

**Evidence:** `docs/repo-quality-analysis-protocol.md` created 2026-04-20 22:23:38.

**User intent:** Clean and compress, but do not lose essential differences or history.

**Codex improvement:** Added a protocol for redundancy analysis, compression, and deletion.

**User improvement:** Reacted to the risk of over-cleanup and asked for better judgment.

**Final agreement:** Similar content is not automatically redundant. Compression must preserve audience, source, and decision value.

**Implemented:**

- `docs/repo-quality-analysis-protocol.md`
- cleanup rules in `AGENTS.md`

### 2026-04-21 to 2026-04-22 - Session State And Checkpointing

**Evidence:**

- `workflow/session-state.template.json` created 2026-04-21 23:41:50.
- `docs/session-checkpoint.md` created 2026-04-21 23:42:54.
- `workflow/session-state.json` created 2026-04-22 14:16:21.

**User intent:** Avoid context loss, repeated rescans, and uncertain continuity after long sessions.

**Codex improvement:** Added session state and proactive checkpointing.

**User improvement:** Asked for high-fidelity handovers and wanted future agents to understand what was done previously.

**Final agreement:** Every meaningful session should update session state and history. Long work needs checkpointing before context exhaustion.

**Implemented:**

- `workflow/session-state.json`
- `docs/session-checkpoint.md`
- `workflow/session-state.template.json`

**Key lesson:** Write state before exhaustion, not after.

### 2026-04-22 14:55:56 - Repository Optimization And Archive Split

**Evidence:**

- `archive/history-2026-04.md` created 2026-04-22 14:55:56.
- `archive/research-log-2026-04.md` created 2026-04-22 14:55:56.
- `archive/prompt-templates-2026-04-pre-split.md` created 2026-04-22 14:55:56.
- prompt-library split files created 2026-04-22 14:55:56.

**User intent:** Keep the workspace useful without huge hot-path files.

**Codex improvement:** Archived full history and split prompt templates into smaller topic files.

**User improvement:** Had repeatedly requested compression and cleanup while preserving essentials.

**Final agreement:** Hot-path files should be compact; full historical material belongs in archive.

**Implemented:**

- archived pre-optimization history
- prompt library split
- compact `HISTORY.md`

### 2026-04-22 14:57:05 - Workspace System Overview Created

**Evidence:** `docs/workspace-system-overview.md` created 2026-04-22 14:57:05.

**User intent:** Let a new agent understand the system quickly.

**Codex improvement:** Built a 30-second system map.

**User improvement:** Wanted future agents to avoid full rescans and context waste.

**Final agreement:** Startup order is: session state, AGENTS, system overview, README, then task files.

**Implemented:**

- `docs/workspace-system-overview.md`
- current startup protocol

### 2026-04-22 15:25:18 to 15:50:28 - Workspace Command Wrapper And Tooling

**Evidence:**

- `scripts/ws.ps1` created 2026-04-22 15:25:18.
- `scripts/test-ws.ps1` created 2026-04-22 15:25:18.
- `scripts/ws.sh` created 2026-04-22 15:50:28.
- `docs/repo-tooling.md` created 2026-04-22 15:50:28.

**User intent:** Give agents reliable tools and avoid wasted attempts with missing tools.

**Codex improvement:** Created a shared wrapper and tooling guide.

**User improvement:** Confirmed installed tools via Scoop and asked the agent to recommend new installs only when needed.

**Final agreement:** PowerShell is the mutating layer for this Windows workspace; WSL/native tools are useful for read-only inspection.

**Implemented:**

- `scripts/ws.ps1`
- `scripts/ws.sh`
- `docs/repo-tooling.md`

### 2026-04-22 16:33:18 - Research Methodology Added

**Evidence:** `docs/research-methodology.md` created 2026-04-22 16:33:18.

**User intent:** Ensure agents use authoritative sources, not random search results.

**Codex improvement:** Created a source hierarchy and evaluation checklist.

**User improvement:** Asked for serious sources and current best practices repeatedly.

**Final agreement:** Vendor docs and primary sources outrank random blogs; AI benchmark claims require scrutiny.

**Implemented:**

- `docs/research-methodology.md`

### 2026-04-22 16:51:38 - Early History Placeholder Created

**Evidence:** `archive/early-history.md` created 2026-04-22 16:51:38.

**User intent:** Preserve full early session history.

**Codex improvement:** Created a placeholder and linked it from `HISTORY.md`.

**User improvement:** Later asked for this richer `EARLY-HISTORY-WITH-CODEX.md` with detailed decision chains.

**Final agreement:** Early history needs a high-fidelity narrative, not just a table row.

**Implemented then:**

- placeholder `archive/early-history.md`

**Implemented now:**

- `EARLY-HISTORY-WITH-CODEX.md`

### 2026-04-22 19:59:44 onward - Agentic Workflow System

**Evidence:**

- `docs/agentic-workflows.md` created 2026-04-22 19:59:44.
- `.opencode/agents/explorer.md` created 2026-04-22 20:39:51.
- `.opencode/agents/drafter.md` created 2026-04-22 20:39:57.
- `.opencode/agents/debugger.md` created 2026-04-22 20:40:02.
- `.opencode/agents/reviewer.md` created 2026-04-22 20:40:07.
- `.opencode/agents/planner.md` created 2026-04-22 22:06:18.
- `.opencode/agents/scribe.md` created 2026-04-22 22:36:45.
- `.opencode/agents/gardener.md` created 2026-04-22 22:36:53.

**User intent:** Use agents efficiently and reduce token burn, but keep continuity.

**Codex improvement:** Designed an Orchestrator plus specialist-agent system.

**User improvement:** Pushed back on over-orchestration and wanted direct handling by default.

**Final agreement:** Direct handling is default. Subagents are exceptions for clearly bounded specialist tasks.

**Implemented:**

- `docs/agentic-workflows.md`
- `.opencode/agents/`
- `opencode.json`
- model routing and disclosure rules

**Key lesson:** Agentic does not mean "spawn agents for everything."

### 2026-04-23 00:21:25 - Codex Agent Workflows Added

**Evidence:** `docs/codex-agent-workflows.md` created 2026-04-23 00:21:25.

**User intent:** Understand how this applies to Codex specifically, not only OpenCode.

**Codex improvement:** Added Codex Desktop-specific workflow guidance.

**User improvement:** Wanted reasoning and tool use to be adaptive without needing constant manual expertise.

**Final agreement:** Codex should normally handle work directly, use available tools, and only delegate or escalate when the task merits it.

**Implemented:**

- `docs/codex-agent-workflows.md`

### 2026-04-23 08:59:46 - Sync From Hub Template

**Evidence:** `propagate-templates/sync-from-hub.template.ps1` created 2026-04-23 08:59:46.

**User intent:** Let individual projects pull updated hub guidance easily.

**Codex improvement:** Added self-service sync script template.

**User improvement:** Wanted both new and existing projects handled.

**Final agreement:** Propagated projects should be able to sync from the hub without remembering the whole propagation command.

**Implemented:**

- `propagate-templates/sync-from-hub.template.ps1`

### 2026-04-23 13:01:30 to 13:38:38 - OpenCode Skills System

**Evidence:**

- `.opencode/skills/propagate/SKILL.md` created 2026-04-23 13:01:30.
- `.opencode/skills/audit-quality/SKILL.md` created 2026-04-23 13:01:37.
- `.opencode/skills/session-handoff/SKILL.md` created 2026-04-23 13:01:46.
- `.opencode/skills/research-deep/SKILL.md` created 2026-04-23 13:08:24.
- `.opencode/skills/cross-domain-harvest/SKILL.md` created 2026-04-23 13:08:40.
- skill references created 2026-04-23 13:38:33 and 13:38:38.

**User intent:** Turn repeated workflows into agent capabilities.

**Codex improvement:** Added OpenCode skills for propagation, audit, session handoff, deep research, and cross-domain harvest.

**User improvement:** Wanted the agent to know and apply practices automatically when relevant.

**Final agreement:** Repeated workflows should become reusable skills or templates rather than repeated instructions.

**Implemented:**

- `.opencode/skills/`
- `propagate-templates/skills-template/README.md`

## Decision Chains In The User's Requested Shape

### Decision Chain 1 - Better Prompting Became A Knowledge Base

**User intent:** "How do I prompt AI properly? I only have simple prompts."

**Codex improvement:** Convert scenarios into reusable prompt templates and strategy docs.

**User improvement:** Provided Gemini's prompt drafts and asked Codex to learn from them if better.

**Final agreement:** Use structured prompts with role, scenario, context, task, constraints, verification, and output shape, but let the agent supply missing structure when safe.

**Implemented:**

- `docs/daily-prompts.md`
- `docs/prompt-templates.md`
- later `docs/prompt-library/`

### Decision Chain 2 - CI Failure Prompt Became Debugging Doctrine

**User intent:** Prompt Codex to efficiently and comprehensively fix a failed CI build.

**Codex improvement:** Add root-cause analysis, smallest maintainable fix, local reproduction, logs, and residual uncertainty.

**User improvement:** Wanted the agent to derive the fix rather than requiring perfect manual context.

**Final agreement:** CI prompt should include failing job, recent changes, relevant files, logs, constraints, and verification target; the agent should inspect CI/logs if tools are available.

**Implemented:**

- debugging prompts in prompt library
- verification-first doctrine
- later GitHub CI skill availability in current environment

### Decision Chain 3 - Teach Me What You Did Became Macro-To-Micro Learning

**User intent:** Learn efficiently from agent work that is beyond current scope.

**Codex improvement:** Use macro-to-micro explanation: environment, tactical change, significance, key concept.

**User improvement:** Asked for efficient learning, not direct exhaustive study.

**Final agreement:** Teaching mode should summarize architecture first, then what changed, tools used, why alternatives were not chosen, and one core concept.

**Implemented:**

- `docs/learning-while-building-with-agents.md`
- teaching mode rules
- prompt library learning/onboarding section

### Decision Chain 4 - Repo Onboarding Became Architecture-First Repo Teaching

**User intent:** "How do I make Codex teach me this repo?"

**Codex improvement:** Provide repo DNA: architecture, directory landscape, stack/tooling, execution lifecycle, non-obvious senior insight.

**User improvement:** Wanted reusable prompts rather than one-off repo explanations.

**Final agreement:** Repo teaching prompts should create a mental map before line-by-line details.

**Implemented:**

- repo onboarding prompts
- workspace overview concept
- prompt-library learning and repo workflow sections

### Decision Chain 5 - "Continue" Became Phase Continuation Protocol

**User intent:** Continue a long Scoop manifest campaign after a Phase 2 update.

**Codex improvement:** Suggested not just saying "continue" unless state is unambiguous; restate next phase, objective, safety gate, and outputs.

**User improvement:** Supplied detailed Phase 2 status and wanted to know whether "continue" was enough.

**Final agreement:** For long campaigns, continuation prompts should include phase, target queue, no-public-action gate, validation criteria, and output files.

**Implemented:**

- campaign continuation prompt guidance
- Scoop lessons moved later to Fluent Search Manifest content

### Decision Chain 6 - Repo Culture Became Living Convention Checks

**User intent:** Keep agents aligned with unwritten repo culture and PR conventions.

**Codex improvement:** Add cultural audit: read local lessons, templates, recent issues/PRs, merged PR titles, maintainer feedback.

**User improvement:** Provided the Scoop Manifest + PR lessons file and asked whether it should be referenced by each repo.

**Final agreement:** Local lessons outrank generic defaults when they reflect maintainer consensus.

**Implemented:**

- Git/GitHub best practices doc/template
- topic-insights system
- repo culture prompts

### Decision Chain 7 - Current Best Practices Became Research Methodology

**User intent:** Avoid outdated practices and make agents read current errors/GitHub GUI/workflow details.

**Codex improvement:** Add current-knowledge drift protection and source hierarchy.

**User improvement:** Asked for OpenAI and Claude docs, then more authoritative sources.

**Final agreement:** Browse or verify time-sensitive claims; prefer primary sources; integrate only durable patterns.

**Implemented:**

- research workflow
- `docs/research-methodology.md`
- model-selection guide updates

### Decision Chain 8 - Reasoning Choice Became Routing Policy

**User intent:** Know whether to use high or extra-high reasoning.

**Codex improvement:** Provide reasoning-level guidance and explain tradeoffs.

**User improvement:** Asked whether xhigh automatically scales down or mostly spends more.

**Final agreement:** Use medium for routine work, high for integration/architecture, extra-high for complex ambiguous high-impact synthesis, and do not use premium effort reflexively.

**Implemented:**

- `docs/codex-reasoning-guide.md`
- `docs/model-selection-guide.md`

### Decision Chain 9 - External Repos Became Evaluate-Then-Integrate

**User intent:** Scan `learn-claude-code`, `claude-code-best-practice`, Simon Willison, Boris, and other sources.

**Codex improvement:** Evaluate source quality, extract patterns, compare/contrast, integrate, compress, cleanup.

**User improvement:** Asked if some sources were too far from topic and asked for reasoning before integration.

**Final agreement:** Source ingestion must have an evaluation phase before integration.

**Implemented:**

- archive source lesson files
- research logs
- integration logs
- compressed hot-path docs

### Decision Chain 10 - Less Words Became Token Efficiency, Not Minimalism

**User intent:** Investigate "using less words."

**Codex improvement:** Evaluate brevity sources and connect them to token efficiency.

**User improvement:** Asked for serious sources if a given source was not enough.

**Final agreement:** Prefer concise prompts and compact handoffs, but preserve enough structure to avoid errors.

**Implemented:**

- `docs/token-efficient-prompting.md`
- later agentic token-efficiency system

### Decision Chain 11 - Tooling Requests Became Windows Tool Baseline

**User intent:** Know what tools Codex uses and install useful ones.

**Codex improvement:** Identify baseline tools and suggest Scoop installs.

**User improvement:** Installed and reported paths for `git`, `rg`, `fd`, `jq`, `gh`, `fzf`, `bat`, `delta`, `uv`, `python`, `node`, `pnpm`, and `bun`.

**Final agreement:** Use available tools; if a missing tool matters, state the problem and recommend the install at that moment.

**Implemented:**

- Windows tooling docs
- `docs/repo-tooling.md`
- workspace command wrappers

### Decision Chain 12 - Cross-Project Access Became Propagation

**User intent:** Make all projects access this central instruction folder without copy-pasting.

**Codex improvement:** Proposed local `AGENTS.md`, templates, sync scripts, and OpenCode config.

**User improvement:** Clarified that current existing repos need syncing and some are outside the main drive.

**Final agreement:** The hub owns templates; topic folders get generated local files; out-of-tree projects need manual copy/sync unless added to registry.

**Implemented:**

- propagation scripts
- propagation templates
- cross-domain registry
- sync state

### Decision Chain 13 - Context Loss Became Handover And Session State

**User intent:** Avoid losing chat memory when opening new threads or moving folders.

**Codex improvement:** Create handover prompts and session state files.

**User improvement:** Asked for high-fidelity handover sections that preserve hidden history, rejected paths, user preferences, intangible context, risks, blockers, and continuation prompts.

**Final agreement:** Handover must capture rationale, not just facts.

**Implemented:**

- `docs/agent-context-handover.md`
- `workflow/session-state.json`
- `HISTORY.md`
- archive history

### Decision Chain 14 - Concise AGENTS Became Hot-Path Compression

**User intent:** Reference Thariq's advice that agent instructions should be concise.

**Codex improvement:** Treated `AGENTS.md` as an operational index rather than a knowledge dump.

**User improvement:** Asked to align markdown with conciseness without losing essentials.

**Final agreement:** Keep hot-path files compact; move deep references into docs and archive.

**Implemented:**

- compressed `AGENTS.md`
- `docs/workspace-system-overview.md`
- archive split and prompt-library split

### Decision Chain 15 - Cleanup Became Safe Classification

**User intent:** "Cleanup every file that is useless, especially temporary files."

**Codex improvement:** Classify files before deletion: active repo, generated artifact, stale analysis, protected instruction, archive-worthy history.

**User improvement:** Wanted aggressive cleanup but not loss of useful context.

**Final agreement:** Use cleanup protection and quality protocol before deleting.

**Implemented:**

- `.cleanup-protect`
- quality audit scripts
- repo-quality analysis protocol
- root drift cleanup sessions

## Rejected Or Corrected Paths

### Rejected: One Giant Prompt File

**Why rejected:** Too large for agents to follow and too expensive for context.

**Replacement:** Hot-path files link to deep docs and archives.

### Rejected: Manual Copy-Paste For Every Project

**Why rejected:** Does not scale, causes drift, and depends on user memory.

**Replacement:** Propagation templates and sync scripts.

### Rejected: Treating Written Rules As Always Current

**Why rejected:** Maintainers often follow living conventions not captured in docs.

**Replacement:** Inspect recent issues/PRs and local lessons before public repo work.

### Rejected: "Continue" Without Rehydrating State

**Why rejected:** Long tasks lose safety gates and phase context.

**Replacement:** Continuation prompts with phase, objective, safety gate, output files, and verification.

### Rejected: Agent Speed As The Only Metric

**Why rejected:** The user explicitly fears work outrunning understanding.

**Replacement:** Teaching checkpoints, macro-to-micro explanations, TDD, and session handovers.

### Rejected: Over-Orchestrating Agents

**Why rejected:** Spawning specialists for simple work wastes time and tokens.

**Replacement:** Direct handling by default; subagents only for bounded specialist tasks.

### Corrected: `meta/` Everywhere

**Original idea:** Bulk-create `meta/` folders everywhere.

**Correction:** `meta/` is optional and should exist only when a project has durable local context.

### Corrected: Cross-Domain System Location

**Original issue:** Workflow files drifted through root and scripts.

**Correction:** Executable code belongs in `scripts/`; state, registries, queues, and logs belong in `workflow/`.

### Corrected: No Git History

**Original state:** Hub had no `.git`, so history was timestamp/session based.

**Correction:** A Git repo was later initialized for rollback safety. However, early history before initial commit still relies on files, archive, and session reconstruction.

## What Another Agent Must Not Misunderstand

1. This is not a normal software app repo.
2. The hub's product is workflow knowledge, propagation infrastructure, and durable context.
3. The user's main goal is not maximum automation. It is compounding capability with understanding.
4. `AGENTS.md` should stay concise. Do not stuff it with every lesson.
5. `workflow/session-state.json` is the first resume file.
6. `HISTORY.md` is a compact ledger; archives preserve long-form history.
7. The cross-domain system exists to promote transferable lessons, not to blindly copy everything.
8. Local project conventions matter. Real maintainer behavior can override generic rules.
9. Personal voice materials must be used for authentic user voice support, not dishonest bypass.
10. Cleanup requires classification first.
11. Propagation should preserve local custom sections.
12. Direct handling is the default for agents; orchestration is the exception.

## Current Durable Architecture Produced By The Early Sessions

```text
AI Prompting/
|- AGENTS.md                         current operating contract
|- README.md                         navigation and learning paths
|- HISTORY.md                        compact session ledger
|- EARLY-HISTORY-WITH-CODEX.md       this high-fidelity early handover
|- docs/                             stable knowledge base
|- research/                         active research intake
|- workflow/                         live state, registries, queues, sync state
|- scripts/                          automation and validation
|- propagate-templates/              source templates for topic folders
|- archive/                          full older logs, raw sources, snapshots
|- personal-voice/                   user voice subsystem
|- .opencode/                        OpenCode agents and skills
`- opencode.json                     OpenCode local config
```

## Continuation Prompt For A Future Agent

```text
You are taking over the AI Prompting hub.

Start by reading:
1. workflow/session-state.json
2. AGENTS.md
3. docs/workspace-system-overview.md
4. README.md
5. EARLY-HISTORY-WITH-CODEX.md if the task touches origin/history/propagation/rationale

Treat this workspace as a living knowledge and propagation hub, not an app repo.

Preserve the user's priorities:
- supply missing structure when safe
- move quickly but keep the user learning
- verify aggressively
- keep hot-path instructions concise
- preserve rationale in history and handovers
- use local project conventions and lessons
- propagate shared lessons without overwriting local customization

If you change durable workflow guidance, update the smallest correct doc, run relevant validation, update session state/history, and propagate only when shared topic-folder defaults changed.
```

## Appendix A - Condensed Artifact Timeline

| Timestamp | Event |
|---:|---|
| 2026-04-10 15:48:33 | `README.md` created; hub begins. |
| 2026-04-10 16:02:19 | `docs/daily-prompts.md` and `docs/project-rollout-template.md` created. |
| 2026-04-10 16:03:05 | `scripts/bootstrap-project-instructions.ps1` created. |
| 2026-04-10 16:06:42 | `propagate-templates/AGENTS.template.md`, `topic-insights.template.md`, and `scripts/sync-project-instructions.ps1` created. |
| 2026-04-10 17:55:11 | `scripts/sync-all-project-instructions.ps1` created. |
| 2026-04-10 18:36:28 | `docs/codex-reasoning-guide.md` created. |
| 2026-04-11 10:41:40 | `archive/learn-claude-code-lessons.md` created. |
| 2026-04-11 12:17:10 | `docs/token-efficient-prompting.md` created. |
| 2026-04-12 11:01:53 | `archive/claude-code-best-practice-lessons.md` created. |
| 2026-04-12 11:57:58 | `archive/simon-willison-agentic-engineering-lessons.md` created. |
| 2026-04-12 12:04:34 | `docs/tdd-with-agents.md` created. |
| 2026-04-12 12:58:51 | `archive/how-boris-uses-claude-code-lessons.md` created. |
| 2026-04-12 13:12:53 | `docs/core-agent-doctrine.md` created. |
| 2026-04-12 13:55:40 | `docs/cross-project-memory-loop.md` and `scripts/harvest-topic-insights.ps1` created. |
| 2026-04-12 14:03:25 | `scripts/build-cross-domain-candidates.ps1` created. |
| 2026-04-12 15:56:32 | `workflow/cross-domain-review-state.json` created. |
| 2026-04-12 16:03:02 | `docs/learning-while-building-with-agents.md` created. |
| 2026-04-13 21:54:36 | `scripts/propagate-to-all.ps1` created. |
| 2026-04-13 22:33:17 | `docs/session-recovery-guide.md` created. |
| 2026-04-14 00:04:27 | `docs/quality-standards.md` created. |
| 2026-04-14 13:21:18 | `docs/ai-product-building.md` created. |
| 2026-04-14 13:22:22 | `research/README.md` created. |
| 2026-04-14 13:22:29 | `research/research-prompt.md` created. |
| 2026-04-15 13:33:43 | `docs/git-github-best-practices.md` created. |
| 2026-04-15 13:34:16 | `propagate-templates/git-github-best-practices.template.md` created. |
| 2026-04-15 18:05:56 | `propagate-templates/.cleanup-protect.template.md` created. |
| 2026-04-16 14:54:12 | `docs/cognitive-identity.md` created. |
| 2026-04-17 22:32:51 | `docs/agent-context-handover.md` created. |
| 2026-04-19 10:53:06 | `workflow/cross-domain-registry.md` created. |
| 2026-04-19 10:53:11 | `workflow/merge-log.md` created. |
| 2026-04-20 00:39:16 | `personal-voice/README.md` created. |
| 2026-04-20 00:39:30 | `personal-voice/VOICE-PROFILE.md` created. |
| 2026-04-20 00:40:34 | `scripts/extract-voice-profile.ps1` created. |
| 2026-04-20 20:02:45 | `propagate-templates/audit-folder-quality.template.ps1` created. |
| 2026-04-20 22:23:38 | `docs/repo-quality-analysis-protocol.md` created. |
| 2026-04-21 23:41:50 | `workflow/session-state.template.json` created. |
| 2026-04-21 23:42:54 | `docs/session-checkpoint.md` created. |
| 2026-04-22 14:16:21 | `workflow/session-state.json` created. |
| 2026-04-22 14:55:56 | major archive split; history/research/prompt templates archived; prompt-library files created. |
| 2026-04-22 14:57:05 | `docs/workspace-system-overview.md` created. |
| 2026-04-22 15:25:18 | `scripts/ws.ps1` and `scripts/test-ws.ps1` created. |
| 2026-04-22 15:50:28 | `scripts/ws.sh` and `docs/repo-tooling.md` created. |
| 2026-04-22 16:33:18 | `docs/research-methodology.md` created. |
| 2026-04-22 16:51:38 | `archive/early-history.md` placeholder created. |
| 2026-04-22 19:59:44 | `docs/agentic-workflows.md` created. |
| 2026-04-22 20:39:51 | first OpenCode specialist agent file created. |
| 2026-04-23 00:21:25 | `docs/codex-agent-workflows.md` created. |
| 2026-04-23 08:59:46 | `propagate-templates/sync-from-hub.template.ps1` created. |
| 2026-04-23 13:01:30 | OpenCode skills system begins with `propagate` skill. |

## Appendix B - Confidence Notes

High confidence:

- File creation and last-write timestamps.
- Current folder architecture.
- Existence and purpose of current docs/scripts/templates.
- Archived history session entries from `archive/history-2026-04.md`.

Medium confidence:

- Exact intent wording for early turns reconstructed from current prompt history and archived summaries.
- Approximate session windows preserved in archive.

Lower confidence:

- Minute-level ordering for user-agent back-and-forth before a file was created.
- Exact content of prompts that did not produce durable artifacts.

When in doubt, preserve the decision and its rationale, but label the evidence level honestly.
