---
description: Mandatory security checks before every commit — secrets, input validation, injection prevention, dependency auditing.
globs: []
alwaysApply: true
---

# Security

## Pre-Commit Checklist

Before every commit, verify:

### 1. No Hardcoded Secrets
- [ ] No API keys, tokens, passwords, or connection strings in code
- [ ] No private keys, certificates, or credential files
- [ ] No secrets in comments, log statements, or debug output
- [ ] No secrets in test fixtures or mock data (use placeholder values)

**If you find a committed secret:** Rotate it immediately. Remove it from git history.

### 2. Input Validation
- [ ] All user input validated at system boundaries (API, form, file upload)
- [ ] Schema-based validation (Zod, Joi, Pydantic, or equivalent)
- [ ] File uploads restricted by type, size, and content verification
- [ ] URL redirects validated against an allowlist

### 3. Injection Prevention
- [ ] All database queries parameterized (use ORM or prepared statements)
- [ ] HTML output encoded for context (HTML entity, URL, JS unicode)
- [ ] No eval(), no dynamic require() with user input
- [ ] Shell commands use parameterized execution, not string interpolation

### 4. Data Protection
- [ ] Sensitive fields excluded from API responses and logs
- [ ] PII handled according to applicable regulations
- [ ] CORS restricted to specific origins
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)

### 5. Dependencies
- [ ] No dependencies with known CVEs (run `npm audit`, `pip audit`, or equivalent)
- [ ] Third-party scripts loaded from trusted CDNs with integrity hashes

## Vulnerability Severity

| Severity | Action |
|----------|--------|
| **Critical** | Fix immediately, block release. Remote exploit, data breach, full compromise. |
| **High** | Fix before release. Exploitable with conditions. |
| **Medium** | Fix in current sprint. Limited impact or requires auth. |
| **Low** | Schedule for next sprint. Defense-in-depth improvement. |

## Rules

1. Never suggest disabling security controls as a "fix"
2. Never hardcode secrets — use environment variables or a secret manager
3. Validate required secrets at startup — fail fast with a clear message
4. Rotate exposed secrets immediately — then review the codebase for similar issues
5. Apply least privilege — application users get minimum needed permissions
