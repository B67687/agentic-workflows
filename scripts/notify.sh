#!/usr/bin/env bash
# =============================================================================
# notify.sh — Multi-channel notification dispatcher (12-factor F7, F11)
#
# Dispatches agent-to-human notifications through configured channels:
#   - Slack webhook (if SLACK_WEBHOOK_URL is set)
#   - CLI output (if running in a terminal)
#   - File-based fallback (writes to .notifications/)
#
# Usage:
#   bash ./scripts/notify.sh <message> [options]
#
# Options:
#   --urgency low|medium|high    (default: medium)
#   --channel slack|cli|file|all (default: all)
#   --subject ""                 Notification subject/headline
#
# Environment:
#   SLACK_WEBHOOK_URL    Slack webhook URL for Slack notifications
#   NOTIFY_SLACK_CHANNEL Slack channel to post to (default: #agent-alerts)
#   NOTIFY_EMAIL_TO      Email recipient (requires mail command)
#
# Principle: "Enable users to trigger agents from slack, email, sms —
# any channel. Agents respond through the same channels."
#   — 12-Factor Agents, Factor 11
# =============================================================================

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NOTIFY_DIR="$REPO_ROOT/.notifications"
mkdir -p "$NOTIFY_DIR"

MESSAGE=""
URGENCY="medium"
CHANNEL="all"
SUBJECT=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --urgency) URGENCY="$2"; shift 2 ;;
    --channel) CHANNEL="$2"; shift 2 ;;
    --subject) SUBJECT="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: notify.sh <message> [--urgency low|medium|high] [--channel slack|cli|file|all] [--subject \"\"]"
      exit 0
      ;;
    *)
      if [ -z "$MESSAGE" ]; then
        MESSAGE="$1"
      fi
      shift
      ;;
  esac
done

if [ -z "$MESSAGE" ]; then
  echo "ERROR: message is required" >&2
  exit 2
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NOTIFY_ID="notify-$(date -u +%Y%m%d%H%M%S)-$RANDOM"
HEADLINE="${SUBJECT:-Agent Notification}"
ESCAPED_MSG=$(echo "$MESSAGE" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null || echo "$MESSAGE")

# --- Helper: send to slack ---
notify_slack() {
  local webhook_url="${SLACK_WEBHOOK_URL:-}"
  if [ -z "$webhook_url" ]; then
    echo "  [notify] Slack: SKIPPED (SLACK_WEBHOOK_URL not set)"
    return 0
  fi

  local channel="${NOTIFY_SLACK_CHANNEL:-#agent-alerts}"
  local color="good"
  [ "$URGENCY" = "high" ] && color="danger"
  [ "$URGENCY" = "medium" ] && color="warning"

  local payload
  payload=$(python3 -c "
import json
payload = {
    'channel': '$channel',
    'username': 'Agentic Workflows',
    'icon_emoji': ':robot_face:',
    'attachments': [{
        'color': '$color',
        'title': '${HEADLINE//\'/\\\'}',
        'text': ${ESCAPED_MSG},
        'footer': 'A2H Notification',
        'ts': $(date +%s),
        'fields': [
            {'title': 'Urgency', 'value': '$URGENCY', 'short': True},
            {'title': 'Timestamp', 'value': '$TIMESTAMP', 'short': True}
        ]
    }]
}
print(json.dumps(payload))
" 2>/dev/null || echo "")

  if [ -n "$payload" ]; then
    curl -sf -X POST -H "Content-type: application/json" \
      --data "$payload" "$webhook_url" 2>/dev/null && \
      echo "  [notify] Slack: sent to $channel" || \
      echo "  [notify] Slack: FAILED"
  fi
}

# --- Helper: output to CLI ---
notify_cli() {
  local prefix=""
  case "$URGENCY" in
    high)   prefix="🔴 [HIGH] " ;;
    medium) prefix="🟡 [MED]  " ;;
    low)    prefix="🟢 [LOW]  " ;;
  esac
  echo ""
  echo "=== ${prefix}${HEADLINE} ==="
  echo "$MESSAGE" | fold -s -w 72 | sed 's/^/  /'
  echo "=== End Notification ==="
  echo ""
}

# --- Helper: write to file ---
notify_file() {
  local file="$NOTIFY_DIR/$NOTIFY_ID.json"
  cat > "$file" <<EOF
{
  "id": "$NOTIFY_ID",
  "timestamp": "$TIMESTAMP",
  "urgency": "$URGENCY",
  "subject": $(echo "$SUBJECT" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null || echo "\"\""),
  "message": $ESCAPED_MSG
}
EOF
  echo "  [notify] File: wrote to $file"
}

# --- Dispatch ---

case "$CHANNEL" in
  slack)
    notify_slack
    ;;
  cli)
    notify_cli
    ;;
  file)
    notify_file
    ;;
  all|*)
    notify_slack
    notify_cli
    notify_file
    ;;
esac
