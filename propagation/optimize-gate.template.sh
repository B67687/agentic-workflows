#!/usr/bin/env bash
# Managed-By: AI-Prompting-Library
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR"
HUB_DIR=""
for d in "$TARGET_DIR"/.. "$TARGET_DIR"/../.. "$TARGET_DIR"/../../..; do
  if [[ -d "$d/ai-prompting" ]] && [[ -f "$d/ai-prompting/scripts/optimize-gate.sh" ]]; then
    HUB_DIR="$d/ai-prompting"
    break
  fi
done
if [[ -z "$HUB_DIR" ]]; then
  echo "ERROR: Could not find ai-prompting hub"
  exit 1
fi
exec bash "$HUB_DIR/scripts/optimize-gate.sh" "$@"
