# Repository Workflow Prompts

Split from docs/prompt-templates.md during the 2026-04 optimization pass.

## 4. Resume A Long-Running Audit Or Campaign

```text
Resume this work from the exact current state below.

Current state:
[paste latest status update]

Before doing new work:
- restate what is already completed
- restate what is still pending
- list the next 3 best actions in priority order

Then execute only the next phase.

Constraints:
- do not redo already-validated work
- update the relevant local artifacts as you go
- keep public upstream activity paused unless escalation is clearly necessary

End with:
- what changed
- what remains
- what the next recommended step is
```

## 5. Keep Work Aligned With Repo Culture

```text
Before doing issue or PR work, align yourself to the repo's actual culture, not only the written rules.

Do this first:
1. Read the local lessons file
2. Read issue and PR templates
3. Inspect recent merged and open PRs/issues
4. Infer the real conventions for scope, title style, tone, evidence, and escalation

Then:
- follow the living convention unless it conflicts with an explicit rule
- keep changes small and maintainer-aligned
- if you discover a new maintainer preference, update the lessons file before continuing similar work

In your summary, separate:
- hard rules
- inferred conventions
- uncertain areas that may need confirmation
```

## 5B. Repo Culture And Vibe Check Prompt

```text
Act like a senior contributor who knows that living repo culture matters as much as written rules.

Before doing issue or PR work:
1. Read the local lessons file
2. Read the issue and PR templates
3. Review recent merged and open PRs/issues
4. Infer the actual conventions for title style, scope, tone, evidence, and escalation

Then compare the planned action against those observations.

Do a vibe check:
- does this look native to the community?
- is the scope something maintainers actually accept?
- does the wording sound like it belongs in this repo?

If new maintainer feedback reveals a missing convention, update the lessons file before continuing similar work.
```

## 6. Repo Operating Mandate Prompt

```text
Before taking any action, internalize the local lessons file for this repo and use it as the standing operating mandate.

Mandatory behavior:
1. State which concrete lesson applies to the task
2. Perform the required pre-flight environment checks before diagnosing repo logic
3. Prefer built-ins and established repo patterns over custom cleverness
4. Respect upstream semantics and maintainer guidance
5. Do not call a fix complete until all required architecture or platform checks are done

Current task:
[insert task]

Before proposing a solution, briefly state:
- which lesson applies
- which checks you performed
- what type of problem this is
```

## 7. Current Practices And Drift Protection Prompt

```text
Treat this task as potentially sensitive to knowledge drift.

Requirements:
1. Do not rely on memory alone where tooling, syntax, or conventions may have changed
2. Prefer current official docs, current repo configs, and current workflow evidence
3. If a field, flag, or pattern may be outdated, say so explicitly and verify before using it
4. If a newer practice is better, explain why it is better than the older approach

Focus:
- prioritize [security, minimalism, maintainability, arm64 support, etc.]
- avoid [deprecated syntax, legacy workaround, unnecessary manual steps, etc.]

When relevant, use actual CI errors, workflow files, or current docs as evidence rather than generic best-practice claims.
```

## 10. Strong Resume Prompt For Your Scoop Campaign

```text
Resume from this exact state:

Phase 2 is implemented in the campaign artifacts, and public upstream activity remains paused.
Main shortlist validation completed:
- no issue / false positive: git, neovim, nodejs-lts, openssl, vim
- manual-only and deferred: findutils, gzip
- openjdk-ea is already covered by Java PR #583, so it should not remain in the local active logic queue

Artifacts already updated:
- manual-validation-notes.md
- validated-fix-queue.md
- lessons-scoop-prs.md

Current situation:
- there are no new local-only active logic candidates right now
- the next likely work is the deferred manual validation pool in Extras, then Java

Before acting, restate:
- what is done
- what is pending
- the next 3 priority actions

Then continue with the next phase only. Do not revisit already-validated shortlist items unless new evidence appears. Update the campaign artifacts as you go, keep public upstream activity paused, and end with:
- changes made
- remaining queue
- recommended next move
```

## 11. Ultra-Short Prompt Upgrade

If your base prompt is too simple, append this:

```text
Start by building context, identify the real root cause or decision point, verify the result, and summarize in a way that helps me learn the system instead of just seeing the output.
```

## 12. Analyze A Repo And Integrate It Into My Knowledge Base

```text
Analyze this repo deeply and integrate what is worth keeping into my local knowledge base, not just into this one answer.

What I want:
1. Identify the repo's main teaching spine or mechanism dependency order
2. Extract the strongest transferable design, prompting, and teaching patterns
3. Separate source-backed observations from your own inference
4. Compare those findings against my current local notes and call out:
   - what already overlaps
   - what is missing
   - what should be updated
5. Update or create markdown files in this workspace so the new knowledge becomes reusable
6. If the new lessons should change how future work in this workspace is done, update the local instruction file too

Focus especially on:
- smallest-correct-version teaching
- where state lives
- code-reading order
- mainline vs bridge docs
- task vs runtime vs execution-lane distinctions
- global vs repo vs component instruction scope
- prompt assembly, permissions, context control, and tool routing

End with:
- what changed in the knowledge base
- what the most important new lesson is
- what prompt or workflow should change going forward
```

## 13. Compact Serious-Work Prompt

```text
Keep this high-signal and token-efficient.

Context:
[only the relevant repo/failure/state]

Goal:
[specific task]

Constraints:
[important boundaries only]

Done when:
[verification and success criteria]

Do not use more context than needed to make the right decision.
```

## 14. Compact Repo-Analysis Prompt

```text
Analyze this repo efficiently.

Focus on:
- what it does
- major flow
- key files or directories
- where important state lives
- best reading order
- top 3 things I should learn first

Keep the explanation compact and high-signal.
```

