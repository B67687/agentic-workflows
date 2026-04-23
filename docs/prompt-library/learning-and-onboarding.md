# Learning And Onboarding Prompts

Split from docs/prompt-templates.md during the 2026-04 optimization pass.

## 2. Teach Me What You Just Did

```text
Teach me what you just did, but optimize for learning speed.

Teach in this order:
1. A 60-second summary
2. The mental model of the system you were working in
3. The important steps you took, in order
4. Why the key decisions mattered
5. The files, commands, and tools that are worth remembering
6. The 3 things I should learn first if I want to do this myself next time

Separate:
- task-specific details
- generally useful concepts
- tool usage

Do not explain everything equally. Focus on leverage.
```

## 2B. Macro-To-Micro Teaching Prompt

```text
I want to understand the solution without getting buried in details.

Teach this from macro to micro:
1. The big picture: what system or environment was involved
2. The tactical change: what changed and how
3. The significance: why this mattered
4. The key concept: the single most important idea to retain

For the tactical part, also cover:
- what files, commands, tools, or libraries mattered
- why this method was chosen over common alternatives

For the key concept, explain it in two short sentences with a simple analogy.
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
7. A recommended learning path with what I should read first, second, and third

Please keep it practical and grounded in the actual repo rather than generic advice.
```

## 3B. Repo DNA Prompt

```text
Act like the lead architect onboarding a new contributor.

Teach me this repo's DNA efficiently:
1. Architectural blueprint: what style of system this is and how input becomes output
2. Directory landscape: what the key folders do and which file acts as the main entry point or control center
3. Tech stack and tooling: what the important frameworks, libraries, and config files are doing here
4. Execution lifecycle: walk me through one real event in this repo from start to finish
5. Senior secret: name one non-obvious design choice or convention that is easy to miss but important

Keep this grounded in the actual repo, not a generic template.
```

## 8. Work First, Then Teach Me

```text
Do the task normally, but after finishing, teach me efficiently.

After the work is done, explain:
- what the real problem was
- how you approached it
- which files and commands mattered most
- what conventions shaped your decisions
- what I should study next so I can handle similar work myself

Keep the explanation concise, practical, and optimized for independence.
```

## 9. Deep Repo Onboarding Prompt

```text
I want you to onboard me to this repo while also being useful.

When working, keep a short running map of:
- what subsystem you are touching
- how it fits into the repo
- what conventions it follows
- what I should notice and remember

After each substantial change, leave a compact explanation aimed at helping me build the right mental model, not just understand the patch.
```

