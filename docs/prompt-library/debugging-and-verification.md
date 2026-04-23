# Debugging And Verification Prompts

Split from docs/prompt-templates.md during the 2026-04 optimization pass.

## 1. Fix A Failed CI Build

```text
Investigate the failing CI build end to end.

Context:
- Repo: [repo]
- Branch/PR: [branch or PR]
- Failing workflow/job: [name if known]
- Recent changes: [optional summary]

What I want:
- Identify the exact failing step
- inspect the workflow, related scripts, and recent changes
- reproduce locally if possible
- form a short hypothesis list before making changes
- fix the root cause with the smallest correct patch
- run the closest local verification
- do not bypass tests, checks, or security gates

Output:
- root cause
- files changed and why
- verification performed
- any remaining uncertainty or CI-only risk

Do not stop at the first symptom if it looks like a downstream effect.
```

## 1B. CI Build Prompt With Evidence

```text
Role:
Senior engineer for this stack and CI system.

Scenario:
The CI build failed after a recent change.

Context:
- Repo: [repo]
- Stage/job: [job]
- Environment: [runner, OS, runtime, container, toolchain]
- Recent changes: [summary]
- Relevant files: [paths or pasted snippets]

Error logs:
[paste the failing log or the last important section]

Task:
1. Analyze the logs and identify the most likely root cause
2. Inspect the workflow and related code before proposing a fix
3. If multiple causes are plausible, rank them briefly
4. Provide the smallest maintainable fix
5. Explain why the fix resolves the failure
6. State how to verify it locally and what still depends on CI

Constraints:
- do not bypass tests or security checks
- prefer maintainable fixes over narrow hacks
- if uncertain, say exactly what evidence is missing
```

## 1C. Red/Green TDD Prompt

```text
Use red/green TDD.

Goal:
Change behavior safely and leave behind test coverage for it.

Process:
1. First run the relevant tests
2. Write or identify a failing test that captures the intended behavior
3. Implement the smallest maintainable change that makes the test pass
4. Rerun the relevant tests
5. Do manual verification too if the problem is not fully covered by tests

Output:
- failing behavior that was captured
- test changes
- implementation changes
- what is now covered by tests
- what was verified manually
```

## 15. Cross-Model Plan Review And Verification Prompt

```text
Use a phased workflow for this task.

Phase 1:
- build a plan from the actual repo and artifacts
- keep the phases intact and testable

Phase 2:
- review that plan independently against the codebase
- add findings, missing phases, or risk notes without flattening the original plan

Phase 3:
- implement phase by phase

Phase 4:
- verify the implementation against the plan with a fresh pass

Keep the plan review and the final verification skeptical and evidence-based.
Call out anything that still depends on CI, external systems, or human confirmation.
```

## 15. First Run The Tests Prompt

```text
First run the tests.

Then:
1. tell me what that reveals about the project shape and current failures
2. investigate the specific problem
3. implement the smallest maintainable fix
4. run the relevant verification again

If manual verification is also needed, do that too and state what you checked.
```

