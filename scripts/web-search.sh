#!/usr/bin/env bash
# =============================================================================
# web-search.sh --- Search the web. Zero API keys, zero setup, zero cost.
#
# Engine: Bing (works out of the box via Python requests with browser headers)
# Upgrade path: BRAVE_API_KEY env var switches to Brave Search API for higher
#               rate limits and structured results.
#
# Usage:
#   bash scripts/web-search.sh "query"
#   bash scripts/web-search.sh "query" --count 5
#   bash scripts/web-search.sh "query" --raw          # JSON output
#   BRAVE_API_KEY="key" bash scripts/web-search.sh "query"
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUERY=""
COUNT=10
RAW=false

# --- Usage -------------------------------------------------------------------
usage() {
  cat <<'USAGE'
Usage: web-search.sh <query> [options]

Web search. Zero API keys required. Uses Bing by default.

Arguments:
  query                 Search query (required)

Options:
  --count N             Number of results (1-20, default: 10)
  --raw                 Output raw JSON
  --help                Show this help

Environment:
  BRAVE_API_KEY         Optional free upgrade. Get at https://brave.com/search/api/
                        When set, uses Brave Search API (2,000 queries/month free).
                        No credit card needed.
USAGE
  exit 0
}

# --- Parse arguments ---------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --count)   COUNT="$2"; shift 2 ;;
    --raw)     RAW=true; shift ;;
    --help)    usage ;;
    --*)       echo "Unknown option: $1" >&2; usage ;;
    *)         QUERY="$1"; shift ;;
  esac
done

if [[ -z "$QUERY" ]]; then
  echo "Error: No query provided." >&2
  usage
fi

# --- Mode 1: Brave Search API (when BRAVE_API_KEY is set) --------------------
if [[ -n "${BRAVE_API_KEY:-}" ]]; then
  if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: curl and jq required for Brave Search mode." >&2
    exit 1
  fi

  ENCODED_QUERY="$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))")"
  URL="https://api.search.brave.com/res/v1/web/search?q=${ENCODED_QUERY}&count=${COUNT}"

  RESPONSE=$(curl -s --max-time 15 \
    -H "Accept: application/json" \
    -H "X-Subscription-Token: ${BRAVE_API_KEY}" \
    "$URL")

  if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
    echo "Brave API error: $(echo "$RESPONSE" | jq -r '.error.detail // .error.message')" >&2
    exit 1
  fi

  if [[ "$RAW" == "true" ]]; then
    echo "$RESPONSE" | jq '.web.results // []'
    exit 0
  fi

  echo "=== Web Search Results (Brave) ==="
  echo "$QUERY"
  echo ""
  echo "$RESPONSE" | jq -r '
    (.web.results // [])[: ($ENV.COUNT | tonumber)] | to_entries[] |
    "\(.key + 1). \(.value.title // "Untitled")",
    "   URL: \(.value.url // "")",
    (if .value.description then "   \(.value.description[0:200])" else "" end),
    ""
  '
  echo "--- $(echo "$RESPONSE" | jq '.web.results | length') results ---"
  exit 0
fi

# --- Mode 2: Bing via Python (default, no API key needed) --------------------
if ! command -v python3 &>/dev/null; then
  echo "Error: Python 3 is required for the default search mode." >&2
  echo "Install: sudo apt install python3 python3-pip" >&2
  exit 1
fi

# Pass arguments safely via environment variables
export SEARCH_QUERY="$QUERY"
export SEARCH_COUNT="$COUNT"
export SEARCH_RAW="$RAW"

python3 "$SCRIPT_DIR/web-search.py"
