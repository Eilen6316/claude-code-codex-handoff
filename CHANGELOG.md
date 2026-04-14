# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.3.0] - 2026-04-14

### Changed
- Handoff skill no longer enforces a fixed output format. Instead of 12 mandatory
  section headings, the skill specifies required information elements and lets the
  model organize them naturally. Only `# CODEX_HANDOFF` remains as a required
  heading (machine-readable boundary for downstream tools).
- Review skill similarly relaxed: verdict rules preserved, section structure flexible.
- Handoff skill restructured into 5 sequential phases for internal clarity.
- "Do not edit files" replaced with "Do not modify the target repository's source
  code" in both skills.

### Fixed
- Version metadata comment no longer hardcodes a plugin version. Uses
  `<!-- codex-handoff | YYYY-MM-DD -->` without a version number.
- plugin.json and marketplace.json version consistency now validated.
- README argument hints now show all execution flags.

### Added
- Pipeline contract validation in validate.sh: cross-skill references, file linkage,
  Skill tool permission check, version drift regression, flag completeness.

## [1.2.0] - 2026-04-13

### Added
- Codex execution flags: `--background`, `--model <model>`, `--effort <level>` are
  now passed through from handoff to `/codex:rescue`.
- Run history: handoff and review outputs are saved to
  `.codex-handoff/history/YYYY-MM-DD-HHMMSS-{handoff,review}.md` for traceability.

### Fixed
- Unified output contract: all examples, fixtures, and workflow guides now match the
  SKILL.md `#` (h1) section format. Fixed 17 inconsistencies across 16 files.

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
