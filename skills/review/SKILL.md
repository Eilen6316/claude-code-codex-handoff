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

# Summary

# Findings

# Regression risks

# Missing tests

# Recommendation

Rules:
- If there are no findings, say so explicitly under `# Findings`.
- Refer to file paths and symbols precisely.
- Keep the review focused on real impact, not cosmetic preferences.
