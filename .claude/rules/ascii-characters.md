---
description: Always use ASCII characters, never Unicode lookalikes.
paths:
  - "**/*.md"
  - "**/*.sh"
  - "**/*.py"
---

# ASCII Character Rule

## Why

The Edit tool matches raw bytes. These character pairs look identical but are different bytes:

| Rendered | Unicode codepoint (bad) | ASCII (good) |
|----------|------------------------|--------------|
| `->`     | U+2192                 | `->` |
| `--`     | U+2013 (en-dash)       | `--` |
| `---`    | U+2014 (em-dash)       | `---` |
| `...`    | U+2026 (ellipsis)      | `...` |
| `*`      | U+2022 (bullet)        | `*` |
| `"`      | U+201C/D (curly quotes)| `"` |
| `'`      | U+2018/9 (smart quotes)| `'` |

## How to fix

Before committing, run:
```
python3 scripts/normalize-ascii.py fix
```

The pre-commit quality gate will block commits with problematic characters.

## Exception

Real Unicode content (CJK, math symbols, emoji) is fine. Only normalize characters that have ASCII equivalents.
