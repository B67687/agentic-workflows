---
name: retrospective
description: Just-in-time retrospective focused on improving agent autonomy. Event-driven — not calendar-driven. Analyzes what happened, identifies what blocked agent autonomy, and produces concrete improvements (learnings + tickets). Use when someone says "retro", "retrospective", "what did we learn", "what went wrong", or after a feature ships, an incident resolves, or any event worth reflecting on. Outputs to .tap/learnings.md.
trigger-phrases: retro, retrospective, what did we learn, what went wrong, post-mortem, incident review
handoffs: tap-audit (to reassess readiness after improvements), tighten-loop (for conversation-level steers)
companion-script: scripts/tap-retrospective.sh
---

# Retrospective

Reflect on what happened. Identify what blocked agent autonomy. Produce concrete improvements so the system gets better.

Not tied to sprints or calendars. Run when there's something worth learning from.

**Companion script:** `scripts/tap-retrospective.sh`
```bash
bash ./scripts/tap-retrospective.sh identify            # identify the trigger
bash ./scripts/tap-retrospective.sh gather "<trigger>"   # gather evidence
bash ./scripts/tap-retrospective.sh analyze              # analyze through autonomy lens
bash ./scripts/tap-retrospective.sh capture "<finding>"  # capture a learning
bash ./scripts/tap-retrospective.sh ticket "<learning>"   # create improvement ticket
bash ./scripts/tap-retrospective.sh append "<learning>"  # append to .tap/learnings.md
```

## Core Question

**What happened that an agent couldn't handle autonomously, and what's the cheapest fix so it can next time?**

## Process

### 1. Identify the Trigger

| Trigger | What to analyze |
|---------|-----------------|
| **Feature shipped** | Full cycle from ticket to merge |
| **Incident** | What broke, detected, fixed |
| **Agent failure pattern** | Rejected PRs, rework cycles, blocked tasks |
| **Project wrap** | Full engagement |
| **Ad hoc** | User specifies what to reflect on |

### 2. Gather Evidence

```
git log --since="[period]"           → what was committed
gh pr list --state merged --search    → PRs in scope
gh pr list --state closed --search    → rejected PRs (signal!)
```

Also read: `.tap/system-health.md`, `.tap/tap-audit.md`, `.tap/learnings.md`, PR review comments.

**Rejected PRs are gold.** Every rejection is a gap in agent capability or context.

### 3. Analyze Through the Autonomy Lens

| Gap | Agent lacked... | Example |
|-----|-----------------|---------|
| **Context** | Information | Missing CLAUDE.md, missing ADR, unclear AC |
| **Harness** | Tools/access | Missing MCP, CLI, skill, permissions |
| **Feedback** | Verification | No tests, no browser QA, CI doesn't catch |
| **Design** | Code complexity | God file, high coupling, inconsistent patterns |
| **Scope** | Boundaries | No AGENTS.md, too ambiguous, needs human judgment |

### 4. Capture Learnings

```
[date] — [trigger]
- [what happened] → [root cause category] → [specific fix]
```

**Good learnings are specific and actionable:**
- "Agent used raw SQL instead of Drizzle → context gap → add data access pattern to CLAUDE.md"
- "Agent couldn't test payment flow → harness gap → configure Stripe test MCP"

**Bad learnings are vague:** "Agent needs to be more careful" (not actionable)

### 5. Create Improvement Tickets

Categorize by impact:
- **Raises readiness score** — add MCP, test infra, AGENTS.md, ADRs
- **Prevents repeat failures** — update CLAUDE.md, add tests
- **Reduces design complexity** — split god file, collapse pass-through

### 6. Write to .tap/learnings.md

Append (never overwrite) to `.tap/learnings.md`.

Agents read `.tap/learnings.md` before starting work. This prevents same mistakes across sessions.

## Boundaries

- Does NOT edit CLAUDE.md or AGENTS.md (creates tickets — human decides)
- Does NOT assign blame or assess team performance
- Does NOT follow a calendar — runs when there's something to learn
- ONLY analyzes events, captures learnings, creates improvement tickets
- Goal is always: increase agent autonomy for next time
