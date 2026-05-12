#!/bin/bash
# =============================================================================
# tools.sh — Workspace tool registry
# Lists all agent-callable tools in the workspace with descriptions.
# Compact format (<400 tokens) designed for injection at session start.
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Agent Tools ==="

# 1. Scripts (from scripts/*.sh with comment headers)
find "$REPO_ROOT/scripts" -maxdepth 1 -name '*.sh' -type f | sort | while read -r f; do
  name="$(basename "$f" .sh)"
  desc="$(head -5 "$f" | grep "^# " | grep -v "^# ===" | head -1 | sed 's/^# //')"
  if [ -z "$desc" ]; then
    desc="(no description)"
  fi
  echo "  script/$name  — $desc"
done

# 2. Commands (from commands/*.md — these are OpenCode slash commands)
if [ -d "$REPO_ROOT/commands" ]; then
  find "$REPO_ROOT/commands" -name '*.md' -type f | sort | while read -r f; do
    name="$(basename "$f" .md)"
    desc="$(head -5 "$f" | grep "^#" | head -1 | sed 's/^#* *//')"
    if [ -z "$desc" ]; then
      desc="(no description)"
    fi
    echo "  command/$name — $desc"
  done
fi

# 3. Binary tools (from ~/.local/bin)
if [ -d "$HOME/.local/bin" ]; then
  ls "$HOME/.local/bin" 2>/dev/null | while read -r name; do
    file="$HOME/.local/bin/$name"
    if [ -x "$file" ] && [ ! -d "$file" ]; then
      desc="$(head -3 "$file" | grep "^# " | head -1 | sed 's/^# //')"
      echo "  bin/$name  — ${desc:-custom binary}"
    fi
  done
fi

echo "=== End Tools ==="
