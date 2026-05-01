#!/usr/bin/env bash
# Managed-By: AI-Prompting-Library
# =============================================================================
# check-sync-status.sh - Check propagation status against the ai-prompting hub
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR"

HUB_DIR=""
for d in "$TARGET_DIR"/.. "$TARGET_DIR"/../.. "$TARGET_DIR"/../../..; do
  if [[ -d "$d/ai-prompting" ]] && [[ -f "$d/ai-prompting/scripts/check-sync-status.sh" ]]; then
    HUB_DIR="$d/ai-prompting"
    break
  fi
done

if [[ -z "$HUB_DIR" ]]; then
  echo "ERROR: Could not find ai-prompting hub"
  exit 1
fi

exec bash "$HUB_DIR/scripts/check-sync-status.sh" "$TARGET_DIR"
