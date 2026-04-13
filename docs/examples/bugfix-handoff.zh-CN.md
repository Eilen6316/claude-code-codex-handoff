# Bug 修复 Handoff 示例

## 用户原始需求

修复分页后搜索筛选条件被重置的问题。尽量保持当前 URL 格式不变。补一个回归测试。

## 仓库发现

- 搜索状态大概率在 `src/features/search/useSearchState.ts`
- 分页 UI 可能在 `src/features/search/SearchResults.tsx` 更新 query 参数
- 共享 router/query helper 可能在 `src/lib/router/query.ts`
- 现有搜索状态测试大概率在 `tests/search/search-state.test.ts`

## 结构化 brief

### Goal

修复分页后搜索筛选条件被重置的问题。

### Repo context

搜索状态看起来是从 `src/features/search/useSearchState.ts` 中的 query 参数推导出来的。分页行为大概率由 `src/features/search/SearchResults.tsx` 更新 URL。共享的 query 参数 helper 看起来位于 `src/lib/router/query.ts`。

### Constraints

- 尽量保持现有 URL 格式不变
- 修复范围限定在搜索状态和分页同步
- 不要重写整个搜索页面架构
- 需要补充一个能覆盖原始问题的回归测试

### Non-goals

- 不要重设计搜索路由
- 不要随意改 query 参数 key
- 不要顺手重构无关的分页组件

### Acceptance criteria

- 切换到上一页或下一页后，当前筛选条件仍然保留
- URL 参数继续准确表示当前搜索状态
- 现有不带筛选条件的分页行为不受影响
- 回归测试覆盖原始 bug

### Files likely involved

- `src/features/search/useSearchState.ts`
- `src/features/search/SearchResults.tsx`
- `src/lib/router/query.ts`
- `tests/search/search-state.test.ts`

### Test plan

- 先通过当前搜索页面流程稳定复现 bug
- 新增或更新一个覆盖“分页后筛选条件仍保留”的回归测试
- 验证分页索引更新行为仍然正确
- 验证带筛选条件的 URL 直接访问仍能正确恢复状态

### Review focus

- 修复是否保持了 URL 兼容性？
- 分页更新是否是 merge，而不是覆盖整个状态？
- 筛选条件与页码是否都从同一个可信来源推导？
- 回归测试是否真的覆盖了原始失败路径？

## 最终 CODEX_HANDOFF

修复分页后当前搜索筛选条件被重置的问题。
重点检查分页更新 query 参数的方式，以及搜索状态从 URL 恢复的逻辑。
优先做最小安全修复，并尽量保持当前 URL 格式不变。
排查 `src/features/search/useSearchState.ts`、`src/features/search/SearchResults.tsx`，以及 `src/lib/router/query.ts` 中的共享 helper。
在 `tests/search/search-state.test.ts` 中新增一个回归测试，证明翻页后筛选条件仍然保留。
不要把这次修复扩展成大范围搜索路由重构。
