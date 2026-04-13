---
name: handoff
description: Generate a repo-grounded Codex handoff brief. 先由 Claude 阅读代码并整理结构化实现说明，再交给 Codex。
argument-hint: "[task]"
disable-model-invocation: true
allowed-tools: Agent Read Grep Glob Bash
---
Create a Codex-ready handoff for: $ARGUMENTS

Workflow:
1. If `$ARGUMENTS` is empty, ask the user for the task before doing anything else.
2. Start by delegating repository inspection to the `repo-analyst` agent from this
   plugin. If that agent is unavailable in the current session, use the built-in
   `Explore` agent and request the same output contract.
3. Show the repository analysis summary in the final response so the user can audit
   what Claude inspected before the handoff is consumed.
4. Use the repo-grounded analysis to draft the final handoff. Do not implement the
   change. Do not edit files. Do not run write commands.
5. Prefer concrete file paths, symbols, commands, and test targets when known.
6. Ask follow-up questions only if missing information blocks safe execution.
7. Match the user's language. If the user asked in Chinese, the final output should
   be in Chinese except for code, file paths, commands, and literal section titles
   that must remain stable.
8. If a section has no meaningful content, say `None identified.` instead of leaving
   it blank.
9. Include a metadata line at the very top of the output before the first section:
   `<!-- codex-handoff v1.4.0 | YYYY-MM-DD -->` using the current date.
10. After generating the handoff, save the complete output (from `# Goal` to the end)
    to `.codex-handoff/latest.md` so the review skill can reference it later. Create
    the `.codex-handoff/` directory if it does not exist.

Output exactly these top-level sections:

# Goal

# Repo context

# Files inspected

# Constraints

# Do not touch

# Non-goals

# Ambiguities

# Acceptance criteria

# Files likely involved

# Test plan

# Review focus

# CODEX_HANDOFF

Requirements for `# CODEX_HANDOFF`:
- Write in imperative voice.
- Assume Codex will implement the change directly in this repository.
- Include the desired outcome, important files, risks to watch, and what to verify
  before finishing.
- Keep it compact enough to paste directly into `/codex:rescue`.
- Reflect any `Do not touch` constraints and unresolved `Ambiguities`.
