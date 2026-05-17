#!/usr/bin/env bash
# diagnose.sh — Search codebase for bug root cause
#
# Reads error description from workflow-state.json context.
# Searches for error messages, relevant files, and call paths.
#
# Usage: bash scripts/workflow/diagnose.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STATE_FILE="$REPO_ROOT/workflow-state.json"

# Get error description from state
ERROR_DESC=""
if [[ -f "$STATE_FILE" ]]; then
  ERROR_DESC=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
ctx = s.get('context', {})
print(ctx.get('error_description', ctx.get('query', '')))
")
fi

if [[ -z "$ERROR_DESC" ]]; then
  echo '{"error":"no error description in context","hint":"reproduce step must populate context.error_description"}'
  exit 0
fi

echo '{'
echo '  "searching_for": '$(echo "$ERROR_DESC" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))")','

# Use a temp Python script to avoid heredoc issues
TMP_SCRIPT=$(mktemp /tmp/diagnose-XXXXXX.py)
cat >"$TMP_SCRIPT" <<'PYEOF'
import json, subprocess, os, re, sys

repo = sys.argv[1]
desc = sys.argv[2]
terms = re.findall(r'\b[A-Za-z][A-Za-z0-9_-]{2,}\b', desc)
stopwords = {'the','and','for','with','that','this','from','have','been','was','not','but','are','all','has','had','can','its','than','what','when','where','how','get','got'}
terms = [t for t in terms if t.lower() not in stopwords]

results = {}
for term in terms[:8]:
    try:
        r = subprocess.run(
            ['grep', '-rl', '--include=*.py', '--include=*.ts', '--include=*.sh', '-l', term, repo],
            capture_output=True, text=True, timeout=10
        )
        files = [f.replace(repo + '/', '') for f in r.stdout.strip().split('\n') if f and 'node_modules' not in f]
        if files:
            results[term] = files[:8]
    except subprocess.TimeoutExpired:
        pass
    except Exception:
        pass

print(json.dumps({'keyword_matches': results, 'terms_searched': len(terms)}, indent=2))
PYEOF

python3 "$TMP_SCRIPT" "$REPO_ROOT" "$ERROR_DESC"
rm -f "$TMP_SCRIPT"

echo '}'
