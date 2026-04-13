---
name: review
description: Review current changes after Codex implementation. 用于在 Codex 改完后，基于当前 diff 做二次审查。
argument-hint: "[scope or concern]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash
---
Review the current implementation changes with this focus: $ARGUMENTS

Workflow:
1. Inspect the current git state first with read-only commands.
2. Review the relevant diff, changed files, and any nearby code needed for context.
3. Do not edit files.
4. Prefer bug-finding, regression risks, missing tests, and incorrect assumptions over
   style commentary.
5. Match the user's language. If the user asked in Chinese, answer in Chinese.

Output exactly these top-level sections:

# Verdict

# Summary

# Findings

# Regression risks

# Missing tests

# Next step

Rules:
- If there are no findings, say so explicitly under `# Findings`.
- Refer to file paths and symbols precisely.
- Keep the review focused on real impact, not cosmetic preferences.
- `# Verdict` must be exactly one of: `APPROVE`, `MINOR_FIX`, `REWORK`.
- `# Next step` must map cleanly to the verdict:
  `APPROVE` -> ship or merge,
  `MINOR_FIX` -> small follow-up changes,
  `REWORK` -> implementation should be revised before approval.
- When possible, tie findings back to an acceptance criterion, constraint, or review
  focus item from the original handoff.
