# Workflow Guide

## Goal

Use Claude as a repo-aware planner and reviewer, and use Codex as the implementation engine.

## Recommended flow

1. Start with a concrete task statement.
2. Run `/codex-handoff:handoff [task]`.
3. Let Claude inspect the repository with `repo-analyst`.
4. Review the analysis summary, especially `Files inspected` and any `Ambiguities`.
5. Copy the final `CODEX_HANDOFF` section into `/codex:rescue`.
6. After Codex finishes, run `/codex-handoff:review [scope]` or `/codex:review`.
7. Use the review verdict to decide the next action:
   `APPROVE`, `MINOR_FIX`, or `REWORK`.

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
