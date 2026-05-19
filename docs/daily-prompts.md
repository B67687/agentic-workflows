# Daily Prompts

5 most reusable prompts for day-to-day repo work. Full library: [prompt-library/](prompt-library/).

## 1. Fix A Failed CI Build

```
Investigate the failing CI build end to end.
Context: - Repo: [repo] - Branch/PR: [branch or PR] - Failing workflow/job: [name]
Goal: root cause → smallest maintainable fix → local verification → residual risk
Output: root cause, files changed, verification performed, remaining uncertainty
```

**Stronger variant (behavior changed):** `First run the tests. Use red/green TDD: capture intended behavior in a failing test, implement the smallest fix, rerun, verify.`

## 2. Do The Work, Then Teach Me Efficiently

```
Do the task normally, then teach me: 60s summary → mental model → important steps →
why key decisions mattered → files/commands/patterns to remember → 3 things to learn first.
Separate: task-specific details, reusable concepts, tool usage, judgment calls.
```

## 3. Teach Me This Repo

```
Teach me this repo so I can become useful quickly.
Cover: what it does, important directories, execution flow, key commands,
conventions/patterns, common traps, learning order, one non-obvious design choice.
Keep it grounded in the actual repo.
```

## 4. Resume Long-Running Work Without Drifting

```
Resume from: [latest state]. Before new work: restate completed + pending + next 3 actions.
Then execute the next phase only.
Constraints: no redo, update artifacts as you go, stop after next phase.
End with: what changed, what remains, next recommended step.
```

## 5. Align To Repo Culture Before PR/Issue Work

```
Before PR/issue work: read lessons file → templates → recent PRs/issues → infer conventions.
Follow living convention unless conflicts with explicit rules.
Separate: hard rules, inferred conventions, uncertain areas.
```

## Short Upgrades

- **One-line**: `Start by building context, identify root cause, verify, summarize.`
- **Token-efficient**: `Keep this high-signal: only context needed for the decision, verify, proportional explanation.`
- **First run tests**: `First run the tests. Then investigate, fix, verify.`

## Bonus Prompts

- **Analyze + upgrade KB**: Extract strongest patterns, compare against notes, update local markdown.
- **Plan → Review → Implement → Verify**: Plan from repo, review independently, implement phase by phase, verify with fresh pass.
- **Build fast without outrunning me**: Task → teach → worked example → smaller similar task → review reasoning.

## Principles

| Concept | Rule |
|---------|------|
| Role sharpening | Add role only when it sharpens judgment (senior engineer, maintainer, reviewer — not decorative titles) |
| Knowledge drift | Prefer current official docs, call out uncertainty, compare against live configs |
| Cross-model review | Use independent review for complex work: plan → review → implement → verify |
| Retrieval practice | Force verification: "What could go wrong?", "Test against requirements", "Find counterexample" |

## See Also

- [prompt-templates.md](prompt-templates.md): Full template library index
- [prompt-library/](prompt-library/): Detailed prompt files (debugging, learning, workflows, voice, visualization)
