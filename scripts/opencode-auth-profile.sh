#!/usr/bin/env bash
# =============================================================================
# opencode-auth-profile.sh - Save and switch whole OpenCode auth profiles
# =============================================================================

set -euo pipefail

AUTH_PATH="${OPENCODE_AUTH_PATH:-$HOME/.local/share/opencode/auth.json}"
PROFILE_DIR="${OPENCODE_AUTH_PROFILE_DIR:-$HOME/.local/share/opencode/auth-profiles}"
CURRENT_FILE="$PROFILE_DIR/.current"

usage() {
  cat <<'EOF'
Usage: ./scripts/opencode-auth-profile.sh COMMAND [name]

Commands:
  status        Show current auth providers and active profile marker
  list          List saved profiles
  save NAME     Save the current auth.json as NAME
  use NAME      Activate saved profile NAME, backing up current auth.json first

This switches the whole OpenCode auth.json without printing secrets.
Use it for separate OpenCode Go accounts/subscriptions.
EOF
}

providers() {
  python3 - "$AUTH_PATH" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1]).expanduser()
if not path.exists():
    print("missing")
    raise SystemExit
try:
    data = json.loads(path.read_text())
    if isinstance(data, dict):
        print(",".join(sorted(data.keys())) or "none")
    else:
        print(type(data).__name__)
except Exception as exc:
    print(f"parse-error:{type(exc).__name__}")
PY
}

cmd="${1:-}"
name="${2:-}"

case "$cmd" in
  status)
    mkdir -p "$PROFILE_DIR"
    echo "Auth path: $AUTH_PATH"
    echo "Providers: $(providers)"
    if [[ -f "$CURRENT_FILE" ]]; then
      echo "Active profile marker: $(<"$CURRENT_FILE")"
    else
      echo "Active profile marker: none"
    fi
    ;;
  list)
    mkdir -p "$PROFILE_DIR"
    find "$PROFILE_DIR" -maxdepth 1 -type f ! -name '.current' -printf '%f\n' | sort
    ;;
  save)
    if [[ -z "$name" ]]; then
      echo "ERROR: profile name required" >&2
      usage >&2
      exit 2
    fi
    if [[ ! "$name" =~ ^[A-Za-z0-9._-]+$ ]]; then
      echo "ERROR: profile name may only use letters, numbers, dot, underscore, dash" >&2
      exit 2
    fi
    if [[ ! -f "$AUTH_PATH" ]]; then
      echo "ERROR: auth file not found: $AUTH_PATH" >&2
      exit 1
    fi
    mkdir -p "$PROFILE_DIR"
    cp "$AUTH_PATH" "$PROFILE_DIR/$name"
    chmod 600 "$PROFILE_DIR/$name"
    printf '%s\n' "$name" > "$CURRENT_FILE"
    echo "Saved current auth profile as: $name"
    echo "Providers: $(providers)"
    ;;
  use)
    if [[ -z "$name" ]]; then
      echo "ERROR: profile name required" >&2
      usage >&2
      exit 2
    fi
    if [[ ! -f "$PROFILE_DIR/$name" ]]; then
      echo "ERROR: saved profile not found: $name" >&2
      exit 1
    fi
    mkdir -p "$(dirname "$AUTH_PATH")"
    if [[ -f "$AUTH_PATH" ]]; then
      cp "$AUTH_PATH" "$AUTH_PATH.before-switch-$(date +%Y%m%d-%H%M%S)"
    fi
    cp "$PROFILE_DIR/$name" "$AUTH_PATH"
    chmod 600 "$AUTH_PATH"
    printf '%s\n' "$name" > "$CURRENT_FILE"
    echo "Activated auth profile: $name"
    echo "Providers: $(providers)"
    ;;
  --help|-h|"")
    usage
    [[ -n "$cmd" ]] && exit 0 || exit 2
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage >&2
    exit 2
    ;;
esac
