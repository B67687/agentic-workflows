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
    if [[ -x "$candidate/scripts/product-shape.sh" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  echo "ERROR: could not find ai-prompting hub product-shape.sh" >&2
  return 1
}

hub="$(find_hub)"
exec "$hub/scripts/product-shape.sh" "$@"
