#!/usr/bin/env bash
# =============================================================================
# quality-gate.sh — Pre-commit quality checks
# Runs before checkpoint-commit to catch common issues:
#   - console.log in staged code files
#   - Hardcoded secrets (API keys, tokens)
#   - TODO/FIXME markers in staged code files
#   - Large files staged for commit
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILED=false

# ---- Utility ----
check_staged() {
  git diff --cached --name-only --diff-filter=ACMR "$@"
}

print_issue() {
  local severity="$1" file="$2" detail="$3"
  if [[ "$severity" == "ERROR" ]]; then
    echo -e "  ${RED}ERROR${NC}   ${file}: ${detail}"
    FAILED=true
  else
    echo -e "  ${YELLOW}WARN${NC}    ${file}: ${detail}"
  fi
}

# ---- Checks ----

check_console_log() {
  echo ":: Checking for console.log in staged code files..."
  local files
  files=$(check_staged -- '*.ts' '*.tsx' '*.js' '*.jsx' '*.mjs' '*.py' 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    echo "   (no code files staged)"
    return
  fi
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    if git diff --cached -U0 "$file" 2>/dev/null | grep '^+.*console\.\(log\|debug\|warn\|error\)' | grep -v '//.*console\.' >/dev/null 2>&1; then
      print_issue "WARN" "$file" "Contains console.log (staged)"
    fi
  done <<< "$files"
}

check_secrets() {
  echo ":: Checking for hardcoded secrets in staged files..."
  local files
  files=$(check_staged 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    echo "   (no files staged)"
    return
  fi

  # API key patterns
  local secrets_patterns=(
    'sk-[A-Za-z0-9]{20,}'           # OpenAI keys
    'ghp_[A-Za-z0-9]{36}'            # GitHub PAT
    'gho_[A-Za-z0-9]{36}'            # GitHub OAuth
    'AKIA[0-9A-Z]{16}'               # AWS access key
    '-----BEGIN (RSA |EC )?PRIVATE KEY-----'
    'password\s*[:=]\s*["'"'"'][^"'"'"']+["'"'"']'
    'secret\s*[:=]\s*["'"'"'][^"'"'"']+["'"'"']'
  )

  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    # Only check staged content
    local staged_content
    staged_content=$(git diff --cached "$file" 2>/dev/null | grep '^+' | sed 's/^+//' || true)
    [[ -z "$staged_content" ]] && continue

    for pattern in "${secrets_patterns[@]}"; do
      if echo "$staged_content" | grep -E "$pattern" >/dev/null 2>&1; then
        # Exclude test files and .env.example
        if [[ "$file" == *.test.* || "$file" == *.spec.* || "$file" == *.example* ]]; then
          continue
        fi
        print_issue "ERROR" "$file" "Potential secret/API key detected in staged changes"
        break
      fi
    done
  done <<< "$files"
}

check_todo_fixme() {
  echo ":: Checking for TODO/FIXME markers in staged code files..."
  local files
  files=$(check_staged -- '*.ts' '*.tsx' '*.js' '*.jsx' '*.mjs' '*.py' '*.go' '*.rs' '*.java' 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    return
  fi
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    if git diff --cached -U0 "$file" 2>/dev/null | grep '^+.*\b\(TODO\|FIXME\|HACK\|XXX\)\b' | grep -v '//.*TODO' | grep -v '#.*TODO' >/dev/null 2>&1; then
      print_issue "WARN" "$file" "Contains TODO/FIXME marker (staged)"
    fi
  done <<< "$files"
}

check_large_files() {
  echo ":: Checking for large staged files..."
  local large_files=()
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    local size
    size=$(git diff --cached -- "$file" 2>/dev/null | wc -c || echo 0)
    if [[ "$size" -gt 500000 ]]; then
      large_files+=("$file")
    fi
  done < <(check_staged 2>/dev/null || true)

  for file in "${large_files[@]}"; do
    print_issue "WARN" "$file" "Large diff (>500KB) — consider splitting the commit"
  done
}

# ---- Main ----

echo "=========================================="
echo "  Quality Gate"
echo "=========================================="
echo ""

check_console_log
check_secrets
check_todo_fixme
check_large_files

echo ""
echo "=========================================="

if [[ "$FAILED" == true ]]; then
  echo -e "${RED}✗ Quality gate FAILED — fix ERRORS before committing.${NC}"
  echo "  (WARN items are advisory, not blocking)"
  exit 1
else
  echo -e "${GREEN}✓ Quality gate PASSED${NC}"
  exit 0
fi
