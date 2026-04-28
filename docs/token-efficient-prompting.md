# Token-Efficient Prompting

Use this file when the goal is lower total workflow cost, not just shorter prompts.

For the shared principles behind it, start with:

- [core-agent-doctrine.md](core-agent-doctrine.md)

## Core Rule

Optimize for the **minimum context that still preserves decision quality**.

The target is not shortness alone.
The target is lower total cost across:

- prompt text
- repeated instructions
- pasted context
- stale thread history
- oversized explanations
- avoidable retries

## The Main Levers

### 1. Scope harder

A narrower task usually saves more tokens than a shorter sentence.

Bad:

```text
Look through the repo and figure out everything that might be wrong with CI, tests, release flow, and repo structure.
```

Better:

```text
Investigate the failing CI job only. Identify the failing step, inspect the related workflow and recent changes, reproduce locally if possible, and fix the root cause.
```

### 2. Include only evidence that changes decisions

Prefer:

- the failing log slice
- the exact workflow or config file
- the 1 to 3 files that matter
- the current state summary, not the whole transcript

### 3. Move durable rules out of the prompt

Store repeated rules in:

- `AGENTS.md`
- lessons files
- stable workspace guides

Then point at them instead of pasting them again.

### 4. Use compact structures

Good compact shape:

```text
Context:
[only what matters]

Goal:
[what you want]

Constraints:
[important limits]

Done when:
[success criteria]
```

### 5. Keep explanation depth proportional

Do not ask for:

- full walkthrough
- all alternatives
- complete architecture
- detailed teaching

unless you really need them in the same turn.

Prefer:

- quick answer
- work first, teach later
- 60-second summary
- structured walkthrough only when deep understanding is the goal

### 6. Reuse working examples

If you already have:

- a prototype
- an earlier repo
- a working snippet
- an old prompt that worked

point the agent at that instead of starting from zero.

### 7. Promote repeated work

If the same workflow keeps recurring, convert it into:

- a reusable prompt
- a script
- an automation
- a command or skill where supported

That reduces both tokens and setup friction.

### 8. Compact or reset before the thread gets expensive

Do not wait until the context is already degraded.

Signs it is time:

- the thread is rehashing settled facts
- irrelevant old detail keeps coming forward
- output is getting generic or inconsistent
- the next step would benefit from a fresh reviewer

## Less Words, Not Less Signal

Conciseness is useful when it removes filler, not when it removes the reasoning cues needed for a correct answer.

What appears to transfer well:

- shorter summaries after the real work is done
- terse status updates
- compact explanations for obvious local issues
- concise chain-of-thought style outputs when the task is straightforward and the model is strong enough

What needs more room:

- ambiguous debugging
- tasks with subtle tradeoffs
- math-heavy or reasoning-heavy edge cases
- teaching when the learner is still forming the mental model
- any communication where tone, diplomacy, or trust matter

Source-backed pattern:

- Anthropic's memory guidance says always-loaded instruction files work best when they are specific and concise.
- Concise Chain-of-Thought research found that shorter reasoning reduced response length substantially with little overall accuracy loss on GPT-4-class multiple-choice benchmarks, but some weaker-model math performance dropped.
- Newer brevity-constraint research suggests that overelaboration can itself create errors for larger models on some benchmarks, so "more words" is not automatically safer.

---

## Agentic Routing And Cache Hygiene (Session 42+)

When working in agentic mode, the main token win is not a large role taxonomy. It is context hygiene: direct handling for most work, fresh context when the thread degrades, and bulk read-only discovery in a cheap lane.

### Routing Rules

| Situation | Handler | Token reason |
|---|---|---|
| Simple or medium task under 15 turns | Main agent direct | No spawn overhead and full local context |
| Bulk search or discovery across 10+ files | Explorer | Small, read-only packet with no implementation context |
| Long session, topic shift, or quality degradation | Worker | Fresh context with compressed state |
| Different capability needed | Specialized model | Use only when capability gap beats routing overhead |

### Context Passing

When spawning a subsession, pass **compressed context only**:

```
Task: [specific, bounded]
Context: [3-5 bullets]
Files: [paths only]
Constraints: [hard limits]
Done when: [success criteria]
```

**Never pass:** full thread history, previous reasoning chains, irrelevant file contents.

### Subsession Lifecycle

1. Detect subtask type
2. Compress context to 5-line summary
3. Spawn specialist with summary + specific task
4. Specialist works with fresh context
5. Result returns to Orchestrator
6. Orchestrator synthesizes and presents
7. Subsession context discarded

### Prompt Cache Hygiene

Prompt caches are sensitive to stable inputs. Changing system instructions, tool definitions, model choices, or message scaffolding can erase the benefit of cached context.

Good defaults:

- Keep global instructions lean and stable.
- Avoid changing tool surfaces mid-session unless required.
- Fork or hand off with the same essential tool contract when cache stability matters.
- Put large durable rules in docs and state files instead of repeatedly pasting them.
- Prefer small state updates over full transcript replay.

### Cost Impact

| Scenario | Waste pattern | Better pattern |
|---|---|---|
| Mixed 20+ turn session | Monolithic context keeps growing | Checkpoint and hand off with 5-line state |
| Search-heavy task | Repeated broad reads in main context | Explorer gets a bounded read-only packet |
| Rewrite/parity audit | Huge source dump pasted into chat | Read architecture first, then inspect specific runtime lanes |
| Post-compaction work | First action is a risky mutation | Run a read-only health probe first |

---

## Brevity Mode

Default to terse output. Escalate depth only when complexity demands it.

### Standard Response Format

| Complexity | Output Style |
|-----------|-------------|
| Simple (facts, confirmations) | One sentence |
| Medium (implementation, fixes) | Bullets + code |
| Complex (architecture, reasoning) | Structured sections |

### Trigger Phrases

When you need full depth, say:
- "Explain fully" — overrides brevity
- "Teach me" — enters teaching mode
- "Walk through" — step-by-step detail

Default behavior without trigger: **terse and action-first**.

---

## 2026 Research Updates

### Token Efficiency Breakthroughs (April 2026)

**Prompt Compression**:
- **LLMLingua** (Microsoft): Up to 20x compression, integrated into LangChain/LlamaIndex. Uses prompt distillation to reduce token count while preserving key information. [arxiv](https://arxiv.org/abs/2310.05736)
- **LongLLMLingua**: 4x compression + 21.4% RAG improvement using only 1/4 tokens. [ACL 2024](https://aka.ms/LLMLingua-2)

**KV Cache Compression**:
- **TurboQuant** (Google): 6x KV cache compression with zero accuracy loss, 8x speedup on H100. [ICLR 2026](https://www.danilchenko.dev/posts/2026-03-27-google-turboquant-llm-compression-6x-zero-accuracy-loss/)
- **LMCache** (8k stars): Fastest KV cache layer with AMD/ROCm support. Enables democratized inference with native GPU acceleration. [GitHub](https://github.com/LMCache/LMCache)
- **TriAttention** (2026): Novel attention mechanism achieving 6-10x memory reduction
- **CodeComp** (2026): Code-specific compression technique
- **DynaKV** (2026): Dynamic KV cache management reducing memory by 6-10x

**Practical Impact**: Both prompt compression and KV cache compression can drop costs 30-90% for the same quality output.

Community note:

Projects like `caveman` are useful reminders that models often waste words. The transferable lesson is aggressive fluff removal, not adopting a novelty persona as doctrine.

## Anti-Patterns

### 1. Repeating standing instructions in every prompt

Put them in instruction files.

### 2. Pasting full logs when only the failing section matters

Trim aggressively.

### 3. Mixing unrelated tasks in one thread

This quietly increases token waste and lowers answer quality.

### 4. Asking for exhaustive output by default

Ask for the shortest form that still serves the goal.

### 5. Asking for full teaching while also asking for broad implementation

Split into:

1. do the work
2. teach me efficiently

### 6. Overspecifying discoverable facts

If the repo or environment already reveals it, do not spend prompt budget repeating it unless it is a hard constraint.

## Compact Prompt Shapes

### Compact serious-work prompt

```text
Context:
[repo/failure/current state]

Goal:
[specific task]

Constraints:
[important boundaries only]

Done when:
[verification and success criteria]
```

### Compact CI prompt

```text
Investigate the failing CI job only.

Context:
- failing job: [name]
- likely related files: [paths]
- recent changes: [short summary]
- error: [relevant log section]

Done when:
- root cause is identified
- the smallest maintainable fix is made
- closest local verification is run
- residual uncertainty is stated
```

### Compact repo-analysis prompt

```text
Teach me this repo efficiently.

Focus on:
- what it does
- major flow
- key files or directories
- where important state lives
- best reading order
- what I should read first
```

## Best Short Rule

```text
Keep this high-signal and token-efficient: use only the context needed for the decision, avoid repeating stable instructions, verify the result, and keep the explanation proportional to what I actually need.
```

---

## Cognitive Load Theory for Prompts

Based on learning science (Sweller, 1988 — *Cognitive Load Theory*, Springer, 370k+ accesses):

### The Core Parallel

| Human Learning | Prompting |
|---------------|-----------|
| Working memory limit (~7 items) | Context window limit (128K tokens) |
| Extraneous load hurts learning | Irrelevant context hurts output quality |
| Chunking aids recall | Breaking tasks aids comprehension |
| Worked examples help | Examples in prompts help |

### Three Types of Cognitive Load

1. **Intrinsic** — Complexity of the task itself (unavoidable)
2. **Extraneous** — How information is presented (avoidable)
3. **Germane** — Effort to build schemas (desirable)

**Prompt implication**: Reduce extraneous load (irrelevant context), manage intrinsic load (chunk complex tasks), maximize germane load (meaningful examples).

### Evidence

- Ollie Lovell (2020): *Sweller's Cognitive Load Theory In Action* — Best practical guide
- Kalyuga & Plass (2025): *Rethinking Cognitive Load Theory* — Oxford UP
- Dunlosky et al. (2013): Practice testing & distributed practice = only "high utility" techniques

### Prompt Design Principles

| CLT Principle | Prompt Application |
|--------------|-------------------|
| Work TOGETHER, not ADDitively | Combine instructions into unified ask |
| Segment the complex | Break multi-step into phased prompts |
| Multiple representations | Use examples + explanation |
| Reduce redundancy | Don't repeat what model knows |
| Test effect | "Verify your answer before outputting" |

---

## 2026 Research Updates

### KV Cache Compression

- **TurboQuant** (Google): 6x KV cache compression with zero accuracy loss, 8x speedup on H100. [ICLR 2026](https://www.danilchenko.dev/posts/2026-03-27-google-turboquant-llm-compression-6x-zero-accuracy-loss/)
- **LMCache** (8k stars): Fastest KV cache layer with AMD/ROCm support. [GitHub](https://github.com/LMCache/LMCache)
- **MIT Fast KV Compaction** (2026): 50x compression in seconds via Attention Matching — closed-form linear algebra vs multi-hour optimization
- **AttentionPredictor**: Learning-based attention prediction — 13x KV compression, 5.6x speedup in cache offloading
- **LongFlow**: KV compression for reasoning models — 11.8x throughput improvement with 80% compression

### Model Token Inflation (April 2026)

**Claude Opus 4.7**: New tokenizer uses 1.0-1.35× more tokens than Opus 4.6; system prompts cost 1.46× more.

| Scenario | Token Multiplier | Cost Implication |
|----------|-----------------|------------------|
| System prompts | 1.46× | 46% more tokens per session |
| User prompts | 1.0-1.35× | Varies by content type |
| Vision inputs | 3.75MP max | Higher resolution, higher cost |

**Recommendation**: When cost matters, use Opus 4.6 for identical outputs at lower token count. Reserve 4.7 for tasks needing its specific improvements (coding, long-context, verification).

### Prompt Caching (Production)

| Provider | Cost Reduction | TTFT Improvement |
|----------|---------------|------------------|
| Anthropic | 50-90% | 65-85% lower |
| OpenAI | 50-90% | 70% lower |
| Google | 50-80% | 60% lower |

Break-even at 1.4-2 cache hits — these numbers are directly applicable to prompt design.

### Prompt Compression

- **Finch** (Google): Up to 93x compression, preserves semantic correctness
- **KVCompose** (ICLR 2026): Composite tokens with attention-guided scoring

### Retrieval Efficiency via MCP Code Context (2026-04-21)

Deep-scan takeaway from GitHub trending tooling: retrieval architecture can be a bigger cost lever than prompt text trimming alone.

`zilliztech/claude-context` publishes a reproducible evaluation setup on a filtered SWE-bench_Verified subset (30 instances, 3 runs per arm, same model family), comparing grep-only retrieval against grep + semantic MCP code context.

Reported outcome:
- Comparable retrieval quality (average F1: 0.40 vs 0.40)
- 39.4% lower token usage (73,373 -> 44,449 average)
- 36.3% fewer tool calls (8.3 -> 5.3 average)

Practical implication:
- If your bottleneck is repeated code discovery in medium/large repos, prioritize better retrieval primitives (semantic index + MCP tool path) before over-optimizing wording alone.
- Treat this as a pattern, not a universal constant; reproduce on your own workload before locking it into cost forecasts.

Source:
- [Claude Context Evaluation](https://raw.githubusercontent.com/zilliztech/claude-context/master/evaluation/README.md)

### Model Routing as Cost Control (2026-04-21)

Language-filtered trending scan takeaway: cost control is moving from "write shorter prompts" to "route each request through the cheapest sufficient model."

`mnfst/manifest` is a useful example because it sits between an agent and model providers as an OpenAI-compatible router. Its docs describe a flow where each request is scored, assigned a tier such as simple / standard / complex / reasoning, then forwarded to the matching model while token count, latency, and cost are captured for the dashboard.

Practical implication:
- Do not hard-code the strongest model for every step in a mixed workflow.
- Route extraction, classification, summarization, coding, and deep reasoning through separate lanes.
- Track quality, cost, latency, fallback rate, and budget-limit hits together.
- Keep automatic fallback so one model outage does not break the whole workflow.

Good fit:
- repeated agent workflows with uneven task difficulty
- teams using multiple providers or paid subscriptions
- local/self-hosted setups where request content should not pass through another hosted routing service

Bad fit:
- one-off tasks where router setup costs more than it saves
- high-risk workflows without evaluation, because cheap routing can silently degrade quality

Source:
- [Manifest docs](https://manifest.build/docs/introduction)

---

## Reasoning Effort Selection

For models that support configurable reasoning effort (`low`, `medium`, `high`, `xhigh`), choosing the right level is a token efficiency lever — higher effort costs more tokens but catches harder problems early.

### The Ladder

| Effort | Use When | Token Cost |
|--------|---------|-----------|
| `low` | Obvious, local, easy-to-verify changes | Lowest |
| `medium` | Normal engineering tasks | Medium |
| `high` | Important, ambiguous, or multi-step work | Higher |
| `xhigh` | Hard, broad, or expensive-to-get-wrong | Highest |

### Quick Rule

If unsure, use `medium`. It's the safest default for day-to-day repo work.

Escalate to `high` when:
- Ambiguity increases
- Scope widens
- Unfamiliarity increases
- Hidden-regression risk goes up

Escalate to `xhigh` only when the task is broad, ambiguous, or the cost of a wrong answer is high.

### Source

This ladder is adapted from the detailed analysis in `codex-reasoning-guide.md`, which synthesizes OpenAI Codex documentation and practical agent usage patterns.

---

## Context Pressure Monitoring

Context pressure is not about knowing your exact token count — it's about recognizing behavioral symptoms that mean the context is degrading.

### The Asymmetry

LLMs don't have introspection into remaining context. But they CAN recognize:
- When their output is becoming generic or repetitive
- When they're re-explaining things already covered
- When they're losing track of what's been done vs. what's remaining
- When questions about the topic suggest context has drifted

### Pressure Signals Table

| Signal | Indicates |
|--------|-----------|
| Generic or repetitive phrasing | Model recycling early context |
| Re-explaining settled points | Can't retrieve efficiently from long context |
| Losing done/remaining tracking | Working memory exceeded |
| Questions about already-covered material | Context drift from original task |
| Output getting shorter or lower quality | Approaching hard limit |

### The Checkpoint Rule

For sessions longer than 20-30 minutes of work, write a handover checkpoint before continuing. This is not failure — it's continuity management. A proactive checkpoint at 80% context means the next model gets a clean summary, and nothing critical is lost when the limit hits.

See [agent-context-handover.md](agent-context-handover.md) for the full proactive checkpoint trigger and template.

### Hierarchical Memory Pattern

The Mem0 memory architecture (User → Session → Agent) models this well: don't hold everything in the model's context, progressively offload to external memory.

For complex sessions:
1. Write key decisions and state to a session artifact
2. Reference that artifact instead of re-explaining
3. Checkpoint before complex multi-step work
4. Use the handover template proactively, not just when asked

Source:
- [Mem0 v3](https://github.com/mem0ai/mem0) — hierarchical memory for AI agents (53k stars)
