# Claude Code Codex Handoff

中文简介：这个插件把 Claude 放在前置分析位，让它先读仓库、定范围、写结构化 brief，再把实现交给 Codex。

`codex-handoff` is a minimal Claude Code plugin for the workflow:

`You -> Claude analyzes repo -> Claude writes Codex brief -> Codex implements -> Claude/Codex reviews`

The first release intentionally stays small:

- A read-only `repo-analyst` subagent for codebase inspection
- A manual `/codex-handoff:handoff` skill for generating an implementation-ready brief
- No hooks yet, so the core workflow stays easy to inspect and iterate

## Why this exists

`codex-plugin-cc` is a good bridge from Claude Code to Codex, but it does not replace
front-end planning. This plugin fills the missing step:

1. Claude inspects the current repository.
2. Claude produces a structured handoff grounded in real files and constraints.
3. You paste the final `CODEX_HANDOFF` section into `/codex:rescue`.

That keeps responsibilities clean:

- Claude: scope, constraints, acceptance criteria, review focus
- Codex: implementation
- Claude or Codex: review

## Plugin contents

```text
.
├── .claude-plugin/plugin.json
├── agents/repo-analyst.md
├── skills/handoff/SKILL.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Local development

Run Claude Code with the plugin loaded from this directory:

```bash
claude --plugin-dir .
```

Then reload after edits:

```bash
/reload-plugins
```

You should see:

- `/codex-handoff:handoff` in `/help`
- `codex-handoff:repo-analyst` in `/agents`

## Recommended setup with Codex

Install the official Codex bridge in Claude Code:

```text
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

## Usage

Run the handoff skill with a concrete task:

```text
/codex-handoff:handoff add retry protection to the login flow and make sure the existing auth state handling still works
```

The skill will tell Claude to:

1. Inspect the repository with the read-only analyst agent
2. Summarize current behavior and risks
3. Produce a structured brief with a final `CODEX_HANDOFF` section

Take the `CODEX_HANDOFF` section and pass it to Codex:

```text
/codex:rescue <paste the CODEX_HANDOFF section here>
```

After implementation, review with either:

```text
/codex:review
```

or your normal Claude review flow.

## Output contract

`/codex-handoff:handoff` always aims to produce these sections:

- `Goal`
- `Repo context`
- `Constraints`
- `Non-goals`
- `Acceptance criteria`
- `Files likely involved`
- `Test plan`
- `Review focus`
- `CODEX_HANDOFF`

The final section is deliberately compact so it can be pasted directly into
`/codex:rescue`.

## Design notes

- The analyst agent is read-only by design.
- The handoff skill is manual by design.
- Hooks are excluded from `0.1.0` on purpose. They are useful for review gates,
  but not a good place for the core planning logic.

## Roadmap

- Optional `codex:review` helper skill
- Optional stop-hook review gate
- Task-specific handoff templates for bugs, refactors, and feature work

## License

MIT
