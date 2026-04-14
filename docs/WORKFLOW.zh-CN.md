# 工作流指南

## 目标

让 Claude 负责"读代码、定范围、写结构化 brief、做审查"，让 Codex 负责"实现改动"。

## 推荐流程

1. 先把任务描述清楚。
2. 运行 `/codex-handoff:handoff [任务]`。
3. Claude 通过 `repo-analyst` 读取仓库，生成结构化 `CODEX_HANDOFF`。
4. 先看分析摘要，重点检查 `Files inspected` 和任何 `Ambiguities`。
5. handoff 自动将 `CODEX_HANDOFF` 交给 `/codex:rescue`，由 Codex 实现。
6. Codex 完成后，`/codex-handoff:review` 自动触发，审查实现结果。
7. 根据固定 verdict 决定下一步：`APPROVE`、`MINOR_FIX` 或 `REWORK`。

handoff 输出会保存到 `.codex-handoff/latest.md`，review 会回读这个文件来交叉检查
验收标准、约束和审查重点。同时带时间戳的副本会存入 `.codex-handoff/history/` 方便追溯。

## 手动模式

使用 `--no-exec` 可以只生成 handoff 而不调用 Codex：

```text
/codex-handoff:handoff --no-exec [任务]
```

之后可以手动把 `CODEX_HANDOFF` 复制给 `/codex:rescue`，或者先审查 handoff 质量再决定是否执行。

## Codex 执行控制

可以传入以下参数控制 Codex 的执行方式：

- `--background` — 后台运行 Codex
- `--model <模型>` — 指定 Codex 模型（如 `gpt-5.4-mini`、`spark`）
- `--effort <级别>` — 指定推理强度（`none` / `minimal` / `low` / `medium` / `high` / `xhigh`）

示例：

```text
/codex-handoff:handoff --background --effort high 给 token refresh 流程增加重试
```

## 适合使用的场景

- 多文件 bug 修复
- 有兼容性风险的重构
- 依赖现有架构上下文的功能开发
- 需要明确验收标准和测试计划的任务

## 不适合使用的场景

- 上下文非常明显的一行小改动
- 不需要仓库上下文的纯 brainstorming
- 更适合直接让 Claude 自己实现而不是委派的任务

## 高质量 handoff 检查项

- 明确点名相关文件
- `Files inspected` 可审计
- 先说明当前行为，再提出改动目标
- 约束和非目标分开写
- `Do not touch` 边界明确
- 有歧义的地方要显式写进 `Ambiguities`
- 验收标准可以被验证
- 测试计划能对上仓库现有工具链

## 审查检查项

- verdict 明确：`APPROVE`、`MINOR_FIX`、`REWORK`
- 行为回归
- 漏测
- 对现有架构的错误假设
- 超出 handoff 范围的额外改动
- 违反既定约束的实现
