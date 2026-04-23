# Authoritative Agent Best Practices

Use this file for source-backed cross-tool guidance.

For the shared practical doctrine that this guidance supports, see:

- [core-agent-doctrine.md](core-agent-doctrine.md)

## Sources

- [OpenAI Codex best practices](https://developers.openai.com/codex/learn/best-practices)
- [Anthropic Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory)
- [GitHub Copilot cloud agent best practices](https://docs.github.com/en/copilot/tutorials/cloud-agent/get-the-best-results)
- [GitHub Copilot CLI best practices](https://docs.github.com/en/copilot/how-tos/copilot-cli/cli-best-practices)
- [Simon Willison's Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/)
- [OpenAI: Introducing study mode](https://openai.com/blog/chatgpt-study-mode/)
- [OpenAI: New tools for understanding AI and learning outcomes](https://openai.com/index/understanding-ai-and-learning-outcomes/)

## What Is Source-Backed Here

This file is:

- source-backed about what the referenced docs emphasize
- inference-based only when summarizing cross-vendor consensus

## Cross-Vendor Consensus

The strongest repeated ideas are:

1. scope the task tightly
2. provide concrete context
3. define acceptance criteria
4. give the agent a way to verify its work
5. plan before coding when ambiguity is high
6. move reusable repo knowledge into instruction files
7. keep sessions focused so context quality stays high
8. use agents for the right work, not every kind of work
9. improve the environment so the agent can build, test, and validate reliably
10. update instructions after repeated mistakes
11. use agent workflows to raise quality, not merely increase output volume

## What OpenAI Codex Emphasizes

- a small default prompt shape: goal, context, constraints, done when
- plan mode for difficult or ambiguous tasks
- durable repo guidance in `AGENTS.md`
- tests, checks, and review instead of code generation alone

For reasoning-effort specifics, see:

- [codex-reasoning-guide.md](codex-reasoning-guide.md)

## What Claude Code Emphasizes

- verification as a core requirement
- an "explore, then plan, then code" flow for harder tasks
- rich content inputs such as files, logs, screenshots, URLs, and piped data
- concise persistent instruction files
- careful context management as sessions grow

## What OpenAI's Learning Guidance Adds

- guided questions can improve learning more than answer dumping
- scaffolded explanations help manage cognitive load
- checks for understanding and guided practice are worth building into learning prompts
- learning quality depends on the interaction pattern, not just the final answer

## What GitHub Copilot Emphasizes

- scoped tasks with clear acceptance criteria
- saying which files or areas matter when possible
- repo-level instruction files for conventions
- planning before implementation
- focused sessions
- an environment that can actually install, run, and verify work

## What Simon Willison Emphasizes

Simon's guide is not vendor policy, but it is high-quality practitioner guidance.

Its strongest repeated ideas are:

- writing code is cheap now, but good code still costs engineering effort
- "first run the tests" is a strong short prompt
- manual testing still matters
- reusable examples are valuable agent inputs
- do not dump unreviewed generated work on collaborators
- the instruction loop should compound

## How To Use This File

- Use [daily-prompts.md](daily-prompts.md) for prompt shapes and scenarios.
- Use [token-efficient-prompting.md](token-efficient-prompting.md) for workflow-cost reduction.
- Use [tdd-with-agents.md](tdd-with-agents.md) for tests-first and TDD patterns.
- Update this file when a new source materially changes the cross-tool playbook.
