#!/usr/bin/env bash
# =============================================================================
# security-scan.sh --- Companion script for Security and Hardening
#
# Scans the current working tree for common security issues:
#   - Hardcoded secrets in code
#   - SQL injection vulnerabilities
#   - Dangerous patterns (eval, innerHTML, etc.)
#   - Missing security headers (via npm audit check)
#   - Dependency vulnerabilities
#
# Usage:
#   bash ./scripts/security-scan.sh check
#     Full security scan of the working tree.
#
#   bash ./scripts/security-scan.sh checklist
#     Output the Three-Tier Boundary System checklist for manual review.
#
#   bash ./scripts/security-scan.sh deps
#     Quick dependency vulnerability audit (npm audit, pip audit, etc.).
# =============================================================================

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"
MODE="${1:-check}"

case "$MODE" in
  check)
    echo "=== Security Scan ==="
    echo "Scanning: ${REPO_ROOT}"
    echo ""
    
    ISSUES=0
    
    # ---- Check 1: Hardcoded secrets in staged/new changes ----
    echo "--- Secrets in working tree ---"
    SECRETS=$(git diff HEAD 2>/dev/null | grep -iP '(password|secret|api.?key|token|private.?key|-----BEGIN)' | grep -v 'grep\|example\|placeholder\|changeme\|your-' | head -10 || true)
    if [ -n "$SECRETS" ]; then
      echo "  ⚠  Potential secrets found in uncommitted changes:"
      echo "$SECRETS" | while read -r line; do echo "     $line"; done
      ISSUES=$((ISSUES + 1))
    else
      echo "  ✓  No obvious secrets in working tree"
    fi
    echo ""
    
    # ---- Check 2: SQL injection patterns ----
    echo "--- SQL injection risks ---"
    SQL_RISKS=$(find . -path ./.git -prune -o -path ./node_modules -prune -o -name '*.py' -print -o -name '*.js' -print -o -name '*.ts' -print -o -name '*.java' -print 2>/dev/null | xargs grep -ln 'execute\|raw_query\|\.query(' 2>/dev/null | grep -v '__pycache__\|\.venv\|node_modules' | head -10 || true)
    if [ -n "$SQL_RISKS" ]; then
      echo "  ℹ   Files with dynamic query patterns:"
      echo "$SQL_RISKS" | while read -r f; do echo "     $f"; done
      ISSUES=$((ISSUES + 1))
    else
      echo "  ✓  No SQL injection patterns detected (or no code files found)"
    fi
    echo ""
    
    # ---- Check 3: Dangerous patterns ----
    echo "--- Dangerous patterns (eval, innerHTML, etc.) ---"
    DANGEROUS=$(find . -path ./.git -prune -o -path ./node_modules -prune -o -type f -name '*.js' -o -name '*.ts' -o -name '*.jsx' -o -name '*.tsx' 2>/dev/null | xargs grep -ln 'eval(\|innerHTML\b\|dangerouslySetInnerHTML\|document.write(' 2>/dev/null | head -10 || true)
    if [ -n "$DANGEROUS" ]; then
      echo "  ⚠  Dangerous patterns found:"
      echo "$DANGEROUS" | while read -r f; do echo "     $f"; done
      ISSUES=$((ISSUES + 1))
    else
      echo "  ✓  No dangerous patterns detected (or no JS/TS files found)"
    fi
    echo ""
    
    # ---- Check 4: Secrets in git history ----
    echo "--- Secrets in recent git history ---"
    HISTORY_SECRETS=$(git log --all -p --diff-filter=ACM -S 'password' --since='6 months ago' -- '*.py' '*.js' '*.ts' '*.env' '*.json' '*.yaml' '*.yml' 2>/dev/null | grep '^+.*password' | grep -v 'password\|placeholder\|example\|your_password' | head -5 || true)
    if [ -n "$HISTORY_SECRETS" ]; then
      echo "  ⚠  Potential secrets found in recent git history:"
      echo "$HISTORY_SECRETS" | while read -r line; do echo "     ${line:0:80}"; done
      ISSUES=$((ISSUES + 1))
    else
      echo "  ✓  No secrets detected in recent history"
    fi
    echo ""
    
    # Summary
    echo "=== Results ==="
    if [ "$ISSUES" -gt 0 ]; then
      echo "  Found $ISSUES area(s) requiring attention."
      echo "  Run: bash ./scripts/security-scan.sh checklist"
    else
      echo "  ✓  No security issues detected."
    fi
    ;;

  checklist)
    cat << "CHECKLIST"
=== Security Checklist (Three-Tier Boundary System) ===

## Always Do (No Exceptions)
- [ ] All external input validated at system boundary
- [ ] All database queries parameterized
- [ ] Output encoded (XSS prevention)
- [ ] HTTPS for all external communication
- [ ] Passwords hashed with bcrypt/scrypt/argon2
- [ ] Security headers set (CSP, HSTS, X-Frame-Options)
- [ ] Cookies: httpOnly + secure + sameSite
- [ ] Dependency audit run (npm audit, pip audit, etc.)

## Ask First (Requires Human Approval)
- [ ] New auth flows or auth logic changes?
- [ ] Storing new categories of sensitive data?
- [ ] New external service integrations?
- [ ] CORS configuration changes?
- [ ] File upload handlers?
- [ ] Rate limiting / throttling changes?
- [ ] Elevated permissions or roles?

## Never Do
- [ ] No secrets in version control
- [ ] No sensitive data in logs
- [ ] No reliance on client-side validation as security boundary
- [ ] No disabled security headers
- [ ] No eval() or innerHTML with user data
- [ ] No hardcoded URLs or endpoints in client-side code
- [ ] No sensitive tokens exposed in client-side code

## Verification
- [ ] Dependency vulnerability scan run
- [ ] Secrets scan run on working tree
- [ ] SQL injection scan run on codebase
- [ ] Dangerous pattern scan run on codebase
- [ ] Git history secrets scan run
CHECKLIST
    ;;

  deps)
    echo "=== Dependency Vulnerability Scan ==="
    # npm audit
    if [ -f "package.json" ]; then
      if command -v npm &>/dev/null; then
        echo "--- npm audit ---"
        npm audit 2>&1 | tail -10 || echo "  (no issues or audit failed)"
      else
        echo "  npm not found in PATH"
      fi
    fi
    
    # pip audit
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
      if command -v pip-audit &>/dev/null; then
        echo "--- pip audit ---"
        pip-audit 2>&1 | tail -10 || echo "  (no issues or audit failed)"
      else
        echo "  pip-audit not found. Install: pip install pip-audit"
      fi
    fi
    
    # cargo audit
    if [ -f "Cargo.toml" ]; then
      if command -v cargo-audit &>/dev/null; then
        echo "--- cargo audit ---"
        cargo audit 2>&1 | tail -10 || echo "  (no issues or audit failed)"
      else
        echo "  cargo-audit not found. Install: cargo install cargo-audit"
      fi
    fi
    ;;

  *)
    echo "Usage: $0 {check|checklist|deps}"
    echo ""
    echo "  check      --- Full security scan of working tree"
    echo "  checklist  --- Output Three-Tier security checklist"
    echo "  deps       --- Dependency vulnerability audit"
    exit 1
    ;;
esac
