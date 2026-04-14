# Review 输出示例

> 审查请求：审查当前 diff，重点检查给 token refresh 增加指数退避重试后的回归风险和缺失测试。

以下是一种可能的 review 输出。具体结构会随任务复杂度变化。

---

# Verdict

MINOR_FIX

# Summary

当前实现整体上已经比较接近原始 handoff，重试范围看起来仍然限制在 token refresh 内。主要剩余问题是：对于不可重试失败的测试覆盖还不完整，而这本来就在验收标准中。

# Findings

- 缺少一个测试来证明不可重试的 refresh 错误会立即失败，而不是进入重试路径
- 新增的 retry 策略常量本身可读性不错，但需要继续保持作用域只限于 refresh，避免以后被误用于无关请求路径

# Regression risks

- 如果不可重试错误被错误分类，调用方可能会遇到不必要的延迟失败
- 如果后续 retry helper 的分类逻辑变化，refresh 行为可能会静默扩大到超出预期的错误集合

# Missing tests

- 增加一个"不可重试 refresh 错误不会进入重试"的测试
- 可以再补一个小测试，确认重试仍然只作用于 refresh，而不是所有认证请求

# Next step

做一个小的 follow-up patch，补上不可重试错误的测试，然后重新跑 auth refresh 相关测试。完成后，这次改动大概率就可以批准。

# Handoff coverage

- token refresh 在瞬时失败时按指数退避重试                    MET
- 重试次数和延迟策略在代码中明确可见                          MET
- 非瞬时失败仍然及时失败                                      UNTESTED
- 认证请求对调用方的外部行为保持不变                          MET
- 测试覆盖"重试后成功"                                        MET
- 测试覆盖"达到上限后失败"                                    MET
- 测试覆盖"不可重试错误立即失败"                              NOT_MET
