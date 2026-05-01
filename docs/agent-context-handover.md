# Agent Context Handover Guide

This file tells AI models **how to write** a context handover when you switch models.

---

## How to Generate a Handover

When you say "I want to switch to [model]", the AI should:

1. Summarize current task
2. List what's done / what's remaining
3. Note key files modified
4. State current direction and why
5. List next steps

Output the handover in a **markdown codeblock** for easy copying:

```markdown
## Current Task
[What you're working on]

## What's Done
- [Completed item 1]
- [Completed item 2]

## What's Remaining
- [Pending item 1]
- [Pending item 2]

## Current Direction
[Why you chose this approach]

## Key Files Modified
- [file]: [changes]

## Next Steps
1. [Immediate next action]
2. [Follow-up]

## Important Context
[Any context the next model needs to know]
```

---

## Best Practices (From Research)

### Minimum Viable Handover

The smallest effective handover:

```
Task: [one line]
Done: [what's complete]  
Next: [immediate action]
Context: [only what MUST know]
```

**Why this works:**
- Models are stateless (input → output)
- Clear task = new model reasons from goal backward
- Done/Next provides continuity without full history

### Proactive Context Handover (Self-Aware Checkpoint)

The handover above is **reactive** — you ask for a switch, the model writes it. The improvement is a **proactive** checkpoint: the model recognizes pressure before it becomes critical and offers a handover unprompted.

### Why Models Can't See Token Counts

LLMs don't have introspection into their remaining context window. They can't say "I have 2000 tokens left." But they CAN recognize *behavioral symptoms* of context pressure.

### Context Pressure Signals

| Signal | What it indicates |
|--------|-------------------|
| Output becoming generic or repetitive | Model is recycling from early context |
| Re-explaining things already covered in this session | Context too long, can't retrieve efficiently |
| Losing track of what's been done vs not done | Memory load exceeded |
| Questions about things already settled | Working context has drifted |
| Output quality dropping or getting shorter | Approaching hard limit |

### The Checkpoint Prompt (Run Periodically)

Add this to your system prompt or reference before complex work:

```
CONTEXT PRESSURE CHECKPOINT:

Before sending your response, assess:
1. Is this message rehashing something already explained in this session?
2. Is my explanation getting generic or repetitive?
3. Am I losing track of what's been done vs. what's remaining?
4. Would a fresh model context work better for the next step?

If YES to 2 or more:
→ Write a handover note FIRST (see template below)
→ Deliver the handover as part of your response
→ Flag: "I've written a handover below in case we need to switch models before the next step."
```

### The Proactive Handover Template

When the model recognizes pressure, it writes this at the end of its response (or instead of continuing):

```markdown
## Context Handover [Auto-generated]

**Why this was written**: I'm detecting context pressure signals. Continuing here risks losing important state before a clean handoff.

## Current Task
[One line — what you're working on]

## What's Done
- [Completed item 1]
- [Completed item 2]

## What's Remaining
- [Pending item 1]
- [Pending item 2]

## Key Context for Next Model
[Only what MUST persist — decisions made, direction chosen, what's been ruled out]

## Current Direction
[Why this approach was chosen]

## Next Steps
1. [Immediate next action]
2. [Follow-up]

---
Shall I continue with the next step, or would you like to start fresh with a new model?
```

### When to Trigger

| Situation | Action |
|-----------|--------|
| Long research task with many files read | Checkpoint every 10-15 tool calls |
| Complex multi-step implementation | Checkpoint at each phase boundary |
| Session approaching 30+ minutes | Write handover, offer to continue or switch |
| User asks something that requires re-reading lots of prior context | Proactively suggest handover |

### Why This Matters

A session that runs until it hits the context limit loses everything at the end. A proactive handover at 80% context means the last 20% captures what matters, and the next model starts with a clean summary instead of fighting through noise.

The handover is not failure — it's how smart agents manage continuity.

---

## Handover Mistakes to Avoid

| Mistake | Why It Fails | Correction |
|---------|--------------|------------|
| Dumping full conversation | Signal lost in noise | Summarize decisions + state |
| No task context | Doesn't know WHY | Include direction + goals |
| Missing "why" decisions | May undo good work | Document reasoning |
| No next action | Model stalls | Always include next step |
| Including everything | Overwhelms context | Include only decision-relevant |

### Mid-Task vs Task-Start Switches

**Task-Start** (easier): Goal/end state + constraints + approach → new model plans fresh

**Mid-Task** (harder): Add current step + what's in progress + what failed + why this approach

### Context Layers to Include

```
System Layer     → Agent identity, capabilities
Task Layer       → Specific instructions for current task  
Tool Layer       → Tool descriptions and usage
Memory Layer     → Historical context, learnings
```

---

## Your Current Quotas

| Model | Daily Limit | Best For |
|-------|-------------|----------|
| Claude Opus 4.7 | 144k | High-stakes reasoning |
| Claude Sonnet 4.6 | 200k | Daily professional coding |
| Gemini 3.1 Pro | 128k | Graduate-level reasoning |
| GPT-5.4 / 5.2 Codex | 400k | Coding-heavy, long context |
| MiniMax M2.7 Free | **Unlimited** | Latest, $0 |

---

## Model Switching Rule

Before generating handover, check if the requested model is:
1. **Overkill** (e.g., Opus for simple boilerplate)
2. **Unnecessary cost** when free option suffices
3. **Wrong fit** for the task type

If yes, **recommend a better model** first, then ask user to confirm.

---

## Example Prompt

```
User: "I want to switch to Gemini 3.1 Pro for code review"
AI: "For code review, Claude Sonnet 4.6 is actually better:
     - You have 200k tokens vs 128k
     - Claude leads SWE-bench (80% vs 80.6%)
     - Better optimized for code review
     
     Shall I switch to Claude Sonnet instead?"
```

---

## For This Switch

Your current session context (copy below):

```markdown
## Current Task
Research on AI agent engineering, model selection, and workspace optimization

## What's Done
- Built comprehensive knowledge base structure (AGENTS.md, docs/CONTEXT.md, docs/)
- Implemented research workflow with hierarchical analysis (Medium/Deep)
- Added cognitive science integration (testing effect, cognitive load theory)
- Created explanation framework (teaching order, curse of knowledge)
- Added interpersonal effectiveness principles (人情世故)
- Created agent-context-handover.md with smart switching logic
- Updated model-selection-guide.md with quotas and recommendations
- Researched learning science connections to AI prompting
- Researched information compression principles (Zettelkasten, PARA)
- Researched model rankings (April 2026)

## What's Remaining
- Continue research on manual URLs provided:
  - system-design-primer (GitHub)
  - OWASP Top Ten
  - Cursor agent best practices
- Model benchmark updates for April 2026

## Current Direction
Using MiniMax M2.7 Free for research (latest model, unlimited tokens)

## Key Files Modified
- AGENTS.md: Operating contract with 10 principles
- docs/agent-context-handover.md: Model switching guide
- docs/model-selection-guide.md: April 2026 rankings
- docs/CONTEXT.md: AI orientation

## Next Steps
1. Read session-state.json first, then AGENTS.md
2. Research: model comparisons, handover prompts, memory sharing, agentic workflows
3. Update knowledge base with findings
```

---

**To switch**: Copy the above codeblock and give it to MiniMax M2.5, or just say:
```
"I want to switch to MiniMax M2.5. Generate handover."
```
