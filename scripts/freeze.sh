#!/bin/bash
# Restrict file edits to one directory.
# Creates .gstack-freeze at repo root with the given path.
# Usage: bash ./scripts/freeze.sh <allowed-path>

set -e

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "Usage: bash ./scripts/freeze.sh <directory-path>"
  echo "Example: bash ./scripts/freeze.sh src/"
  exit 1
fi

# Resolve to an absolute path if relative
if [[ "$TARGET" != /* ]]; then
  TARGET="$(cd "$(git rev-parse --show-toplevel 2>/dev/null || echo ".")" && pwd)/$TARGET"
fi

# Normalize --- remove trailing slash
TARGET="${TARGET%/}"

# Verify the directory exists
if [ ! -d "$TARGET" ]; then
  echo "Error: directory does not exist: $TARGET"
  exit 1
fi

echo "$TARGET" > /dev/null  # resolve path
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

echo "$TARGET" > "$REPO_ROOT/.gstack-freeze"
echo "Frozen to: $TARGET"
echo "Run bash ./scripts/unfreeze.sh to remove the restriction."
