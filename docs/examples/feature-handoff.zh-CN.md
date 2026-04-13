# 功能开发 Handoff 示例

## 用户原始需求

给认证 API 请求使用的 token refresh 流程增加指数退避重试。优先复用现有 retry helper。不要改变对外 API 行为。补充或更新测试。

## 仓库发现

- Token refresh 逻辑大概率位于 `src/auth/refresh.ts`
- 认证请求包装层大概率从 `src/api/client.ts` 调用 refresh 逻辑
- 仓库里已经有 `src/lib/retry.ts`
- 相关测试位于 `tests/auth/refresh.test.ts`
- 外部调用方可能依赖当前错误形态与 refresh 入口

## 结构化 brief

### Goal

给认证 API 请求中的 token refresh 路径增加指数退避重试。

### Repo context

当前 token refresh 实现大概率集中在 `src/auth/refresh.ts`，并由 `src/api/client.ts` 中的认证 API client 调用。仓库里已有可复用的重试工具 `src/lib/retry.ts`。现有 refresh 行为相关测试大概率在 `tests/auth/refresh.test.ts`。

### Files inspected

- `read`: `src/auth/refresh.ts`
- `read`: `src/api/client.ts`
- `read`: `src/lib/retry.ts`
- `read`: `tests/auth/refresh.test.ts`
- `searched`: `src/auth/**`
- `searched`: `tests/auth/**`

### Constraints

- 如可行，优先复用现有 retry helper
- 不要修改 auth client 的对外 API
- 除非测试更新有明确必要，否则保持现有错误形态
- 重试逻辑只应作用于 token refresh
- 不要把所有 API 请求都包进重试循环

### Do not touch

- 对外暴露的 auth client 接口
- refresh 路径之外的 token 存储语义

### Non-goals

- 不要重构整个认证流程
- 不要改变 token 存储语义
- 不要给无关网络请求增加重试
- 除非为了小范围抽取必须，否则不要做大规模 auth 重构

### Ambiguities

- 还需要确认 `src/lib/retry.ts` 是否能直接表达目标 backoff 策略
- 还需要确认哪些 refresh 失败会被当前实现视为“瞬时失败”

### Acceptance criteria

- token refresh 在瞬时失败时会按指数退避重试
- 重试次数和延迟策略在代码中明确可见
- 非瞬时失败仍然会及时失败
- 认证请求对调用方的外部行为保持不变
- 测试覆盖“重试后成功”“达到上限后失败”“不可重试错误立即失败”

### Files likely involved

- `src/auth/refresh.ts`
- `src/api/client.ts`
- `src/lib/retry.ts`
- `tests/auth/refresh.test.ts`

### Test plan

- 更新或新增 refresh retry 相关单元测试
- 验证首次 refresh 失败、后续成功的情况
- 验证达到最大重试次数后的失败行为
- 验证不可重试错误不会进入循环
- 先跑 auth 相关测试，再视情况扩到更大范围

### Review focus

- 重试是否只限定在 refresh，而不是所有请求？
- backoff 参数是否合理、可读？
- 是否干净复用了现有 helper，而不是重复造一套 retry？
- 是否保持了既有对外行为和错误契约？
- 测试是否稳定，而不是依赖脆弱的 timing？

## 最终 CODEX_HANDOFF

在认证请求流程的 token refresh 路径中实现指数退避重试。
先确认 `src/lib/retry.ts` 是否可以直接复用；优先复用，不要新建第二套 retry 抽象。
以 `src/auth/refresh.ts` 为主要改动点，只在必要时对 `src/api/client.ts` 做最小集成改动。
保持调用方可见行为不变，不要把重试范围扩展到无关请求路径。
不要修改对外暴露的 auth client 接口，也不要碰 refresh 路径之外的 token 存储语义。
在动手前确认 `src/lib/retry.ts` 是否能表达目标 backoff 策略，以及当前实现如何区分瞬时失败与不可重试失败。
在 `tests/auth/refresh.test.ts` 中新增或更新测试，覆盖：
1. 一次瞬时失败后重试成功
2. 达到最大重试次数后失败
3. 不可重试错误立即失败
保持实现易于审查，避免大范围重构。
