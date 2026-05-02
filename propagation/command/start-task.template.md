---
description: Classify a task before starting and choose the right lane
---

Use this command before non-trivial work.

Return a compact task intake with:
- goal
- in-scope work
- likely files or areas
- success condition
- recommended lane: direct, research, plan, or implement
- next command to use

Default rule:
- if the task is small, obvious, and easy to verify, direct handling is allowed
- otherwise start in research

If the task looks non-trivial, end by recommending `/research $ARGUMENTS`.
