#!/bin/bash
# =============================================================================
# skill-toolset.sh --- Progressive disclosure for agent skills (L1/L2/L3)
#
# Provides three-tier skill loading following the Agent Skills specification:
#   L1 --- Metadata: list all skills with names and descriptions
#   L2 --- Full load: load a skill's complete instructions
#   L3 --- Resource:  load a specific file (reference, asset, script)
#
# Delegates to skill-toolset.py for implementation.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/skill-toolset.py"

if [ ! -f "$PYTHON_SCRIPT" ]; then
  echo "ERROR: $PYTHON_SCRIPT not found"
  exit 1
fi

exec python3 "$PYTHON_SCRIPT" "$@"
