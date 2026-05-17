#!/usr/bin/env bash
# gather-facts.sh — Execute research questions against the codebase
#
# Reads questions from workflow-state.json context.questions
# Searches the codebase for each question using existing tools.
# Outputs compressed findings as JSON to stdout.
#
# Usage: bash scripts/workflow/gather-facts.sh
# Output: JSON lines to stdout (agent captures and saves to context)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

STATE_FILE="$REPO_ROOT/workflow-state.json"
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"error":"workflow-state.json not found"}'
  exit 1
fi

# Extract questions from state
QUESTIONS=$(python3 -c "
import json,sys
with open('$STATE_FILE') as f:
    state = json.load(f)
questions = state.get('context', {}).get('questions', [])
if not questions:
    # Fallback: use the query directly
    query = state.get('context', {}).get('query', '')
    if query:
        questions = [query]
print(json.dumps(questions))
")

if [[ "$QUESTIONS" == "[]" || -z "$QUESTIONS" ]]; then
  echo '{"error":"no questions in context","hint":"formulate_questions step must populate context.questions"}'
  exit 0
fi

echo '{"status":"gathering","questions_count":'"$(echo "$QUESTIONS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")"'}'

# For each question, search the codebase
echo "$QUESTIONS" | python3 -c "
import json, sys, subprocess, os

questions = json.load(sys.stdin)
findings = []

repo_root = '$REPO_ROOT'

for i, q in enumerate(questions):
    # Extract key terms from question for search
    # Simple: use the question text directly with grep
    result = {
        'question': q,
        'searches': [],
        'files_found': [],
        'patterns': []
    }

    # Search for relevant files via grep -rl
    try:
        # Extract keywords (skip common words)
        words = [w for w in q.lower().split() if len(w) > 3 and w not in ('what','how','does','the','this','that','with','from','which','where','when','why','your','their','about','would','could','should','there','these')]
        for word in words[:5]:  # limit to 5 keywords
            r = subprocess.run(
                ['grep', '-rl', '--include=*.py', '--include=*.ts', '--include=*.sh', '--include=*.md', '-l', word, repo_root],
                capture_output=True, text=True, timeout=15
            )
            files = [f.replace(repo_root + '/', '') for f in r.stdout.strip().split('\n') if f]
            if files:
                result['searches'].append({'keyword': word, 'files': files[:10]})
                result['files_found'].extend(files[:10])
    except:
        pass

    findings.append(result)

print(json.dumps({'findings': findings, 'status': 'complete'}))
"
