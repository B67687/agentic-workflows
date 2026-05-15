#!/usr/bin/env bash
# =============================================================================
# detect-gaps.sh --- Componentization shim for session-start.sh
#
# Contents merged into session-start.sh. This script now delegates.
# Kept for backward compatibility (hooks.json, tools.toml, docs).
# =============================================================================
set -euo pipefail
exec "$(cd "$(dirname "$0")" && pwd)/session-start.sh" "$@"
