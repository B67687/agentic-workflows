#!/usr/bin/env bash
# Blocks destructive shell commands to prevent accidental data loss
# Reads JSON from stdin (Claude Code hook protocol), checks for dangerous patterns
set -euo pipefail

# Read the JSON input from Claude Code
INPUT=$(cat)

# Extract the command being executed
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Check for dangerous patterns
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "rm -rf \${HOME}"
  "> /dev/"
  ":(){ :|:& };:"
  "dd if=/dev/zero"
  "mkfs"
  "chmod -R 000 /"
  "mv / /dev/null"
  "wget.*|bash"
  "curl.*|bash"
  "git push --force"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    # Return a JSON decision to Claude Code to block the command
    cat <<JSONEOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked potentially dangerous command: matches pattern '$pattern'"
  }
}
JSONEOF
    exit 0
  fi
done

# Allow safe commands
exit 0
