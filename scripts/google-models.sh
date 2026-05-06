#!/usr/bin/env bash
# =============================================================================
# google-models.sh - List or sync Gemini models from Google's model endpoint
# =============================================================================

set -euo pipefail

SYNC=false
CONFIG_PATH="${OPENCODE_CONFIG:-$HOME/.config/opencode/opencode.jsonc}"
PROVIDER_ID="${GOOGLE_OPENCODE_PROVIDER_ID:-google-ai-studio}"

usage() {
  cat <<'EOF'
Usage: ./scripts/google-models.sh [--sync-opencode-config] [--config path] [--provider id]

Lists currently available Gemini models using Google's OpenAI-compatible
models endpoint. With --sync-opencode-config, updates the provider model list
in the OpenCode config from Google's live endpoint.

Credentials are read from, in order:
- GEMINI_API_KEY
- GOOGLE_API_KEY
- ~/.local/share/opencode/auth.json provider "google-ai-studio"

No API key is printed.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sync-opencode-config)
      SYNC=true
      ;;
    --config)
      CONFIG_PATH="${2:-}"
      shift
      ;;
    --provider)
      PROVIDER_ID="${2:-}"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

key="${GEMINI_API_KEY:-${GOOGLE_API_KEY:-}}"

if [[ -z "$key" && -f "$HOME/.local/share/opencode/auth.json" ]]; then
  key="$(
    python3 - "$PROVIDER_ID" <<'PY'
import json
import sys
from pathlib import Path

provider = sys.argv[1]
path = Path.home() / ".local/share/opencode/auth.json"
try:
    data = json.loads(path.read_text())
    value = data.get(provider, {})
    print(value.get("key", ""))
except Exception:
    print("")
PY
  )"
fi

if [[ -z "$key" ]]; then
  echo "ERROR: no Gemini API key found. Set GEMINI_API_KEY or connect google-ai-studio in OpenCode." >&2
  exit 1
fi

json="$(
  curl -fsS "https://generativelanguage.googleapis.com/v1beta/openai/models" \
    -H "Authorization: Bearer $key"
)"

models="$(
  GOOGLE_MODELS_JSON="$json" python3 - <<'PY'
import json
import os
import sys

data = json.loads(os.environ["GOOGLE_MODELS_JSON"])
ids = []
for item in data.get("data", []):
    model_id = item.get("id")
    if model_id:
        if model_id.startswith("models/"):
            model_id = model_id.split("/", 1)[1]
        ids.append(model_id)
for model_id in sorted(set(ids)):
    print(model_id)
PY
)"

if [[ -z "$models" ]]; then
  echo "ERROR: Google returned no models from the OpenAI-compatible models endpoint." >&2
  exit 1
fi

if [[ "$SYNC" != true ]]; then
  printf '%s\n' "$models"
  exit 0
fi

python3 - "$CONFIG_PATH" "$PROVIDER_ID" "$models" <<'PY'
import json
import sys
from pathlib import Path

config_path = Path(sys.argv[1]).expanduser()
provider_id = sys.argv[2]
model_ids = [line for line in sys.argv[3].splitlines() if line.strip()]

data = json.loads(config_path.read_text())
provider = data.setdefault("provider", {}).setdefault(provider_id, {})
provider["models"] = {model_id: {"name": model_id} for model_id in model_ids}
config_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Synced {len(model_ids)} Google model(s) into {config_path} provider {provider_id}.")
PY
