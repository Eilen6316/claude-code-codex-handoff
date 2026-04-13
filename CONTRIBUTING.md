# Contributing to codex-handoff

[简体中文](./CONTRIBUTING.zh-CN.md)

Thank you for considering a contribution! This document covers the basics.

## Local setup

```bash
git clone https://github.com/Eilen6316/claude-code-codex-handoff.git
cd claude-code-codex-handoff
```

No build step is required. The plugin is a set of Markdown files and shell scripts.

## Validation

Before submitting a PR, run the full validation suite:

```bash
bash scripts/validate.sh
```

This checks:

- All required files exist
- `plugin.json` is valid JSON
- Agent and skill files have valid frontmatter
- Fixture-based example completeness
- Claude CLI validation (if `claude` is installed)

## Commit conventions

- Use short, imperative commit messages (e.g., "Add retry example", "Fix fixture path")
- One logical change per commit
- Keep PRs focused — avoid mixing unrelated changes

## Pull request process

1. Fork the repository and create a feature branch from `main`.
2. Make your changes and verify with `bash scripts/validate.sh`.
3. If you add a new example, add a matching fixture under `eval/fixtures/`.
4. If you add or change a skill section, update both the English and Chinese examples.
5. Open a PR against `main` with a clear description of what changed and why.

## Adding examples

Examples live under `docs/examples/`. Each example needs:

- An English version (`*.en.md`) and a Chinese version (`*.zh-CN.md`)
- A matching fixture in `eval/fixtures/` with `required_strings` covering all section headings
- An entry in `docs/examples/README.md`

## Reporting issues

- **Bug reports**: Describe what you expected, what happened, and steps to reproduce.
- **Feature requests**: Describe the use case and the desired behavior.

## Code of conduct

Be respectful, constructive, and focused on improving the project.

## License

By contributing, you agree that your contributions will be licensed under the MIT license.
