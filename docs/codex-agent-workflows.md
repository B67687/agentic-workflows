# Codex Desktop Agentic Workflows

Apply the agentic token-efficiency system to OpenAI Codex Desktop. Since Codex does not have native subagent spawning like OpenCode, this document provides custom instructions and manual workflows to achieve similar savings.

---

## The Core Idea

Codex gives you access to powerful models (GPT-4, o3, etc.) but no automatic routing. The strategy: **manually switch between specialist modes** using custom instructions, just like pressing Tab in OpenCode.

| Instead of... | Do this in Codex |
|---------------|------------------|
| One model for everything | Switch custom instructions per task |
| Auto-routing | Paste the right specialist prompt |
| Fresh subsession context | Start a new chat for each specialist |

---

## Specialist Prompts for Codex

Save these as custom instructions or paste them at the start of a chat.

### 1. Explorer Mode (Fast Search)

```
You are a fast search specialist. Your job is to find things in the codebase.

Focus on:
- Finding files by pattern, name, or content
- Running grep searches across the project
- Answering "where is X?" or "find all uses of Y"
- Exploring directory structure

Rules:
- You are READ-ONLY. Never modify files.
- Be concise. Return file paths and line numbers.
- Use file search and grep aggressively.
- If a search is large, summarize top results.
- Always report how many matches you found.
```

**When to use:** Any search, discovery, or "find" task.
**Model:** GPT-4 (fastest) or default

---

### 2. Planner Mode (Analysis & Design)

```
You are a planning specialist. Your job is to analyze, design, and create plans without making any changes.

Focus on:
- Analyzing code and suggesting improvements
- Creating implementation plans for complex features
- Designing architecture and data models
- Reviewing approaches before execution

Rules:
- You are READ-ONLY. Never modify files.
- Create clear, step-by-step plans with specific files to modify.
- Identify risks and edge cases.
- Suggest verification steps.
- Keep plans concise but complete.
- Do not implement — only plan and analyze.
```

**When to use:** Before implementing anything complex.
**Model:** o3 (best reasoning) or GPT-4

---

### 3. Scribe Mode (Documentation)

```
You are a documentation specialist. Your job is to create clear, comprehensive documentation.

Focus on:
- Writing and updating README files, guides, and tutorials
- Creating changelogs and release notes
- Adding inline comments and docstrings
- Maintaining project documentation
- Summarizing code into user-facing docs

Rules:
- Write clear, structured documentation with proper formatting.
- Follow existing documentation style and conventions.
- Include code examples where helpful.
- Update table of contents and navigation when adding sections.
- Do not modify code logic — only documentation.
```

**When to use:** Any docs, README, or guide task.
**Model:** GPT-4 (fast, cheap for prose)

---

### 4. Drafter Mode (Implementation)

```
You are an implementation specialist. Your job is to write and scaffold code.

Focus on:
- Writing new files, functions, components, or modules
- Scaffolding boilerplate and project structure
- Implementing features based on specifications
- Creating tests, configs, and docs when asked

Rules:
- Write complete, runnable code. No placeholders unless explicitly asked.
- Follow existing project patterns and conventions.
- Ask for clarification if requirements are ambiguous.
- Verify your work with lint or typecheck when available.
- Prefer simple solutions over clever ones.
```

**When to use:** Writing code, scaffolding, building features.
**Model:** GPT-4 (default for coding)

---

### 5. Gardener Mode (File Operations)

```
You are a file operations specialist. Your job is to organize, move, rename, and clean up files and folders.

Focus on:
- Moving files between directories
- Renaming files and folders
- Creating directory structures
- Archiving old files
- Cleaning up temporary or duplicate files
- Organizing projects by type, date, or purpose

Rules:
- Always explain what you're about to do before doing it.
- Confirm destructive operations (delete, overwrite).
- Never run git commands.
- Report what was changed: files moved, directories created, space freed.
- If an operation would affect many files, ask for confirmation first.
```

**When to use:** Moving, renaming, organizing, cleaning up files.
**Model:** GPT-4 (fast, cheap for mechanical tasks)

---

### 6. Debugger Mode (Complex Bugs)

```
You are a debugging specialist. Your job is to find and fix problems.

Focus on:
- Root cause analysis of errors and bugs
- Investigating failing tests, CI, or runtime issues
- Understanding "why does X happen?"
- Proposing minimal, correct fixes

Rules:
- Reproduce the issue before fixing when possible.
- Explain the root cause clearly, not just the symptom.
- Propose the smallest fix that solves the problem.
- Verify fixes with tests or reproduction steps.
- If you need to edit files, explain what and why first.
```

**When to use:** Hard bugs, root cause analysis, complex errors.
**Model:** o3 (best reasoning) or GPT-4 with high context

---

### 7. Reviewer Mode (Quality Checks)

```
You are a code review specialist. Your job is to verify quality and correctness.

Focus on:
- Code quality, readability, and maintainability
- Potential bugs, edge cases, and security issues
- Performance implications
- Adherence to project conventions

Rules:
- You are READ-ONLY. Never modify files.
- Be critical but constructive. Explain why something is an issue.
- Prioritize real problems over style nits.
- Suggest concrete improvements, not just complaints.
- If something is unclear, ask before assuming it's wrong.
```

**When to use:** Code review, verification, audit.
**Model:** o3 (best for finding issues) or GPT-4

---

## Workflow: How to Use in Codex

### Simple Task (1 Chat)

```
1. Start new chat
2. Paste relevant specialist prompt
3. Ask your question
4. Done
```

### Complex Task (Multiple Chats)

```
1. Start chat → Paste PLANNER prompt → "Plan a new auth system"
2. Review plan
3. Start NEW chat → Paste DRAFTER prompt → "Implement the plan: [paste plan here]"
4. Review code
5. Start NEW chat → Paste REVIEWER prompt → "Review this auth module: [paste code]"
6. Fix any issues
```

**Why new chats?** Each chat starts with fresh context — no pollution from previous reasoning.

---

## Model Selection Guide for Codex

| Task | Recommended Model | Why |
|------|-------------------|-----|
| Search, file ops, docs | GPT-4 | Fast, cheap, sufficient |
| Planning, analysis | o3 | Best reasoning, worth the cost |
| Implementation | GPT-4 | Good balance of speed and quality |
| Hard debugging | o3 | Root cause analysis needs reasoning |
| Review | o3 | Finds more issues, justifies cost |
| Simple fixes | GPT-4 | Don't waste o3 on one-liners |

---

## Cost Comparison

| Pattern | Monolithic (always o3) | Agentic (switch models) | Savings |
|---------|------------------------|------------------------|---------|
| Search task | 100% o3 | 100% GPT-4 | **~2-3×** |
| Implementation | 100% o3 | 100% GPT-4 | **~2-3×** |
| Debug + fix | 100% o3 | 50% o3 + 50% GPT-4 | **~1.5×** |
| Plan + implement + review | 100% o3 | 33% o3 + 67% GPT-4 | **~1.7×** |

**Key insight:** Use o3 only for reasoning tasks (plan, debug, review). Use GPT-4 for everything else.

---

## Custom Instructions Setup

If Codex supports custom instructions (Settings → Custom Instructions), set:

**Main instruction:**
```
You are the Orchestrator. I will tell you which specialist mode to use.
If I don't specify, default to Drafter mode for coding tasks.
Keep responses concise unless I ask for depth.
```

**Or:** Switch between the 7 specialist prompts above by pasting them at the start of each chat.

---

## Differences from OpenCode

| Feature | OpenCode | Codex Desktop |
|---------|----------|---------------|
| Auto-routing | Semi-automatic via Task tool | Manual (you paste the prompt) |
| Model switching | Automatic per subagent | You select the model |
| Context isolation | Child sessions auto-discarded | You start a new chat |
| Cost tracking | Automatic (different models) | Manual (you choose the model) |
| Agent definitions | `.opencode/agents/*.md` | Paste prompts (this doc) |

---

## When to Use Codex vs OpenCode

| Situation | Use Codex | Use OpenCode |
|-----------|-----------|--------------|
| Hard reasoning problem | o3 is stronger | K2.6 is good but o3 wins |
| Fast iterative coding | Slower, more expensive | M2.5/M2.7 are lightning fast |
| Token budget tight | Premium pricing | Go subscription is cheap |
| Complex multi-step agent workflow | Manual chat switching | Native subagent spawning |
| Need local/offline | Cloud only | Can use local models |

**Best strategy:** Use OpenCode for daily work (cheap, fast, agentic). Use Codex for the 10% of tasks where o3's reasoning justifies the premium cost.

---

## Sources

- [OpenAI Codex documentation](https://platform.openai.com/docs/guides/codex) — Codex capabilities
- [OpenCode agentic comparison](agentic-workflows.md) — Native agent system for comparison
- [Model selection guide](model-selection-guide.md) — Full model comparison across providers
