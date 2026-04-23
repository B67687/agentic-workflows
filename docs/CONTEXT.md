# Context: AI Prompting Workspace

This is a **living knowledge base** for prompt design, agent workflows, and cross-repo lesson propagation. Not code.

## Folder Structure

```
/ (root)
|- AGENTS.md            # Operating contract; read after session state
|- README.md            # Navigation index
|- docs/                # Core knowledge
|- scripts/             # Automation scripts
|- workflow/            # Generated workflow files, state, logs, registries
|- research/            # Daily research
|- propagate-templates/ # Templates for repo sync
|- archive/             # Absorbed content
`- personal-voice/      # Personal voice training
```

## High-Signal Files (Quick Access)

| File | Purpose |
|------|---------|
| `workflow/session-state.json` | Active state; read first on resume |
| `docs/core-agent-doctrine.md` | 10-principle backbone |
| `docs/workspace-system-overview.md` | Whole-system map for cold starts |
| `docs/session-checkpoint.md` | Full checkpoint rules |
| `docs/daily-prompts.md` | 5 reusable prompts |
| `docs/prompt-templates.md` | Copy-paste templates (index at top) |
| `docs/token-efficient-prompting.md` | Cost reduction |
| `docs/cognitive-identity.md` | Human-AI cognitive partnership |
| `docs/ai-product-building.md` | Build products with agents |
| `docs/quality-standards.md` | Quality criteria |
| `personal-voice/VOICE-PROFILE.md` | **Your voice patterns** |

## Quick Orientation (If Confused)

1. `workflow/session-state.json` - What was happening and what comes next
2. `AGENTS.md` (root) - Operating rules
3. `docs/workspace-system-overview.md` - How the whole system fits together
4. `README.md` (root) - Where everything lives
5. `core-agent-doctrine.md` - The principles
6. `daily-prompts.md` - How to prompt for common tasks

## Key Principles Summary

1. **Scope tightly** — Don't ask for "everything"
2. **Give rich evidence** — Logs, files, configs, then stop
3. **Define done early** — Success criteria matter
4. **Choose lightest lane** — Inline, reusable, isolated, review
5. **Put rules at right scope** — Personal, repo-local, component-local
6. **Plan when ambiguous**
7. **Optimize quality, not volume**
8. **Promote repeated work**
9. **Update memory after lessons**
10. **Use teaching mode deliberately**

## Research Workflow

When asked to "research X":
- Use hierarchical analysis (Medium for all, Deep only if "worth it")
- Apply verification framework (source triangulation, confidence levels)
- Integrate into target docs

## Maintenance Rule

If you want to keep improving this folder:
1. Save the prompt shape that worked
2. Save the lesson that should change future behavior
3. Save one compact example of when to use it

## Run Before/After Changes

```pwsh
.\scripts\audit-folder-quality.ps1
```

## Participation

This knowledge base flows across 25 topic folders in M-Namikaz-Others. Insights can be harvested from any folder and integrated here, then propagated back via `scripts/propagate-to-all.ps1 -Apply`.
