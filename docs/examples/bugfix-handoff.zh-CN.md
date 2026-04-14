# Bug 修复 Handoff 示例

> 用户需求：修复分页后搜索筛选条件被重置的问题。尽量保持当前 URL 格式不变。
> 补一个回归测试。

以下是一种可能的 handoff 输出。具体结构会随任务复杂度变化。

---

<!-- codex-handoff | 2026-04-13 -->

# Goal

修复分页后搜索筛选条件被重置的问题。

# Repo context

搜索状态看起来是从 `src/features/search/useSearchState.ts` 中的 query 参数推导出来的。分页行为大概率由 `src/features/search/SearchResults.tsx` 更新 URL。共享的 query 参数 helper 看起来位于 `src/lib/router/query.ts`。

# Files inspected

- `read`: `src/features/search/useSearchState.ts`
- `read`: `src/features/search/SearchResults.tsx`
- `read`: `src/lib/router/query.ts`
- `read`: `tests/search/search-state.test.ts`
- `searched`: `src/features/search/**`
- `searched`: `tests/search/**`

# Constraints

- 尽量保持现有 URL 格式不变
- 修复范围限定在搜索状态和分页同步
- 不要重写整个搜索页面架构
- 需要补充一个能覆盖原始问题的回归测试

# Do not touch

- 现有 query 参数命名，除非无法兼容
- 搜索流程之外的无关分页组件

# Non-goals

- 不要重设计搜索路由
- 不要随意改 query 参数 key
- 不要顺手重构无关的分页组件

# Ambiguities

- 还需要确认问题根因是 URL 覆盖，还是状态恢复顺序错误
- 还需要确认"直接访问 URL"和"页内翻页"是否走完全相同的代码路径

# Acceptance criteria

- 切换到上一页或下一页后，当前筛选条件仍然保留
- URL 参数继续准确表示当前搜索状态
- 现有不带筛选条件的分页行为不受影响
- 回归测试覆盖原始 bug

# Files likely involved

- `src/features/search/useSearchState.ts`
- `src/features/search/SearchResults.tsx`
- `src/lib/router/query.ts`
- `tests/search/search-state.test.ts`

# Test plan

- 先通过当前搜索页面流程稳定复现 bug
- 新增或更新一个覆盖"分页后筛选条件仍保留"的回归测试
- 验证分页索引更新行为仍然正确
- 验证带筛选条件的 URL 直接访问仍能正确恢复状态

# Review focus

- 修复是否保持了 URL 兼容性？
- 分页更新是否是 merge，而不是覆盖整个状态？
- 筛选条件与页码是否都从同一个可信来源推导？
- 回归测试是否真的覆盖了原始失败路径？

# CODEX_HANDOFF

修复分页后当前搜索筛选条件被重置的问题。
重点检查分页更新 query 参数的方式，以及搜索状态从 URL 恢复的逻辑。
优先做最小安全修复，并尽量保持当前 URL 格式不变。
排查 `src/features/search/useSearchState.ts`、`src/features/search/SearchResults.tsx`，以及 `src/lib/router/query.ts` 中的共享 helper。
不要修改现有 query 参数命名，除非无法兼容；也不要碰搜索流程之外的无关分页组件。
在动手前确认问题根因到底是 URL 覆盖还是状态恢复顺序错误，并确认"直接访问 URL"和"页内翻页"是否走相同代码路径。
在 `tests/search/search-state.test.ts` 中新增一个回归测试，证明翻页后筛选条件仍然保留。
不要把这次修复扩展成大范围搜索路由重构。
