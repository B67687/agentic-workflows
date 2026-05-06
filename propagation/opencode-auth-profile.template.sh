#!/usr/bin/env bash
# Managed-By: AI-Prompting-Library

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.ai-prompting-hub.sh"

HUB_DIR="$(resolve_ai_prompting_hub "scripts/opencode-auth-profile.sh" "$SCRIPT_DIR")"
exec bash "$HUB_DIR/scripts/opencode-auth-profile.sh" "$@"
