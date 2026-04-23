# Archived Findings

Durable discoveries that have proven valuable over time.

## How It Works

- Significant findings from research-log.md get moved here
- These are validated discoveries worth referencing long-term
- Add date of original discovery and why it's important

## Format

```
## [Topic Name]

**Discovered**: YYYY-MM-DD
**Source**: [link]

### What
[Description]

### Why It Matters
[Impact on agent workflows, efficiency, etc.]
```

---

<!-- Archived discoveries go below -->

## Context Rotation And Compression

**Discovered**: 2026-04-22
**Source**: [archive/research-log-2026-04.md](../archive/research-log-2026-04.md)

### What

Strong agent systems repeatedly solve the same bottleneck: context accumulation. The recurring solutions are fresh-context rotation, terse compression, retrieval/search, and learned skills.

### Why It Matters

This validates the hub's session-state and archive/index design. Hot-path files should stay small, while detailed memory stays retrievable behind links.

## Runtime Primitives For Serious Agent Apps

**Discovered**: 2026-04-21
**Source**: [archive/research-log-2026-04.md](../archive/research-log-2026-04.md)

### What

Serious agent apps need more than raw model calls: managed loops, tools, handoffs, guardrails, sessions, tracing, and sandboxed execution.

### Why It Matters

This belongs in product architecture decisions. Use direct calls for short paths, but use a runtime when tools, state, artifacts, multi-step work, or observability matter.

## Model Routing As Cost Control

**Discovered**: 2026-04-21
**Source**: [archive/research-log-2026-04.md](../archive/research-log-2026-04.md)

### What

Cost control is moving from prompt wording into routing infrastructure: choose models by task difficulty, monitor usage, apply budget limits, and fall back automatically.

### Why It Matters

Do not hard-code the most expensive model everywhere. Model choice should be part of system design and verification.

## Stable Local Surfaces

**Discovered**: 2026-04-21
**Source**: [archive/research-log-2026-04.md](../archive/research-log-2026-04.md)

### What

Stable local URLs and predictable dev surfaces reduce brittleness for agent workflows, screenshots, OAuth callbacks, and parallel app testing.

### Why It Matters

Agent ergonomics are not only prompts. The local environment should be addressable and repeatable.

## Personal Voice And Detection Resistance

**Discovered**: 2026-04-19 to 2026-04-21
**Source**: [archive/research-log-2026-04.md](../archive/research-log-2026-04.md)

### What

The user's natural writing patterns are a better anti-detection strategy than generic "humanizing." Sentence rhythm, imperfection, uncertainty, and language mixing matter.

### Why It Matters

Before writing for the user, read `personal-voice/VOICE-PROFILE.md` and preserve their style rather than polishing it into a generic voice.
