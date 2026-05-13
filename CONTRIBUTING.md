# Contributing

Thanks for your interest in contributing to the agentic-workflows harness.

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE).

## How to Contribute

1. **Open an issue** first for bugs, feature requests, or design discussions.
2. **Fork** the repo and create a branch from `main`.
3. **Make your changes** following the conventions in [AGENTS.md](AGENTS.md) and
   [rules/](rules/).
4. **Test** your changes:
   ```bash
   bash ./scripts/test-smoke.sh
   bash ./scripts/tools.sh
   ```
5. **Submit a pull request** with a clear description of what changed and why.

## Guidelines

- Keep contributions focused and scoped. One PR = one concern.
- Avoid adding personal voice profiles, writing samples, or other identity-specific
  content — this is a general-purpose harness.
- If you're adding a new skill, follow the pattern in `skills/<name>/SKILL.md`
  with its companion script in `skills/<name>/scripts/`.
- All scripts should be POSIX-compatible (bash) unless the repo explicitly
  requires another shell.

## Code of Conduct

Be respectful and constructive. This is a systems engineering workspace —
disagreements should be about design, not people.
