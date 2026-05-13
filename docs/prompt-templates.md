# Prompt Templates

Stable index for reusable prompt templates.

The full library is split into focused files under `docs/prompt-library/` so this entrypoint stays cheap to read.

## Quick Use

| Need | Use |
|---|---|
| Debug CI or behavior safely | [prompt-library/debugging-and-verification.md](prompt-library/debugging-and-verification.md) |
| Learn a repo or topic efficiently | [prompt-library/learning-and-onboarding.md](prompt-library/learning-and-onboarding.md) |
| Resume, audit, or analyze repo work | [prompt-library/repo-workflows.md](prompt-library/repo-workflows.md) |
| Compare an original codebase with a rewrite | [prompt-library/repo-workflows.md](prompt-library/repo-workflows.md#14b-source-rewrite-and-agent-runtime-parity-prompt) |
| Match user voice or reduce AI fingerprints | [prompt-library/voice-and-humanization.md](prompt-library/voice-and-humanization.md) |
| Generate editable diagrams | [prompt-library/visualization.md](prompt-library/visualization.md) |

(Pre-split copy preserved at `archive/prompt-templates-2026-04-pre-split.md` --- local only.)

## Highest-Use Short Prompts

### Fix CI Build

```text
Analyze this failing CI job: [name]
Focus on:
- root cause
- smallest maintainable fix
- closest local verification
- residual uncertainty
```

Full versions: [debugging-and-verification.md](prompt-library/debugging-and-verification.md)

### Teach Me This Repo

```text
Teach me this repo so I can become useful in it quickly.
Cover what it does, important folders, execution flow, key commands, conventions, traps, and the learning order.
```

Full versions: [learning-and-onboarding.md](prompt-library/learning-and-onboarding.md)

### Resume Long Work

```text
Resume this long-running task from the latest state file or handover.
First identify what is already done, what remains, and what should not be repeated.
Then continue from the next concrete action and verify before reporting.
```

Full versions: [repo-workflows.md](prompt-library/repo-workflows.md)

### Verification Prompt

```text
Before you answer, list your assumptions.
What could be wrong with this solution? Find at least 2 potential issues.
Test your output against the requirements. List any gaps.
```

Full versions: [debugging-and-verification.md](prompt-library/debugging-and-verification.md)

### Voice Matching

```text
Write in my personal voice.
Read ../personal-voice/VOICE-PROFILE.md first.
Match my sentence length, transitions, formality, quirks, uncertainty, and natural imperfections.
Avoid generic AI phrasing.
```

Full versions: [voice-and-humanization.md](prompt-library/voice-and-humanization.md)

### Source Rewrite Parity

```text
Compare this original implementation and rewrite. Map architecture, tool contracts, permission boundaries, context/session state, compaction, routing, and verification. Separate spec parity from behavioral parity, update existing knowledge-base docs with transferable lessons, and end with what the human operator must change.
```

Full version: [repo-workflows.md](prompt-library/repo-workflows.md#14b-source-rewrite-and-agent-runtime-parity-prompt)

## Library Files

| File | Contents |
|---|---|
| [debugging-and-verification.md](prompt-library/debugging-and-verification.md) | CI, evidence-driven debugging, TDD, cross-model review, first-run-tests prompts |
| [learning-and-onboarding.md](prompt-library/learning-and-onboarding.md) | Teach-me, repo onboarding, repo DNA, work-then-teach prompts |
| [repo-workflows.md](prompt-library/repo-workflows.md) | Resume campaigns, repo culture, drift protection, repo analysis, compact serious-work prompts, PR code overview with diagrams |
| [voice-and-humanization.md](prompt-library/voice-and-humanization.md) | Beginner/amateur reasoning, humanization, AI detection references, language-specific writing patterns |
| [visualization.md](prompt-library/visualization.md) | Excalidraw/diagram generation prompt |

## Maintenance Rule

Keep this file as an index plus only the most reused short prompts.

When a template grows into a detailed playbook, move the full version into `docs/prompt-library/` and link it here.
