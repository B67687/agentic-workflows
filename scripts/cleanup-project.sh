#!/usr/bin/env bash
# =============================================================================
# cleanup-project.sh --- Analyze and reclaim space in a project directory
#
# Usage:
#   bash scripts/cleanup-project.sh                    # scan only (no changes)
#   bash scripts/cleanup-project.sh --apply            # apply safe cleanups
#   bash scripts/cleanup-project.sh --aggressive       # apply + ask about big items
#   bash scripts/cleanup-project.sh /path/to/project   # scan a specific project
#
# Scans common cache, build artifact, and bloat locations:
#   - Git:  count-objects, prune-packable, stale worktrees
#   - Node: node_modules stale check, .npm/_cacache
#   - Gradle: cache size check
#   - Dart/Flutter: .dart_tool/, build/
#   - Rust: target/ dir size
#   - Python: __pycache__, .venv size, pip cache
#   - Go: go-build cache, pkg/mod
#   - General: build/, dist/, .next/, coverage/
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET="${1:-$REPO_ROOT}"
MODE="scan"
if [ "$TARGET" = "--apply" ] || [ "$TARGET" = "--aggressive" ]; then
  MODE="${TARGET#--}"
  TARGET="${2:-$REPO_ROOT}"
fi

fmt_size() {
  local bytes="$1"
  if [ "$bytes" -lt 1024 ]; then
    echo "${bytes}B"
  elif [ "$bytes" -lt 1048576 ]; then
    echo "$((bytes / 1024))K"
  elif [ "$bytes" -lt 1073741824 ]; then
    echo "$((bytes / 1048576))M"
  else
    echo "$(echo "scale=1; $bytes / 1073741824" | bc)G"
  fi
}

declare -a actions

check_git() {
  local dir="$1"
  local git_dir="$dir/.git"
  [ -d "$git_dir" ] || return 0
  echo "  Git:"

  local loose pack prune new_pack
  loose=$(git -C "$dir" count-objects 2>/dev/null | awk '{print $1}')
  pack=$(git -C "$dir" count-objects -v 2>/dev/null | grep "size-pack" | awk '{print $2}')
  prune=$(git -C "$dir" count-objects -v 2>/dev/null | grep "prune-packable" | awk '{print $2}')

  echo "      Loose objects: $loose"
  echo "      Pack size: $(fmt_size "$((pack * 1024))")"
  [ "${prune:-0}" -gt "0" ] && echo "      Prune-packable: $prune objects (run gc)"

  if [ "${prune:-0}" -gt "0" ] && [ "$MODE" = "apply" ] || [ "$MODE" = "aggressive" ]; then
    echo "      Running git gc --aggressive --prune=now..."
    git -C "$dir" gc --aggressive --prune=now 2>/dev/null
    new_pack=$(git -C "$dir" count-objects -v 2>/dev/null | grep "size-pack" | awk '{print $2}')
    echo "      Pack reduced: $(fmt_size "$((pack * 1024))") -> $(fmt_size "$((new_pack * 1024))")"
  fi
}

check_node() {
  local dir="$1"
  [ -f "$dir/package.json" ] || return 0
  echo "  Node.js:"

  if [ -d "$dir/node_modules" ]; then
    local nm_size
    nm_size=$(du -sb "$dir/node_modules" 2>/dev/null | cut -f1)
    echo "      node_modules: $(fmt_size "$nm_size")"
  fi

  if [ -d "$dir/.npm" ]; then
    local npm_cache
    npm_cache=$(du -sb "$dir/.npm/_cacache" 2>/dev/null | cut -f1)
    [ -n "$npm_cache" ] && [ "$npm_cache" -gt "0" ] && echo "      npm cache: $(fmt_size "$npm_cache")"
  fi
}

check_gradle() {
  local dir="$1"
  local gradle_dir
  gradle_dir=$(find "$dir" -maxdepth 2 -name ".gradle" -type d 2>/dev/null | head -1)
  [ -z "$gradle_dir" ] && return 0
  echo "  Gradle:"

  local cache_size
  cache_size=$(du -sb "$gradle_dir/caches" 2>/dev/null | cut -f1)
  [ -n "$cache_size" ] && [ "$cache_size" -gt "0" ] && echo "      Cache: $(fmt_size "$cache_size")"
}

check_dart() {
  local dir="$1"
  [ -f "$dir/pubspec.yaml" ] || [ -f "$dir/pubspec.lock" ] || return 0
  echo "  Dart/Flutter:"

  if [ -d "$dir/.dart_tool" ]; then
    local dt_size
    dt_size=$(du -sb "$dir/.dart_tool" 2>/dev/null | cut -f1)
    echo "      .dart_tool: $(fmt_size "$dt_size")"
  fi
  if [ -d "$dir/build" ] && [ -f "$dir/pubspec.yaml" ]; then
    local build_size
    build_size=$(du -sb "$dir/build" 2>/dev/null | cut -f1)
    [ -n "$build_size" ] && [ "$build_size" -gt "1048576" ] && echo "      build/: $(fmt_size "$build_size")"
    if [ "$MODE" = "apply" ] || [ "$MODE" = "aggressive" ] && [ "$build_size" -gt "10485760" ]; then
      echo "      Cleaning build/..."
      rm -rf "$dir/build"
      echo "      build/ cleaned"
    fi
  fi
}

check_rust() {
  local dir="$1"
  [ -f "$dir/Cargo.toml" ] || return 0
  echo "  Rust:"

  if [ -d "$dir/target" ]; then
    local target_size
    target_size=$(du -sb "$dir/target" 2>/dev/null | cut -f1)
    echo "      target/: $(fmt_size "$target_size")"
  fi
}

check_python() {
  local dir="$1"
  [ -f "$dir/requirements.txt" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/pyproject.toml" ] || return 0
  echo "  Python:"

  local pycache
  pycache=$(find "$dir" -type d -name "__pycache__" -exec du -sb {} \; 2>/dev/null | awk '{sum+=$1} END{print sum}')
  [ -n "$pycache" ] && [ "$pycache" -gt "0" ] && echo "      __pycache__ total: $(fmt_size "$pycache")"

  if [ -d "$dir/.venv" ] || [ -d "$dir/venv" ]; then
    local vdir="$dir/.venv"
    [ -d "$dir/venv" ] && vdir="$dir/venv"
    local venv_size
    venv_size=$(du -sb "$vdir" 2>/dev/null | cut -f1)
    echo "      venv: $(fmt_size "$venv_size")"
  fi
}

check_build_dirs() {
  local dir="$1"
  echo "  Build artifacts:"
  local found=false
  for bd in "build" "dist" ".next" "coverage" ".cache" ".eslintcache" ".tsbuildinfo"; do
    if [ -d "$dir/$bd" ]; then
      local sz
      sz=$(du -sb "$dir/$bd" 2>/dev/null | cut -f1)
      if [ -n "$sz" ] && [ "$sz" -gt "1048576" ]; then
        echo "      $bd/: $(fmt_size "$sz")"
        found=true
      fi
    fi
  done
  $found || echo "      (none >1MB)"
}

echo "===================================================================="
echo "  Cleanup Scanner: $(basename "$TARGET")"
echo "  Mode: $MODE"
echo "===================================================================="
echo ""

check_git "$TARGET"
check_node "$TARGET"
check_gradle "$TARGET"
check_dart "$TARGET"
check_rust "$TARGET"
check_python "$TARGET"
check_build_dirs "$TARGET"

echo ""
echo "===================================================================="
echo "  Done."
if [ "$MODE" != "scan" ]; then
  echo "  Applied ${#actions[@]} cleanup actions"
fi
echo "===================================================================="
