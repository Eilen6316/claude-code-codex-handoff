# Claude Code Codex Handoff

[![Validate](https://github.com/Eilen6316/claude-code-codex-handoff/actions/workflows/validate.yml/badge.svg)](https://github.com/Eilen6316/claude-code-codex-handoff/actions/workflows/validate.yml)

[English README](./README.md)

一个面向 Claude Code 的插件，用于把”模糊任务”变成”基于仓库上下文的结构化 handoff”，再交给 Codex 执行。

## Demo

![codex-handoff demo](./docs/assets/demo.gif)

它解决的不是普通 prompt 润色问题，而是这个问题：

`你 -> Claude 先读仓库 -> Claude 生成 CODEX_HANDOFF -> Codex 实现 -> Claude 审查`

安装了 [Codex 插件](https://github.com/openai/codex-plugin-cc) 后，
整个流程一条命令自动跑完，无需手动复制粘贴。

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
- `/codex-handoff:handoff [--no-exec] [任务]`
  生成基于仓库上下文的结构化 `CODEX_HANDOFF`，然后自动交给 Codex 实现，
  实现完成后自动触发 review。使用 `--no-exec` 可以只生成 handoff 而不执行。
- `/codex-handoff:review [范围]`
  手动触发的 review skill，用于在实现完成后做二次审查，并输出固定 verdict：`APPROVE`、`MINOR_FIX`、`REWORK`。
- `scripts/validate.sh`
  结构校验脚本，可本地运行，也方便接入你自己的 CI。

## 安装

### 方式 A：通过插件市场安装（推荐）

1. 添加市场：

   ```text
   /plugin marketplace add Eilen6316/claude-code-codex-handoff
   ```

2. 安装插件：

   ```text
   /plugin install codex-handoff@codex-handoff
   ```

3. 重新加载插件：

   ```text
   /reload-plugins
   ```

### 方式 B：使用 `--plugin-dir` 本地加载

1. 克隆仓库：

   ```bash
   git clone https://github.com/Eilen6316/claude-code-codex-handoff.git
   cd claude-code-codex-handoff
   ```

2. 在当前会话中加载插件：

   ```bash
   claude --plugin-dir .
   ```

## 60 秒快速开始

1. 安装 Codex 插件（自动执行需要）：

   ```text
   /plugin marketplace add openai/codex-plugin-cc
   /plugin install codex@openai-codex
   /reload-plugins
   /codex:setup
   ```

2. 一条命令搞定 —— Claude 分析、Codex 实现、Claude 审查：

   ```text
   /codex-handoff:handoff 给登录流程增加重试保护，同时不要破坏现有 auth state 行为
   ```

   这会自动完成：
   - 生成结构化 `CODEX_HANDOFF` 简报
   - 通过 `/codex:rescue` 将简报交给 Codex 实现
   - 触发 `/codex-handoff:review` 审查实现结果

3. 如果只想生成 handoff 而不执行：

   ```text
   /codex-handoff:handoff --no-exec 给登录流程增加重试保护
   ```

## 示例

用户原始需求：

```text
给 token 刷新流程加上带指数退避的重试机制，该流程用于已认证的 API 请求。
如果已有重试工具函数，优先复用。
不要改变公开 API 的行为。
补充或更新测试。
```

Claude 先分析仓库，再输出结构化 brief。

代表性的 `CODEX_HANDOFF`：

```markdown
# Goal
给已认证 API 请求所使用的 token 刷新路径添加带指数退避的重试机制。

# Repo context
当前 token 刷新实现集中在 `src/auth/refresh.ts`，可能从 `src/api/client.ts` 中的已认证 API 客户端调用。`src/lib/retry.ts` 中已有一个可复用的重试工具。`tests/auth/refresh.test.ts` 中有现有的刷新行为测试。

# Files inspected
- `read`: `src/auth/refresh.ts`
- `read`: `src/api/client.ts`
- `read`: `src/lib/retry.ts`
- `read`: `tests/auth/refresh.test.ts`
- `searched`: `src/auth/**`
- `searched`: `tests/auth/**`

# Constraints
- 如果现有重试工具合适，优先复用
- 不要改变 auth 客户端的公开 API
- 除非有充分理由更新测试，否则保持现有错误结构不变
- 重试逻辑仅限于 token 刷新
- 不要对所有 API 请求引入重试循环

# Do not touch
- 暴露给外部调用方的公开 auth 客户端接口
- 刷新路径之外的 token 存储语义

# Non-goals
- 不要重新设计认证流程
- 不要更改 token 存储语义
- 不要给无关的网络调用添加重试行为
- 除非为了小规模提取，否则不要重构整体 auth 架构

# Ambiguities
- 确认 `src/lib/retry.ts` 是否能直接表达所需的退避策略
- 在扩大重试范围前，验证当前瞬时刷新失败是如何分类的

# Acceptance criteria
- Token 刷新在遇到瞬时失败时使用指数退避进行重试
- 重试次数和延迟策略在代码中有明确定义
- 非瞬时失败仍然快速失败
- 从调用方角度看，现有认证请求流程行为保持不变
- 测试覆盖：重试后成功、达到最大重试次数后终止、不可重试错误的行为

# Files likely involved
- `src/auth/refresh.ts`
- `src/api/client.ts`
- `src/lib/retry.ts`
- `tests/auth/refresh.test.ts`

# Test plan
- 更新或新增 token 刷新重试行为的单元测试
- 验证第一次刷新瞬时失败后再次成功的场景
- 验证达到最大重试次数后的失败场景
- 验证不可重试错误不会循环
- 先运行 auth 相关的定向测试，再运行更广泛的受影响测试套件

# Review focus
- 重试是否仅限于刷新，而非所有出站请求？
- 退避参数是否合理且可读？
- 是否干净地复用了现有工具而非重复实现？
- 公开行为和错误契约是否保持不变？
- 测试是否确定性的而非依赖时序？

# CODEX_HANDOFF
在已认证请求流程中为 token 刷新实现带指数退避的重试。
先确认 `src/lib/retry.ts` 是否可以直接复用，优先复用而非引入第二个重试抽象。
以 `src/auth/refresh.ts` 为中心做最小安全变更，如有需要仅对 `src/api/client.ts` 做最少的集成修改。
保持调用方看到的公开行为不变。不要将重试扩展到无关的请求路径。
不要触碰公开 auth 客户端接口或刷新路径之外的 token 存储语义。
在修改重试行为之前，先验证 `src/lib/retry.ts` 能否表达所需退避策略，以及瞬时刷新失败目前是如何分类的。
在 `tests/auth/refresh.test.ts` 中补充或更新测试，覆盖：
1. 一次瞬时刷新失败后成功
2. 达到最大重试次数后终止失败
3. 不可重试错误立即失败
保持实现易于审查，避免大范围重构。
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

脚本已经是 CI-ready 的。仓库中包含了 GitHub Actions 工作流
`.github/workflows/validate.yml`，会在 push 和 PR 时自动运行。

## 贡献

请阅读 [CONTRIBUTING.zh-CN.md](./CONTRIBUTING.zh-CN.md) 了解本地配置、验证、
提交规范和 PR 流程。

## 文档

- [Workflow Guide (English)](./docs/WORKFLOW.en.md)
- [工作流指南（简体中文）](./docs/WORKFLOW.zh-CN.md)
- [示例索引](./docs/examples/README.md)

## 当前状态

已经可用，而且是有明确偏好的版本。

最适合那些希望让 Claude 先做“repo-aware 规划”，再把实现交给 Codex 的个人或团队。

## 许可证

MIT
