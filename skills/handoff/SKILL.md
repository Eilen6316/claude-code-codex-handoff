---
name: handoff
description: Generate a repo-grounded Codex handoff brief. 先由 Claude 阅读代码并整理结构化实现说明，再交给 Codex。
argument-hint: "[--no-exec] [--background] [--model <model>] [--effort <level>] [task]"
disable-model-invocation: true
allowed-tools: Agent Read Grep Glob Bash Skill
---
Create a Codex-ready handoff for: $ARGUMENTS

## Phase 1: Parse arguments

- If `$ARGUMENTS` is empty, ask the user for the task before doing anything else.
- If the user's request includes `--no-exec`, only generate the handoff and save it.
  Do not invoke Codex or trigger a review. Strip `--no-exec` from the task text.
- If the user's request includes `--background`, pass it through to `/codex:rescue`.
  Strip it from the task text.
- If the user's request includes `--model <value>`, pass it through to `/codex:rescue`.
  Strip it from the task text.
- If the user's request includes `--effort <value>`, pass it through to `/codex:rescue`.
  Strip it from the task text.

## Phase 2: Analyze the repository

1. Delegate repository inspection to the `repo-analyst` agent from this plugin. If that
   agent is unavailable, use the built-in `Explore` agent.
2. Show the analysis summary in the final response so the user can audit what was
   inspected.

## Phase 3: Draft the handoff brief

Use the analysis to write a handoff brief for Codex. Do not implement the change
yourself. Do not modify the target repository's source code.

The brief must cover these information elements. Organize them however makes the
task clearest — use headings, prose, or bullet lists as appropriate. Simple tasks
may need only a few paragraphs; complex tasks may warrant more structure.

**Required information:**
- What to achieve (the goal)
- Which files were inspected and what the current behavior is
- What Codex should verify before calling it done (acceptance criteria)
- How to test the change

**Include when relevant:**
- Constraints or invariants to preserve
- Files or interfaces not to touch
- What is explicitly out of scope
- Unresolved ambiguities that Codex should investigate first
- Which files are likely to need changes

The brief must end with a `# CODEX_HANDOFF` section. This is the only heading that
must appear exactly as written — it is the machine-readable boundary that downstream
tools use to extract the handoff payload.

Requirements for `# CODEX_HANDOFF`:
- Write in imperative voice.
- Assume Codex will implement the change directly in this repository.
- Include the desired outcome, important files, risks to watch, and what to verify.
- Keep it compact enough to paste directly into `/codex:rescue`.

Additional rules:
- Prefer concrete file paths, symbols, commands, and test targets when known.
- Ask follow-up questions only if missing information blocks safe execution.
- Match the user's language. If the user asked in Chinese, write in Chinese except
  for code, file paths, and commands.
- Include `<!-- codex-handoff | YYYY-MM-DD -->` at the very top using today's date.

## Phase 4: Save the handoff

Save the complete output to `.codex-handoff/latest.md` so the review skill can
reference it later. Also save a timestamped copy to
`.codex-handoff/history/YYYY-MM-DD-HHMMSS-handoff.md`. Create directories if needed.

## Phase 5: Execute and review

1. If `--no-exec` was specified, stop here.
2. Otherwise, hand the `# CODEX_HANDOFF` section content to Codex by invoking:
   `Skill("codex:rescue", args="<flags> <content of # CODEX_HANDOFF section>")`.
   Prepend any captured flags (`--background`, `--model <value>`, `--effort <value>`)
   before the handoff content. If no flags, pass content directly.
   If `codex:rescue` is not available, tell the user to install the Codex plugin
   (`/plugin install codex@openai-codex`) and skip.
3. After Codex finishes, trigger a review:
   `Skill("codex-handoff:review", args="review the implementation against the handoff criteria")`.
   If the review skill is not available, skip.
