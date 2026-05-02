# Agentic Workflows

Native agentic configuration for the AI Prompting workspace. Uses OpenCode's built-in agent system with semi-automatic routing via the `Task` tool.

---

## The Problem

Sticking to one model for everything creates two hidden costs:

1. **Token burn** — Using K2.6 for simple search tasks costs more than necessary
2. **Context degradation** — Long threads degrade quadratically; quality drops after 15+ turns

The solution: **smart task routing** — handle simple tasks directly for speed and low token cost, delegate to specialist agents only when the benefit clearly exceeds the overhead.

### The Cost Landscape Has Changed (2026-04)

Since this system was designed, model costs have collapsed:

| Model | Cost | Quality |
|-------|------|---------|
| **Claude Sonnet 4.6** (Copilot Student) | **$0** | Very High — daily driver |
| **Gemini 3.1 Pro** (AI Studio) | **$0** | High — 14,400 requests/day |
| **MiniMax M2.5 Free** (OpenCode Zen) | **$0** | High — 80.2% SWE-V |
| **Kimi K2.6** (Go, during 3× promo) | ~$10/mo | Highest in Go — ~3,450 req/5hr |
| **DeepSeek V3.2** (API) | $0.252/M | Strong reasoning |

**The old assumption** was that every request to a premium model was expensive, so routing to cheaper models saved real money.

**The new reality**: With Copilot Student (free Sonnet 4.6), Gemini free tier, and K2.6 on promotion, the *per-request* cost difference between "cheap" and "premium" is often **zero**. The real cost is now **time and complexity**:

| Factor | Multi-AI Routing | Single-AI Direct |
|--------|-----------------|------------------|
| Spawn overhead | 4–8 seconds per subagent | Zero |
| Context loss | Compressed to 3–5 bullets | Full thread history retained |
| Cognitive load | Must manage agent boundaries | One conversation |
| Parallel work | Possible (real benefit) | Sequential only |
| Fresh context | Guaranteed (real benefit) | Requires manual handoff |

### When Multi-AI Still Wins

1. **Fresh context on long sessions** (15+ turns) — Spawn the same model with a 5-line summary
2. **Genuinely parallel tasks** — Two independent workstreams at once
3. **Differentiated capabilities** — Gemini for 1M context, DeepSeek for math, multimodal
4. **High-volume exploration** — M2.5 Free for bulk search (zero cost, fast)

### When Single-AI Is Better

1. **Normal coding/writing sessions under 15 turns** — Routing overhead > savings
2. **Tasks requiring deep context awareness** — One model remembers earlier decisions
3. **Debugging** — Context continuity matters more than "fresh eyes"
4. **When using free premium models** — Sonnet 4.6 (Copilot) or Gemini (AI Studio) handle everything

### Revised Principle

> **Use one main AI for 90% of work. Spawn subagents only for fresh context, parallel work, or capabilities the main AI lacks.**

The model quality gap between "orchestrator" and "subagent" has narrowed so much that the primary benefit of subsessions is now **context hygiene**, not cost savings.

---

## Runtime Lessons From Agentic CLI Codebases (2026-04-24)

Deep source reading of the original TypeScript codebase and the Rust rewrite changed the practical lesson: speed helps, but only after the workflow has stable contracts.

### Transferable Runtime Patterns

| Runtime mechanism | Workspace behavior |
|---|---|
| Tool contracts declare read/write/destructive/concurrency behavior | Prompts and workflows should name allowed tools, write scope, verification, and output limits before broad execution |
| Permission engines fail closed when commands are too complex to prove safe | Do not approve broad compound commands just because the first subcommand looks harmless |
| Long tool output is persisted or truncated intentionally | Ask for summaries plus artifact paths instead of pasting massive raw output into chat |
| Subagents get stripped context, scoped permissions, and cleanup | Spawn only bounded work packets; require changed files, verification, and residual risk on return |
| Forked sessions preserve stable system/tool surfaces for cache hits | Avoid changing global instructions, tool lists, or execution modes mid-session unless the benefit is worth the cache/context reset |
| Rewrites use deterministic parity harnesses | Treat "same specs" as weaker than scenario parity; require captured requests, scripted cases, and open-gap tables |
| Compaction and recovery run health probes before risky work | After resume/compaction, do a read-only sanity probe before edits, deletes, or bulk moves |

### What Rust Actually Buys

Rust improves local runtime hot paths: file IO, registries, permission checks, cache fingerprinting, parsing, and deterministic test harnesses. It does not remove model latency, weak prompts, vague scope, or context degradation. The human workflow still has to provide narrow goals, verification targets, and clean handoff boundaries.

### New Default For Heavy Agentic Work

Use this order for broad autonomous tasks:

1. **Define the lane**: discovery, planning, implementation, verification, parity audit, or cleanup.
2. **State the contract**: allowed files, allowed tools, destructive limits, output budget, success criteria.
3. **Run discovery read-only first**: collect facts before mutation.
4. **Checkpoint before mutation**: update session state or topic handover.
5. **Mutate in the smallest safe slice**: no kitchen-sink execution.
6. **Health-probe after compaction/resume**: verify tools and repo state still match assumptions.
7. **Verify with evidence**: tests, scripted scenarios, diff review, or explicit residual risk.
8. **Promote durable lessons**: update the smallest correct doc/template, not a new orphan file.

## Deterministic Default Workflow

The workspace now prefers one deterministic flow for non-trivial work:

**Research -> Plan -> Implement**

This is not just doctrine. The hub now includes two helpers:

- `scripts/retrieve-context.sh` to pull only the local files relevant to the current step
- `scripts/session-boundary.sh` to decide whether to continue, checkpoint, or restart in a new session

Use them like this:

```bash
bash ./scripts/retrieve-context.sh "managed core vs repo-owned"
bash ./scripts/session-boundary.sh --phase research --turns 9 --verified
```

The behavioral default is:

- do research without editing
- write the plan before implementation
- checkpoint after verified phases
- start a new session when the phase changes or context quality drops

---

## Architecture

```
You talk to: Orchestrator Agent (K2.6)
    ↓
Reads subagent descriptions, decides match
    ↓
Spawns specialist agent (subsession) with compressed context
    ↓
Receives result, synthesizes, presents to you
```

**Routing is semi-automatic.** The Orchestrator handles simple tasks directly by default. It only reads subagent `description` fields and spawns a match when the task clearly exceeds direct-handling thresholds. You can also manually invoke any subagent with `@agentname`.

---

## Agent Roles (Simplified — April 2026)

Given the current cost landscape, the 4-agent setup is over-engineered for most sessions. The primary benefit of subsessions is **fresh context**, not cost savings.

### Recommended Setup

| Agent | Default Model | Role | When To Spawn |
|-------|--------------|------|---------------|
| **Orchestrator** | **Kimi K2.6** (or Sonnet 4.6 via Copilot) | Handles 90% of work directly | Default — never spawn for simple tasks |
| **Explorer** | **MiniMax M2.5 Free** | Bulk search across many files | Only for 10+ file searches or complex grep |
| **Worker** | **Same as Orchestrator** (K2.6 or M2.7) | Fresh context for long sessions | 15+ turns, topic shift, or quality degradation |

**Why only 2 subagents?**

- **Explorer** — M2.5 Free is genuinely free and fast (100 TPS). Worth spawning for bulk search.
- **Worker** — The Drafter/Analyst distinction was artificial. Both just meant "do work with fresh context." Use the same model as the Orchestrator (K2.6) or drop to M2.7 if volume matters.

**Removed:**
- ~~Drafter~~ — Merged into Worker. "Implementation" is just "work with fresh context."
- ~~Analyst~~ — Merged into Worker. "Deep investigation" is just "work with fresh context."

### Model Selection for the Main AI

Your main AI should be whichever model you have best access to:

| Your Setup | Recommended Main AI | Why |
|-----------|-------------------|-----|
| Copilot Student (free) | **Claude Sonnet 4.6** | Best quality at zero cost. 300 premium requests/month. |
| OpenCode Go ($10/mo, K2.6 promo) | **Kimi K2.6** | Best quality in Go, ~3,450 req/5hr during 3× promo. |
| OpenCode Go (post-promo) | **Kimi K2.6** for quality, **M2.5** for volume | K2.6 drops to 1,150 req/5hr; M2.5 gives 5.5× more. |
| Gemini AI Studio (free) | **Gemini 3.1 Pro** | 14,400 requests/day, 1M context, multimodal. |
| DeepSeek API | **DeepSeek V3.2** | Cheapest reasoning ($0.252/M), MIT license. |

### Three-Tier Fallback

| Tier | Model | Cost | When |
|------|-------|------|------|
| **1. Default** | Orchestrator direct (your main AI) | **$0 extra** | 90% of tasks — just handle directly |
| **2. Fresh context** | Worker (same model, clean slate) | **Same cost** | 15+ turns, topic shift, quality degradation |
| **3. Escalation** | Claude Opus 4.7 or GPT-5.3-Codex | **Premium quota** | Security suspected, or Tiers 1+2 failed |

**Escalation rules:**
- Security vulnerability suspected or confirmed
- Main AI failed twice on the same task
- User explicitly requests premium analysis
- Task requires frontier reasoning (Opus 4.7) or advanced coding (GPT-5.3-Codex)

---

## Configuration

Agents are configured natively in OpenCode's global OpenCode config:

### Runtime Authority

Use the global config at `/home/namikaz/.config/opencode/opencode.jsonc`.

Do not create repo-local `opencode.json` files or workspace-level `.opencode/` directories for this workflow. The current setup keeps one runtime authority and lets repos differ only through normal repo files such as `session-state.json`, `AGENTS.md`, and `docs/workspace-system-overview.md`.

### Current Pattern (JSON excerpt)

The current system uses a primary orchestrator plus optional subsessions:

```json
{
  "instructions": ["session-state.json"],
  "shell": "bash",
  "model": "opencode/minimax-m2.5-free",
  "small_model": "opencode/minimax-m2.5-free",
  "default_agent": "orchestrator",
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "model": "opencode/minimax-m2.5-free",
      "small_model": "opencode/minimax-m2.5-free",
      "steps": 20,
      "permission": {
        "edit": "allow",
        "bash": "allow",
        "webfetch": "allow",
        "skill": "allow",
        "sequential-thinking_*": "allow",
        "task": {
          "*": "deny",
          "explorer": "allow",
          "worker": "allow"
        }
      }
    },
    "explore": {
      "model": "opencode/minimax-m2.5-free",
      "steps": 6
    },
    "review": {
      "mode": "subagent",
      "model": "opencode/minimax-m2.5-free",
      "temperature": 0.1,
      "steps": 6,
      "permission": {
        "edit": "deny"
      }
    },
    "build": {
      "mode": "primary",
      "steps": 24
    },
    "plan": {
      "mode": "primary",
      "model": "opencode/minimax-m2.5-free",
      "temperature": 0.1,
      "steps": 8,
      "permission": {
        "edit": "deny",
        "bash": "deny"
      }
    }
  },
  "mcp": {
    "sequential-thinking": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"],
      "enabled": true
    }
  }
}
```

### Current Agent Roles

| Agent | Role |
|------|------|
| `orchestrator` | Default lane. Handles work directly and routes only when a fresh context or specialized lane is genuinely helpful. |
| `explorer` | Read-only bulk discovery for large search or repo mapping tasks. |
| `worker` | Fresh-context implementation or verification lane when the main thread is too saturated or the task needs a clean slice. |
| `review` | Read-only review lane for diff audits and bug/risk finding. |
| `plan` | Read-only planning lane for concise decision-complete plans. |
| `build` | Straight implementation lane when you want less routing logic than the orchestrator. |

There are no repo-local `.opencode/agents/*.md` files in the supported workspace design. Agent behavior lives in the global config and in the hub doctrine docs.

---

## How Routing Works

### Semi-Automatic (Default)

The Orchestrator handles tasks directly by default. Only when a task clearly exceeds direct-handling thresholds does it read subagent `description` fields and use the `Task` tool to spawn the best match.

**Updated thresholds (hybrid model):**
- **Direct:** < 10 files search, 1-3 line edits, < 10 file ops, doc updates/typos, simple Q&A, quick checks, simple plans
- **Route:** 10+ files search, new modules/multi-file refactors, bulk ops 10+ files, full doc writes, deep analysis, full reviews, complex architecture

**Examples of tasks that SHOULD be handled directly:**
```
You: "What files are in docs/?"
Orchestrator: Simple listing → handled directly with `glob` (no spawn)

You: "Delete these 3 files"
Orchestrator: Simple file ops → handled directly with `bash` (no spawn)
```

**Examples of tasks that SHOULD spawn a subagent:**
```
You: "Find all uses of auth_token across 50 files"
Orchestrator: Large search → exceeds direct threshold
              → spawns @explorer (free model, fresh context)

You: "Audit all 25 topic folders for quality issues"
Orchestrator: Bulk analysis → spawns @worker for systematic audit with fresh context

You: "Plan a new authentication system"
Orchestrator: Complex design → handles planning directly (K2.6)
              → presents plan to user
              → after approval, spawns @worker to implement
```

**Accuracy:** High for obvious cases (search → Explorer, fresh context → Worker). Medium for mixed or ambiguous requests.

### Manual (@mention)

You can always bypass auto-routing:

```
@explorer find auth_token
@worker why is this test failing
@worker check the new auth module
```

### Override

Force the Orchestrator to handle directly or use a specific model:

```
"Use K2.6 for this" → bypasses routing, Orchestrator handles directly
"Actually use @worker" → corrects a misroute
```

---

## Internal Coordination Notes

Do not add public-facing footers that disclose routing, model use, or internal execution mechanics unless the target repo or platform explicitly requires it.

Instead, keep accountability inside the work artifacts:

- Session state records which lanes were used, what changed, and what remains risky.
- Final user summaries focus on root cause, fix, verification, and residual risk.
- PRs and public comments stay project-native: no model names, no routing notes, no generic automation tells.
- If a platform requires disclosure, follow that platform's rule and keep it concise.

---

## Borrowed Workflow Patterns That Fit This Hub

Several external skill repos have good ideas, but this workspace adopts them as compact workflow patterns instead of importing a second full meta-system.

### 1. Grilling Before Big Changes

Use before major feature work, wide refactors, repo reorganization, or ambiguous requests.

Goal:
- force alignment before implementation
- surface hidden assumptions
- clarify scope, constraints, and success criteria

In this hub, the output should update:
- `session-state.json`
- the current plan in conversation
- repo docs only if a durable rule or shared language changed

### 2. Disciplined Diagnosis

Use for hard bugs, regressions, and performance issues.

Loop:
1. reproduce
2. narrow
3. hypothesize
4. instrument
5. fix
6. regression-test

Do not skip straight from "symptom seen" to "patch applied".

### 3. Red-Green-Refactor

This hub already uses TDD as a first-class lane. The key reminder is that agents should prefer one small verified slice over a broad speculative implementation.

See `docs/tdd-with-agents.md`.

### 4. Zoom-Out Pass

Use when local edits are outrunning system understanding.

Ask for:
- architecture map
- module responsibilities
- dependency edges
- why this area exists
- where the actual boundary of change should be

This is especially useful before:
- refactors
- architecture changes
- multi-file edits in unfamiliar repos

### 5. Architecture Improvement Routine

Do not wait for a codebase to become a full ball of mud.

Run a periodic architecture pass on active repos:
- identify complexity that no longer pays rent
- tighten boundaries
- promote shared language
- simplify interfaces

This should happen as a bounded review lane, not as constant opportunistic rewriting.

### The Rule

Adopt small workflow ideas that reinforce the current system:
- one runtime authority
- one repo resume path
- one-way propagation
- read-only harvest
- explicit manual promotion

Do not import a second skill/config runtime that competes with the hub.

---

## Context Passing Format

When spawning a subsession, the Orchestrator should pass only what the specialist needs:

```
---
Task: [specific, bounded]
Context: [3-5 bullets max]
Files: [only paths, no content unless critical]
Constraints: [hard limits]
Done when: [success criteria]
---
```

**Never pass:**
- Full thread history
- Previous reasoning chains
- Irrelevant file contents
- Teaching material

**Example:**

```
---
Task: Find all usages of `auth_token` in the codebase
Context:
- auth module recently refactored
- looking for stale references
- focus on Python files
Files: None needed (glob search)
Constraints: Skip test files, skip node_modules
Done when: List of files + line numbers provided
---
```

### Manual Fresh-Context Packet (Non-OpenCode Environments)

For environments that do not have native OpenCode-style subagent routing, use this packet to spawn a fresh context manually:

```
Task:
[specific, bounded]

Context:
- [3-5 bullets only]

Files:
- [paths only]

Constraints:
- [write scope, destructive limits, style rules]

Done when:
- [verification and success criteria]
```

Never paste the full transcript, old reasoning chains, or unrelated file contents into a new chat.

---

## Cost Comparison: Single-AI vs Agentic (Updated April 2026)

### The Old Math vs The New Math

**Old assumption (2026-Q1):** Premium models cost significantly more per request, so routing to cheaper models saves real money.

**New reality:** With Copilot Student (free Sonnet 4.6), Gemini free tier, and K2.6 on promotion, the per-request cost is often identical. The real comparison is **quality vs overhead**.

### Scenario: Normal coding session (under 15 turns)

| Pattern | Speed | Quality | Complexity |
|---------|-------|---------|------------|
| Single-AI direct (Sonnet 4.6 or K2.6) | Fastest | Best — full context | Low |
| Multi-AI (route discovery to Explorer, fresh work to Worker) | Slower (spawn overhead) | Good - but context compressed | Higher |
| **Winner** | **Single-AI** | **Single-AI** | **Single-AI** |

### Scenario: Long mixed session (20+ turns)

| Pattern | Cost Curve | Quality at Turn 20 |
|---------|-----------|-------------------|
| Single-AI monolithic | Quadratic (degrading) | Degraded |
| Single-AI with periodic handoffs | Linear (manual resets) | Maintained |
| Worker subsession (fresh context) | Linear (automatic) | Maintained |
| **Winner** | **Worker subsession** | **Worker subsession** |

### Scenario: Bulk exploration (search across 50 files)

| Pattern | Cost | Speed | Quality |
|---------|------|-------|---------|
| Single-AI (K2.6) | Low (part of $10/mo) | Medium | Best |
| Explorer (M2.5 Free) | **$0** | **Fastest (100 TPS)** | Good enough |
| **Winner** | **Explorer** | **Explorer** | Single-AI for synthesis |

### Bottom Line

| Situation | Use |
|-----------|-----|
| Normal session (< 15 turns) | **Single-AI direct** — faster, simpler, better context |
| Long session (15+ turns) | **Worker subsession** — fresh context is the win |
| Bulk search/exploration | **Explorer (M2.5 Free)** — zero cost, fast |
| Parallel independent tasks | **Worker subsessions** — real concurrency |
| Different capabilities needed | **Specialized model** — Gemini 1M context, DeepSeek math, etc. |

---

## Warm Handoff Protocol

When context pressure builds, compress and restart:

### Trigger Conditions

| Signal | Action |
|--------|--------|
| 10+ turns in current thread | Proactively suggest handoff |
| Topic shift detected | Compress + spawn fresh |
| Model starts repeating itself | Immediate handoff |
| Output quality drops | Compress + restart |

### Handoff Template

```
Previous work summary (5 lines max):
1. [What was accomplished]
2. [Key decisions made]
3. [Current state]
4. [Blockers if any]
5. [Next task]

Continue with: [specific next step]
```

---

## Subsession Management

### Rules

1. **One subsession per subtask** — Don't chain multiple tasks in one subsession
2. **Compress before spawning** — Never pass full thread history
3. **Synthesize on return** — Orchestrator distills specialist output before presenting
4. **Fail fast** - If a subsession fails twice, checkpoint and re-plan or switch to a fresh best-model review lane

### Lifecycle

```
1. Detect subtask
2. Compress context (5-line summary)
3. Spawn subsession with specialist + compressed context
4. Specialist works with fresh context
5. Result returns to Orchestrator
6. Orchestrator synthesizes and presents
7. Subsession context discarded
```

---

## Fallback Rules

When primary model is unavailable or quota exhausted:

| Primary | Fallback 1 | Fallback 2 | Fallback 3 |
|---------|-----------|------------|------------|
| K2.6 (Orchestrator) | K2.5 (61% more requests) | M2.7 (volume) | Sonnet 4.6 (Copilot) |
| Sonnet 4.6 (Copilot) | K2.6 (Go) | Gemini 3.1 Pro (AI Studio) | — |
| M2.5 Free (Explorer) | Qwen3.5 Plus (10,200 req/5hr) | M2.7 (if both exhausted) | — |
| Worker (K2.6 or M2.7) | Same model, retry | Other Go model | Sonnet 4.6 (Copilot) |

**Note:** OpenCode does not natively support automatic model fallbacks in agent configs. These fallback chains are documented for manual use — either switch models in the UI or tell the Orchestrator explicitly (e.g., "use K2.5 instead of K2.6").

---

## Free-Tier Agentic Coding

You can run the entire agentic system on free models. See `docs/free-tier-agentic-guide.md` for the full guide.

### Quick Toggle

Switch the orchestrator model in `/home/namikaz/.config/opencode/opencode.jsonc` based on your budget:

| Mode | Orchestrator | Worker | Cost |
|------|-------------|--------|------|
| **Full Go** | K2.6 | K2.6 | $10/mo |
| **Hybrid** | M2.5 Free | K2.6 | ~$3-5/mo |
| **Full Free** | M2.5 Free | Hy3 Free | $0 |

### Why This Works

The agentic framework is **model-agnostic**. Free models like M2.5 Free (80.2% SWE-bench Verified) and Hy3 Preview Free (74.4%) are genuinely capable coding agents. The orchestrator's direct-by-default behavior, routing thresholds, and tool permissions work identically regardless of the model underneath.

**Recommended default:** Hybrid mode. Free orchestrator handles 90% of tasks directly. K2.6 worker is only spawned for complex implementation or when fresh context is needed. This cuts Go credit burn by ~80% without losing agentic capability.

### Tradeoffs

- **Rate limits:** Free models may have lower RPM. Switch models or add delays if hit.
- **Data collection:** Free models may collect data. Don't use them for proprietary code or credentials.
- **Context:** M2.5 Free has 1M context (more than K2.6's 256K). Hy3 has 256K. Trinity Large Free has 512K.

---

## Quality Guardrails

1. **Never downgrade critical tasks** — Debugging and final review always use best model
2. **Verify specialist output** — Orchestrator spot-checks results before presenting
3. **Track error rates** — If an agent misroutes 3× in a session, revert to monolithic for that session
4. **User override** — You can always say "use K2.6 for this" to bypass routing
5. **Stop loop failures** - If the same fix path fails twice, checkpoint, re-plan, or switch to fresh context
6. **Protect permission boundaries** - Treat broad shell commands, env/path manipulation, redirects, and cross-shell mutations as higher-risk until proven safe

---

## Reusable Workflows

This workspace now packages its reusable behavior as bash scripts plus normal hub docs, not repo-local `.opencode` skills.

### Hub-side operators

| Workflow | Entry point | Purpose |
|---------|-------------|---------|
| Propagation | `scripts/propagate-to-all.sh` | Bootstrap missing repo files and refresh only the managed core |
| Sync status | `scripts/check-sync-status.sh` | Report managed-clean, managed-drifted, managed-missing, and repo-owned file state |
| Harvest | `scripts/harvest-topic-insights.sh` | Read topic insights from repos into a central snapshot |
| Candidate build | `scripts/build-cross-domain-candidates.sh` | Turn harvested lessons into explicit promotion candidates |
| Merge and optional re-propagation | `scripts/merge-and-propagate.sh` | Promote one approved candidate into hub docs and optionally refresh managed core |

### Topic-repo wrappers

Every managed repo can carry two thin wrappers:

| Wrapper | Purpose |
|--------|---------|
| `sync-from-hub.sh` | Delegates to the hub managed-refresh workflow for that repo only |
| `check-sync-status.sh` | Delegates to the hub status checker for that repo only |

The supported contract is:

- managed core can be refreshed by the hub
- repo-owned files are bootstrapped once and then belong to the repo
- lesson promotion is explicit, manual, and read-only until approval

---

## Status

- [x] Orchestrator configured in the global OpenCode config
- [x] `default_agent` set to orchestrator
- [x] Task permissions configured for explorer + worker
- [x] Orchestrator permissions added (edit, bash, webfetch, task, sequential-thinking)
- [x] Repo-local `.opencode` runtime scaffolding removed from the supported design
- [x] Bash-based propagation, harvest, and promotion workflows are the supported automation path
- [x] Documentation updated with April 2026 cost analysis

### Changelog

| Date | Change | Reason |
|------|--------|--------|
| 2026-04-23 | Simplified from 7→3 agents (removed planner, scribe, gardener, debugger, reviewer) | Over-engineered taxonomy |
| 2026-04-24 | Simplified from 3→2 subagents (removed drafter, analyst; merged into worker) | Cost landscape changed — fresh context is the real win, not different models |

---

## Sources

- [OpenCode Agents docs](https://opencode.ai/docs/agents/) — Agent configuration, Task tool, permissions
- [OpenCode Config docs](https://opencode.ai/docs/config/) — `default_agent`, `permission.task`
- [OpenCode Go docs](https://opencode.ai/docs/go/) — Model list and request limits
- [MiniMax M2.5 announcement](https://www.minimaxi.com/en/news/minimax-m25) — 100 TPS, cost efficiency
- [GLM-5.1 Hugging Face](https://huggingface.co/zai-org/GLM-5.1) — Benchmark comparisons
- [Kimi K2.6 benchmarks](https://lushbinary.com/blog/kimi-k2-6-developer-guide-benchmarks-api-agent-swarm) — Quality baseline
