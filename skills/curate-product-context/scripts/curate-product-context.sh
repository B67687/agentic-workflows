#!/usr/bin/env bash
# Product context curator. Generates .tap/product.md skeleton.
# Usage: bash ./scripts/curate-product-context.sh init "<product>"
set -euo pipefail
case "${1:-init}" in
  init)
    cat << TAP
# Product Context: $2
_Generated $(date -u +%Y-%m-%d)_

## What We Build
<one sentence>

## Audience
<who uses it>

## Current Focus
<what we're working on now>

## Active Bets
- <bet 1>
- <bet 2>

## Non-Goals
- <explicitly out of scope>
TAP
    ;;
  *) echo "Usage: $0 init \"<product>\"" >&2; exit 1 ;;
esac
