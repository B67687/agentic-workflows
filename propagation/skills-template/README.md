# Agent Skills Template

This folder contains templates for creating Agent Skills in topic folders.

## What Are Agent Skills?

Agent Skills are reusable instruction packages that follow the agentskills.io open standard. They let OpenCode discover and load specialized workflows on demand.

## How to Create a Skill

1. Create a directory: `.opencode/skills/<skill-name>/`
2. Add a `SKILL.md` file with YAML frontmatter + instructions
3. OpenCode auto-discovers skills on startup

## SKILL.md Format

```yaml
---
name: skill-name
description: What this skill does and when to use it. Be specific.
---

# Skill Instructions

Step-by-step guidance for the agent...
```

## Example Skills

### Code Review Skill
```yaml
---
name: code-review
description: Review code for quality, bugs, and style issues. Use when the user asks for a review, PR feedback, or code critique.
---

# Code Review Checklist

1. Check for obvious bugs and logic errors
2. Verify error handling
3. Review naming conventions
4. Check for security issues
5. Suggest improvements
```

### Deployment Skill
```yaml
---
name: deploy
description: Deploy the application. Use when the user asks to deploy, push to production, or release.
disable-model-invocation: true
---

# Deployment Steps

1. Run tests
2. Build application
3. Deploy to target
4. Verify deployment
```

## Tips

- Keep `SKILL.md` under 500 lines
- Move detailed reference material to separate files in the skill directory
- Use specific descriptions so the agent knows when to activate the skill
- Add `disable-model-invocation: true` for skills that should only be triggered manually

## More Info

- [Agent Skills Standard](https://agentskills.io)
- [OpenCode Skills Docs](https://opencode.ai/docs/skills/)
