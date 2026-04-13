# Claude Code Codex Handoff

[English README](./README.md)

`codex-handoff` 是一个面向 Claude Code 的插件，用来实现“先由 Claude 读仓库、定范围、写 handoff，再交给 Codex 实现，最后再做审查”的工作流：

`你 -> Claude 分析仓库 -> Claude 生成 Codex brief -> Codex 实现 -> Claude 或 Codex 审查`

这个插件对应你想要的模式 A：

- Claude 负责规划、技术判断、验收标准和审查
- Codex 负责具体实现
- handoff 基于真实仓库上下文，而不是只靠一句模糊提示

## 功能

- `codex-handoff:repo-analyst`
  只读代码分析子代理，用于找文件、梳理结构、提炼约束、生成测试建议。
- `/codex-handoff:handoff [任务]`
  手动触发的 handoff skill，会先分析仓库，再输出结构化 `CODEX_HANDOFF`，供 `/codex:rescue` 使用。
- `/codex-handoff:review [范围]`
  手动触发的 review skill，用于在 Codex 改完后做二次审查。
- `scripts/validate.sh`
  可在本地运行、也方便接入 CI 的验证脚本。

## 仓库结构

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

## 本地加载

在当前目录加载插件启动 Claude Code：

```bash
claude --plugin-dir .
```

建议先跑这几条检查：

```bash
claude plugins validate .
claude --plugin-dir . agents
bash scripts/validate.sh
```

## 与 Codex 联动的推荐配置

先安装官方 `codex-plugin-cc`：

```text
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

## 典型使用方式

1. 先生成基于仓库的 handoff：

   ```text
   /codex-handoff:handoff 给登录流程增加重试保护，同时不要破坏现有 auth state 行为
   ```

2. 复制最后的 `CODEX_HANDOFF` 段落，交给 Codex：

   ```text
   /codex:rescue <粘贴 CODEX_HANDOFF>
   ```

3. 实现完成后做审查：

   ```text
   /codex-handoff:review 审查当前 diff 的回归风险和缺失测试
   ```

   或者直接：

   ```text
   /codex:review
   ```

## handoff 输出结构

`/codex-handoff:handoff` 目标输出这些部分：

- `Goal`
- `Repo context`
- `Constraints`
- `Non-goals`
- `Acceptance criteria`
- `Files likely involved`
- `Test plan`
- `Review focus`
- `CODEX_HANDOFF`

## 文档

- [Workflow Guide (English)](./docs/WORKFLOW.en.md)
- [工作流指南（简体中文）](./docs/WORKFLOW.zh-CN.md)

## 校验

仓库内置的验证脚本会检查：

- `plugin.json` 是否是合法 JSON
- 关键文件是否存在
- agent/skill 文件是否有 frontmatter
- 如果本机装了 `claude`，则额外做一次官方 CLI 级别的验证和代理加载检查

这份仓库没有直接附带 `.github/workflows/*`，因为部分 GitHub PAT 在没有
`workflow` scope 的情况下无法推送工作流文件；但 `scripts/validate.sh`
已经可以直接接入你自己的 CI。

## 许可证

MIT
