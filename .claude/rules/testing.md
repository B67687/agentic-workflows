---
description: Testing conventions and requirements for this project.
paths:
  - "**/*test*"
  - "**/tests/**"
  - "**/test_*"
  - "**/*.spec.*"
  - "**/*.test.*"
  - scripts/test-smoke.sh
---

# Testing Rules

## Before committing

- Run `bash scripts/test-smoke.sh` to verify core tools work
- Ensure new scripts have corresponding test coverage in test-smoke.sh
- Do not commit if smoke tests fail

## Test conventions

- Shell scripts: test via `scripts/test-smoke.sh` using assert patterns
- Python: use pytest-style assertions
- Keep tests fast — aim for under 30s total
- Name tests descriptively: `test_<function>_<behavior>`
