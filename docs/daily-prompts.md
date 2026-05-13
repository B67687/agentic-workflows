# Daily Prompts

These are the 5 prompts most worth reusing in day-to-day repo work.

## 1. Fix A Failed CI Build

```text
Investigate the failing CI build end to end.

Context:
- Repo: [repo]
- Branch/PR: [branch or PR]
- Failing workflow/job: [name if known]
- Recent changes: [optional summary]
- Relevant files/logs: [paths or pasted snippets]

Goal:
Identify the exact failing step, determine the root cause, implement the smallest maintainable fix, and verify it with the closest local equivalent.

Constraints:
- do not bypass tests, checks, or security gates
- do not stop at the first symptom if it looks downstream
- if uncertainty remains, state exactly what is still unproven locally

Done when:
- root cause is identified
- the fix is implemented
- local verification is run
- residual CI-only risk is called out explicitly

Output:
- root cause
- files changed and why
- verification performed
- remaining uncertainty
```

### Stronger variant when behavior changed

```text
First run the tests. Then use red/green TDD: capture the intended behavior in a failing test, implement the smallest maintainable fix, rerun the relevant tests, and do manual verification if needed.
```

## 2. Do The Work, Then Teach Me Efficiently

```text
Do the task normally, but after finishing, teach me efficiently.

Teach in this order:
1. 60-second summary
2. The mental model of the system you were working in
3. The important steps you took
4. Why the key decisions mattered
5. The files, commands, tools, and patterns worth remembering
6. The 3 things I should learn first if I want to do this myself next time

Separate:
- task-specific details
- generally reusable concepts
- tool usage
- judgment calls

Optimize for learning speed, not exhaustive explanation.
```

## 3. Teach Me This Repo

```text
Teach me this repo so I can become useful in it quickly.

Please cover:
1. What this repo does
2. The important directories and what lives in them
3. The major execution flow or architecture
4. The key commands for setup, dev, test, build, and release
5. The conventions and patterns that matter here
6. The common traps or confusing areas
7. A recommended learning order
8. One non-obvious design choice or convention that matters

Keep this grounded in the actual repo, not a generic template.
```

## 4. Resume Long-Running Work Without Drifting

```text
Resume from this exact current state:
[paste latest status update]

Before doing new work:
- restate what is already completed
- restate what is still pending
- list the next 3 best actions in priority order

Then execute only the next phase.

Constraints:
- do not redo already-validated work
- update the relevant local artifacts as you go
- stop after the next phase and summarize

Done when:
- the next phase only is completed
- the relevant artifacts are updated
- the new state is clearly reported

End with:
- what changed
- what remains
- the next recommended step
```

## 5. Align To Repo Culture Before PR Or Issue Work

```text
Before doing issue or PR work, align yourself to the repo's actual culture, not only the written rules.

Do this first:
1. Read the local lessons file
2. Read the issue and PR templates
3. Review recent merged and open PRs/issues
4. Infer the actual conventions for title style, scope, tone, evidence, and escalation

Then:
- follow the living convention unless it conflicts with an explicit rule
- keep changes small and maintainer-aligned
- if you discover a new maintainer preference, update the lessons file before continuing similar work

Do a quick vibe check:
- does this look native to the repo?
- is the scope something maintainers actually accept?
- does the wording sound like it belongs here?

In your summary, separate:
- hard rules
- inferred conventions
- uncertain areas
```

## One-Line Upgrade

If your prompt is too short, append this:

```text
Start by building context, identify the real root cause or decision point, verify the result, and summarize in a way that helps me trust the work and learn the system.
```

## Token-Efficient Upgrade

If you want to optimize for total token usage, append this:

```text
Keep this high-signal and token-efficient: use only the context needed for the decision, avoid repeating stable instructions, verify the result, and keep the explanation proportional to what I actually need.
```

## Tiny Upgrade: First Run The Tests

If the repo has a test suite, this is one of the best short prompts:

```text
First run the tests. Then investigate the problem, implement the smallest maintainable fix, and verify again.
```

## Bonus: Analyze A Repo And Upgrade The Knowledge Base

```text
Analyze this repo deeply, extract the strongest transferable patterns, compare them against my current notes, and update the local markdown knowledge base so future work benefits from what you learned.

Pay special attention to:
- where instructions and state should live
- which execution lane should handle which work
- what should stay global, repo-local, or component-local
- what deserves a fresh review pass instead of more thread history
```

## Bonus: Plan, Review, Implement, Verify

```text
Use a phased workflow:
1. plan from the actual repo
2. review the plan independently
3. implement phase by phase
4. verify against the plan with a fresh pass

Do not flatten the original plan during review. Add findings, missing phases, and risk notes separately.
```

## Bonus: Build Fast Without Outrunning My Understanding

```text
Do the task, but keep me learning while we move.

After finishing:
1. give me a 60-second summary
2. show me the mental model behind the work
3. turn your work into one worked example
4. give me one smaller similar task to try myself next
5. when I attempt it, review my reasoning, not just the final result

Optimize for fast skill growth, not exhaustive explanation.
```

## Role Sharpening

Add a role only when it sharpens judgment:

Good:
- senior engineer for this stack
- repo maintainer mindset  
- reviewer looking for regressions

Bad:
- decorative titles that do not change behavior

## Knowledge Drift

When topics change fast, prefer:

1. current official docs and live repo conventions
2. call out uncertainty when syntax or tooling may have changed
3. compare intended approach against current configs, docs, or CI errors
4. explain why a newer method is better before adopting it

## Cross-Model Review

For complex work, use independent review:

```text
Use a phased workflow:
1. plan from the actual repo
2. review the plan independently  
3. implement phase by phase
4. verify against the plan with a fresh pass
```

## See Also

- (Superseded) `core-agent-doctrine.md`: The 10-principle backbone (see ADRs for durable principles)
- [prompt-templates.md](prompt-templates.md): Copy-paste templates for serious work
- [tdd-with-agents.md](tdd-with-agents.md): Red/green TDD patterns

## Retrieval Practice for AI (Testing Effect)

Based on learning science: Roediger & Karpicke (2006) found retrieval practice produces 80% retention vs 36% re-reading.

Just as humans learn better by testing themselves, AI outputs improve when forced to verify:

### Verification Prompts (Test Effect)

```text
Before you answer, list your assumptions.
```

```text
What could be wrong with this solution? Find at least 2 potential issues.
```

```text
Test your output against the requirements. List any gaps.
```

```text
What's the simplest counterexample that would break this?
```

```text
If you had to explain this to someone who knows nothing about the domain, what would you say first?
```

### Why It Works

| Human Learning | AI Equivalent |
|---------------|--------------|
| Retrieval strengthens memory | Verification improves reasoning |
| Struggle is a feature, not a bug | "What could go wrong?" surfaces blind spots |
| Testing > re-reading | "Verify" > "just do it" |

This is the **prompting equivalent of retrieval practice** --- forcing the model to retrieve and verify rather than just generate.
