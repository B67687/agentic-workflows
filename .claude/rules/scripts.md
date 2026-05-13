---
description: Conventions for writing and maintaining shell scripts.
paths:
  - "scripts/**"
  - "propagation/**"
  - "skills/**/scripts/**"
---

# Script Conventions

## Shell scripts

- Use `set -euo pipefail` for strict error handling
- Prefer `local` variables in functions
- Use lowercase for variable names, UPPERCASE for environment/exports
- Always quote variable expansions: `"$var"` not `$var`
- Use `[[ ]]` for conditionals (bash), not `[ ]`
- Add `set -x` for debug mode when needed, never commit with it enabled

## Error handling

- Exit codes: 0 = success, 1 = generic error, 2 = blocking/usage error
- Print errors to stderr: `echo "Error: ..." >&2`
- Use helper functions from scripts/tools.sh when available

## Safety

- Never `rm -rf` without validation guards
- Never hardcode paths — use `$(dirname "${BASH_SOURCE[0]}")` patterns
- Never `curl | bash` patterns in committed scripts
- Use `mktemp` for temporary files
