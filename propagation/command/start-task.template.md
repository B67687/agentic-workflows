---
description: Classify a task before starting and choose the right lane
---

Use this command before non-trivial work.

First run:
`bash ./git-session-start.sh`

Return a compact task intake with:
- goal
- in-scope work
- likely files or areas
- success condition
- recommended lane: direct, research, plan, or implement
- git lane: stay in current checkout or move to a worktree
- next command to use

Default rule:
- if the task is small, obvious, and easy to verify, direct handling is allowed
- otherwise start in research
- if the current checkout is already dirty and the task is separate, risky, or long-running, recommend a worktree
- if the branch is behind or the repo state looks surprising, surface that before deeper work

If the task looks non-trivial, end by recommending `/research $ARGUMENTS`.
