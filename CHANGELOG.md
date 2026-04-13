# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.1.0] - 2026-04-13

### Added
- Automatic Codex execution: `/codex-handoff:handoff` now automatically passes the
  generated `CODEX_HANDOFF` to `/codex:rescue` for implementation, then triggers
  `/codex-handoff:review` for post-implementation review.
- `--no-exec` flag for handoff skill to generate handoff only without invoking Codex.
- `marketplace.json` for installation via `/plugin marketplace add`.

### Changed
- Workflow is now fully automated: one command completes analysis, implementation, and review.

## [1.0.0] - 2026-04-13

- Initial public release.
- Read-only `repo-analyst` subagent for repository inspection and analysis.
- `/codex-handoff:handoff` skill that produces a structured `CODEX_HANDOFF` brief.
- `/codex-handoff:review` skill for post-implementation review with fixed verdicts:
  `APPROVE`, `MINOR_FIX`, or `REWORK`.
- Review-handoff linkage: handoff saves to `.codex-handoff/latest.md`, review reads it back.
- Bilingual support (English and Simplified Chinese) for all documentation.
- Fixture-based evaluation under `eval/fixtures/`.
- Validation script for local and CI-ready maintenance.
- GitHub Actions CI workflow, issue templates, and PR template.
