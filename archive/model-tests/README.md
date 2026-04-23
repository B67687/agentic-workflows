# Model Testing System

Tests new models against standardized tasks to evaluate fitness for this workspace.

**Status: PAUSED** — Token cost concern. Awaiting user direction to re-enable.

## How It Works

1. **Add tasks** to `tasks/` as markdown files with inputs and expected outcomes
2. **Switch model** — user says "switch to [model] and test" or I recommend a switch after finding a better model
3. **Run tests** — I execute tasks against the current model and record results
4. **Self-document** — results auto-append to `results/` with model, date, duration, tokens, and verdict
5. **Synthesize** — after enough runs, I update `docs/model-selection-guide.md` if a model is significantly better

## Directory Structure

```
model-tests/
|- tasks/              # Standardized test tasks
|- results/           # Per-model, per-date results
|- archive/          # Historical comparisons
```

## Workflow

### Adding a Task

Tasks live in `tasks/` as markdown with frontmatter:

```markdown
---
id: coding-debug-fs-001
category: coding
difficulty: medium
tags: [powershell, file-system, debugging]
expected_outcome: Fixes the script without breaking anything
---

## Task

[Exact task description]

## Expected Behavior

[What the model should produce]
```

### Running Tests

When you say **"switch to [model] and test"**:

1. I switch the active model in OpenCode
2. I run through all tasks in `tasks/`
3. Each task output is recorded to `results/{model}/{date}.md`
4. I synthesize a verdict and tell you:
   - Which tasks passed/failed
   - How the model compares to current best
   - Whether to update `model-selection-guide.md`
   - What category this model excels at

### Self-Documentation

Each result file captures:
- Model and provider
- Date and duration
- Token usage (if available)
- Per-task: input, output, pass/fail, notes
- Overall verdict with reasoning

## Task Categories

| Category | What It Tests | Examples |
|---|---|---|
| coding | Code generation, fixes, refactors | Debug script, write function, refactor module |
| reasoning | Multi-step thinking, planning | Trace failure chain, design approach |
| context | Long-context retention, summarization | Summarize doc, answer from long input |
| tool-use | Function calling, API use | Git operations, file ops, search |
| style | Output quality, constraint adherence | Match voice, follow format, concise output |
| speed | Latency, throughput | Tokens/second, time to first token |

## Current Baseline Models

| Model | Provider | Strengths |
|---|---|---|
| Kimi K2.6 | OpenCode Go | Agentic coding, beats GPT-5.4 on SWE-bench Pro |
| Claude Sonnet 4.6 | GitHub Copilot | Daily serious work, best quality/quota |
| GPT-5.4 | OpenAI | Broad tool ecosystem, long context |

## Notes

- Tests are workspace-agnostic but weighted toward this hub's use cases (PowerShell, markdown, agentic workflows)
- "Pass" means the output met the expected outcome — not that it's the best possible answer
- A model can "pass" a task but still be worse overall than the current best
- Compare models on the categories that matter for your current work
