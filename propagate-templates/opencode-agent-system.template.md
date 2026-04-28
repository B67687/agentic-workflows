<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: OpenCode Agent System -->
# OpenCode Agent Configuration

This folder uses OpenCode's native agent system for agentic workflows. Agent definitions live in `.opencode/agents/`.

## Quick Start

1. Ensure `opencode.json` exists in this project's root
2. Create `.opencode/agents/` directory
3. Copy agent definitions from the hub template or customize your own
4. Set `"default_agent": "orchestrator"` in `opencode.json`
5. Restart OpenCode

## Agent Definitions

Create one `.md` file per agent in `.opencode/agents/`:

### Example: Explorer

```markdown
---
description: Fast read-only agent for searching and discovering code
mode: subagent
model: opencode-go/minimax-m2.5
permission:
  edit: deny
  bash:
    "*": deny
    "git status*": allow
    "git log*": allow
  webfetch: allow
---
You are a fast search specialist. Find files, run searches, explore structure.
Rules: READ-ONLY. Be concise. Return paths and line numbers. Summarize large outputs instead of dumping raw text.
```

### Example: Worker

```markdown
---
description: Fresh-context worker for implementation, investigation, and review. Use when context is degraded (15+ turns), topic has shifted, or you need a clean slate for complex work.
mode: subagent
model: opencode-go/kimi-k2.6
permission:
  edit: allow
  bash: allow
  webfetch: allow
---
You are a generalist worker with fresh context. Continue complex work that has outgrown the main session.
Focus: Implementation, investigation, review, any complex task.
Rules: You receive compressed context (5-line summary). Ask if critical details missing. Keep write scope explicit. Verify work. Return changed files, verification, and residual risk.
```

## Recommended Agent Set (Simplified - April 2026)

Given the current cost landscape (Copilot Student = free Sonnet 4.6, Gemini AI Studio = 14,400 free req/day, K2.6 on promotion), the per-request cost difference between "cheap" and "premium" is often zero. The real tradeoff is complexity vs freshness.

| Agent | Role | Suggested Model | When to Spawn |
|-------|------|-----------------|---------------|
| Orchestrator | Routing, synthesis, direct handling | Your best available model | Default - handles 90% of tasks directly |
| Explorer | Search, discovery | Free/fast model (M2.5 Free) | Large searches (>10 files), complex patterns |
| Worker | Fresh context for any complex work | Same as Orchestrator (or M2.7 for volume) | 15+ turns, topic shift, quality degradation |

**Why only 2 subagents?**
- Drafter + Analyst merged into Worker - both just meant "do work with fresh context"
- The primary benefit of subsessions is now **context hygiene**, not cost savings
- Spawn only when: fresh context needed, parallel work possible, or different capabilities required

**Most tasks** (planning, docs, file ops, simple debug/review) should be handled directly by the Orchestrator. Only spawn subagents when the task clearly exceeds direct-handling thresholds.

**Adapt models to your subscription.** The hub uses OpenCode Go models; you may use Zen, Copilot, or other providers.

**Public output rule:** Do not add routing/model footers unless the target repo or platform explicitly requires disclosure. Keep public comments focused on root cause, fix, verification, and residual risk.

## opencode.json Template

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator",
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "model": "[your-best-model]",
      "description": "Main orchestrator. Handles tasks directly by default, only routing to specialist subagents when clearly beneficial.",
      "prompt": "You are the Orchestrator. Handle tasks directly by default. Only spawn a subagent when the task clearly exceeds direct-handling thresholds.\n\nSpecialist agents available:\n- @explorer: Search and discovery (large searches, complex patterns)\n- @worker: Fresh context for any complex work (implementation, investigation, review)\n\nRouting rules:\n- Search/discovery (>10 files, complex patterns) -> @explorer\n- Fresh context needed (15+ turns, topic shift, quality drop) -> @worker\n- Everything else -> handle directly\n\nPass compressed context to subagents:\n- Task: [specific, bounded]\n- Context: [3-5 bullets max]\n- Files: [paths only]\n- Done when: [success criteria]\n\nAfter resume or compacted context, run a read-only health probe before risky edits. Do not add routing/model footers unless explicitly required.",
      "permission": {
        "edit": "allow",
        "bash": "allow",
        "webfetch": "allow",
        "skill": "allow",
        "task": {
          "*": "deny",
          "explorer": "allow",
          "worker": "allow"
        }
      }
    }
  }
}
```

## Key Principles

1. **One subtask per subagent** - Don't chain multiple tasks
2. **Compress before spawning** - Never pass full thread history
3. **Synthesize on return** - Distill specialist output before presenting
4. **Health-probe after resume** - Check read-only state before risky edits
5. **Fail fast** - If a subagent fails twice, checkpoint and re-plan
6. **Right model for right job** - Don't use expensive models for simple tasks

## Learn More

- Full architecture: `AI Prompting/docs/agentic-workflows.md`
- Model selection: `AI Prompting/docs/model-selection-guide.md`
- Token efficiency: `AI Prompting/docs/token-efficient-prompting.md`
- OpenCode docs: https://opencode.ai/docs/agents/
