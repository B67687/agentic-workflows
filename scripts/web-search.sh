#!/usr/bin/env bash
# =============================================================================
# web-search.sh --- Local web search via Brave Search API (no MCP daemon)
#
# Calls the Brave Search API directly via curl. Requires BRAVE_API_KEY in
# the environment (free tier: 2,000 queries/month).
#
# Usage:
#   export BRAVE_API_KEY="your_key_here"
#   bash scripts/web-search.sh "query string"
#   bash scripts/web-search.sh "query string" --count 5 --freshness pw
#   bash scripts/web-search.sh "query string" --type news
#
# Types: web (default), news, video, image, local
# =============================================================================
set -euo pipefail

# --- Configuration -----------------------------------------------------------
API_KEY="${BRAVE_API_KEY:-}"
QUERY=""
COUNT=10
FRESHNESS=""     # pd (past day), pw (week), pm (month), py (year)
SEARCH_TYPE="web"
SAFESEARCH="moderate"
COUNTRY="US"
LANG="en"
OFFSET=0

# --- Usage -------------------------------------------------------------------
usage() {
  cat <<'USAGE'
Usage: web-search.sh <query> [options]

Search the web using the Brave Search API.

Arguments:
  query                 Search query (required)

Options:
  --count N             Results per page (1-20, default: 10)
  --freshness FILTER    Time filter: pd (day), pw (week), pm (month), py (year)
  --type TYPE           Search type: web, news, video, image, local (default: web)
  --safesearch LEVEL    off, moderate, strict (default: moderate)
  --country CODE        Country code (default: US)
  --lang CODE           Search language (default: en)
  --offset N            Pagination offset (max 9, default: 0)
  --help                Show this help

Environment:
  BRAVE_API_KEY         Required. Get one at https://brave.com/search/api/
                        Free tier: 2,000 queries/month, no credit card needed.
USAGE
  exit 1
}

# --- Parse arguments ---------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --count)       COUNT="$2"; shift 2 ;;
    --freshness)   FRESHNESS="$2"; shift 2 ;;
    --type)        SEARCH_TYPE="$2"; shift 2 ;;
    --safesearch)  SAFESEARCH="$2"; shift 2 ;;
    --country)     COUNTRY="$2"; shift 2 ;;
    --lang)        LANG="$2"; shift 2 ;;
    --offset)      OFFSET="$2"; shift 2 ;;
    --help)        usage ;;
    --*)           echo "Unknown option: $1" >&2; usage ;;
    *)             QUERY="$1"; shift ;;
  esac
done

# --- Validate ----------------------------------------------------------------
if [[ -z "$QUERY" ]]; then
  echo "Error: No query provided." >&2
  usage
fi

if [[ -z "$API_KEY" ]]; then
  cat >&2 <<'EOF'
Error: BRAVE_API_KEY is not set.

Get a free API key from: https://brave.com/search/api/
Free tier: 2,000 queries/month, no credit card needed.

Then set it in your shell profile:
  export BRAVE_API_KEY="your_key_here"

Or set it inline:
  BRAVE_API_KEY="your_key" bash scripts/web-search.sh "query"
EOF
  exit 1
fi

# Check dependencies
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required but not installed." >&2
    exit 1
  fi
done

# --- Build URL ---------------------------------------------------------------
# URL-encode the query (simple approach)
urlencode() {
  local string="$1"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for ((pos=0; pos<strlen; pos++)); do
    c="${string:$pos:1}"
    case "$c" in
      [-_.~a-zA-Z0-9]) encoded+="$c" ;;
      *) printf -v o '%%%02x' "'$c"; encoded+="$o" ;;
    esac
  done
  echo "$encoded"
}

ENCODED_QUERY="$(urlencode "$QUERY")"

# Build the API URL based on search type
case "$SEARCH_TYPE" in
  web)    API_URL="https://api.search.brave.com/res/v1/web/search";;
  news)   API_URL="https://api.search.brave.com/res/v1/news/search";;
  video)  API_URL="https://api.search.brave.com/res/v1/video/search";;
  image)  API_URL="https://api.search.brave.com/res/v1/image/search";;
  local)  API_URL="https://api.search.brave.com/res/v1/local/search";;
  *)
    echo "Error: Unknown search type '$SEARCH_TYPE'. Use: web, news, video, image, local" >&2
    exit 1
    ;;
esac

# Build query parameters
PARAMS="q=${ENCODED_QUERY}&count=${COUNT}&offset=${OFFSET}&safesearch=${SAFESEARCH}"
PARAMS+="&country=${COUNTRY}&search_lang=${LANG}"

if [[ -n "$FRESHNESS" ]]; then
  PARAMS+="&freshness=${FRESHNESS}"
fi

FULL_URL="${API_URL}?${PARAMS}"

# --- Execute search ----------------------------------------------------------
RESPONSE=$(curl -s --max-time 15 \
  -H "Accept: application/json" \
  -H "Accept-Encoding: gzip" \
  -H "X-Subscription-Token: ${API_KEY}" \
  "$FULL_URL" 2>&1)

CURL_EXIT=$?

if [[ $CURL_EXIT -ne 0 ]]; then
  echo "Error: Network request failed (exit code: $CURL_EXIT)" >&2
  exit 2
fi

# --- Check for API errors ----------------------------------------------------
if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
  ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.detail // .error.message // "Unknown API error"')
  ERROR_CODE=$(echo "$RESPONSE" | jq -r '.error.code // "UNKNOWN"')
  echo "Error [$ERROR_CODE]: $ERROR_MSG" >&2
  exit 3
fi

# --- Format results ----------------------------------------------------------
echo "=== Search Results ==="
echo "Query: $QUERY"
echo "Type: $SEARCH_TYPE"
echo ""

case "$SEARCH_TYPE" in
  web)
    echo "$RESPONSE" | jq -r '
      if (.web?.results? // []) == [] then
        "No results found."
      else
        (.web.results // .web?.results? // []) | to_entries[] |
        "\(.key + 1). \(.value.title // "Untitled")\n   URL: \(.value.url // "N/A")\n   \(.value.description // "" | .[0:200])\n"
      end
    '
    # Show summary if available
    echo "$RESPONSE" | jq -r '
      if (.summarizer?.status? // "") == "complete" then
        "\n--- AI Summary ---\n\(.summarizer.summary // "")\n"
      else
        ""
      end
    '
    ;;

  news)
    echo "$RESPONSE" | jq -r '
      if (.results? // []) == [] then
        "No results found."
      else
        .results[] |
        "• \(.title // "Untitled")\n  URL: \(.url // "N/A")\n  Source: \(.source // "N/A")  Date: \(.age // "N/A")\n  \(.description // "" | .[0:200])\n"
      end
    '
    ;;

  video)
    echo "$RESPONSE" | jq -r '
      if (.results? // []) == [] then
        "No results found."
      else
        .results[] |
        "• \(.title // "Untitled")\n  URL: \(.url // "N/A")\n  Duration: \(.duration // "N/A")  Views: \(.views // "N/A")\n  \(.description // "" | .[0:200])\n"
      end
    '
    ;;

  image)
    echo "$RESPONSE" | jq -r '
      if (.results? // []) == [] then
        "No results found."
      else
        .results[:20][] |
        "• \(.title // "Untitled")\n  URL: \(.url // "N/A")\n  Size: \(.width // "?")x\(.height // "?")"
      end
    '
    ;;

  local)
    echo "$RESPONSE" | jq -r '
      if (.results? // []) == [] then
        "No results found."
      else
        .results[] |
        "• \(.title // "Untitled")\n  Address: \(.address // "N/A")\n  Rating: \(.rating // "N/A")  Phone: \(.phone // "N/A")\n  \(.description // "" | .[0:200])\n"
      end
    '
    ;;
esac

# --- Show metadata -----------------------------------------------------------
echo ""
echo "$RESPONSE" | jq -r '
  "--- Metadata ---",
  "Total results: \(.web?.total_results? // .total_results? // "N/A")",
  if .query?.original? then "Original query: \(.query.original)" else "" end,
  if .web?.results? then "Results on page: \(.web.results | length)" else "" end
' 2>/dev/null | grep -v '^$'
