# Core Agent Doctrine

Use this file as the shared backbone for this workspace.

It captures the durable principles that were starting to repeat across multiple docs.

These principles are grounded in cognitive science — see AGENTS.md for the research-backed foundations.

## The Core Rule

Build the smallest correct context, choose the right execution lane, define what done means, verify the result, and capture any lesson that should change future behavior.

## 1. Scope The Task Tightly

Do not ask for "everything."

Strong agent work starts with:

- a clear goal
- a bounded scope
- known constraints
- explicit success criteria

## 2. Give Rich Evidence, Then Stop Micromanaging

The best inputs are concrete:

- logs
- screenshots
- failing commands
- file paths
- configs
- known-good examples

Once the evidence is strong, over-steering the method can make the result worse.

## 2B. The Agent Should Supply Missing Structure When Safe

The user should not need perfect prompting skill for the system to work well.

When the request is clear enough and the risk is low, the agent should proactively supply missing structure such as:

- sharper scoping
- a sensible investigation order
- an explicit verification target
- the right execution lane
- a tests-first or TDD approach when behavior is changing

Only escalate or ask for clarification when the missing piece has real consequences for safety, scope, or correctness.

## 3. Define Done And Verification Early

Do not stop at:

```text
Fix this.
```

Upgrade it to:

- what behavior should change
- what checks should pass
- what still might remain unproven

Verification is not optional polish.
It is the quality engine.

**Self-verification (2026 research)**: Smart agents verify their own outputs before reporting. This is the key differentiator between "smart" and "functional" agents. Claude Opus 4.7 implements this as a core behavior — checking work against requirements before delivery.

For complex tasks, include verification prompts:
```text
Before reporting complete, verify:
1. Does the output match the requirements?
2. Are there any errors or edge cases missed?
3. What could be wrong with this solution?
```

## 4. Choose The Lightest Execution Lane

Not every task deserves the heaviest mechanism.

Good default:

- inline work for small, local tasks
- reusable prompts or scripts for repeated procedures
- isolated workers or fresh threads for autonomous multi-step work
- independent review lanes for plan review and verification

## 5. Put Rules At The Right Scope

Do not solve reuse by stuffing everything into one giant file.

Prefer:

- personal/global layer for private habits and cross-project defaults
- repo-local layer for team-shared rules
- component-local layer for subsystem-specific guidance
- git-ignored local overrides for personal repo-specific preferences

## 6. Plan When Ambiguity Is High, And Re-Plan When Execution Degrades

Planning is not just a prelude.
It is also the recovery path.

Use it when:

- the repo is unfamiliar
- multiple wrong paths are likely
- the task is broad
- the current execution path is drifting or wobbling

## 7. Optimize For Quality, Not Output Volume

Generated code is cheap.
Good code is not.

So use agents to improve:

- test coverage
- verification quality
- maintainability
- naming
- documentation
- reviewability

## 8. Promote Repeated Work Into Reusable Assets

If the same workflow keeps recurring, stop paying full prompt cost for it.

Promote it into:

- a reusable prompt
- a script
- an automation
- a command or skill where supported

## 9. Update Shared Memory After Meaningful Lessons

Do not only fix the immediate mistake.

Update:

- `AGENTS.md`
- repo lessons files
- templates
- reusable prompts

That is how the system compounds instead of repeating the same errors.

**Experience compression (2026 research)**: Memory systems operate on a compression spectrum:
- Episodic memory: 5-20× compression (raw experience)
- Procedural memory: 50-500× compression (skills and patterns)
- Declarative memory: 1000×+ compression (rules and facts)

Current gap: No adaptive cross-level compression exists — systems choose one level and stick with it. Smart agents dynamically adjust compression based on context and retrieval needs.

Also: Static memory defenses are insufficient against adversarial injection, noisy outputs, and biased feedback. Memory misevolution can cause safety degradation (MemEvoBench, arXiv:2604.15774). Validate memory before trusting it.

## 10. Use Teaching Mode Deliberately

Execution answers and teaching answers are not the same thing.

When the goal is learning, ask for:

- layered explanation
- structured walkthroughs
- mental models
- key files and commands
- what to learn next

## How To Use This File

- Use [daily-prompts.md](daily-prompts.md) for prompt shapes and scenario playbooks.
- Use [token-efficient-prompting.md](token-efficient-prompting.md) for workflow-cost reduction.
- Use [tdd-with-agents.md](tdd-with-agents.md) for tests-first and red/green TDD patterns.
- Use [authoritative-agent-best-practices.md](authoritative-agent-best-practices.md) for source-backed cross-tool guidance.

## Best Short Summary

**Strong agent work is not "write a clever prompt." It is: scope tightly, provide evidence, choose the right lane, verify aggressively, and turn repeated lessons into durable shared memory.**

## 2026 Research: LLM Coding Pitfalls (Andrej Karpathy)

Based on [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (36.3k stars), which extracts Andrej Karpathy's observations on LLM coding failures:

### The Problems LLMs Make

> "The models make wrong assumptions on your behalf and just run along with them without checking. They don't manage their confusion, don't seek clarifications, don't surface inconsistencies, don't present tradeoffs, don't push back when they should."

> "They really like to overcomplicate code and APIs, bloat abstractions, don't clean up dead code... implement a bloated construction over 1000 lines when 100 would do."

> "They still sometimes change/remove comments and code they don't sufficiently understand as side effects, even if orthogonal to the task."

### The Four Principles

| Principle | What It Addresses | How to Apply |
|-----------|-------------------|--------------|
| **Think Before Coding** | Wrong assumptions, hidden confusion, missing tradeoffs | State assumptions explicitly; ask rather than guess; present multiple interpretations; stop when confused |
| **Simplicity First** | Overcomplication, bloated abstractions | No features beyond what was asked; no abstractions for single-use; if 200 lines could be 50, rewrite it |
| **Surgical Changes** | Orthogonal edits, touching code you shouldn't | Don't "improve" adjacent code; match existing style; touch only what you must |
| **Goal-Driven Execution** | Weak success criteria, no verification loops | Transform "add validation" into "write tests for invalid inputs, then make them pass" |

### Integration with This Doctrine

These four principles directly map to this doctrine:
- **Think Before Coding** → "Give Rich Evidence" + "Supply Missing Structure"
- **Simplicity First** → "Scope The Task Tightly"
- **Surgical Changes** → "Choose The Lightest Execution Lane"
- **Goal-Driven Execution** → "Define Done And Verification Early"

The key insight from Karpathy: **"Don't tell it what to do, give it success criteria and watch it go."**

## 2026 Research: Context Engineering Discipline

Based on [get-shit-done](https://github.com/gsd-build/get-shit-done) (53.9k stars) — meta-prompting and spec-driven development for Claude Code:

### What Is Context Engineering

Context engineering is the discipline of structuring, filtering, and presenting information to AI agents to maximize the quality of their outputs. It goes beyond "good prompting" to systematically managing the context window.

**The core insight**: AI output quality is heavily dependent on context quality. Better context engineering = better agent performance without better models.

### Key Practices

| Practice | What It Does | Why It Matters |
|----------|-------------|----------------|
| **Spec-first** | Write the spec before asking for code | Forces clarity about goals before diving into implementation |
| **Context pruning** | Remove stale/irrelevant context | Prevents distraction and token waste |
| **Explicit success criteria** | State what "done" looks like | Gives the agent a target to optimize toward |
| **Constraint declaration** | State what's NOT in scope | Prevents scope creep and unnecessary work |

### The Spec-First Workflow

```
1. Write the spec (what, not how)
2. Agent reviews and clarifies
3. Agent implements to spec
4. Verify against spec
5. Refactor if needed
```

This separates the "what" (human's job) from the "how" (agent's job), matching the delegation spectrum from cognitive-identity.md.

### Integration with This Doctrine

Context engineering directly supports multiple doctrine principles:
- **Spec-first** → "Scope The Task Tightly" + "Define Done And Verification Early"
- **Context pruning** → "Give Rich Evidence, Then Stop Micromanaging"
- **Constraint declaration** → "Scope The Task Tightly" (what's NOT in scope)
- **Explicit success criteria** → "Define Done And Verification Early"

### The Meta-Prompting Pattern

Beyond spec-first, get-shit-done demonstrates meta-prompting: prompting about prompting itself.

Examples:
- "Before you write code, what assumptions are you making?"
- "What information would help you do this better?"
- "What would a good result look like?"
- "What's the simplest approach that could work?"

This creates a feedback loop where the agent helps optimize the context before acting.

---

## Security-First Agent Design

Based on OWASP Top 10:2025 and IBM AI Agent Security research.

### The Core Problem

AI agents introduce unique security risks beyond traditional software:
- **Prompt injection** — Adversarial inputs manipulate agent behavior
- **Excessive agency** — Agents perform unauthorized actions
- **Memory poisoning** — Corrupted context corrupts decisions
- **Tool manipulation** — Exploiting agent tool-calling capabilities

### OWASP Top 10:2025 for Agents

| Risk | Agent Implication |
|------|-------------------|
| A01: Broken Access Control | Agents with excessive permissions perform unauthorized actions |
| A05: Injection | Prompt injection through malicious inputs |
| A06: Insecure Design | Missing security-by-design in agent architectures |
| A07: Authentication Failures | Agent identity management for external APIs |

### IBM Security Best Practices

| Practice | Implementation |
|----------|----------------|
| Permission-gated tools | Only grant access that's explicitly needed |
| Full audit logging | Track all agent actions and decisions |
| RBAC | Role-based access control for agent capabilities |
| Guardrails | Validate inputs and outputs at boundaries |
| Least privilege | Agent gets minimum permissions required |
| Input sanitization | Sanitize all user inputs before agent processing |

### Integration with This Doctrine

Security aligns with existing principles:
- **Scope tightly** → Define what the agent CANNOT do
- **Define done and verification** → Include security verification in success criteria
- **Verify aggressively** → Check for prompt injection, verify tool access
- **Supply missing structure** → Add security constraints when user doesn't specify

### The Security Checklist

Before any agent work, consider:
1. What access does this agent need?
2. What should it NEVER be allowed to do?
3. How do we verify the output isn't manipulated?
4. What's the audit trail for this action?
5. What happens if the agent is compromised?

---

## Source Archives

These files contain the source-backed analysis that informed the principles above. They are preserved for reference and deeper dives.

| Source | File | Key Takeaways |
|--------|------|---------------|
| shanraisshan/claude-code-best-practice | `archive/claude-code-best-practice-lessons.md` | Lightest execution lane, scope hierarchy, context budgeting |
| shareAI-lab/learn-claude-code | `archive/learn-claude-code-lessons.md` | Mechanism dependency order, teaching by structure |
| Boris Cherny's workflow guide | `archive/how-boris-uses-claude-code-lessons.md` | Parallelism as first-class, plan mode as recovery |
| Simon Willison's patterns | `archive/simon-willison-agentic-engineering-lessons.md` | Code is cheap / verified code costs effort, first-run-tests |
