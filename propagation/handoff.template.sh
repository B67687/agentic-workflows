#!/usr/bin/env bash
# Managed-By: AI-Prompting-Library

set -euo pipefail

find_hub() {
  local candidates=(
    "/home/namikaz/projects/dev/ai-prompting"
    "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../ai-prompting"
  )
  local candidate

  for candidate in "${candidates[@]}"; do
    if [[ -f "$candidate/scripts/handoff.sh" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  echo "ERROR: could not find ai-prompting hub handoff.sh" >&2
  return 1
}

hub="$(find_hub)"
exec bash "$hub/scripts/handoff.sh" "$@"
