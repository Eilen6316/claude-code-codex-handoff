# Claude Code Codex Handoff

[![Validate](https://github.com/Eilen6316/claude-code-codex-handoff/actions/workflows/validate.yml/badge.svg)](https://github.com/Eilen6316/claude-code-codex-handoff/actions/workflows/validate.yml)

[简体中文说明](./README.zh-CN.md)

A Claude Code plugin for repo-grounded handoff to Codex.

## Demo

![codex-handoff demo](./docs/assets/demo.gif)

Instead of sending a rough coding idea straight to Codex, this plugin lets Claude
inspect the repository first, identify relevant files and constraints, and produce
a structured implementation brief for Codex to execute.

## Why this exists

Direct implementation prompts often miss repository-specific context:

- architecture boundaries
- local conventions
- nearby call paths
- implicit constraints
- test expectations
- review hotspots

This plugin makes that explicit.

Role split:

- Claude: planner, tech lead, reviewer
- Codex: implementer

Workflow:

`You -> Claude analyzes repo -> Claude writes CODEX_HANDOFF -> Codex implements -> Claude reviews`

When the [Codex plugin](https://github.com/openai/codex-plugin-cc) is installed,
the entire pipeline runs automatically with a single command. No manual copy-paste needed.

## What you get

- `codex-handoff:repo-analyst`
  A read-only subagent for repository inspection, architecture mapping, constraints, and test planning.
- `/codex-handoff:handoff [--no-exec] [task]`
  Generates a repo-grounded `CODEX_HANDOFF` brief, then automatically hands it to Codex
  for implementation and triggers a review when done. Use `--no-exec` to only generate
  the handoff without invoking Codex.
- `/codex-handoff:review [scope]`
  A manual review skill for checking the current implementation against intent, risks, and missing tests, with a fixed verdict: `APPROVE`, `MINOR_FIX`, or `REWORK`.
- `scripts/validate.sh`
  Structural validation plus optional Claude CLI checks.

## Installation

### Option A: Install from plugin marketplace (recommended)

1. Add the marketplace:

   ```text
   /plugin marketplace add Eilen6316/claude-code-codex-handoff
   ```

2. Install the plugin:

   ```text
   /plugin install codex-handoff@codex-handoff
   ```

3. Reload plugins:

   ```text
   /reload-plugins
   ```

### Option B: Load locally with `--plugin-dir`

1. Clone the repository:

   ```bash
   git clone https://github.com/Eilen6316/claude-code-codex-handoff.git
   cd claude-code-codex-handoff
   ```

2. Load the plugin for the current session:

   ```bash
   claude --plugin-dir .
   ```

## 60-second quickstart

1. Install the Codex plugin (required for automatic execution):

   ```text
   /plugin marketplace add openai/codex-plugin-cc
   /plugin install codex@openai-codex
   /reload-plugins
   /codex:setup
   ```

2. Run a single command — Claude analyzes, Codex implements, Claude reviews:

   ```text
   /codex-handoff:handoff add retry protection to the login flow without regressing existing auth state handling
   ```

   This will automatically:
   - Generate the structured `CODEX_HANDOFF` brief
   - Pass it to Codex via `/codex:rescue` for implementation
   - Trigger `/codex-handoff:review` to review the result

3. To only generate the handoff without executing:

   ```text
   /codex-handoff:handoff --no-exec add retry protection to the login flow
   ```

## Example

User request:

```text
Add retry with exponential backoff to the token refresh flow used by authenticated API requests.
Reuse any existing retry helper if available.
Do not change public API behavior.
Add or update tests.
```

Claude analyzes the repository and produces a structured brief.

Representative `CODEX_HANDOFF`:

```markdown
# Goal
Add retry with exponential backoff to the token refresh path used during authenticated API requests.

# Repo context
The current token refresh implementation appears centered in `src/auth/refresh.ts`, and is likely invoked from the authenticated API client in `src/api/client.ts`. There is already a reusable retry utility in `src/lib/retry.ts`. Existing tests for refresh behavior appear in `tests/auth/refresh.test.ts`.

# Files inspected
- `read`: `src/auth/refresh.ts`
- `read`: `src/api/client.ts`
- `read`: `src/lib/retry.ts`
- `read`: `tests/auth/refresh.test.ts`
- `searched`: `src/auth/**`
- `searched`: `tests/auth/**`

# Constraints
- Reuse the existing retry helper if it is a good fit
- Do not change the public API of the auth client
- Preserve existing error shape unless a test update is clearly justified
- Keep retry logic scoped to token refresh only
- Avoid introducing retry loops around all API requests

# Do not touch
- Public auth client interfaces exposed to external callers
- Token storage semantics outside the refresh path

# Non-goals
- Do not redesign authentication flow
- Do not change token storage semantics
- Do not add retry behavior to unrelated network calls
- Do not refactor broad auth architecture unless necessary for a small extraction

# Ambiguities
- Confirm whether `src/lib/retry.ts` can express the required backoff policy as-is
- Verify how transient refresh failures are currently classified before widening retry behavior

# Acceptance criteria
- Token refresh retries on transient failure using exponential backoff
- Retry count and delay policy are explicit in code
- Non-transient failures still fail promptly
- Existing authenticated request flow continues to behave the same from the caller perspective
- Tests cover success after retry, terminal failure, and non-retriable failure behavior

# Files likely involved
- `src/auth/refresh.ts`
- `src/api/client.ts`
- `src/lib/retry.ts`
- `tests/auth/refresh.test.ts`

# Test plan
- Update or add unit tests for refresh retry behavior
- Verify success when the first refresh attempt fails transiently and a later one succeeds
- Verify failure after max retry attempts
- Verify non-retriable errors do not loop
- Run targeted auth-related tests first, then broader affected suite if available

# Review focus
- Is retry scoped only to refresh, not all outbound requests?
- Are backoff parameters reasonable and readable?
- Is existing helper reused cleanly instead of duplicating retry logic?
- Are public behavior and error contracts preserved?
- Are tests deterministic rather than timing-fragile?

# CODEX_HANDOFF
Implement retry with exponential backoff for token refresh in the authenticated request flow.
Start by confirming whether `src/lib/retry.ts` can be reused directly. Prefer reusing it over introducing a second retry abstraction.
Make the smallest safe change centered on `src/auth/refresh.ts`, with only minimal integration changes in `src/api/client.ts` if needed.
Preserve public behavior for callers. Do not broaden retry behavior to unrelated request paths.
Do not touch public auth client interfaces or token storage semantics outside the refresh path.
Before changing retry behavior, verify whether `src/lib/retry.ts` can express the required backoff policy and how transient refresh failures are currently classified.
Add or update tests in `tests/auth/refresh.test.ts` to cover:
1. success after one transient refresh failure
2. terminal failure after max retries
3. immediate failure for non-retriable errors
Keep the implementation easy to review and avoid large refactors.
```

More examples:

- [Feature handoff example](./docs/examples/feature-handoff.en.md)
- [Bugfix handoff example](./docs/examples/bugfix-handoff.en.md)
- [Review output example](./docs/examples/review-output.en.md)
- [Examples index](./docs/examples/README.md)

## Included files

```text
.
├── .claude-plugin/plugin.json
├── .claude-plugin/marketplace.json
├── .github/
│   ├── workflows/validate.yml
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── agents/repo-analyst.md
├── docs/WORKFLOW.en.md
├── docs/WORKFLOW.zh-CN.md
├── docs/examples/
├── eval/fixtures/
├── skills/handoff/SKILL.md
├── skills/review/SKILL.md
├── scripts/validate.sh
├── scripts/eval-fixtures.sh
├── CONTRIBUTING.md
└── CONTRIBUTING.zh-CN.md
```

## Validation

Run:

```bash
claude plugins validate .
claude --plugin-dir . agents
bash scripts/eval-fixtures.sh
bash scripts/validate.sh
```

The validation script checks:

- plugin manifest JSON validity
- required repository files
- frontmatter presence for agents and skills
- fixture-based example completeness for handoff output sections
- optional Claude CLI validation when `claude` is installed locally

The script is CI-ready. A GitHub Actions workflow is included at
`.github/workflows/validate.yml` and runs automatically on push and PR.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on local setup, validation,
commit conventions, and the PR process.

## Documentation

- [Workflow Guide (English)](./docs/WORKFLOW.en.md)
- [工作流指南（简体中文）](./docs/WORKFLOW.zh-CN.md)
- [Examples index](./docs/examples/README.md)

## Status

Usable and intentionally opinionated.

Best for teams or individuals who want Claude to act as a repo-aware planner
before handing implementation to Codex.

## License

MIT
