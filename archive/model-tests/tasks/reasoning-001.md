---
id: reasoning-001
category: reasoning
difficulty: medium
tags: [debugging, multi-step, root-cause]
expected_outcome: Identifies root cause and explains the chain
time_estimate: < 3 minutes
---

## Task

A CI pipeline that was working last week started failing today. The failure is in the "test" job. No code changes were made to the repository. The last 5 builds before today all passed. The failure started 3 builds ago.

Build #117 failed. The error in the test job is:
```
Error: Cannot find module 'jest'
```

Build #118 failed with the same error. Build #119 failed with the same error.

Given this information, what are the most likely root causes (in order of probability)? Walk through the reasoning chain. Do not just guess — show the logical deduction.

## Expected Behavior

A ranked list of likely causes with the reasoning that leads to each one. At least 3 candidates. Clear distinction between "common causes" and "unlikely but possible causes."
