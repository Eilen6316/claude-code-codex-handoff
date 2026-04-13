# 贡献指南

[English](./CONTRIBUTING.md)

感谢你考虑为本项目做出贡献！以下是基本流程。

## 本地配置

```bash
git clone https://github.com/Eilen6316/claude-code-codex-handoff.git
cd claude-code-codex-handoff
```

无需构建步骤。插件由 Markdown 文件和 shell 脚本组成。

## 验证

提交 PR 前，请运行完整验证：

```bash
bash scripts/validate.sh
```

验证内容包括：

- 所有必需文件是否存在
- `plugin.json` 是否为合法 JSON
- Agent 和 Skill 文件是否包含有效 frontmatter
- 基于 fixture 的示例完整性检查
- Claude CLI 验证（如果本地安装了 `claude`）

## 提交规范

- 使用简短的祈使句式提交信息（如 "Add retry example"、"Fix fixture path"）
- 每次提交只包含一个逻辑变更
- PR 保持专注，不要混入无关修改

## Pull Request 流程

1. Fork 本仓库，从 `main` 创建功能分支。
2. 完成修改后运行 `bash scripts/validate.sh` 进行验证。
3. 如果添加了新示例，需要在 `eval/fixtures/` 下添加对应的 fixture。
4. 如果修改了 skill 的章节结构，需要同时更新英文和中文示例。
5. 向 `main` 发起 PR，清楚描述变更内容和原因。

## 添加示例

示例位于 `docs/examples/` 下。每个示例需要：

- 英文版（`*.en.md`）和中文版（`*.zh-CN.md`）
- 在 `eval/fixtures/` 中添加匹配的 fixture，`required_strings` 覆盖所有章节标题
- 在 `docs/examples/README.md` 中添加条目

## 报告问题

- **Bug 报告**：描述预期行为、实际行为和复现步骤。
- **功能请求**：描述使用场景和期望的行为。

## 行为准则

保持尊重、建设性沟通，专注于改进项目。

## 许可协议

参与贡献即表示你同意你的贡献将按 MIT 许可协议授权。
