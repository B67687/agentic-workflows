#!/usr/bin/env bash
# review-diff.sh — Collect changed files and their diffs
#
# Usage: bash scripts/workflow/review-diff.sh

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

CHANGED=$(git -C "$REPO_ROOT" diff --name-only HEAD 2>/dev/null || echo "")
UNTRACKED=$(git -C "$REPO_ROOT" ls-files --others --exclude-standard 2>/dev/null || echo "")
DIFF=$(git -C "$REPO_ROOT" diff HEAD 2>/dev/null || echo "")

cat <<EOF
{
  "changed_files": $(echo "$CHANGED" | python3 -c "import json,sys; files=[l.strip() for l in sys.stdin if l.strip()]; print(json.dumps(files))"),
  "untracked_files": $(echo "$UNTRACKED" | python3 -c "import json,sys; files=[l.strip() for l in sys.stdin if l.strip()]; print(json.dumps(files))"),
  "diff_length": ${#DIFF},
  "diff": $(echo "$DIFF" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()[:5000]))")
}
EOF
