#!/usr/bin/env bash
# =============================================================================
# template-resolve.sh --- Resolve template paths from priority stack
#
# Priority resolution order (first match wins):
#   1. overrides/   — project-specific overrides (highest)
#   2. presets/     — domain/genre presets
#   3. extensions/  — third-party or optional extensions
#   4. core/        — built-in templates (lowest)
#
# Usage:
#   template-resolve.sh find <name>          # Return path of first match
#   template-resolve.sh list                 # List all templates with tiers
#   template-resolve.sh list --tier <tier>   # Filter by tier
#   template-resolve.sh list --json          # Machine-readable JSON output
#   template-resolve.sh path <name>          # Alias for find, full path
#   template-resolve.sh show <name>          # Print file content of first match
#
# Exit codes:
#   0 — success
#   1 — usage error
#   2 — template not found
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/templates"

# Priority stack (highest to lowest)
TIERS=("overrides" "presets" "extensions" "core")
declare -A TIER_LABELS=(
  [overrides]="Project overrides (highest priority)"
  [presets]="Domain/genre presets"
  [extensions]="Third-party / optional extensions"
  [core]="Built-in templates (lowest priority)"
)
declare -A TIER_SEVERITY=(
  [overrides]="HIGHEST"
  [presets]="HIGH"
  [extensions]="MEDIUM"
  [core]="BASE"
)

usage() {
  cat >&2 <<'EOF'
Usage:
  template-resolve.sh find <name>          Resolve path (first match)
  template-resolve.sh list [--tier <t>]    List templates [in tier]
  template-resolve.sh list --json          Machine-readable JSON
  template-resolve.sh path <name>          Alias for 'find'
  template-resolve.sh show <name>          Print file content

Tier order (first match wins): overrides > presets > extensions > core
EOF
  exit 1
}

# ── Helpers ──────────────────────────────────────────────────────────────────

die_not_found() {
  echo "ERROR: template '$1' not found in any tier." >&2
  echo "  Searched (in order): ${TIERS[*]}" >&2
  exit 2
}

resolve_template() {
  local name="$1"
  for tier in "${TIERS[@]}"; do
    local dir="$TEMPLATES_DIR/$tier"
    if [ -f "$dir/$name" ]; then
      echo "$dir/$name"
      return 0
    fi
  done
  return 1
}

# ── Commands ─────────────────────────────────────────────────────────────────

cmd_find() {
  local name="$1"
  local path
  path=$(resolve_template "$name") || die_not_found "$name"
  echo "$path"
}

cmd_show() {
  local name="$1"
  local path
  path=$(resolve_template "$name") || die_not_found "$name"
  cat "$path"
}

cmd_list() {
  local filter_tier=""
  local as_json=false

  while [ $# -gt 0 ]; do
    case "$1" in
      --tier) filter_tier="$2"; shift 2 ;;
      --tier=*) filter_tier="${1#*=}"; shift ;;
      --json) as_json=true; shift ;;
      *) shift ;;
    esac
  done

  if $as_json; then
    # JSON output
    local first=true
    echo '['
    for tier in "${TIERS[@]}"; do
      [ -n "$filter_tier" ] && [ "$tier" != "$filter_tier" ] && continue
      local dir="$TEMPLATES_DIR/$tier"
      if [ -d "$dir" ]; then
        for f in "$dir"/*; do
          [ -f "$f" ] || continue
          local base
          base=$(basename "$f")
          [ "$base" = ".gitkeep" ] && continue
          $first || echo ','
          first=false
          echo '  {'
          echo '    "name": '"$(printf '%s' "$base" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')"','
          echo '    "tier": "'"$tier"'",'
          echo '    "path": '"$(printf '%s' "$f" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')"','
          echo '    "severity": "'"${TIER_SEVERITY[$tier]}"'"'
          echo -n '  }'
        done
      fi
    done
    echo ''
    echo ']'
  else
    # Human-readable table
    echo "── Templates ──────────────────────────────────"
    echo ""
    for tier in "${TIERS[@]}"; do
      [ -n "$filter_tier" ] && [ "$tier" != "$filter_tier" ] && continue
      local dir="$TEMPLATES_DIR/$tier"
      local label="${TIER_LABELS[$tier]}"
      local sev="${TIER_SEVERITY[$tier]}"
      if [ -d "$dir" ]; then
        local count=0
        for f in "$dir"/*; do
          [ -f "$f" ] && [ "$(basename "$f")" != ".gitkeep" ] && count=$((count + 1))
        done
        if [ "$count" -gt 0 ]; then
          echo "  [$sev] $label"
          for f in "$dir"/*; do
            [ -f "$f" ] || continue
            local base
            base=$(basename "$f")
            [ "$base" = ".gitkeep" ] && continue
            echo "    └─ $base"
          done
          echo ""
        fi
      fi
    done
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  [ $# -lt 1 ] && usage

  local cmd="$1"
  shift

  case "$cmd" in
    find|path)
      [ $# -lt 1 ] && { echo "Usage: template-resolve.sh $cmd <name>" >&2; exit 1; }
      cmd_find "$1"
      ;;
    show)
      [ $# -lt 1 ] && { echo "Usage: template-resolve.sh show <name>" >&2; exit 1; }
      cmd_show "$1"
      ;;
    list)
      cmd_list "$@"
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
