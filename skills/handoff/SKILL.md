---
name: handoff
description: Generate a repo-grounded Codex handoff brief for a coding task. Use manually when you want Claude to inspect the current project, define scope, and produce an implementation-ready brief for Codex.
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
3. Use the repo-grounded analysis to draft the final handoff. Do not implement the
   change. Do not edit files. Do not run write commands.
4. Prefer concrete file paths, symbols, commands, and test targets when known.
5. Ask follow-up questions only if missing information blocks safe execution.

Output exactly these top-level sections:

# Goal

# Repo context

# Constraints

# Non-goals

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
