# Agentic Workflows

Native agentic configuration for the AI Prompting workspace. Uses OpenCode's built-in agent system with semi-automatic routing via the `Task` tool.

---

## The Problem

Sticking to one model for everything creates two hidden costs:

1. **Token burn** — Using K2.6 for simple search tasks costs 5× more than necessary
2. **Context degradation** — Long threads degrade quadratically; quality drops after 15+ turns

The solution: **smart task routing** — handle simple tasks directly for speed and low token cost, delegate complex tasks to specialist agents for quality and fresh context.

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

## Agent Roles

| Agent | Default Model | Fallback Model | Escalation Model | Provider | Role | How Invoked |
|-------|---------------|----------------|------------------|----------|------|-------------|
| **Orchestrator** | **Kimi K2.6** | — | — | Go | Planning, routing, synthesis | Primary agent — loads by default |
| **Explorer** | **MiniMax M2.5 Free** | — | — | Zen | Search, discovery, grep, file finding | Auto-routed for search tasks, or `@explorer` |
| **Planner** | **MiniMax M2.7** | — | — | Go | Create plans, analyze, design | Auto-routed for complex tasks, or `@planner` |
| **Scribe** | **MiniMax M2.5 Free** | — | — | Zen | Write docs, READMEs, guides, changelogs | Auto-routed for doc tasks, or `@scribe` |
| **Drafter** | **MiniMax M2.7** | — | — | Go | Implementation, scaffolding, code generation | Auto-routed for write tasks, or `@drafter` |
| **Gardener** | **MiniMax M2.5 Free** | — | — | Zen | File operations, organization, cleanup | Auto-routed for file ops, or `@gardener` |
| **Debugger** | **Orchestrator direct (K2.6)** | **M2.7** | **Claude Sonnet 4.6** | Go | Hard bugs, root cause analysis, reasoning | Auto-routed for debug tasks, or `@debugger` |
| **Reviewer** | **Orchestrator direct (K2.6)** | **M2.7** | **Claude Sonnet 4.6** | Go | Code review, verification, quality checks | Auto-routed for review tasks, or `@reviewer` |

### Why These Models?

| Agent | Default Model | Provider | Rationale |
|-------|--------------|----------|-----------|
| Orchestrator | K2.6 | Go | Routing decisions require reasoning; cost is negligible (1 decision per task) |
| Explorer | M2.5 Free | Zen | **FREE** — 100 TPS, fastest for search, zero cost |
| Planner | M2.7 | Go | Cheap planning without code changes; 3,400 req/5hr |
| Scribe | M2.5 Free | Zen | **FREE** — docs don't need heavy reasoning; fast and cheap for prose |
| Drafter | M2.7 | Go | 56.2% SWE-Pro, good for harness engineering and bulk implementation |
| Gardener | M2.5 Free | Zen | **FREE** — file ops are mechanical; handles bash output at zero cost |
| Debugger | **K2.6 direct** | Go | **$0 extra** — already paid; handles most debug/review directly |
| Reviewer | **K2.6 direct** | Go | **$0 extra** — already paid; handles most debug/review directly |

**Three-tier fallback for Debug / Review:**

| Tier | Model | Cost | When |
|------|-------|------|------|
| **1. Default** | Orchestrator direct (K2.6) | **$0 extra** | Most debug/review tasks — just handle directly |
| **2. Fallback** | @debugger/@reviewer (M2.7) | **Flat rate** (Go) | Needs fresh context or very large task |
| **3. Escalation** | Claude Sonnet 4.6 | **Pay-as-you-go** | Security suspected, or Tiers 1+2 both failed |

**Escalation rules:**
- Security vulnerability suspected or confirmed
- K2.6 and M2.7 both failed (2+ attempts each)
- User explicitly requests premium analysis

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
      "description": "Main orchestrator agent. Routes tasks to specialist subagents...",
      "permission": {
        "edit": "allow",
        "bash": "allow",
        "webfetch": "allow",
        "task": {
          "*": "deny",
          "explorer": "allow",
          "planner": "allow",
          "scribe": "allow",
          "drafter": "allow",
          "gardener": "allow",
          "debugger": "allow",
          "reviewer": "allow"
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

| File | Agent | Model | Permissions |
|------|-------|-------|-------------|
| `explorer.md` | Explorer | `opencode/minimax-m2.5-free` | Read-only |
| `planner.md` | Planner | `opencode-go/minimax-m2.7` | Read-only |
| `scribe.md` | Scribe | `opencode/minimax-m2.5-free` | Write (docs only), webfetch |
| `drafter.md` | Drafter | `opencode-go/minimax-m2.7` | Write + edit + bash |
| `gardener.md` | Gardener | `opencode/minimax-m2.5-free` | Edit + bash (scoped) |
| `debugger.md` | Debugger | `opencode-go/minimax-m2.7` | Full tools (edit: ask) |
| `reviewer.md` | Reviewer | `opencode-go/minimax-m2.7` | Read-only |

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
Orchestrator: Bulk analysis → spawns @reviewer for systematic audit

You: "Plan a new authentication system"
Orchestrator: Complex design → spawns @planner
              → presents plan to user
              → after approval, spawns @drafter to implement
```

**Accuracy:** High for obvious cases (search → Explorer, write → Drafter, plan → Planner). Medium for mixed or ambiguous requests.

### Manual (@mention)

You can always bypass auto-routing:

```
@explorer find auth_token
@debugger why is this test failing
@reviewer check the new auth module
```

### Override

Force the Orchestrator to handle directly or use a specific model:

```
"Use K2.6 for this" → bypasses routing, Orchestrator handles directly
"Actually use @debugger" → corrects a misroute
```

---

## Agent Disclosure

**After EVERY response, the Orchestrator must disclose agent usage:**
Add a footer showing which agents were used, what model each ran on, how many tasks they handled, and why. Format:
```
---
Agents used: @explorer x3 (MiniMax M2.5 Free), @reviewer x1 (Claude Sonnet 4.6)
Reason: large search then quality audit
```
```
---
Agents used: Orchestrator (direct, Kimi K2.6) — no specialist needed.
```
Rules:
- Use the **full model name** (Kimi K2.6, MiniMax M2.5 Free, Claude Sonnet 4.6, etc.)
- For subagents, prefix with task count: `@explorer x3`
- For direct handling, state the orchestrator model explicitly

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

---

## Cost Comparison: Monolithic vs Agentic

### Scenario: Implement a new API endpoint

| Phase | Monolithic (K2.6 only) | Agentic | Savings |
|-------|----------------------|---------|---------|
| Explore codebase | 100% K2.6 | 80% M2.5 | **5×** |
| Draft implementation | 100% K2.6 | 70% M2.7 | **3×** |
| Debug edge cases | 100% K2.6 | 100% K2.6 | — |
| Review quality | 100% K2.6 | 100% GLM-5.1 | — |
| **Total** | **100% baseline** | **~50% baseline** | **~2× overall** |

### Scenario: Long mixed session (20 turns)

| Pattern | Cost Curve | Quality at Turn 20 |
|---------|-----------|-------------------|
| Monolithic K2.6 | Quadratic (degrading) | Degraded |
| Agentic with subsessions | Linear (fresh context each) | Maintained |

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
4. **Fail fast** — If a subsession fails twice, escalate to Debugger (K2.6)

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

| Primary | Fallback 1 | Fallback 2 |
|---------|-----------|------------|
| K2.6 (Orchestrator) | K2.5 (61% more requests) | M2.7 (lower quality) |
| M2.5 (Explorer) | Qwen3.5 Plus (10,200 req/5hr) | M2.7 (if both exhausted) |
| M2.7 (Drafter) | Qwen 3.6 Plus (78.8% SWE-V) | K2.6 (if quality critical) |
| GLM-5.1 (Reviewer) | K2.6 (same quality tier) | M2.7 (fast but lower benchmarks) |

**Note:** OpenCode does not natively support automatic model fallbacks in agent configs. These fallback chains are documented for manual use — either switch models in the UI or tell the Orchestrator explicitly (e.g., "use Qwen3.5 Plus instead of M2.5").

---

## Quality Guardrails

1. **Never downgrade critical tasks** — Debugging and final review always use best model
2. **Verify specialist output** — Orchestrator spot-checks results before presenting
3. **Track error rates** — If an agent misroutes 3× in a session, revert to monolithic for that session
4. **User override** — You can always say "use K2.6 for this" to bypass routing

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

- [x] Agent definitions created in `.opencode/agents/` (7 agents: explorer, planner, scribe, drafter, gardener, debugger, reviewer)
- [x] Orchestrator configured in `opencode.json`
- [x] `default_agent` set to orchestrator
- [x] Built-in `build` agent disabled (kept as fallback)
- [x] Task permissions configured for all subagents
- [x] Agent Skills configured in `.opencode/skills/` (3 skills: propagate, audit-quality, session-handoff)
- [x] Orchestrator permissions added (edit, bash, webfetch)
- [x] Documentation updated

---

## Sources

- [OpenCode Agents docs](https://opencode.ai/docs/agents/) — Agent configuration, Task tool, permissions
- [OpenCode Config docs](https://opencode.ai/docs/config/) — `default_agent`, `permission.task`
- [OpenCode Go docs](https://opencode.ai/docs/go/) — Model list and request limits
- [MiniMax M2.5 announcement](https://www.minimaxi.com/en/news/minimax-m25) — 100 TPS, cost efficiency
- [GLM-5.1 Hugging Face](https://huggingface.co/zai-org/GLM-5.1) — Benchmark comparisons
- [Kimi K2.6 benchmarks](https://lushbinary.com/blog/kimi-k2-6-developer-guide-benchmarks-api-agent-swarm) — Quality baseline
