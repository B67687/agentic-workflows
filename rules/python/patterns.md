---
description: Python specific patterns, tooling, and idioms. Used alongside rules/common/.
globs: ["**/*.py"]
alwaysApply: false
---

# Python Patterns

## Type Annotations

- Use type hints for all function signatures — parameters, return types, and class attributes
- Use `Optional[X]` or `X | None` for nullable values (Python 3.10+)
- Use `TypedDict` for structured dictionaries, `dataclass` or `NamedTuple` for structured data
- Use `Protocol` for structural subtyping (duck typing with static checking)
- Run `mypy --strict` or `pyright` as a pre-commit check

## Code Style

- Follow PEP 8 — use `ruff` or `black` for formatting
- 4 spaces per indentation level. 88-100 max line length.
- `snake_case` for functions, variables, and modules
- `PascalCase` for classes
- `UPPER_CASE` for constants
- Use list/dict/set comprehensions over `map()`/`filter()` — more readable
- Use `pathlib` over `os.path` — object-oriented path handling

## Imports

- Order: standard library → third-party → local. Groups separated by blank line.
- Use absolute imports over relative imports — clearer and less brittle
- Prefer importing modules over individual names: `import os.path` not `from os.path import join`
- Use `from __future__ import annotations` at the top of every file (Python 3.7+)

## Testing

- **Framework:** pytest
- **Test files:** `tests/test_<module>.py`
- **Fixtures:** use pytest fixtures for setup/teardown — avoid `setUp`/`tearDown` methods
- **Parametrize:** use `@pytest.mark.parametrize` for testing multiple inputs
- **Coverage:** pytest-cov with 80%+ thresholds
- **Mocking:** use `unittest.mock` or `pytest-mock` — mock at system boundaries (network, database, filesystem)

## Async Patterns

- Use `asyncio` for I/O-bound concurrency — not threading or multiprocessing
- Use `anyio` or `asyncio` for async — avoid mixing different async libraries
- Use `httpx.AsyncClient` for async HTTP — not `requests` which is synchronous
- Use `async for` with async generators and streaming responses
- Handle cancellation with `asyncio.CancelledError` — don't suppress it

## Tooling

- **Format:** `ruff format` or `black`
- **Lint:** `ruff check` with the recommended config
- **Type-check:** `mypy --strict` or `pyright`
- **Test:** `pytest` with `pytest-cov` and `pytest-xdist` for parallelism
- **Dependencies:** `pip` or `uv` with `requirements.txt` or `pyproject.toml`
