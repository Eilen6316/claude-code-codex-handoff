# Workflow Guide

## Goal

Use Claude as a repo-aware planner and reviewer, and use Codex as the implementation engine.

## Recommended flow

1. Start with a concrete task statement.
2. Run `/codex-handoff:handoff [task]`.
3. Let Claude inspect the repository with `repo-analyst`.
4. Copy the final `CODEX_HANDOFF` section into `/codex:rescue`.
5. After Codex finishes, run `/codex-handoff:review [scope]` or `/codex:review`.

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
- Current behavior is summarized before proposing changes
- Constraints and non-goals are separate
- Acceptance criteria are testable
- Test plan matches the repository's existing tooling

## Review checklist

- Behavior regressions
- Missing tests
- Incorrect assumptions about existing architecture
- Scope creep beyond the handoff
- Changes that violate stated constraints
