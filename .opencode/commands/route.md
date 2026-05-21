---
description: Route a normal-language request through the workflow tree
---

Use this when the user types a task in normal language and no workflow is active.

The agent reads `workflow.d/root.yaml` and runs the `classify` step automatically at session start. This command is only needed when you need to re-route mid-session.

Procedure:
1. Read `workflow-state.json` — if a workflow is active, resume it
2. If no active workflow, load `workflow.d/root.yaml` and run the `classify` step
3. The classify step is deliberative: propose a category, get user confirmation, branch to the matching workflow
4. Execute the routed workflow's steps

Categories matching workflow definitions:
- research — investigate the codebase objectively
- design — design discussion before implementation
- implement — execute verified vertical slices
- verify — review changes for correctness
- review — code review
- docs — create or update documentation
- refactor — restructure without behavior change
- debug — diagnose and fix bugs
- propagate — sync templates to topic repos
- question — handle inline, no workflow needed

Do not run a script. The workflow definitions in `workflow.d/` are the routing system.
