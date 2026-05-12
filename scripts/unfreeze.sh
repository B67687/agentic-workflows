#!/bin/bash
set -euo pipefail
# Remove the file-edit restriction.
# Usage: bash ./scripts/unfreeze.sh

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

if [ -f "$REPO_ROOT/.gstack-freeze" ]; then
  rm "$REPO_ROOT/.gstack-freeze"
  echo "Unfrozen. File edits are no longer restricted."
else
  echo "No freeze restriction found."
fi
