# Late History With Codex

Created: 2026-04-23 14:07:56 +08:00
Timezone: Asia/Singapore, UTC+08:00

## Purpose

This file is a detailed handover record for the late-April workspace redesign thread. It is written for a future agent that needs to understand not just what changed, but why it changed, what the user corrected, and what final agreements shaped the current repo.

Use this together with:

- `workflow/session-state.json` for current resume state
- `AGENTS.md` for operating rules
- `docs/workspace-system-overview.md` for the system map
- `HISTORY.md` and `archive/history-2026-04.md` for the broader ledger

## Timestamp Notes

All timestamps are in UTC+08:00.

Timestamp precision is mixed because the thread was recorded across several mechanisms:

- Exact git commit times are exact.
- File `LastWriteTime` values are exact filesystem observations, but they show file write time, not necessarily the start of the decision.
- `HISTORY.md` and `archive/history-2026-04.md` entries often preserve only date or broad period.
- When the exact clock time was not preserved, this file marks the time as `session-level` and keeps the ordering from the ledger.

Do not treat inferred time ranges as exact minute-by-minute transcript data. Do treat the ordering as durable.

## Executive Summary

The late thread started as model-access research and became a full workspace operating-system redesign.

The repeated pattern was:

1. User asked for practical advice or cleanup.
2. Assistant expanded it into a system-level rule.
3. User corrected overreach or ambiguity.
4. The repo was updated to encode the final rule.

The biggest final agreements:

- Model selection must be access-aware, cost-aware, and task-aware.
- Cheap/free models are useful, but not all cheap models belong in main coding loops.
- Topic folders need a mandatory `[folder-name]-content/` operating area.
- `meta/` is optional and should not be bulk-created.
- Hub content already lives in `docs/`, `research/`, `scripts/`, `workflow/`, `propagate-templates/`, `archive/`, and `personal-voice/`; do not create `ai-prompting-content/` for the hub without a deliberate redesign.
- `scripts/` is only for executable automation.
- `workflow/` is for state, queues, registries, generated outputs, and process logs.
- `docs/quality-standards.md` is documentation, not a root file.
- Resume state comes first: read `workflow/session-state.json` before scanning.
- Hot-path files stay compact; old detail goes to archive.
- PowerShell is the mutating automation lane; WSL/Linux commands are read-only inspection helpers.
- Agentic routing should default to direct handling. Specialist agents are exceptions, not the default.
- Every routed response in the OpenCode setup must disclose which agent/model was used.

## Master Timeline

| Timestamp | Precision | Event | Durable result |
|---|---|---|---|
| 2026-04-21, Access Refresh | session-level | User asked which models are strongest given real access: GitHub education/Copilot, OpenCode Go, OpenCode Zen, Google AI Studio free tier, and possible student/free routes. | Session 20 updated `docs/model-selection-guide.md` with access-aware routing. |
| 2026-04-21, Access Refresh | session-level | Assistant treated model choice as a cross-provider routing problem instead of a single "best model" answer. | Daily default became Claude Sonnet 4.6 via Copilot; hardest work Opus 4.7 sparingly; cheap volume via OpenCode Go; free long-context via Google AI Studio. |
| 2026-04-21, evening | session-level | User added GPT-5 nano in OpenCode free and asked whether it should be used over MiniMax M2.5 Free, plus asked to propagate to NoFaceScanApp. | Session 21 ranked GPT-5 nano as cheap worker model, while MiniMax M2.5 Free stayed better for coding-agent loops. |
| 2026-04-21 17:22:00 | file time | Propagation protection templates were edited. | `.cleanup-protect.template.md` marker behavior was fixed. |
| 2026-04-21 17:45:49 to 17:46:12 | file time | Harvest, candidate, review-state, and sync scripts were updated. | Workflow state paths and review queue scripts were corrected. |
| 2026-04-21, evening | session-level | User corrected the structure: `[folder-name]-content/` should be mandatory; `meta/` should not be created automatically. | Propagation now creates content folders and leaves `meta/` optional. |
| 2026-04-21, evening | session-level | User said `AGENTS.md` must tell agents to operate inside `[folder-name]-content/`, and asked to apply this repo rule too. | Topic folders got explicit operating-area rules; hub got an exception because its existing top-level folders are already its content areas. |
| 2026-04-21, evening | session-level | User asked for cleanup and full repo analysis. | Obsolete `.cleanup-protect.md` duplicates, empty hub `meta/`, and `create-meta-folders.ps1` were removed; misplaced files were classified. |
| 2026-04-21, evening | session-level | Assistant first moved some workflow files into `scripts/`. | User later rejected this because some files were not scripts. |
| 2026-04-21, evening | session-level | User asked whether `cross-domain-registry.md`, `merge-log.md`, and review-state JSON belonged at root. | Final agreement: no root, no `scripts/`; put them in `workflow/`. |
| 2026-04-21, evening | session-level | User asked whether `quality-standards.md` belongs at root. | Final agreement: central standards belong at `docs/quality-standards.md`; topic-specific standards belong under `meta/` only when needed. |
| 2026-04-21 17:26:28 | recorded in sync state | Propagation sync state showed recent successful sync. | Sync health was verifiable through `workflow/sync-state.json`. |
| 2026-04-21, night | session-level | User asked to continue research and integration. | Sessions 22-23 established the research -> integrate -> propagate loop for trending research. |
| 2026-04-21 23:25:53 to 23:30:54 | file time | Starred repo and research archive files were written. | Large research outputs moved toward archive/integration logs. |
| 2026-04-22 early | session-level | User/workflow needed context-limit resilience. | Session 24 added proactive context handover patterns. |
| 2026-04-22 00:20:58 | file time | `workflow/session-state.template.json` was written. | Session-state template existed before later full checkpoint system. |
| 2026-04-22, session 26 | session-level | Context exhaustion and repeated rescans became the main problem. | `workflow/session-state.json` became mandatory first-read resume file. |
| 2026-04-22 14:15:03 | file time | Propagated audit template was updated. | Folder-structure audit warnings became visible in topic folders. |
| 2026-04-22, sessions 27-28 | session-level | User wanted root drift cleaned and folder structure enforced. | Topic root drift was audited; safe moves were made; risky active git folders were left for manual decision. |
| 2026-04-22 14:55:56 to 14:59:22 | file time | Prompt library, research findings, archive index, ignore files, and voice files were updated. | Hot-path compression and archive discipline started to solidify. |
| 2026-04-22 15:50:28 to 15:51:14 | file time | `docs/repo-tooling.md`, `scripts/ws.sh`, `scripts/ws.ps1`, and redirect docs were updated. | PowerShell became mutating lane; WSL became read-only inspection lane. |
| 2026-04-22 16:33:18 | file time | `docs/research-methodology.md` was written. | Source hierarchy and verification rules became durable. |
| 2026-04-22 16:56:04 | file time | `docs/workspace-system-overview.md` was updated. | Fast startup protocol and system map became the main orientation path. |
| 2026-04-22 18:10:56 | file time | `docs/cross-project-memory-loop.md` was updated. | Cross-domain flow aligned to `workflow/`. |
| 2026-04-22 20:00:17 to 20:03:10 | file time | Token-efficiency, session-checkpoint, model-selection, and HISTORY files were updated. | Sessions 38-42 model and token-efficiency decisions became documented. |
| 2026-04-22 20:40:50 to 22:36:53 | file time | `.opencode/agents/*` files and `workflow/agentic-savings-log.md` were created/updated. | Native OpenCode agent system took shape. |
| 2026-04-23 00:21:25 to 00:41:56 | file time | Codex agent workflow docs, OpenCode templates, and propagation script support were updated. | Codex Desktop workflow documentation and `.template.json` propagation support were added. |
| 2026-04-23 08:59:46 | file time | `propagate-templates/sync-from-hub.template.ps1` was written. | Topic folders gained self-service sync capability. |
| 2026-04-23 09:01:11 | file time | `workflow/cross-domain-registry.md` was updated. | Participating folder registry stood at 25 folders. |
| 2026-04-23 12:50:38 to 12:51:49 | file time | AGENTS template, OpenCode template, and sync state were updated. | Direct-handling default and model disclosure were propagated to 25 folders. |
| 2026-04-23 13:02:00 to 13:09:01 | file time | `opencode.json`, skills template, template README, and agentic workflow docs were updated. | Skills system and OpenCode docs were aligned. |
| 2026-04-23 13:32:49 | exact git commit | Initial git commit created. | Rollback safety started after major configuration/docs setup. Commit: `cb312ff`. |
| 2026-04-23 13:39:04 | exact git commit | Five skills were improved. | Skill descriptions, arguments, allowed tools, and research references improved. Commit: `82b1002`. |
| 2026-04-23 13:58:20 | exact git commit | Hub was restructured around learning paths and archive cleanup. | README rewritten, `docs/CONTEXT.md` deleted, model tests archived, research findings moved to docs. Commit: `eebf45e`. |
| 2026-04-23 13:54:18 to 13:58:28 | file time | README, executive summaries, AGENTS, and session state were updated. | Current optimized hub state recorded. |
| 2026-04-23 14:07:56 | exact current command time | User requested this full late-history handover file. | This file was created to document the decision chain. |

## Decision Threads

### 1. Model Selection Had To Become Access-Aware

**Timestamp:** 2026-04-21, Access Refresh, session-level.

**User intent:** The user did not want a generic leaderboard. They wanted to know the strongest model they could actually use daily, given GitHub education/Copilot access, OpenCode Go free models, possible OpenCode Zen value, Google AI Studio free tier, and other student/free options.

**Assistant improvement:** The assistant reframed "best model" into a routing table: daily default, hardest-work model, cheap coding lane, long-context/free API lane, and optional paid upgrade lane.

**User improvement to the improvement:** The user drilled into exact ambiguities: Gemini 3.1 Pro preview limits, whether Copilot education or Google AI Studio gives more Gemini usage, whether GPT-5.3 Codex versus smaller GPT models were actually better, and where GPT-5 nano fits.

**Final agreement:** Model choice is not one global ranking. It is task/access/cost routing.

**Implemented:**

- `docs/model-selection-guide.md` updated for Copilot Student/Pro, OpenCode Go, OpenCode Zen, Google AI Studio, OpenRouter, Gemini Code Assist, Cursor Student, DeepSeek, and Qwen.
- Daily default: Claude Sonnet 4.6 through Copilot.
- Hardest work: Claude Opus 4.7 sparingly.
- Cheap coding volume: OpenCode Go models.
- Free long-context/API: Google AI Studio, with live limit checks before big use.
- Zen is worth paying only after Copilot premium or Go limits become real constraints.

### 2. GPT-5 Nano Was Added, But Not As A Main Coding Agent

**Timestamp:** 2026-04-21 evening, session-level.

**User intent:** The user added GPT-5 nano in OpenCode free and wanted to know whether it should outrank MiniMax M2.5 Free.

**Assistant improvement:** The assistant split "free model" into worker tasks versus coding-agent loops.

**User improvement to the improvement:** The user wanted the answer reflected in the actual tables, not just explained conversationally.

**Final agreement:** GPT-5 nano is useful, but it is not the default repo-editing/coding-loop model.

**Implemented:**

- `docs/model-selection-guide.md` ranks GPT-5 nano for cheap summaries, extraction, classification, ranking, and simple transforms.
- MiniMax M2.5 Free remains preferred over GPT-5 nano for code edits, repo reasoning, and OpenCode agent loops.

### 3. NoFaceScanApp Needed To Join The Propagation System

**Timestamp:** 2026-04-21 evening, session-level.

**User intent:** The user added NoFaceScanApp and wanted it included in the shared folder system.

**Assistant improvement:** The assistant treated this as both a one-folder propagation task and a test of the propagation rules.

**User improvement to the improvement:** The user noticed the structure itself was not fully propagated, especially the mandatory content folder.

**Final agreement:** Every participating topic folder needs a mandatory `[folder-name]-content/` primary operating area. `meta/` is optional.

**Implemented:**

- NoFaceScanApp added to the cross-domain registry and participating folder list.
- Required files propagated to `M:\M-Namikaz-Others\NoFaceScanApp`.
- Created `M:\M-Namikaz-Others\NoFaceScanApp\no-face-scan-app-content`.
- `scripts/propagate-to-all.ps1` updated to create mandatory content folders.
- `propagate-templates/AGENTS.template.md` updated with the operating-area rule.

### 4. `meta/` Stopped Being A Mandatory Folder

**Timestamp:** 2026-04-21 evening, session-level.

**User intent:** The user wanted structure, but not empty bureaucracy. The content folder should be mandatory; `meta/` should only exist when useful.

**Assistant improvement:** The assistant initially leaned toward standardizing more folders.

**User improvement to the improvement:** The user corrected that `meta/` should not be pre-created everywhere.

**Final agreement:** `meta/` is optional topic-specific context. Do not create it until a project needs handover notes, local quality rules, or other durable local context.

**Implemented:**

- Deleted obsolete `scripts/create-meta-folders.ps1`.
- Removed the empty hub `meta/`.
- Updated templates and docs to say `meta/` is optional.

### 5. The Hub Is Exempt From The Topic Content-Folder Rule

**Timestamp:** 2026-04-21 evening, session-level.

**User intent:** The user wanted the same "operate inside content folder" rule applied to this repo if necessary.

**Assistant improvement:** The assistant classified the hub separately from sibling topic folders.

**User improvement to the improvement:** The user accepted movement when necessary but wanted the actual repo shape analyzed, not blindly normalized.

**Final agreement:** The hub is not a normal topic folder. Its working areas already exist at top level.

**Implemented:**

- `AGENTS.md` says the hub's working areas are `docs/`, `research/`, `scripts/`, `workflow/`, `propagate-templates/`, `archive/`, and `personal-voice/`.
- It also says not to move hub content into `ai-prompting-content/` unless the whole hub is intentionally redesigned.

### 6. Root Files Were Classified More Strictly

**Timestamp:** 2026-04-21 evening, session-level.

**User intent:** The user questioned root files like `cross-domain-registry.md`, `merge-log.md`, and review-state JSON.

**Assistant improvement:** The assistant first moved some of them into `scripts/` because scripts used them.

**User improvement to the improvement:** The user correctly rejected that: not everything used by scripts is itself a script.

**Final agreement:** Use semantic folders, not adjacency by implementation.

**Implemented final locations:**

- `scripts/` contains executable automation only.
- `workflow/` contains registries, queues, generated outputs, state, and logs.
- `archive/` contains preserved analysis/reference files.
- `docs/` contains durable knowledge docs.

**Specific implemented moves:**

- `workflow/cross-domain-registry.md`
- `workflow/cross-domain-candidates.md`
- `workflow/cross-domain-review-state.json`
- `workflow/harvested-topic-insights.md`
- `workflow/merge-log.md`
- `workflow/sync-state.json`
- `archive/zip-analysis.md`
- `docs/quality-standards.md`

### 7. `quality-standards.md` Became A Documentation File

**Timestamp:** 2026-04-21 evening, session-level.

**User intent:** The user asked whether `quality-standards.md` should be in root.

**Assistant improvement:** The assistant classified it by audience and role.

**User improvement to the improvement:** The user wanted root to stay meaningful, not a dumping ground for important-sounding docs.

**Final agreement:** Central quality standards belong under `docs/`. Topic-specific quality standards belong in `meta/` only if a topic needs them.

**Implemented:**

- Root `quality-standards.md` moved to `docs/quality-standards.md`.
- README quick reference points to `docs/quality-standards.md`.
- Propagated audit template wording no longer implies root `quality-standards.md` should exist.

### 8. Cleanup Needed To Preserve History, Not Erase It

**Timestamp:** 2026-04-21 evening to 2026-04-22, session-level.

**User intent:** The user asked to clean useless files and then analyze whether files should move.

**Assistant improvement:** The assistant used the repo-quality principle: orphan is not delete; similar is not redundant; active git folders need manual care.

**User improvement to the improvement:** The user pushed for another pass when questionable root files remained.

**Final agreement:** Cleanup is classification first, deletion second.

**Implemented:**

- Removed duplicate `.cleanup-protect.md` files caused by template mapping bug.
- Removed stale/generated artifacts where safe.
- Left active git clones and ambiguous project roots for manual decision.
- Added/kept audit rules to make root drift visible.

### 9. Research Became A Loop, Not A Dump

**Timestamp:** 2026-04-21 night, Sessions 22-23.

**User intent:** Continue research and update the actual guidance, not just collect links.

**Assistant improvement:** The assistant formalized the cycle as research -> integrate -> propagate -> verify.

**User improvement to the improvement:** The user wanted tables showing repos looked at, deep dives, learnings, and combined lessons.

**Final agreement:** Research only becomes durable when integrated into the smallest correct central doc.

**Implemented:**

- `research/research-log.md` captured active research.
- `research/integration-log.md` tracked promotion into docs.
- Durable lessons went into docs such as `docs/token-efficient-prompting.md` and `docs/ai-product-building.md`.
- Templates were propagated only when shared defaults changed.

### 10. Context Handover Became Proactive

**Timestamp:** 2026-04-22 early, Sessions 24 and 26.

**User intent:** The user wanted long sessions to survive context pressure without losing continuity.

**Assistant improvement:** The assistant identified the real failure mode: state was being written after exhaustion instead of before.

**User improvement to the improvement:** The user favored practical recovery over theory. The system needed a concrete first-read file.

**Final agreement:** Read session state first on every resume, and checkpoint before heavy operations.

**Implemented:**

- `workflow/session-state.json`
- `workflow/session-state.template.json`
- `docs/session-checkpoint.md`
- `AGENTS.md` startup order: session state first.
- `docs/workspace-system-overview.md` fast startup protocol.

### 11. Hot-Path Files Were Compressed, Archives Preserved Detail

**Timestamp:** 2026-04-22, Sessions 29-31.

**User intent:** The repo needed to be easier for future sessions to load and understand.

**Assistant improvement:** The assistant separated hot-path orientation from deep history.

**User improvement to the improvement:** The user wanted no quality loss, not just shorter files.

**Final agreement:** Hot-path files are compact indexes. Full detail belongs in archive files.

**Implemented:**

- `docs/workspace-system-overview.md` became the 30-second system map.
- README became a navigation index.
- `HISTORY.md` became the active ledger.
- Older full history moved to `archive/history-2026-04.md`.
- Large prompt library split into `docs/prompt-library/`.

### 12. PowerShell And WSL Got Separate Jobs

**Timestamp:** 2026-04-22 15:50:28 to 15:51:14, file-time supported.

**User intent:** Make workspace commands reliable on this Windows filesystem.

**Assistant improvement:** The assistant separated mutating automation from inspection.

**User improvement to the improvement:** The user wanted tools that worked without awkward cross-shell assumptions.

**Final agreement:** PowerShell is the source of truth for mutating hub automation. WSL/Linux is useful for read-only inspection.

**Implemented:**

- `docs/repo-tooling.md`
- `scripts/ws.ps1`
- `scripts/ws.sh`
- `docs/windows-repo-tooling.md` redirect

### 13. Research Source Quality Became Explicit

**Timestamp:** 2026-04-22 16:33:18, file time.

**User intent:** Research should be reliable and source-aware.

**Assistant improvement:** The assistant converted this into a source hierarchy and verification protocol.

**User improvement to the improvement:** The user wanted the repo to prevent weak source habits in future sessions.

**Final agreement:** Tool/model claims must be source-backed, dated, and checked against official or primary sources when possible.

**Implemented:**

- `docs/research-methodology.md`
- README links into research path
- `research/research-log.md` and integration practices updated

### 14. Root Drift Cleanup Became Guardrailed

**Timestamp:** 2026-04-22, Sessions 27-28.

**User intent:** Topic folder roots should not slowly accumulate random files.

**Assistant improvement:** The assistant added audit warnings and moved safe root drift into content folders.

**User improvement to the improvement:** The user implicitly required caution around active repos and ambiguous folders.

**Final agreement:** Root drift cleanup must classify before moving. Active `.git` repos and tool homes are not auto-moved.

**Implemented:**

- Propagated audit now reports folder-structure warnings.
- Safe legacy content moved into canonical content folders.
- Risky items left for manual decision:
  - `Fluent Search Manifest/temp_extras`
  - `OpenCode/opencode-content`

### 15. OpenCode Go Model Routing Got More Granular

**Timestamp:** 2026-04-22, Sessions 38-40.

**User intent:** The user wanted to know which OpenCode Go models are actually worth using, not just which is strongest.

**Assistant improvement:** The assistant split quality, speed, and requests-per-dollar.

**User improvement to the improvement:** The user cared about credit drain and work rate, so volume mattered as much as benchmark score.

**Final agreement:** K2.6 is quality king; M2.5 is speed/volume king; M2.7 remains useful for bulk drafts and harness work; GLM-5.1 is expensive and should be reserved.

**Implemented:**

- `docs/model-selection-guide.md` contains K2.6 vs M2.7, all-Go model analysis, and unified cross-provider routing.

### 16. PR Sequence Diagrams Became A Selective Pattern

**Timestamp:** 2026-04-22, Session 41.

**User intent:** Improve PR communication patterns.

**Assistant improvement:** The assistant added Mermaid sequence diagrams as a specific PR tool.

**User improvement to the improvement:** The pattern was bounded to behavioral PRs so it would not become noise.

**Final agreement:** Add a sequence diagram when behavior takes more text to explain than to draw.

**Implemented:**

- `docs/ai-product-building.md`
- `propagate-templates/git-github-best-practices.template.md`
- Propagated to topic folders.

### 17. Agentic Token Efficiency Started Broad, Then Got Corrected Toward Direct Handling

**Timestamp:** 2026-04-22 evening to 2026-04-23 12:51:49, file-time and session-state supported.

**User intent:** Cut token burn without losing continuity or quality.

**Assistant improvement:** The assistant proposed an Orchestrator plus specialist agents.

**User improvement to the improvement:** The user cared about speed and not over-routing. The system needed to default to direct handling and only spawn specialists when worthwhile.

**Final agreement:** The Orchestrator handles simple work directly. Subagents are for bounded specialized tasks, not every task.

**Implemented:**

- `.opencode/agents/` with explorer, planner, scribe, drafter, gardener, debugger, reviewer.
- `opencode.json` uses Orchestrator as default.
- Direct-handling default added to `AGENTS.md`, `docs/agentic-workflows.md`, and templates.
- `workflow/agentic-savings-log.md` created.
- Agent disclosure footer includes model names.
- Propagated to 25 topic folders.

### 18. Agent Disclosure Was Refined To Include Model Names

**Timestamp:** 2026-04-23 12:50:38 to 12:51:49, file-time supported.

**User intent:** The user needed transparent routing and model usage.

**Assistant improvement:** The assistant initially added agent disclosure.

**User improvement to the improvement:** Disclosure without model identity was insufficient for judging routing quality.

**Final agreement:** Disclosure must include agent and model.

**Implemented format:**

```text
Agents used: @explorer (M2.5)
Reason: ...
```

For direct handling:

```text
Agents used: Orchestrator (direct, K2.6) - no specialist needed.
```

### 19. Skills Were Added After Agents

**Timestamp:** 2026-04-23 13:02:00 to 13:39:04, file-time and git-commit supported.

**User intent:** Repeated workflows should become reusable assets.

**Assistant improvement:** The assistant created skills for repeated operations instead of only documenting procedures.

**User improvement to the improvement:** The skills needed enough argument/tool guidance to be useful, not just names.

**Final agreement:** Use skills for repeatable workflows that need consistent procedure.

**Implemented:**

- `.opencode/skills/propagate/SKILL.md`
- `.opencode/skills/audit-quality/SKILL.md`
- `.opencode/skills/session-handoff/SKILL.md`
- `.opencode/skills/research-deep/SKILL.md`
- `.opencode/skills/cross-domain-harvest/SKILL.md`
- `propagate-templates/skills-template/README.md`
- Commit `82b1002` improved descriptions, allowed tools, arguments, and references.

### 20. Git Was Initialized As A Safety Net

**Timestamp:** 2026-04-23 13:32:49, exact git commit.

**User intent:** Not explicitly a user-facing request, but the repo had grown risky enough that rollback safety became important.

**Assistant improvement:** Initialize git after the system had enough structure to preserve.

**User improvement to the improvement:** Future work should now use git status/diff instead of relying only on filesystem scans.

**Final agreement:** The hub now has git safety. Do not assume it is still a no-git folder.

**Implemented:**

- Commit `cb312ff`: initial commit with hub config, agents, skills, templates, docs.
- Commit `82b1002`: skill improvements.
- Commit `eebf45e`: hub restructuring, learning paths, executive summaries, archive model-tests, delete `docs/CONTEXT.md`.

### 21. `docs/CONTEXT.md` Was Deleted After Startup Order Changed

**Timestamp:** 2026-04-23 13:58:20, exact git commit.

**User intent:** Reduce orientation overhead and make the repo clearer for new sessions.

**Assistant improvement:** The assistant removed a redundant orientation file after `workflow/session-state.json`, `AGENTS.md`, `docs/workspace-system-overview.md`, and `README.md` became the startup path.

**User improvement to the improvement:** The user wanted quality, not just compression. Deleting context only works if the remaining path is better.

**Final agreement:** `docs/CONTEXT.md` is gone. Do not look for it on startup.

**Implemented:**

- `docs/CONTEXT.md` deleted in commit `eebf45e`.
- `README.md` rewritten with learning paths and "I Want To..." index.
- `docs/workspace-system-overview.md` remains the system map.

### 22. Research Findings Moved From Research To Docs

**Timestamp:** 2026-04-23 13:58:20, exact git commit.

**User intent:** Durable findings should not sit forever in research intake.

**Assistant improvement:** The assistant added an integration rule and moved durable findings into docs.

**User improvement to the improvement:** This strengthened the earlier research -> integrate -> propagate cycle.

**Final agreement:** `research/` is active intake; durable synthesis belongs in `docs/`.

**Implemented:**

- `research/archived-findings.md` moved to `docs/research-findings.md`.
- `AGENTS.md` adds rule to integrate findings within 3 days.
- README research path points to durable findings.

### 23. Model Tests Were Archived

**Timestamp:** 2026-04-23 13:58:20, exact git commit.

**User intent:** Keep root clean and avoid active-looking systems that are not currently hot path.

**Assistant improvement:** The assistant archived `model-tests/` instead of deleting it.

**User improvement to the improvement:** This follows the repo-quality protocol: preserve useful history even when it leaves the hot path.

**Final agreement:** `model-tests/` is preserved as historical/reference material under archive.

**Implemented:**

- `model-tests/` moved to `archive/model-tests/`.

## Current Final State A Future Agent Should Assume

### Startup Order

1. Read `workflow/session-state.json`.
2. Read `AGENTS.md`.
3. Read `docs/workspace-system-overview.md`.
4. Read `README.md`.
5. Only then read task-specific files.

### Folder Semantics

| Location | Meaning |
|---|---|
| `docs/` | Durable knowledge base. |
| `research/` | Active research intake and campaign notes. |
| `scripts/` | Executable automation only. |
| `workflow/` | Session state, sync state, registries, harvested lessons, queues, logs. |
| `propagate-templates/` | Source templates copied to topic folders. |
| `archive/` | Preserved old detail, raw logs, inactive systems. |
| `personal-voice/` | User writing style system. |
| `.opencode/agents/` | Native OpenCode agent definitions. |
| `.opencode/skills/` | Reusable workflow skills. |

### Topic Folder Rule

For sibling topic folders:

- Normal work belongs in `[folder-name]-content/`.
- The implemented scripts derive `[folder-name]` by converting the project folder name to kebab-case.
- Root stays for propagated instruction files and truly root-scoped project files.
- `meta/` is optional.
- If `meta/HANDOVER.md` exists and the task is local resume work, read it first.

### Current Model Routing Agreements

| Need | Preferred lane |
|---|---|
| Daily strong coding/default | Claude Sonnet 4.6 through Copilot when available; K2.6 in OpenCode Orchestrator setup. |
| Hardest reasoning/code tasks | Claude Opus 4.7 sparingly due premium multiplier/cost. |
| OpenCode Go quality | Kimi K2.6. |
| OpenCode Go speed/volume | MiniMax M2.5, with Qwen3.5/Qwen3.6 Plus depending volume/quality need. |
| Bulk drafts/harness work | MiniMax M2.7. |
| Expensive specialist review | GLM-5.1 only when its edge is worth the cost. |
| Cheap worker transforms | GPT-5 nano. |
| Free long-context/API | Google AI Studio, but live-check limits before heavy runs. |

### Current Agentic Routing Agreements

- Default to direct handling.
- Spawn specialists only when the task is complex, bounded, and materially benefits from specialization.
- Compress context before subsessions.
- Verify specialist output before presenting it.
- Disclose agent/model usage in the OpenCode setup.

### Known Open Items

- `workflow/session-state.json` still says to restart/reload OpenCode Desktop to pick up latest config changes.
- `archive/early-history.md` remains a placeholder until the user provides Sessions 1-11 and earlier.
- Manual root-drift decisions still noted from Session 28:
  - `Fluent Search Manifest/temp_extras`
  - `OpenCode/opencode-content`

## What Was Implemented In Files

| Area | Main files |
|---|---|
| Model routing | `docs/model-selection-guide.md` |
| Cross-provider/model research | `docs/model-selection-guide.md`, `research/integration-log.md`, `HISTORY.md` |
| Propagation structure | `scripts/propagate-to-all.ps1`, `propagate-templates/AGENTS.template.md`, `propagate-templates/README.md` |
| Workflow state folder | `workflow/*`, `scripts/*`, `README.md`, `docs/workspace-system-overview.md` |
| Quality standards | `docs/quality-standards.md`, `scripts/audit-folder-quality.ps1`, propagated audit template |
| Session recovery | `workflow/session-state.json`, `workflow/session-state.template.json`, `docs/session-checkpoint.md` |
| Workspace overview | `docs/workspace-system-overview.md`, `README.md`, `AGENTS.md` |
| Tooling | `scripts/ws.ps1`, `scripts/ws.sh`, `docs/repo-tooling.md` |
| Research methodology | `docs/research-methodology.md` |
| Agent workflows | `docs/agentic-workflows.md`, `docs/codex-agent-workflows.md`, `.opencode/agents/*`, `opencode.json` |
| Skills | `.opencode/skills/*`, `propagate-templates/skills-template/README.md` |
| Archive cleanup | `archive/history-2026-04.md`, `archive/research-log-2026-04.md`, `archive/model-tests/` |

## Handover Advice For The Next Agent

Do not restart from scratch. This repo has already gone through multiple correction passes. The most common failure mode is to over-normalize or over-orchestrate.

Before changing structure:

1. Check whether a file is hot-path, generated workflow state, durable docs, or archive.
2. If it is used by scripts but is not executable, it probably belongs in `workflow/`, not `scripts/`.
3. If it is documentation, prefer `docs/` unless the user explicitly requests root.
4. If it is a topic-folder local rule, prefer `meta/` only when needed.
5. If it is active project work in a topic folder, put it in `[folder-name]-content/`.
6. Preserve historical detail in archive unless it is clearly junk.

Before changing model guidance:

1. Verify current access and limits.
2. Separate strongest, cheapest, fastest, and daily-most-optimal.
3. Check whether the user is asking about main coding loops or cheap worker tasks.
4. Update tables, not just prose, because the user relies on the guide for routing.

Before changing agentic routing:

1. Keep direct handling as default.
2. Only route to specialists when it saves context or improves quality enough to justify overhead.
3. Include model names in disclosure.
4. Keep context packets small.

## Verification Record For This Handover

Observed before creating this file:

- `git log` shows commits:
  - `cb312ff` at 2026-04-23 13:32:49 +08:00
  - `82b1002` at 2026-04-23 13:39:04 +08:00
  - `eebf45e` at 2026-04-23 13:58:20 +08:00
- `workflow/sync-state.json` records last propagation sync at 2026-04-23 12:51:48.
- `workflow/session-state.json` records Session 42 as completed and points to OpenCode reload/testing as next action.
- `git status --short` showed `workflow/session-state.json` already modified before this handover file was created.
