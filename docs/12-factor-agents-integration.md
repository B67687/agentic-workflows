# 12-Factor Agents — Integration Map

Maps [humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents) principles
to this repository's concrete patterns, commands, scripts, and skills.

**Why this matters:** The 12-factor-agents framework (19.8k ★) codifies what makes
LLM-powered software reliable, scalable, and maintainable — coining the term
"context engineering" along the way. This hub built similar patterns independently.
This doc makes the alignment explicit, documents gaps, and guides future integration.

---

## The 12 Factors (with Appendix 13)

### Factor 1: Natural Language to Tool Calls

**Principle:** Convert natural language to structured tool calls. Deterministic code
picks up the payload and acts on it.

**Our implementation:**

| Component | How it implements Factor 1 |
|---|---|
| `commands/route.md` | Routes natural-language task descriptions to the correct execution lane |
| `commands/task.md` | Classifies, grills, shapes, and slices tasks — translating vague intent to structured action |
| `commands/implement.md` | Executes verified slices from a structured plan |
| `scripts/workflow-router.sh` | Routes task requests to the appropriate handler |

**Gap:** No explicit documentation that our command/routing system *is* this pattern.
Our commands are the "tools" the agent calls, and `route.md` is the "NL-to-tool" bridge.

---

### Factor 2: Own Your Prompts

**Principle:** Don't outsource prompt engineering to a framework. Treat prompts as
first-class code with testing, evals, and iteration.

**Our implementation:**

| Component | How it implements Factor 2 |
|---|---|
| `commands/prompt-contract.md` | Builds a compact self-prompt contract before non-trivial work — covers outcome, context, constraints, verification |
| `AGENTS.md` | The operating contract — the first prompt every agent reads |
| `skills/spec-driven-development/SKILL.md` | Spec-driven prompts as code |
| `scripts/prompt-contract.sh` | Automation for prompt contract generation |
| `docs/daily-prompts.md` | Most-used prompt templates |
| `docs/prompt-templates.md` | Prompt library index with cross-references |

**Alignment:** Excellent. Our prompt-contract system is a concrete implementation of
"prompts as code." No framework hides our prompts — every instruction is explicit.

**Reference:** [12-factor-agents Factor 2](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-02-own-your-prompts.md)

---

### Factor 3: Own Your Context Window

**Principle:** The context window is your primary interface with the LLM. Customize
how you structure and present information — don't rely on standard message formats.

**Our implementation:**

| Component | How it implements Factor 3 |
|---|---|
| `session-state.json` | Active session context — the first thing every agent reads on resume |
| `AGENTS.md` | The operating contract — shared rules and conventions |
| `docs/workflow.md` | Fast orientation — replaces multi-file startup |
| Startup order: session-state.json → AGENTS.md → workflow.md | Engineered retrieval chain — each file builds on the last |
| `scripts/retrieve-context.sh` | Scored retrieval: only high-signal local files, ranked by relevance |
| `scripts/search-index.sh` | BM25 search across all text files |
| `scripts/context-pressure.sh` | Monitors context health (age, dirt, commit count) |
| `scripts/context-save.sh` / `context-restore.sh` | Save and restore context across sessions |

**Alignment:** Very strong. Our startup chain *is* context engineering. The key
addition from 12-factor-agents is the **XML-style custom context format** (using
`<event_type>` tags instead of JSON messages), which can be more token-efficient
and attention-efficient.

**Addressed:** `scripts/retrieve-context.sh` now supports `--xml` flag for
XML-style tagged output (more token- and attention-efficient than JSON).
`scripts/prefetch-context.sh` provides deterministic pre-fetch of git state,
session data, and tool registry in XML format. Both available since Slice 2.

**Reference:** [12-factor-agents Factor 3](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-03-own-your-context-window.md)

---

### Factor 4: Tools Are Just Structured Outputs

**Principle:** Tools don't need to be complex. At their core, they're just structured
JSON output from the LLM that triggers deterministic code via a switch statement.

**Our implementation:**

| Component | How it implements Factor 4 |
|---|---|
| `commands/` (14 command files) | Each command is a "tool" — structured markdown with frontmatter metadata |
| `scripts/tools.sh` | Tool registry — lists all agent-callable tools with descriptions |
| `commands/implement.md` switch/case flow | The switch statement pattern: `if intent == X → do Y` |
| `skills/` manifest + index | Each skill is a structured "tool" with verification gates |

**Alignment:** Good. Every command file is a structured output definition with
metadata (description, arguments, expected output). The route system dispatches
to the right handler based on the intent — exactly the switch-statement pattern.

**Reference:** [12-factor-agents Factor 4](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-04-tools-are-structured-outputs.md)

---

### Factor 5: Unify Execution State and Business State

**Principle:** Don't separate "execution state" (current step, next step, waiting
status) from "business state" (what happened so far). One source of truth.

**Our implementation:**

| Component | How it implements Factor 5 |
|---|---|
| `session-state.json` | Single JSON file tracks currentTask, whatChanged, filesTouched, verification, keyLearnings, residualRisk |
| `scripts/session-status.sh` | Workspace orientation — reads session state + branch + health |
| `scripts/checkpoint-commit.sh` | Commits session state + code changes atomically |
| `scripts/checkpoint-review.sh` | Reviews state before committing |

**Alignment:** Good. `session-state.json` is our unified event sourcing —
it captures task state, context metrics, assumptions, and history in one file.
The `immediateNextSteps` array in session-state is exactly the "next step" pattern.

**Addressed:** `session-state.json` now includes an `events` array for
append-only event sourcing. Each checkpoint records: timestamp, type, milestone,
summary, files changed, and verification. Available since Slice 2.

**Reference:** [12-factor-agents Factor 5](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-05-unify-execution-state.md)

---

### Factor 6: Launch/Pause/Resume with Simple APIs

**Principle:** Agents should be launchable, pausable, and resumable via simple APIs.
Long-running operations and human-in-the-loop should not require deep framework
integration.

**Our implementation:**

| Component | How it implements Factor 6 |
|---|---|
| `scripts/session-fork.sh` | Creates isolated worktree on a new branch — clean launch |
| `scripts/session-status.sh` | Probe session state before resuming |
| `scripts/checkpoint-commit.sh` | Commits state + code — enables clean resume |
| `scripts/context-save.sh` / `context-restore.sh` | Serialize/deserialize session context |
| `session-state.json` resume protocol | Resume reads: session-state → AGENTS.md → workflow.md |
| `scripts/pipeline-run.sh` | Pipeline lifecycle: init → dispatch → collect — each task is launchable/pausable |

**Alignment:** Strong. Our fork + checkpoint + resume chain is a concrete
implementation of launch/pause/resume. `pipeline-run.sh` provides the API surface
for multi-task orchestration.

**Gap:** No REST API surface for external systems to launch/pause/resume agent
sessions. Our launch/pause/resume is file-system-based, not API-based.

**Reference:** [12-factor-agents Factor 6](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-06-launch-pause-resume.md)

---

### Factor 7: Contact Humans with Tool Calls

**Principle:** Treat human contact as a tool call. The LLM can request a human
response or human approval with the same mechanism as any other tool — and the
control flow breaks out of the loop to wait for the response.

**Our implementation:**

| Component | How it implements Factor 7 |
|---|---|
| `commands/counsel.md` | Multi-perspective model review — not human-in-the-loop, but similar multi-participant pattern |
| `commands/parley.md` | Multi-agent conversation between free AI agents — structured debate |
| `scripts/counsel-run.sh` | Runs counsel with model selection |
| `scripts/parley.sh` | Runs parley conversations |

**Addressed (Slice 3):** We now have a working A2H protocol implementation:
- `scripts/a2h-contact.sh` — Agent-to-Human contact protocol with `contact`,
  `approve`, `respond`, and `list` commands. Implements the spec from
  `drafts/a2h-spec.md`: HumanContact and FunctionCall objects, contact channels.
- `scripts/notify.sh` — Multi-channel notification dispatcher. Supports Slack
  webhook (SLACK_WEBHOOK_URL), CLI output, and file-based delivery.
- `commands/implement.md` — Added `--risk high` approval gate that triggers
  deterministic human approval before implementation.
- `scripts/implement-preflight.sh` — Handles `--risk high` by invoking
  `a2h-contact.sh approve` for the interrupt-between-selection-and-execution
  pattern.

**Reference:** [A2H Protocol Draft](https://github.com/humanlayer/12-factor-agents/blob/main/drafts/a2h-spec.md),
[HumanLayer SDK](https://github.com/humanlayer/humanlayer),
[12-factor-agents Factor 7](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-07-contact-humans-with-tools.md)

---

### Factor 8: Own Your Control Flow

**Principle:** Build your own control structures — summarization, caching,
LLM-as-judge, context compaction, rate limiting, durable sleep, pause-for-event.

**Our implementation:**

| Component | How it implements Factor 8 |
|---|---|
| `docs/workflow.md` phase system | Question Gate → Research → Plan → Implement → Verify → Checkpoint |
| `commands/implement.md` | Preflight → execute slice → verify → commit loop |
| `commands/pipeline.md` | Multi-task dispatch with isolated workers |
| `scripts/phase-gate.sh` | Gate between phases — prevents skipping |
| `scripts/implement-preflight.sh` | Pre-implementation checks — blocks if conditions aren't met |
| `scripts/checkpoint-commit.sh` | Verifies before committing — quality gate |
| `scripts/context-pressure.sh` | Monitors context health and suggests compaction |

**Alignment:** Very strong. Our entire phase system IS owning control flow.
The preflight → implement → verify → commit loop is exactly the pattern.

**Gap:** Missing the **interrupt-between-selection-and-execution** pattern.
When a tool is selected but before it executes, there's no hook for human review
or long-running waits. Our pipeline system runs tasks sequentially but doesn't
support pausing *within* a task between tool selection and execution.

**Reference:** [12-factor-agents Factor 8](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-08-own-your-control-flow.md)

---

### Factor 9: Compact Errors into Context Window

**Principle:** Error messages go back into the context window for self-healing.
Add error counters to prevent infinite retry loops. Escalate to humans after
N consecutive failures.

**Our implementation:**

| Component | How it implements Factor 9 |
|---|---|
| `scripts/log-error.sh` | Pipeable error capture feeding into triage system |
| `scripts/triage.sh` (in debug skill) | Failure context capture as structured JSON |
| `buglog.json` | Tracks past bugs and fixes across sessions |
| `scripts/assumption-expiry.sh` | Enforces TTL on non-verifiable claims |
| `session-state.json` `verification` array | Captures what was verified and how |
| `skills/debugging-and-error-recovery/SKILL.md` | Systematic debugging workflow |

**Alignment:** Very strong. We have error logging, triage, bug tracking, and
assumption expiry — all feeding back into the working context.

**Addressed (Slice 5):** `scripts/error-counter.sh` implements the full error
counter pattern: tracks consecutive failures per operation, outputs compact XML
error context for LLM consumption (self-healing), and auto-escalates to a human
via A2H protocol after N consecutive failures (default: 3, configurable via
`ERROR_THRESHOLD`). Combined with `scripts/log-error.sh` (capture) and
`scripts/a2h-contact.sh` (escalation), this completes the therapeutic pipeline:
capture → count → context → escalate.

**Reference:** [12-factor-agents Factor 9](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-09-compact-errors.md)

---

### Factor 10: Small, Focused Agents

**Principle:** Rather than monolithic agents, build small focused agents that do
one thing well. Keep context windows manageable — 3-10, maybe 20 steps max.

**Our implementation:**

| Component | How it implements Factor 10 |
|---|---|
| `skills/` (43 skills) | Each skill is a focused pattern for one domain — debug, test, review, ship |
| `commands/` (14 commands) | Each command is a focused tool — task, plan, implement, research |
| `scripts/` (78 scripts) | Each script does one thing well |
| `skills/manifest.json` | Skill bundles: define, build, verify, ship, meta |
| `skills/bash-explore/` | Read-only bulk discovery — focused exploration |
| `skills/debugging-and-error-recovery/` | Systematic debugging — one problem domain |
| Agent dispatch: `scripts/agent-dispatch.sh` | Each agent type has a focused role |

**Alignment:** **Beautiful alignment.** This is our core architecture. Our entire
system is built on focused, single-purpose components. The skill system IS
"small, focused agents" applied to engineering capabilities. Each skill has a
well-defined scope, inputs, outputs, and verification gates.

**Reference:** [12-factor-agents Factor 10](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-10-small-focused-agents.md)

---

### Factor 11: Trigger from Anywhere, Meet Users Where They Are

**Principle:** Enable triggering agents from Slack, email, SMS, webhooks, cron —
any channel. Agents respond through the same channels.

**Our implementation:**

| Component | How it implements Factor 11 |
|---|---|
| `propagation/` | Templates synced across 25+ topic folders |
| Dual-harness: OpenCode + Pi | Agents can be triggered from either harness |
| `scripts/propagate-to-all.sh` | Bulk propagation to all topic folders |
| `scripts/harvest-topic-insights.sh` | Pull learnings back from topic folders |
| `scripts/workflow-router.sh` | Routes tasks from various entry points |

**Alignment:** Partial. We have multi-harness support and cross-repo propagation,
but we lack explicit contact channels (Slack, Email, SMS) for agent-to-human
communication.

**Addressed (outbound):** `scripts/notify.sh` dispatches agent notifications to
Slack (via webhook), CLI output, and file-based logs. Supports urgency levels
and structured notification objects.

**Remaining (inbound):** We still lack Slack commands, email-to-agent, and
webhook receivers for activating agents from external channels. Our trigger
surface is limited to the file system and harness commands.

**Reference:** [12-factor-agents Factor 11](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-11-trigger-from-anywhere.md)

---

### Factor 12: Make Your Agent a Stateless Reducer

**Principle:** Model your agent as a stateless reducer: `state = reducer(state, event)`.
The thread is serializable, forkable, and resumable.

**Our implementation:**

| Component | How it implements Factor 12 |
|---|---|
| `session-state.json` | Serialized state that can be checkpointed and resumed |
| `scripts/checkpoint-commit.sh` | Reducer pattern: state → action → new state → commit |
| `scripts/context-save.sh` / `context-restore.sh` | Save/restore the full context |
| `session-state.json` events array | `whatChanged` + `filesTouched` + `verification` form an event log |

**Alignment:** Good. Our checkpoint system is a reducer: read state, do work,
write new state, commit. Session files are serializable and handoffable.

**Addressed:** `session-state.json` now has a `events` array — an append-only
event log that records each work cycle. Combined with the existing mutable
fields, this gives us both quick state access and replayable history.
Available since Slice 2.

**Reference:** [12-factor-agents Factor 12](https://github.com/humanlayer/12-factor-agents/blob/main/content/factor-12-stateless-reducer.md)

---

### Appendix 13: Pre-Fetch All the Context You Might Need

**Principle:** If you know what tools the model will need, execute them
deterministically before the LLM invocation and include their results in the
context window — saving round trips.

**Our implementation:**

| Component | How it implements Factor 13 |
|---|---|
| Startup order: session-state → AGENTS.md → workflow.md | Pre-fetches the most critical context before any LLM call |
| `scripts/retrieve-context.sh` | Pre-fetches relevant local context based on query |
| `scripts/search-index.sh` | Pre-fetches BM25 search results |
| `scripts/context-restore.sh` | Restores saved context on resume |
| `scripts/session-status.sh` | Pre-fetches workspace orientation (branch, health, tools, tests) |

**Alignment:** Good. Our startup chain IS pre-fetching. `retrieve-context.sh`
pre-fetches relevant documents before the agent acts.

**Addressed:** `scripts/prefetch-context.sh` deterministically gathers git state,
session data, tool registry, and learnings before any LLM invocation.
`scripts/retrieve-context.sh` supports `--prefetch` flag for built-in pre-fetch
during context retrieval. Both available since Slice 2.

**Reference:** [12-factor-agents Appendix 13](https://github.com/humanlayer/12-factor-agents/blob/main/content/appendix-13-pre-fetch.md)

---

## A2H Protocol (Agent-to-Human)

Beyond the 12 factors, the [A2H protocol draft](https://github.com/humanlayer/12-factor-agents/blob/main/drafts/a2h-spec.md)
defines a REST API for agent-to-human communication:

| Object | Purpose | Our equivalent |
|---|---|---|
| `HumanContact` | Agent asks a human a question | `commands/counsel.md` (model, not human) |
| `FunctionCall` | Agent requests human approval for operation | None |
| `ContactChannel` | Slack, Email, SMS, WhatsApp channels | None |
| `POST /human_contacts` | Create a human contact request | None |
| `POST /function_calls` | Create a function call for approval | None |
| `GET /humans` | Discover available humans | None |

**Status:** Not implemented. This protocol is the scaffolding for Milestone 3
of the integration plan.

---

## HumanLayer SDK Reference

The [HumanLayer SDK](https://github.com/humanlayer/humanlayer) (10.8k ★) provides:

- `require_approval` decorator for high-stakes function calls
- `human_as_tool` pattern — humans treated as tool calls in the agent loop
- Contact channels: Slack, Email, CLI, web
- `hlyr` — TypeScript CLI with MCP server
- `hld` — Go daemon coordinating approvals + Claude Code sessions
- `humanlayer-wui` — Web UI for approval management
- `claudecode-go` — Go SDK for programmatic Claude Code sessions

**Status:** Referenced. Not yet integrated. The `require_approval` pattern and
contact channels address our primary gaps (Factors 7 and 11).

---

## Gaps Summary

| Factor | Gap Severity | What's Missing |
|---|---|---|
| F1 (NL→Tools) | ✅ Addressed | `commands/` routing system + `route.md` — natural language to structured tool calls |
| F2 (Own prompts) | None | Fully implemented |
| F3 (Own context) | ✅ Addressed | XML-style output (`--xml` flag) + pre-fetch (`--prefetch` flag) in retrieve-context.sh |
| F4 (Tools = structured outputs) | ✅ Addressed | `commands/` (14 commands) — each is a structured tool with metadata |
| F5 (Unify state) | ✅ Addressed | `events` array in session-state.json for append-only event sourcing |
| F6 (Launch/Pause/Resume) | ✅ Addressed | `session-fork.sh` + `checkpoint-commit.sh` + `context-save.sh` — file-system-based launch/pause/resume |
| **F7 (Contact humans)** | ✅ Addressed | `scripts/a2h-contact.sh` + `scripts/notify.sh` — full A2H protocol |
| **F8 (Own control flow)** | ✅ Addressed | `--risk high` flag triggers approval gate in implement-preflight.sh |
| **F9 (Compact errors)** | ✅ Addressed | error-counter.sh + log-error.sh + a2h-contact.sh — capture → count → context → escalate |
| F10 (Small focused agents) | None | Fully implemented — this IS our architecture |
| **F11 (Trigger anywhere)** | ⚡ Partial (outbound) | `scripts/notify.sh` dispatches to Slack/CLI/file. **Inbound triggers** (Slack commands, email-to-agent, webhooks) still missing |
| F12 (Stateless reducer) | ✅ Addressed | `events` array in session-state.json + checkpoint commit cycle |
| F13 (Pre-fetch context) | ✅ Addressed | `scripts/prefetch-context.sh` + `retrieve-context.sh --prefetch` |

---

## Integration Milestones

| # | Milestone | Factors Addressed | Status |
|---|---|---|---|
| 1 | Foundation + Principles Map | All (documentation) | ✅ This doc |
| 2 | Context Engineering Deepening | F3, F5, F12, F13 | ✅ Complete (Slice 2) |
| 3 | Human-in-the-Loop Integration | F7, F8, F11 | ✅ Complete (Slice 3) |
| 4 | Scaffolding & Templates | All (tooling) | ✅ Complete (Slice 4) |
| 5 | Error Handling & Control Flow | F8, F9 | ✅ Complete (Slice 5) |

---

## References

- [12-Factor Agents — Full Guide](https://github.com/humanlayer/12-factor-agents)
- [A2H Protocol Specification](https://github.com/humanlayer/12-factor-agents/blob/main/drafts/a2h-spec.md)
- [HumanLayer SDK + CodeLayer IDE](https://github.com/humanlayer/humanlayer)
- [12-Factor Agents Workshop Walkthrough](https://github.com/humanlayer/12-factor-agents/tree/main/workshops)
- [got-agents/agents — OSS implementations](https://github.com/got-agents/agents)
- [Context Engineering Cheat Sheet (@lenadroid)](https://x.com/lenadroid/status/1943685060785524824)
