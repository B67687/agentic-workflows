#!/usr/bin/env bash
# =============================================================================
# quality-gate.sh --- Pre-commit quality checks
# Runs before checkpoint-commit to catch common issues:
#   - console.log in staged code files
#   - Hardcoded secrets (API keys, tokens)
#   - TODO/FIXME markers in staged code files
#   - Large files staged for commit
#   - Unsourced external references in docs (see workflow/source-citation.md)
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILED=false

# ---- Repo root ----
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"

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
    print_issue "WARN" "$file" "Large diff (>500KB) --- consider splitting the commit"
  done
}

check_error_handling() {
  echo ":: Checking staged .sh files for error handling patterns..."
  local files
  files=$(check_staged -- '*.sh' 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    echo "   (no .sh files staged)"
    return
  fi

  while IFS= read -r file; do
    [[ -z "$file" ]] && continue

    # Check full file content from staged index (not just added lines)
    local staged
    staged=$(git show :"$file" 2>/dev/null || cat "$file" 2>/dev/null)

    local has_errexit=false has_nounset=false has_pipefail=false

    echo "$staged" | grep -qE '^\s*set\s+-[a-z]*e' && has_errexit=true
    echo "$staged" | grep -qE '^\s*set\s+-[a-z]*u' && has_nounset=true
    echo "$staged" | grep -qE 'pipefail' && has_pipefail=true

    local missing=()
    $has_errexit || missing+=("set -e")
    $has_nounset || missing+=("set -u")
    $has_pipefail || missing+=("pipefail")

    if [[ ${#missing[@]} -gt 0 ]]; then
      local joined
      joined=$(IFS=,; echo "${missing[*]}")
      if $has_errexit || $has_nounset || $has_pipefail; then
        print_issue "WARN" "$file" "Missing: $joined (expected: set -euo pipefail)"
      else
        print_issue "WARN" "$file" "Missing ALL error handling: $joined (consider adding set -euo pipefail)"
      fi
    fi
  done <<< "$files"
}

check_shellcheck() {
  if ! command -v shellcheck &>/dev/null; then
    return
  fi

  echo ":: Running shellcheck on staged .sh files..."
  local files
  files=$(check_staged -- '*.sh' 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    echo "   (no .sh files staged)"
    return
  fi

  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    # Only check if file still exists (not deleted)
    [[ ! -f "$file" ]] && continue

    local output
    output=$(shellcheck -f gcc "$file" 2>/dev/null || true)
    if [[ -n "$output" ]]; then
      local err_count
      err_count=$(grep -c 'error:' <<< "$output" 2>/dev/null || true)
      local warn_count
      warn_count=$(grep -c 'warning:' <<< "$output" 2>/dev/null || true)
      if [[ "$err_count" -gt 0 ]]; then
        print_issue "WARN" "$file" "shellcheck: $err_count error(s), $warn_count warning(s)"

        # Show errors inline for visibility
        echo "$output" | grep 'error:' | head -3 | while IFS= read -r line; do
          echo "         -> $line"
        done
      elif [[ "$warn_count" -gt 5 ]]; then
        print_issue "WARN" "$file" "shellcheck: $warn_count warnings (consider reviewing)"
      fi
    fi
  done <<< "$files"
}

check_source_citation() {
  echo ":: Checking staged docs for unsourced external references..."
  local files
  files=$(check_staged -- 'README.md' 'docs/*.md' 'workflow/*.md' 'commands/*.md' 'research/*.md' 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    echo "   (no doc files staged)"
    return
  fi

  local issues=0
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    local added_lines
    added_lines=$(git diff --cached -U0 "$file" 2>/dev/null | grep '^+' | sed 's/^+//' || true)
    [[ -z "$added_lines" ]] && continue

    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      # Skip if line already has a URL or Markdown link
      echo "$line" | grep -qE 'https?://' && continue
      echo "$line" | grep -qE '\]\(https?://' && continue
      # Skip code blocks and indented code
      echo "$line" | grep -qE '^```\|^    \|^\t' && continue

      # Find potential GitHub org/repo references (3+ chars / 3+ chars)
      local repo_refs
      repo_refs=$(echo "$line" | grep -oE '\b[a-zA-Z][a-zA-Z0-9_-]{2,}/[a-zA-Z][a-zA-Z0-9._-]{2,}\b' || true)
      if [[ -n "$repo_refs" ]]; then
        while IFS= read -r ref; do
          [[ -z "$ref" ]] && continue
          # Skip self-references
          echo "$ref" | grep -qE '^B67687/' && continue
          # Skip internal path prefixes (scripts/, skills/, docs/, etc.)
          echo "$ref" | grep -qE '^(scripts|skills|docs|research|commands|workflow)/' && continue
          # Skip file path patterns
          echo "$ref" | grep -qE '/\.' && continue
          # Skip if second part has a file extension (internal paths, not repos)
          echo "$ref" | grep -qE '/[a-zA-Z0-9._-]+\.[a-zA-Z]{1,4}$' && continue
          print_issue "WARN" "$file" "External reference '${ref}' without URL citation"
          issues=$((issues + 1))
        done <<< "$repo_refs"
      fi
    done <<< "$added_lines"
  done <<< "$files"

  if [[ "$issues" -gt 0 ]]; then
    echo "   See workflow/source-citation.md for citation requirements."
  fi
}

check_unaddressed_dissent() {
  local challenge_response
  challenge_response="$REPO_ROOT/.runtime/challenge-response.json"

  if [[ ! -f "$challenge_response" ]]; then
    return
  fi

  # Check if file has content (not empty /dev/null equivalent)
  local file_size
  file_size=$(stat -c%s "$challenge_response" 2>/dev/null || echo 0)
  if [[ "$file_size" -lt 10 ]]; then
    return
  fi

  echo ":: Checking for unaddressed plan dissent..."
  local py_script='
import json, sys

with open("'"$challenge_response"'") as f:
    try:
        resp = json.load(f)
    except json.JSONDecodeError:
        print("  WARN    challenge-response.json: malformed JSON, skipping")
        sys.exit(0)

findings = resp.get("findings", [])
if not findings:
    sys.exit(0)

blocking = []
significant = []
for f in findings:
    sev = f.get("severity", "significant")
    status = f.get("_status", f.get("status", "unaddressed"))
    title = f.get("title", "unknown")
    if status == "addressed":
        continue
    if sev == "blocking":
        blocking.append(title)
    else:
        significant.append(title)

for b in blocking:
    print(f"  ERROR   {b} (blocking, unaddressed)")

for s in significant:
    print(f"  WARN    {s} (significant, unaddressed)")

if blocking:
    sys.exit(1)
'

  if python3 -c "$py_script" 2>/dev/null; then
    : # clean exit (no unaddressed blocking findings)
  else
    FAILED=true
  fi
}

check_ascii() {
  echo ":: Checking for non-ASCII characters in staged text files..."
  local files
  files=$(check_staged -- '*.md' '*.sh' '*.py' '*.json' '*.yaml' '*.yml' '*.txt' '*.toml' 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    echo "   (no text files staged)"
    return
  fi

  local norm_script="$(dirname "$0")/../normalize-ascii.py"
  if [[ ! -f "$norm_script" ]]; then
    echo "   (normalize-ascii.py not found, skipping)"
    return
  fi

  # Check each staged file
  local has_issues=false
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    if python3 "$norm_script" check --file "$file" >/dev/null 2>&1; then
      : # clean
    else
      # Re-run to get visible output
      python3 "$norm_script" check --file "$file" 2>&1 | grep -v "OK:" | head -3
      has_issues=true
    fi
  done <<< "$files"

  if [[ "$has_issues" == true ]]; then
    print_issue "ERROR" "(staged files)" "Non-ASCII characters found. Run: python3 scripts/normalize-ascii.py fix"
  fi
}

check_pending_decisions() {
  local decision_log="$REPO_ROOT/.runtime/decision-log.jsonl"

  if [[ ! -f "$decision_log" ]]; then
    return
  fi

  echo ":: Checking for unresolved decisions..."
  local pending
  pending=$(grep -c 'PENDING_\|status.*pending\|confidence.*null' "$decision_log" 2>/dev/null || echo 0)

  if [[ "$pending" -gt 0 ]]; then
    print_issue "WARN" "(session)" "$pending decision(s) still pending or unscored"
    print_issue "WARN" "(session)" "  Review: bash scripts/decision.sh audit --failed"
    print_issue "WARN" "(session)" "  Resolve: bash scripts/decision.sh log <id> <selected> --confidence N"
  fi
}

check_comprehension_evidence() {
  local evidence_file="$REPO_ROOT/.runtime/comprehension-evidence.md"

  if [[ ! -f "$evidence_file" ]]; then
    # No evidence file: only warn if there's skill-load activity
    local audit_file="$REPO_ROOT/.runtime/skill-audit.jsonl"
    if [[ -f "$audit_file" ]] && [[ "$(wc -l < "$audit_file" 2>/dev/null || echo 0)" -gt 0 ]]; then
      print_issue "WARN" "(session)" "Skills loaded but no comprehension evidence found in .runtime/comprehension-evidence.md"
      print_issue "WARN" "(session)" "  Run: bash scripts/comprehension-gate.sh extract <skill-or-command>"
    fi
    return
  fi

  # Check for required markers and content via the comprehension-gate verify command
  local gate_script="$REPO_ROOT/scripts/comprehension-gate.sh"
  if [[ ! -f "$gate_script" ]]; then
    return
  fi

  echo ":: Checking comprehension evidence..."
  local verify_output
  verify_output=$(bash "$gate_script" verify "$evidence_file" 2>&1 || true)

  local verify_exit=$?
  if [[ "$verify_exit" -eq 1 ]]; then
    # FAIL
    print_issue "ERROR" ".runtime/comprehension-evidence.md" "Comprehension gate FAILED"
    echo "  $verify_output" | while IFS= read -r line; do echo "         $line"; done
  elif [[ "$verify_exit" -eq 2 ]]; then
    # WARN
    print_issue "WARN" ".runtime/comprehension-evidence.md" "Comprehension gate has warnings"
    echo "  $verify_output" | while IFS= read -r line; do echo "         $line"; done
  fi
  # exit 0: PASS, nothing to report
}

check_constitution_validity() {
  local constitution="$REPO_ROOT/constitution.md"
  local template="$REPO_ROOT/templates/core/constitution-template.md"

  if [[ ! -f "$constitution" ]]; then
    print_issue "WARN" "constitution.md" "Not found --- run: bash scripts/constitution.sh init"
    return
  fi

  echo ":: Checking constitution validity..."

  # Check version format
  local version
  version=$(grep '^version: ' "$constitution" | sed 's/version: "\(.*\)"/\1/' 2>/dev/null || echo "")
  if [[ -z "$version" ]]; then
    print_issue "WARN" "constitution.md" "Missing or invalid version in frontmatter"
  fi

  # Check article count
  local article_count
  article_count=$(grep -c '^## Article ' "$constitution" 2>/dev/null || echo 0)
  if [[ "$article_count" -eq 0 ]]; then
    print_issue "ERROR" "constitution.md" "No articles found --- constitution is empty"
  fi

  # Check template staleness
  if [[ -f "$template" ]] && [[ "$constitution" -ot "$template" ]]; then
    print_issue "WARN" "constitution.md" "Template is newer than constitution --- consider regenerating: bash scripts/constitution.sh init --force"
  fi

  # Check for ambiguity markers in staged md files
  echo ":: Checking for [NEEDS CLARIFICATION] markers in staged files..."
  local ambiguous_files
  ambiguous_files=$(check_staged -- '*.md' 2>/dev/null | xargs grep -l '\[NEEDS CLARIFICATION' 2>/dev/null || true)
  if [[ -n "$ambiguous_files" ]]; then
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      local count
      count=$(grep -c '\[NEEDS CLARIFICATION' "$f" 2>/dev/null || echo 0)
      if [[ "$count" -gt 0 ]]; then
        print_issue "WARN" "$f" "$count unresolved [NEEDS CLARIFICATION] marker(s)"
      fi
    done <<< "$ambiguous_files"
  fi
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
check_error_handling
check_shellcheck
check_source_citation
check_ascii
check_unaddressed_dissent
check_comprehension_evidence
check_pending_decisions
check_constitution_validity

echo ""
echo "=========================================="

if [[ "$FAILED" == true ]]; then
  echo -e "${RED}✗ Quality gate FAILED --- fix ERRORS before committing.${NC}"
  echo "  (WARN items are advisory, not blocking)"
  exit 1
else
  echo -e "${GREEN}✓ Quality gate PASSED${NC}"
  exit 0
fi
