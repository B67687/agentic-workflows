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

Agents are configured natively in OpenCode's agent system:

### Primary Agent (JSON)

`opencode.json` defines the Orchestrator:

```json
{
  "default_agent": "orchestrator",
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "model": "opencode-go/kimi-k2.6",
      "description": "Main orchestrator agent. Handles tasks directly by default, only routing to specialist subagents (explorer, worker) when the task clearly benefits from it. Handles planning, synthesis, and direct conversation.",
      "prompt": "You are the Orchestrator. Your job is to understand the user's request and handle it directly by default, only routing to specialist agents when the task clearly benefits from it.\n\nIMPORTANT: Customize the model IDs below to match your OpenCode subscription (Go, Zen, Copilot, etc.). Use cheap models for simple tasks and expensive models for hard tasks.\n\n### DEFAULT STANCE: Handle Directly\nYour default behavior is to handle tasks yourself using available tools (read, glob, grep, bash, edit, webfetch). Only spawn a subagent when ALL of these are true:\n1. The task clearly matches a specialist's core domain\n2. The task would genuinely benefit from that specialist's specific model/capabilities\n3. The overhead (4-8 seconds + extra tokens) is justified by complexity\n\nBefore spawning ANY subagent, ask yourself: \"Could I complete this in under 10 seconds with a simple tool call?\" If yes, handle it directly.\n\n### Direct-Handling Thresholds\n| Task Type | Threshold | Action |\n|-----------|-----------|--------|\n| Search | 1-2 files, obvious pattern | Handle directly with read/glob |\n| Search | 3+ files, complex patterns, grep across codebase | Spawn @explorer |\n| File edits | 1-3 line changes, single file | Handle directly |\n| File edits | New file, module, or multi-file change | Spawn @worker |\n| File ops | Move/rename < 10 files | Handle directly |\n| File ops | Bulk reorganize 10+ files, archive, cleanup | Handle directly or spawn @worker if complex |\n| Docs | Update 1 section, fix typo | Handle directly |\n| Docs | Write new guide, full README, changelog | Handle directly |\n| Explanation | Simple Q&A, clarification | Handle directly |\n| Explanation | Deep analysis, root cause | Handle directly (K2.6) by default; spawn @worker (M2.7) only if fresh context needed |\n| Review | Quick sanity check | Handle directly |\n| Review | Full code review, audit | Handle directly (K2.6) by default; spawn @worker (M2.7) only if fresh context needed |\n\n**Three-tier fallback... (line truncated to 2000 chars)
      "permission": {
        "edit": "allow",
        "bash": "allow",
        "webfetch": "allow",
        "task": {
          "*": "deny",
          "explorer": "allow",
          "worker": "allow"
        }
      }
    },
    "build": {
      "disable": true
    }
  }
}
```

**Note:** The built-in `build` agent is disabled to avoid redundancy (Orchestrator replaces it). It remains in config as a fallback — set `"disable": false` to re-enable.

### Subagents (Markdown)

`.opencode/agents/*.md` files define subagents. OpenCode auto-discovers them.

| File | Agent | Model | Permissions | When Spawned |
|------|-------|-------|-------------|--------------|
| `explorer.md` | Explorer | `opencode/minimax-m2.5-free` | Read-only | Bulk search (10+ files), complex grep |
| `worker.md` | Worker | `opencode-go/kimi-k2.6` (or M2.7) | Write + edit + bash | Fresh context for long sessions, parallel work |

**Removed (merged into Worker):**
- ~~`drafter.md`~~ — "Implementation" is just work with fresh context
- ~~`analyst.md`~~ — "Deep investigation" is just work with fresh context

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

Switch the orchestrator model in `opencode.json` based on your budget:

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

## Agent Skills

This workspace uses OpenCode's native **Agent Skills** support (agentskills.io standard) to package reusable workflows.

### Available Skills

Skills live in `.opencode/skills/<name>/SKILL.md` and are loaded on-demand via the `skill` tool.

| Skill | Location | Description | Invoke With |
|-------|----------|-------------|-------------|
| **propagate** | `.opencode/skills/propagate/` | Propagate templates from hub to all 25 topic folders | "Propagate templates" or `/propagate` |
| **audit-quality** | `.opencode/skills/audit-quality/` | Run quality audit on current folder | "Audit this folder" or `/audit-quality` |
| **session-handoff** | `.opencode/skills/session-handoff/` | Create checkpoint with 5-line summary | "I'm leaving" or 10+ turns |
| **research-deep** | `.opencode/skills/research-deep/` | Authoritative research with source triangulation | "Research X" or "Investigate Y" |
| **cross-domain-harvest** | `.opencode/skills/cross-domain-harvest/` | Harvest insights and propagate approved lessons | "Harvest insights" or "Cross-domain review" |

### How Skills Work

1. **Discovery**: OpenCode loads skill `name` + `description` at startup (minimal context)
2. **Activation**: When a task matches a skill's description, the agent loads the full `SKILL.md`
3. **Execution**: The agent follows the instructions, optionally running bundled scripts

### Skill Format

```yaml
---
name: skill-name
description: What this does and when to use it
---

# Instructions
Step-by-step guidance for the agent...
```

### Permissions

Skills are enabled in `opencode.json`:
```json
"permission": {
  "skill": "allow"
}
```

Per-skill permissions can be configured with patterns:
```json
"permission": {
  "skill": {
    "*": "allow",
    "internal-*": "deny"
  }
}
```

---

## Status

- [x] Agent definitions created in `.opencode/agents/` (2 agents: explorer, worker)
- [x] ~~Deprecated agents removed: drafter.md, analyst.md~~ (merged into worker)
- [x] Orchestrator configured in `opencode.json`
- [x] `default_agent` set to orchestrator
- [x] Built-in `build` agent disabled (kept as fallback)
- [x] Task permissions configured for explorer + worker
- [x] Agent Skills configured in `.opencode/skills/` (5 skills: propagate, audit-quality, session-handoff, research-deep, cross-domain-harvest)
- [x] Orchestrator permissions added (edit, bash, webfetch)
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
