#!/usr/bin/env bash
# =============================================================================
# source-verify.sh — Companion script for Source-Driven Development
#
# Detects project dependencies, extracts versions, and generates a structured
# source verification prompt for verifying patterns against official docs.
#
# Usage:
#   bash ./scripts/source-verify.sh detect
#     Detect project stack and versions from dependency files.
#
#   bash ./scripts/source-verify.sh prompt <pattern> <source-url>
#     Generate a source-driven verification prompt.
#     Example: bash ./scripts/source-verify.sh prompt "React Router v7 loader" \
#       "https://reactrouter.com/en/main/route/loader"
#
#   bash ./scripts/source-verify.sh check
#     Quick check: list all dependency files found with versions.
# =============================================================================

set -euo pipefail

MODE="${1:-check}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "$MODE" in
  detect|check)
    echo "=== Source Detection ==="
    echo ""
    
    FOUND=0
    
    # package.json
    if [ -f "package.json" ]; then
      FOUND=$((FOUND + 1))
      echo "[package.json]"
      python3 -c "
import json
with open('package.json') as f:
    d = json.load(f)
deps = {**d.get('dependencies', {}), **d.get('devDependencies', {})}
for name in ['react','react-dom','next','vue','nuxt','svelte','angular','express','fastify','prisma','drizzle','tailwindcss','typescript','vite']:
    if name in deps:
        print(f'  {name}: {deps[name]}')
print(f'  Total deps: {len(deps)}')
" 2>/dev/null || echo "  (could not parse)"
      echo ""
    fi
    
    # requirements.txt / pyproject.toml
    if [ -f "requirements.txt" ]; then
      FOUND=$((FOUND + 1))
      echo "[requirements.txt]"
      grep -iE '^(django|flask|fastapi|sqlalchemy|pydantic|httpx|requests|pytest)' requirements.txt | head -10 || echo "  (no major frameworks detected)"
      echo ""
    fi
    if [ -f "pyproject.toml" ]; then
      FOUND=$((FOUND + 1))
      echo "[pyproject.toml]"
      python3 -c "
try:
    import tomllib
    with open('pyproject.toml', 'rb') as f:
        d = tomllib.load(f)
    deps = d.get('project', {}).get('dependencies', [])
    for dep in deps:
        print(f'  {dep}')
except:
    print('  (could not parse — need Python 3.11+ or tomli)')
" 2>/dev/null || echo "  (could not parse)"
      echo ""
    fi
    
    # go.mod
    if [ -f "go.mod" ]; then
      FOUND=$((FOUND + 1))
      echo "[go.mod]"
      head -5 go.mod
      echo ""
    fi
    
    # Cargo.toml
    if [ -f "Cargo.toml" ]; then
      FOUND=$((FOUND + 1))
      echo "[Cargo.toml]"
      grep -E '^[a-z]' Cargo.toml | head -10
      echo ""
    fi
    
    # Gemfile
    if [ -f "Gemfile" ]; then
      FOUND=$((FOUND + 1))
      echo "[Gemfile]"
      grep -E '^(gem|source)' Gemfile | head -10
      echo ""
    fi
    
    # composer.json
    if [ -f "composer.json" ]; then
      FOUND=$((FOUND + 1))
      echo "[composer.json]"
      python3 -c "
import json
with open('composer.json') as f:
    d = json.load(f)
deps = {**d.get('require', {}), **d.get('require-dev', {})}
for name, ver in list(deps.items())[:10]:
    print(f'  {name}: {ver}')
" 2>/dev/null || echo "  (could not parse)"
      echo ""
    fi

    if [ "$FOUND" -eq 0 ]; then
      echo "  No dependency files found in current directory."
    else
      echo "  Found $FOUND dependency file(s)."
    fi
    ;;

  prompt)
    PATTERN="${2:-}"
    SOURCE_URL="${3:-}"
    
    if [ -z "$PATTERN" ] || [ -z "$SOURCE_URL" ]; then
      echo "Usage: $0 prompt \"<pattern>\" \"<source-url>\"" >&2
      exit 1
    fi
    
    # Detect stack for context
    STACK_INFO=$(python3 -c "
import json
try:
    with open('package.json') as f:
        d = json.load(f)
    deps = {**d.get('dependencies', {}), **d.get('devDependencies', {})}
    for k in ['react','vue','next','nuxt','express','fastify','django','flask']:
        if k in deps:
            print(f'{k} {deps[k]}')
except: pass
" 2>/dev/null || echo "")
    
    cat << PROMPT
# Source Verification Request

## Pattern
${PATTERN}

## Source
${SOURCE_URL}

## Stack Context
${STACK_INFO:-$(echo "  (no dependency file detected — specify manually)")}

## Verification Checklist
- [ ] Is this the official source? (check domain, docs.github.com/docs.gitlab.com etc)
  NOT: medium.com, dev.to, random blog posts
- [ ] Does the source match the project's installed version?
  (version from dependency file vs version in docs)
- [ ] Is the pattern documented as current/recommended or deprecated?
  (check for migration guides, changelogs)
- [ ] Are there warnings about breaking changes?
- [ ] Does the code I'm implementing follow the source exactly?
  (cite specific lines, not general concepts)

## Result
<!-- After verification, fill this in -->
- Verified against: <source>
- Source version: <version>
- Status: [ ] Current — pattern matches latest docs
         [ ] Deprecated — find updated source
         [ ] Version mismatch — adjust to match project version
PROMPT
    ;;

  *)
    echo "Usage: $0 {detect|prompt|check}"
    echo ""
    echo "  detect          — Scan project for dependency files and versions"
    echo "  prompt <p> <u>  — Generate source verification prompt"
    echo "  check           — Quick dependency file listing"
    exit 1
    ;;
esac
