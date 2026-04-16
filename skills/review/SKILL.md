---
name: review
description: Review current changes after Codex implementation. 用于在 Codex 改完后，基于当前 diff 做二次审查。
argument-hint: "[scope or concern]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash
---
Review the current implementation changes with this focus: $ARGUMENTS

Workflow:
1. Check if `.codex-handoff/latest.md` exists. If it does, read it and use whatever
   context is available (acceptance criteria, constraints, scope boundaries, review
   focus, etc.) as a cross-reference when evaluating the implementation.
2. Inspect the current git state with read-only commands.
3. Review the relevant diff, changed files, and nearby code for context.
4. Do not modify the target repository's source code.
5. Prioritize bug-finding, regression risks, missing tests, and incorrect assumptions
   over style commentary.
6. Match the user's language.

The review must provide:
- A verdict: exactly one of `APPROVE`, `MINOR_FIX`, or `REWORK`
- A concise summary of what was implemented and how well it matches intent
- Concrete findings when issues exist; refer to file paths and symbols precisely
- Regression risks, if any
- Missing tests, if any
- A next step aligned with the verdict:
  `APPROVE` → ship or merge,
  `MINOR_FIX` → small follow-up changes,
  `REWORK` → revise before approval

If `.codex-handoff/latest.md` is available and contains acceptance criteria, include
a handoff coverage assessment that marks each criterion as `MET`, `NOT_MET`, or
`UNTESTED`.

If a category has no substantive content, say so briefly rather than inventing
filler. Organize the review in whatever structure is clearest, but keep the verdict
prominent near the top so it is easy to find.

After generating the review, save it to
`.codex-handoff/history/YYYY-MM-DD-HHMMSS-review.md`. Create the directory if needed.
