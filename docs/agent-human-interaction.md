# Agent-Human Interaction Patterns

How agents and humans should interact --- grounded in the A2A protocol's interrupted states
(`INPUT_REQUIRED`, `AUTH_REQUIRED`), Anthropic's agent loop guidelines, and
Socratic questioning principles.

## The Core Pattern

```
Human gives task -> Agent works independently -> Agent hits decision point
                                                     v
                              ┌────────────────────────────────┐
                              │ Can proceed -> continue working │
                              │ Needs input -> PAUSE, ask once  │
                              │ Ambiguous -> SELF-PROBE first    │
                              │ Can't resolve -> ESCALATE       │
                              └────────────────────────────────┘
                                                     v
                              Agent resumes or reports -> Human reviews
```

The key insight from Anthropic's "Building Effective Agents" (Dec 2024):
> "Agents can pause for human feedback at checkpoints or when encountering blockers."

## Interaction States

### 1. Autonomous (No Human Needed)

The agent has sufficient context, tools, and authority to proceed.

**Pattern:** Agent works -> Agent delivers result

**Guardrails:**
- Authority must be explicitly delegated (not assumed)
- Agent should log decisions for auditability
- Human can review results at end

### 2. Input Required

The agent has hit a decision point where human context or preference is needed.

**Pattern:** Agent works -> Agent hits fork -> Agent PAUSES -> Agent asks structured question -> Human answers -> Agent continues

**Best practice (from structured-questioning skill):**
- Decompose the question first (5W+H)
- Include your recommended answer
- State what changes based on each possible answer
- Example:
  > "I've narrowed the slowdown to two possible causes:
  > 1. N+1 query in product variants (fix: eager loading, 2h)
  > 2. Missing index on category_id (fix: add index, 30min)
  > The query log suggests option 1. Shall I proceed with eager loading?"

### 3. Auth Required

The agent needs credentials, permissions, or escalation approval.

**Pattern:** Agent works -> Agent hits auth gate -> Agent PAUSES -> Agent states what's needed -> Human authorizes -> Agent continues

**Rules:**
- State exactly what operation requires auth
- State the minimum permission needed
- Never attempt to bypass the auth gate
- Log the auth request and outcome

### 4. Escalation

The agent cannot resolve the task with available tools, context, or authority.

**Pattern:** Agent works -> Agent hits unrecoverable -> Agent PAUSES -> Agent summarizes what was tried -> Human decides to repair, redirect, or abort

**Examples:**
- Tool returned unexpected error after 3 retries
- Required external service is unreachable
- Task requires a skill the agent doesn't have

## How to Ask (for Agents)

When an agent needs to ask a human something, the question should follow this structure:

```
1. Context: What led to this question (2-3 sentences max)
2. Fork: What are the possible paths?
3. Recommendation: Which path do you recommend and why?
4. Impact: What changes based on each answer?
5. Urgency: When does this need answered by?
```

**Bad:**
> "What should I do?"

**Good:**
> "I'm generating the report and found that the November data has a 3-day gap.
> Options: (a) fill with projected averages, (b) leave as null with a footnote,
> (c) exclude November entirely. I recommend (a) --- it's what we did last quarter
> and the discrepancy was under 2%. The report is due Friday. If I don't hear back
> by Thursday EOD, I'll proceed with (a)."

## How to Ask (for Humans)

When a human needs to ask an agent, apply the structured-questioning skill:

1. **Run the 5W+H checklist** --- ensure all dimensions are covered
2. **Frame in ACI-optimized language** --- give the agent room to think
3. **Specify success criteria** --- what does a good answer look like?
4. **Set boundaries** --- what's out of scope?

## Integration with This Workspace

| Workspace Tool | A2P Pattern | How They Fit |
|---|---|---|
| `handoff.sh` | Escalation | Handoff to human when agent can't proceed |
| `grill-me` skill | Input Required | Structured questioning before committing to a plan |
| `counsel` command | Auth Required / Review | Expert review before risky decisions |
| `agent-dispatch.sh` result polling | Input Required | Async task with human-in-loop checkpoints |
| `pipeline-run.sh` | All states | Pipeline tasks can pause for human input |

## Decision Gate Protocol

Use this when the agent needs human input mid-task:

```
1. STOP --- do not continue past the decision point
2. SELF-PROBE --- can I resolve this without the human?
   - Check docs, check cache, check tools
   - If yes: resolve silently, log the decision
3. FORMULATE --- create the structured question
   - Context -> Fork -> Recommendation -> Impact -> Urgency
4. SEND --- deliver the question
5. WAIT --- with timeout. If timeout expires, re-ask once with urgency bump.
6. If second timeout: execute recommendation as default.
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Better |
|---|---|---|
| Asking without context | Human has to reconstruct the situation | Give 2-3 sentence summary |
| Asking multiple questions at once | Overwhelms, leads to partial answers | One question at a time |
| Asking yes/no without explaining implications | Human can't evaluate trade-offs | State what each answer means |
| Assuming silence = consent | Human may not have seen the question | Add explicit timeout and re-ask |
| Agent guessing instead of asking | Harder to debug than a clear question | Ask early, ask clearly |
| Over-asking (every trivial decision) | Wastes human time | Define thresholds for autonomous action |

## References

1. A2A Protocol Specification v1.0 --- `INPUT_REQUIRED`, `AUTH_REQUIRED` task states
2. Anthropic, "Building Effective Agents" (Dec 2024) --- agent loop, human-in-loop patterns
3. OpenAI Agents SDK --- Guardrails and human review patterns
4. Aristotle, *Nicomachean Ethics* III --- the *Septem Circumstantiae* (5W+H origins)
5. This workspace: `skills/structured-questioning/SKILL.md` --- structured question formulation
