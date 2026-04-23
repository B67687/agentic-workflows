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
Rules: READ-ONLY. Be concise. Return paths and line numbers.
```

### Example: Drafter

```markdown
---
description: Write and implement new code
mode: subagent
model: opencode-go/minimax-m2.7
permission:
  edit: allow
  bash: allow
  webfetch: allow
---
You are an implementation specialist. Write complete, runnable code.
Rules: Follow project conventions. Ask if ambiguous. Prefer simple solutions.
```

## Recommended Agent Set

| Agent | Role | Suggested Model |
|-------|------|----------------|
| Orchestrator | Routing, synthesis | K2.6 / your best model |
| Explorer | Search, discovery | Cheapest fast model |
| Planner | Analysis, design | Mid-tier reasoning model |
| Scribe | Documentation | Cheapest fast model |
| Drafter | Implementation | Mid-tier coding model |
| Gardener | File operations | Cheapest fast model |
| Debugger | Complex bugs | Best reasoning model |
| Reviewer | Quality checks | Best available model |

**Adapt models to your subscription.** The hub uses OpenCode Go models; you may use Zen, Copilot, or other providers.

## opencode.json Template

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator",
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "model": "[your-best-model]",
      "description": "Main orchestrator. Routes tasks to specialist subagents.",
      "prompt": "You are the Orchestrator. Route subtasks to the right specialist agent.\n\nSpecialist agents available:\n- @explorer: Search and discovery\n- @planner: Plan and analyze\n- @scribe: Documentation\n- @drafter: Write and implement\n- @gardener: File operations\n- @debugger: Debug and investigate\n- @reviewer: Review and verify\n\nRouting rules:\n- Search/discovery → @explorer\n- Plan/design → @planner\n- Docs → @scribe\n- Write/implement → @drafter\n- File ops → @gardener\n- Debug → @debugger\n- Review → @reviewer\n- Simple tasks → handle directly\n\nPass compressed context to subagents:\n- Task: [specific, bounded]\n- Context: [3-5 bullets max]\n- Files: [paths only]\n- Done when: [success criteria]",
      "permission": {
        "edit": "allow",
        "bash": "allow",
        "webfetch": "allow",
        "task": {
          "*": "deny",
          "explorer": "allow",
          "planner": "allow",
          "scribe": "allow",
          "drafter": "allow",
          "gardener": "allow",
          "debugger": "allow",
          "reviewer": "allow"
        }
      }
    }
  }
}
```

## Key Principles

1. **One subtask per subagent** — Don't chain multiple tasks
2. **Compress before spawning** — Never pass full thread history
3. **Synthesize on return** — Distill specialist output before presenting
4. **Fail fast** — If a subagent fails twice, escalate to best model
5. **Right model for right job** — Don't use expensive models for simple tasks

## Learn More

- Full architecture: `AI Prompting/docs/agentic-workflows.md`
- Model selection: `AI Prompting/docs/model-selection-guide.md`
- Token efficiency: `AI Prompting/docs/token-efficient-prompting.md`
- OpenCode docs: https://opencode.ai/docs/agents/
