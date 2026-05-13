# Security Review Checklist

## OWASP Top 10 Prevention

**Broken Access Control:**
- [ ] Server-side authorization checks (client-side only is insufficient)
- [ ] Role/permission boundaries defined and enforced at API layer
- [ ] Object-level access control (users can't access other users' data via ID manipulation)
- [ ] API endpoints require authentication unless explicitly public

**Cryptographic Failures:**
- [ ] Secrets/API keys stored in environment variables, secrets manager, or encrypted vaults
- [ ] Data in transit: TLS/HTTPS enforced across all endpoints
- [ ] Sensitive data (PII, credentials, tokens) never logged or exposed in error responses
- [ ] Passwords hashed with bcrypt/argon2 (never plain text, never MD5/SHA1)

**Injection:**
- [ ] SQL queries use parameterized statements or ORM query builders (no string concatenation)
- [ ] Shell commands use libraries with injection protection (no `os.system` with user input)
- [ ] Template engines have auto-escaping enabled for HTML output (no `|safe` without explicit sanitization)

**Insecure Design:**
- [ ] Rate limiting on auth endpoints (login, registration, password reset, MFA)
- [ ] Rate limiting on public API endpoints
- [ ] Input size limits on form fields, file uploads, and request bodies
- [ ] Graceful handling of unexpected input types and malformed payloads

**Security Misconfiguration:**
- [ ] Debug mode, development endpoints, and admin consoles disabled in production
- [ ] CORS is restricted to known origins (not `Access-Control-Allow-Origin: *` with credentials)
- [ ] All endpoints enforce HTTPS (no HTTP fallback for secure content)
- [ ] Default credentials changed, unused default pages/endpoints removed

**Vulnerable and Outdated Components:**
- [ ] Dependency audit: `npm audit` / `pip audit` / `cargo deny check` run and clean
- [ ] Known vulnerabilities in dependencies addressed (no suppress without review)
- [ ] Base images, language runtimes, and OS packages updated for security patches
- [ ] Direct dependencies preferred over transitive (audit the full tree)

**Identification and Authentication Failures:**
- [ ] Multi-factor authentication available (required for admin roles)
- [ ] Session tokens: httpOnly + secure + SameSite flags on cookies
- [ ] Session timeout configured (idle timeout + absolute timeout for high-risk actions)
- [ ] No hardcoded credentials in configuration files, documentation, or code

**Software and Data Integrity Failures:**
- [ ] Dependencies pinned to specific versions (no version ranges like `^1.2.3` in production)
- [ ] Package lockfiles committed and reviewed (lockfile contains the resolved dependency tree)
- [ ] CI/CD pipeline uses checksum/signature verification for downloaded artifacts
- [ ] Subresource integrity (SRI) hashes applied to externally loaded scripts and stylesheets

**Security Logging and Monitoring Failures:**
- [ ] Auth events logged (logins, logouts, failed attempts, password changes)
- [ ] Admin/sensitive operations logged with user, timestamp, and action summary
- [ ] Log injection prevented (strip newlines and control characters from log inputs)
- [ ] Alerts configured for repeated auth failures and access denied patterns

**Server-Side Request Forgery (SSRF):**
- [ ] URLs fetched from user input validated against an allowlist
- [ ] Internal network addresses blocked from outbound requests
- [ ] Metadata endpoints (169.254.x.x, 10.x.x.x, 172.16-31.x.x, 192.168.x.x) blocked

## Boundary Enforcement

- [ ] All external boundaries have validation (user input → API, API → service, service → database)
- [ ] Authorization checked at every network boundary, not just the entry point
- [ ] Data flow validated at each system boundary (APIs, config files, logs, external sources)
- [ ] All data from external sources treated as untrusted until validated
