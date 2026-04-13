# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.4.0] - 2026-04-13

- Added CONTRIBUTING.md with bilingual contributing guidelines.
- Added GitHub Actions CI workflow for automated validation.
- Added issue templates (bug report, feature request) and PR template.
- Improved `.gitignore` with broader editor and OS coverage.
- Improved `validate.sh` with `jq` dependency check and BOM-tolerant frontmatter detection.
- Added version metadata to handoff output for traceability.
- Added review-handoff linkage: handoff saves to `.codex-handoff/latest.md`, review reads it back.
- Expanded keywords in `plugin.json` for better discoverability.
- Updated READMEs with contributing and CI references.

## [1.3.0] - 2026-04-13

- Added bilingual review examples under `docs/examples/`.
- Added fixture coverage for review output structure.
- Extended repository validation to include review examples and review fixtures.

## [1.2.0] - 2026-04-13

- Added auditable `repo-analyst` output with explicit `Files inspected` and `Assumptions and unknowns`.
- Extended the handoff schema with `Do not touch` and `Ambiguities`.
- Upgraded the review skill to emit a fixed verdict: `APPROVE`, `MINOR_FIX`, or `REWORK`.
- Added fixture-based example evaluation under `eval/fixtures/` plus a local eval script.

## [1.1.0] - 2026-04-13

- Reworked both READMEs with a stronger front-page value proposition and a faster quickstart.
- Added concrete handoff examples for feature work and bug fixes under `docs/examples/`.
- Added an examples index to make it easier to understand what a good `CODEX_HANDOFF` looks like.

## [1.0.0] - 2026-04-13

- Promoted the plugin to a stable `1.0.0` release.
- Added a bilingual `/codex-handoff:review` skill for manual post-Codex review.
- Added English and Simplified Chinese workflow documentation.
- Added a validation script for local and CI-ready maintenance.
- Updated the agent and handoff skill descriptions for bilingual usage.

## [0.1.0] - 2026-04-13

- Initial public release.
- Added a read-only `repo-analyst` subagent for repository inspection.
- Added a manual `/codex-handoff:handoff` skill that produces a structured
  `CODEX_HANDOFF` brief for Codex.
- Added documentation for local testing and the recommended Claude-to-Codex workflow.
