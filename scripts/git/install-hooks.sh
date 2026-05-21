#!/usr/bin/env bash
# install-hooks.sh — Install git hooks from scripts/git/ to .git/hooks/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

install_hook() {
  local script="$1"
  local hook_name="$2"
  local source="$REPO_ROOT/scripts/git/$script"
  local target="$REPO_ROOT/.git/hooks/$hook_name"
  
  if [[ ! -f "$source" ]]; then
    echo "[HOOK] $hook_name: source not found at $source, skipping"
    return
  fi
  
  cat > "$target" << HOOK
#!/usr/bin/env bash
# $hook_name hook — auto-installed by scripts/git/install-hooks.sh
exec bash "$source"
HOOK
  chmod +x "$target"
  echo "[HOOK] $hook_name: installed from scripts/git/$script"
}

install_hook "pre-push.sh" "pre-push"
