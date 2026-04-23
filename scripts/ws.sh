#!/usr/bin/env bash
set -uo pipefail

command_name="${1:-help}"
shift || true

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
include_archive=0
include_generated=0
query=""

hot_paths=(
  "AGENTS.md:220"
  "README.md:150"
  "docs/workspace-system-overview.md:240"
  "HISTORY.md:350"
  "research/research-log.md:500"
  "docs/prompt-templates.md:350"
)

generated_paths=(
  "workflow/harvested-topic-insights.md"
  "workflow/cross-domain-candidates.md"
  "workflow/sync-state.json"
)

print_help() {
  cat <<'EOF'
Usage: bash scripts/ws.sh <command> [options]

Commands:
  help                         Show this help.
  status                       Session summary, hot-path sizes, and WSL tool status.
  hotspots                     Hot-path budgets plus largest active authored files.
  validate                     Read-only WSL validation checks.
  search -q "text"             Search active files with repo exclusions.

Options:
  -q, --query TEXT             Search query.
  --include-archive            Include curated archive files in search/scans.
  --include-generated          Include generated workflow files and raw archive snapshots.

This is the native WSL/Linux read-only companion to scripts/ws.ps1.
Use PowerShell for propagation or any other mutating workspace automation.
EOF
}

parse_common_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -q|--query)
        if [[ $# -lt 2 ]]; then
          echo "ERROR: $1 requires a value." >&2
          exit 2
        fi
        query="$2"
        shift 2
        ;;
      --include-archive)
        include_archive=1
        shift
        ;;
      --include-generated)
        include_generated=1
        shift
        ;;
      *)
        echo "ERROR: unknown option: $1" >&2
        exit 2
        ;;
    esac
  done
}

section() {
  printf '\n== %s ==\n' "$1"
}

is_excluded_file() {
  local rel="$1"

  [[ "$rel" == .git/* ]] && return 0
  [[ "$rel" == personal-voice/samples/* ]] && return 0
  [[ "$rel" == archive/raw/* && "$include_generated" -eq 0 ]] && return 0
  [[ "$rel" == archive/* && "$include_archive" -eq 0 && "$include_generated" -eq 0 ]] && return 0

  if [[ "$include_generated" -eq 0 ]]; then
    local generated
    for generated in "${generated_paths[@]}"; do
      [[ "$rel" == "$generated" ]] && return 0
    done
  fi

  return 1
}

list_active_files() {
  local roots=(docs research scripts propagate-templates personal-voice)
  [[ "$include_archive" -eq 1 || "$include_generated" -eq 1 ]] && roots+=(archive)
  [[ "$include_generated" -eq 1 ]] && roots+=(workflow)

  (
    cd "$repo_root" || exit 1
    find . -maxdepth 1 -type f \( -name '*.md' -o -name '*.json' -o -name '.rgignore' \) -print
    local root
    for root in "${roots[@]}"; do
      [[ -d "$root" ]] || continue
      if [[ "$root" == "personal-voice" ]]; then
        find "$root" -maxdepth 1 -type f -print
      else
        find "$root" -type f -print
      fi
    done
  ) | sed 's#^\./##' | while IFS= read -r rel; do
    if ! is_excluded_file "$rel"; then
      printf '%s\n' "$rel"
    fi
  done | sort -u
}

count_lines() {
  local file="$1"
  [[ -f "$file" ]] && wc -l < "$file" | tr -d ' '
}

count_bytes() {
  local file="$1"
  [[ -f "$file" ]] && wc -c < "$file" | tr -d ' '
}

show_session_summary() {
  local state="$repo_root/workflow/session-state.json"
  if [[ ! -f "$state" ]]; then
    echo "workflow/session-state.json is missing."
    return
  fi
  grep -E '^- \*\*(Session|Status|Name|Phase|What comes next):\*\* ' "$state" || true
}

show_hotspots() {
  section "Hot-Path Budgets"
  printf '%-38s %8s %8s %10s %s\n' "Path" "Lines" "Budget" "Bytes" "Status"

  local item rel budget path lines bytes status
  for item in "${hot_paths[@]}"; do
    rel="${item%%:*}"
    budget="${item##*:}"
    path="$repo_root/$rel"
    if [[ -f "$path" ]]; then
      lines="$(count_lines "$path")"
      bytes="$(count_bytes "$path")"
      if [[ "$lines" -gt "$budget" ]]; then status="WARN"; else status="OK"; fi
    else
      lines=""
      bytes=""
      status="MISSING"
    fi
    printf '%-38s %8s %8s %10s %s\n' "$rel" "$lines" "$budget" "$bytes" "$status"
  done

  section "Largest Active Authored Files"
  while IFS= read -r rel; do
    [[ -f "$repo_root/$rel" ]] || continue
    printf '%10s %8s %s\n' "$(count_bytes "$repo_root/$rel")" "$(count_lines "$repo_root/$rel")" "$rel"
  done < <(list_active_files) |
    sort -rn |
    head -15 |
    awk 'BEGIN { printf "%10s %8s %s\n", "Bytes", "Lines", "Path" } { bytes=$1; lines=$2; $1=""; $2=""; sub(/^  */, ""); printf "%10s %8s %s\n", bytes, lines, $0 }'
}

show_tool_status() {
  section "WSL Tool Status"
  local tools=(git rg fd jq gh fzf bat delta uv node npm pnpm bun)
  local tool path
  for tool in "${tools[@]}"; do
    if path="$(command -v "$tool" 2>/dev/null)"; then
      printf '%-8s %s\n' "$tool" "$path"
    else
      printf '%-8s MISSING\n' "$tool"
    fi
  done
}

run_search() {
  if [[ -z "$query" ]]; then
    echo 'ERROR: search requires -q "text" or --query "text".' >&2
    exit 2
  fi

  if ! command -v rg >/dev/null 2>&1; then
    echo "ERROR: rg is required. Install native ripgrep inside WSL." >&2
    exit 127
  fi

  local args=(--line-number --hidden --glob '!.git/**' --glob '!personal-voice/samples/**')
  if [[ "$include_archive" -eq 0 && "$include_generated" -eq 0 ]]; then
    args+=(--glob '!archive/**')
  elif [[ "$include_archive" -eq 1 && "$include_generated" -eq 0 ]]; then
    args+=(--glob '!archive/raw/**' --glob '!archive/session-raw*.txt')
  fi

  if [[ "$include_generated" -eq 0 ]]; then
    local generated
    for generated in "${generated_paths[@]}"; do
      args+=(--glob "!$generated")
    done
  fi

  (cd "$repo_root" && rg "${args[@]}" -- "$query" .)
}

validate() {
  local failed=0

  section "Parser"
  bash -n "$repo_root/scripts/ws.sh" && echo "scripts/ws.sh parses." || failed=1

  section "Required Tools"
  local required=(bash find grep awk sed git rg jq)
  local tool
  for tool in "${required[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "$tool: OK"
    else
      echo "$tool: MISSING"
      failed=1
    fi
  done

  section "Hot-Path Budgets"
  local item rel budget path lines
  for item in "${hot_paths[@]}"; do
    rel="${item%%:*}"
    budget="${item##*:}"
    path="$repo_root/$rel"
    if [[ ! -f "$path" ]]; then
      echo "$rel: MISSING"
      failed=1
      continue
    fi
    lines="$(count_lines "$path")"
    if [[ "$lines" -gt "$budget" ]]; then
      echo "$rel: WARN $lines > $budget"
    else
      echo "$rel: OK $lines <= $budget"
    fi
  done

  section "Read-Only Scope"
  echo "WSL wrapper is read-only. Use PowerShell scripts/ws.ps1 for propagation and other mutating workspace automation."

  return "$failed"
}

case "$command_name" in
  help) print_help ;;
  status) parse_common_args "$@"; section "Workspace Status"; show_session_summary; show_hotspots; show_tool_status ;;
  hotspots) parse_common_args "$@"; show_hotspots ;;
  search) parse_common_args "$@"; run_search ;;
  validate) parse_common_args "$@"; validate ;;
  *) echo "ERROR: unknown command: $command_name" >&2; print_help >&2; exit 2 ;;
esac
