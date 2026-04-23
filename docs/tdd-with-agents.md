# TDD With Agents

This file captures the highest-value testing patterns for agentic coding work.

## Core Idea

When behavior is changing, one of the strongest short prompts is:

```text
Use red/green TDD.
```

That compact instruction can encode a lot of engineering discipline.

## Why This Matters

Generated code is cheap.
Confidence is not.

TDD helps turn an agent from "code producer" into "behavior verifier."

## Best Short Patterns

### 1. Red/green TDD

Use this when you are:

- fixing a bug with a reproducible behavior
- adding a feature with a testable outcome
- changing logic that should be locked down by tests

Prompt:

```text
Use red/green TDD. Start by writing or identifying a failing test that captures the intended behavior. Then implement the smallest change that makes it pass. Finally, run the relevant tests again and summarize what behavior is now protected.
```

### 2. First run the tests

Use this when you are entering an existing repo or starting a bugfix in unfamiliar code.

Prompt:

```text
First run the tests. Then investigate the failing behavior, fix it using red/green TDD where possible, and verify again.
```

Why it works:

- it reveals that a test suite exists
- it gives the agent an early map of project size and shape
- it nudges the agent into a verification mindset

### 3. Manual verification after tests

Use this when tests are necessary but not sufficient.

Common examples:

- UI behavior
- browser flows
- API behavior with real requests
- shell workflows
- formatting, screenshots, or rendered output

Prompt:

```text
After the tests pass, do the relevant manual verification too. Summarize what is covered by tests and what was checked manually.
```

## Recommended Order

For many real tasks, the best flow is:

1. first run the tests
2. write or find the failing test
3. make the smallest fix
4. rerun the tests
5. do manual verification if needed

## When TDD Fits Best

Strong fit:

- backend logic
- data transformations
- parsing
- bug fixes with clear expected behavior
- regressions you want to prevent permanently

Weaker fit:

- exploratory refactors with no stable behavior change yet
- documentation-only tasks
- one-off investigative work
- tasks where the right behavior is still unclear

For weaker-fit cases, start with exploration or first-run-the-tests rather than forcing strict TDD immediately.

## Best Combined Prompt

```text
First run the tests. Then use red/green TDD: write or identify a failing test for the intended behavior, implement the smallest maintainable fix, rerun the relevant tests, and do task-appropriate manual verification if needed. End by separating what is now covered by tests from what was verified manually.
```

## Best Short Summary

The best reason to use TDD with agents is simple:

**It changes the work from "generate code that seems right" to "lock behavior down, then make the smallest change that proves itself."**
