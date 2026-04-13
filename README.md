# Claude Code Codex Handoff

[简体中文说明](./README.zh-CN.md)

`codex-handoff` is a Claude Code plugin for repo-grounded handoff and review workflows:

`You -> Claude analyzes repo -> Claude writes Codex brief -> Codex implements -> Claude or Codex reviews`

This plugin is designed for Mode A:

- Claude acts as planner, tech lead, and reviewer
- Codex acts as implementer
- The handoff is grounded in the current repository instead of a vague prompt

## Features

- `codex-handoff:repo-analyst`
  A read-only subagent for file discovery, architecture mapping, constraints, and test planning.
- `/codex-handoff:handoff [task]`
  A manual skill that inspects the repo and produces a structured `CODEX_HANDOFF` brief for `/codex:rescue`.
- `/codex-handoff:review [scope]`
  A manual skill for post-implementation review of current changes or a specific area.
- `scripts/validate.sh`
  Structural validation plus optional local Claude CLI checks.

## Repository layout

```text
.
├── .claude-plugin/plugin.json
├── agents/repo-analyst.md
├── docs/WORKFLOW.en.md
├── docs/WORKFLOW.zh-CN.md
├── skills/handoff/SKILL.md
├── skills/review/SKILL.md
└── scripts/validate.sh
```

## Install for local development

Run Claude Code with this plugin loaded from the current directory:

```bash
claude --plugin-dir .
```

Useful checks:

```bash
claude plugins validate .
claude --plugin-dir . agents
bash scripts/validate.sh
```

## Recommended setup with Codex

Install the official Codex bridge in Claude Code:

```text
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

## Typical workflow

1. Generate a repo-grounded handoff:

   ```text
   /codex-handoff:handoff add retry protection to the login flow without regressing existing auth state handling
   ```

2. Copy the final `CODEX_HANDOFF` section into Codex:

   ```text
   /codex:rescue <paste CODEX_HANDOFF>
   ```

3. Review the result:

   ```text
   /codex-handoff:review review the current diff for regressions and missing tests
   ```

   Or use:

   ```text
   /codex:review
   ```

## Output contract

`/codex-handoff:handoff` targets these sections:

- `Goal`
- `Repo context`
- `Constraints`
- `Non-goals`
- `Acceptance criteria`
- `Files likely involved`
- `Test plan`
- `Review focus`
- `CODEX_HANDOFF`

## Documentation

- [Workflow Guide (English)](./docs/WORKFLOW.en.md)
- [工作流指南（简体中文）](./docs/WORKFLOW.zh-CN.md)

## Validation

The included validation script checks:

- plugin manifest JSON validity
- required repository files
- frontmatter presence for agents and skills
- optional Claude CLI validation when `claude` is installed locally

The validation script is CI-ready, but no workflow file is included in the repository
because some GitHub tokens cannot push `.github/workflows/*` without the extra
`workflow` scope.

## License

MIT
