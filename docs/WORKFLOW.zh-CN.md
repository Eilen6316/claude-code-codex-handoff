# 工作流指南

## 目标

让 Claude 负责“读代码、定范围、写结构化 brief、做审查”，让 Codex 负责“实现改动”。

## 推荐流程

1. 先把任务描述清楚。
2. 运行 `/codex-handoff:handoff [任务]`。
3. 让 Claude 通过 `repo-analyst` 读取仓库并整理上下文。
4. 先看分析摘要，重点检查 `Files inspected` 和任何 `Ambiguities`。
5. 把最后的 `CODEX_HANDOFF` 段落复制给 `/codex:rescue`。
6. Codex 完成后，再运行 `/codex-handoff:review [范围]` 或 `/codex:review`。
7. 根据固定 verdict 决定下一步：`APPROVE`、`MINOR_FIX` 或 `REWORK`。

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
