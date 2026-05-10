# Lessons From Simon Willison's `Agentic Engineering Patterns`

This file distills the most transferable lessons from Simon Willison's guide and explains how they should influence this workspace.

## Source Guide

- [Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/)
- [What is agentic engineering?](https://simonwillison.net/guides/agentic-engineering-patterns/what-is-agentic-engineering/)
- [Writing code is cheap now](https://simonwillison.net/guides/agentic-engineering-patterns/code-is-cheap/)
- [Hoard things you know how to do](https://simonwillison.net/guides/agentic-engineering-patterns/hoard-things-you-know-how-to-do/)
- [AI should help us produce better code](https://simonwillison.net/guides/agentic-engineering-patterns/better-code/)
- [Anti-patterns: things to avoid](https://simonwillison.net/guides/agentic-engineering-patterns/anti-patterns/)
- [First run the tests](https://simonwillison.net/guides/agentic-engineering-patterns/first-run-the-tests/)
- [Agentic manual testing](https://simonwillison.net/guides/agentic-engineering-patterns/agentic-manual-testing/)
- [Linear walkthroughs](https://simonwillison.net/guides/agentic-engineering-patterns/linear-walkthroughs/)
- [Prompts I use](https://simonwillison.net/guides/agentic-engineering-patterns/prompts/)

## Scope Note

The observations below are partly source-backed and partly generalized.

- Source-backed: what Simon explicitly recommends in the guide.
- Inference: how those recommendations should change this workspace's prompting and knowledge-base design.

## What The Guide Is Really Good At

Its biggest strength is that it treats coding agents as part of a software engineering practice, not as a prompt-writing trick.

The guide keeps returning to the same discipline:

- generated code is cheap
- verified, reviewable, maintainable code is not

That is a very good north star for this workspace.

## Transferable Lessons

### 1. Code is cheap now, but good code still costs effort

One of Simon's clearest arguments is that the cost of producing code has collapsed, but the cost of producing good code has not.

Source-backed implications:

- working code is not enough
- we still need confidence, tests, documentation, error handling, and maintainability
- coding agents change the economics of implementation, not the need for engineering judgment

Transferable rule:

- spend less of the prompt budget on "please write code"
- spend more on quality bars, verification, scope, and evidence

### 2. Use agents to improve code quality, not just output volume

Simon's guide is very clear that shipping worse code with agents is a choice.

Transferable rule:

- use agents to pay down quality debt that used to be too time-consuming
- use them for refactors, naming cleanup, test additions, and documentation updates
- keep the standard that agent assistance should help produce better code, not merely more code

### 3. "First run the tests" is a powerful short prompt

This is one of the highest-signal patterns in the guide.

Source-backed benefits:

- it tells the agent there is a test suite
- it nudges the agent to learn project shape from the tests
- it puts the agent into a verification mindset early

This belongs in this workspace as a compact high-value default.

### 3B. Red/green TDD may be the star pattern

After checking Simon's guide more closely, red/green TDD deserves to be treated as a headline pattern, not a side note.

Why:

- it gives the agent a disciplined loop for behavior changes
- it keeps fixes anchored to observable outcomes
- it converts a vague implementation task into a testable contract

Practical hierarchy:

1. use `red/green TDD` for behavior changes
2. use `first run the tests` when entering or orienting in an existing repo
3. add manual verification when tests do not cover the real-world behavior fully

### 4. Manual testing is evidence, not a fallback

The guide makes a strong case that passing tests is not enough.

Source-backed pattern:

- run code directly
- probe edge cases
- explore APIs with tools like `curl`
- use browser automation for UI work
- turn manually discovered bugs into permanent tests

Transferable rule:

- verification should include both automated checks and task-appropriate manual evidence when the problem needs it

### 5. Linear walkthroughs are a serious learning pattern

The guide shows that agents can produce structured walkthroughs that help people understand a codebase or a system they do not yet own mentally.

Transferable rule:

- when asking to learn a repo or recent work, ask for a structured walkthrough, not an unshaped summary
- use walkthroughs as a way to recover understanding after a large agent-assisted change

### 6. Hoard working examples and reuse them deliberately

This is one of the best long-term habits in the guide.

Source-backed idea:

- keep notes, prototypes, proof-of-concepts, and small working examples
- ask agents to combine existing working examples into new solutions

Transferable rule:

- this workspace should keep durable prompts, lessons, examples, and repo notes because they become future agent inputs
- the knowledge base is not just documentation, it is reusable scaffolding

### 7. Do not inflict unreviewed output on collaborators

The anti-pattern section is especially useful.

Source-backed rule:

- do not open PRs with code you have not reviewed yourself
- keep PRs small enough to review efficiently
- include evidence such as testing notes, screenshots, or implementation context

That aligns strongly with the existing repo-culture and verification guidance in this workspace.

### 8. The instruction loop should compound

Simon reinforces the idea that every project should end with lessons that improve future runs.

Transferable rule:

- after meaningful work, capture what changed future behavior
- update instruction files, lessons files, or templates
- treat the knowledge base as a compounding asset

## Best Short Summary

The most important lesson from Simon Willison's guide is this:

**The real bottleneck is no longer typing code. It is deciding what should be built, verifying that it truly works, and leaving behind reusable knowledge so future agent runs get better instead of merely faster.**
