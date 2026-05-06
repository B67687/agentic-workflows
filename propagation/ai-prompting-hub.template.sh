#!/usr/bin/env bash
# Managed-By: AI-Prompting-Library

resolve_ai_prompting_hub() {
  local required_path="${1:-scripts/propagation-contract.sh}"
  local start_dir="${2:-$(pwd)}"
  local dir candidate

  if [[ -n "${AI_PROMPTING_HUB:-}" ]] && [[ -f "$AI_PROMPTING_HUB/$required_path" ]]; then
    printf '%s\n' "$AI_PROMPTING_HUB"
    return 0
  fi

  dir="$(cd "$start_dir" && pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ "$(basename "$dir")" == "ai-prompting" ]] && [[ -f "$dir/$required_path" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi

    candidate="$dir/ai-prompting"
    if [[ -f "$candidate/$required_path" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi

    dir="$(dirname "$dir")"
  done

  for candidate in \
    "/home/namikaz/projects/dev/ai-prompting" \
    "/mnt/m/M-Namikaz-Others/ai-prompting"
  do
    if [[ -f "$candidate/$required_path" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  echo "ERROR: Could not find ai-prompting hub with $required_path" >&2
  return 1
}
