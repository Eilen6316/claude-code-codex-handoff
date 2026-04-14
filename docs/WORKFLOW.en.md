# Workflow Guide

## Goal

Use Claude as a repo-aware planner and reviewer, and use Codex as the implementation engine.

## Recommended flow

1. Start with a concrete task statement.
2. Run `/codex-handoff:handoff [task]`.
3. Claude inspects the repository with `repo-analyst` and generates a structured `CODEX_HANDOFF`.
4. Review the analysis summary, especially `Files inspected` and any `Ambiguities`.
5. The handoff automatically passes the `CODEX_HANDOFF` section to `/codex:rescue` for Codex to implement.
6. After Codex finishes, `/codex-handoff:review` is automatically triggered to review the result.
7. Use the review verdict to decide the next action:
   `APPROVE`, `MINOR_FIX`, or `REWORK`.

The handoff output is saved to `.codex-handoff/latest.md` so the review skill can
cross-reference the original acceptance criteria, constraints, and review focus.
A timestamped copy is also saved to `.codex-handoff/history/` for traceability.

## Manual mode

Use `--no-exec` to generate the handoff without invoking Codex:

```text
/codex-handoff:handoff --no-exec [task]
```

You can then manually copy the `CODEX_HANDOFF` section into `/codex:rescue`, or
review the handoff quality before deciding whether to proceed.

## Codex execution control

Pass execution flags to control how Codex runs:

- `--background` — run Codex in the background
- `--model <model>` — specify a Codex model (e.g. `gpt-5.4-mini`, `spark`)
- `--effort <level>` — specify reasoning effort (`none` / `minimal` / `low` / `medium` / `high` / `xhigh`)

Example:

```text
/codex-handoff:handoff --background --effort high add retry to the token refresh flow
```

## When to use this plugin

- Multi-file bug fixes
- Refactors with compatibility risks
- Feature work that depends on existing architecture
- Tasks where acceptance criteria and test plans matter

## When not to use this plugin

- One-line edits with obvious context
- Pure brainstorming with no repository grounding needed
- Tasks where Claude should implement directly without delegation

## Handoff quality checklist

- Relevant files are named explicitly
- Files inspected are auditable
- Current behavior is summarized before proposing changes
- Constraints and non-goals are separate
- `Do not touch` boundaries are explicit
- Ambiguities are called out instead of hidden
- Acceptance criteria are testable
- Test plan matches the repository's existing tooling

## Review checklist

- Verdict is explicit: `APPROVE`, `MINOR_FIX`, or `REWORK`
- Behavior regressions
- Missing tests
- Incorrect assumptions about existing architecture
- Scope creep beyond the handoff
- Changes that violate stated constraints
