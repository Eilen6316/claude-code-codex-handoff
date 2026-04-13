# Claude Code Codex Handoff

[English README](./README.md)

一个面向 Claude Code 的插件，用于把“模糊任务”变成“基于仓库上下文的结构化 handoff”，再交给 Codex 执行。

它解决的不是普通 prompt 润色问题，而是这个问题：

`你 -> Claude 先读仓库 -> Claude 生成 CODEX_HANDOFF -> Codex 实现 -> Claude 或 Codex 审查`

## 为什么要做这个插件

直接把需求丢给实现模型，通常会丢失很多仓库相关上下文：

- 架构边界
- 项目里的本地约定
- 附近调用路径
- 隐含约束
- 测试预期
- 审查重点

这个插件把这些信息前置出来。

职责分工：

- Claude：规划、技术判断、验收标准、审查
- Codex：具体实现

## 你会得到什么

- `codex-handoff:repo-analyst`
  只读分析子代理，用于读代码、找相关文件、梳理结构、提炼约束、给出测试建议。
- `/codex-handoff:handoff [任务]`
  手动触发的 handoff skill，会基于仓库上下文生成结构化 `CODEX_HANDOFF`，供 `/codex:rescue` 使用。
- `/codex-handoff:review [范围]`
  手动触发的 review skill，用于在实现完成后做二次审查，并输出固定 verdict：`APPROVE`、`MINOR_FIX`、`REWORK`。
- `scripts/validate.sh`
  结构校验脚本，可本地运行，也方便接入你自己的 CI。

## 60 秒快速开始

1. 克隆仓库：

   ```bash
   git clone https://github.com/Eilen6316/claude-code-codex-handoff.git
   cd claude-code-codex-handoff
   ```

2. 在本地加载插件：

   ```bash
   claude --plugin-dir .
   ```

3. 可选但推荐：安装官方 `codex-plugin-cc`：

   ```text
   /plugin marketplace add openai/codex-plugin-cc
   /plugin install codex@openai-codex
   /reload-plugins
   /codex:setup
   ```

4. 生成 handoff：

   ```text
   /codex-handoff:handoff 给登录流程增加重试保护，同时不要破坏现有 auth state 行为
   ```

5. 复制最后的 `CODEX_HANDOFF`，交给：

   ```text
   /codex:rescue
   ```

6. 实现完成后审查：

   ```text
   /codex-handoff:review 审查当前 diff 的回归风险和缺失测试
   ```

   审查结果会以固定 verdict 收尾：
   `APPROVE`、`MINOR_FIX` 或 `REWORK`。

## 示例

用户原始需求：

```text
Add retry with exponential backoff to the token refresh flow used by authenticated API requests.
Reuse any existing retry helper if available.
Do not change public API behavior.
Add or update tests.
```

Claude 先分析仓库，再输出结构化 brief。

代表性的 `CODEX_HANDOFF`：

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

更多示例：

- [Feature handoff 示例](./docs/examples/feature-handoff.zh-CN.md)
- [Bugfix handoff 示例](./docs/examples/bugfix-handoff.zh-CN.md)
- [Review 输出示例](./docs/examples/review-output.zh-CN.md)
- [示例索引](./docs/examples/README.md)

## 仓库结构

```text
.
├── .claude-plugin/plugin.json
├── agents/repo-analyst.md
├── docs/WORKFLOW.en.md
├── docs/WORKFLOW.zh-CN.md
├── docs/examples/
├── skills/handoff/SKILL.md
├── skills/review/SKILL.md
└── scripts/validate.sh
```

## 校验

运行：

```bash
claude plugins validate .
claude --plugin-dir . agents
bash scripts/eval-fixtures.sh
bash scripts/validate.sh
```

验证脚本会检查：

- `plugin.json` 是否是合法 JSON
- 必需文件是否存在
- agent/skill 是否有 frontmatter
- handoff 示例是否包含完整结构化 section
- 如果本机装了 `claude`，则额外执行一次官方 CLI 级别的验证

脚本已经是 CI-ready 的，但仓库里没有直接提交 `.github/workflows/*`，因为部分
GitHub PAT 在没有 `workflow` scope 的情况下无法推送工作流文件。

## 文档

- [Workflow Guide (English)](./docs/WORKFLOW.en.md)
- [工作流指南（简体中文）](./docs/WORKFLOW.zh-CN.md)
- [示例索引](./docs/examples/README.md)

## 当前状态

已经可用，而且是有明确偏好的版本。

最适合那些希望让 Claude 先做“repo-aware 规划”，再把实现交给 Codex 的个人或团队。

## 许可证

MIT
