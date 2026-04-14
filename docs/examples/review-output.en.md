# Review Output Example

> Review request: Review the current diff for regressions and missing tests after
> implementing retry with exponential backoff in the token refresh flow.

Below is one possible review output. The structure may vary by task complexity.

---

# Verdict

MINOR_FIX

# Summary

The implementation appears close to the original handoff, and the retry scope still
seems limited to token refresh. The main remaining issue is incomplete test coverage
for non-retriable failures, which was part of the requested acceptance criteria.

# Findings

- Missing a test that proves non-retriable refresh errors fail immediately instead of
  entering the retry path
- The new retry policy constant is readable, but it should remain clearly scoped to
  refresh logic to avoid accidental reuse in unrelated request paths

# Regression risks

- If non-retriable errors are misclassified, callers may experience delayed failures
- If the retry helper classification changes later, refresh behavior could silently
  broaden beyond the intended error set

# Missing tests

- Add a test that simulates a non-retriable refresh error and asserts there is no retry
- Consider adding a small assertion that retry behavior stays scoped to refresh rather
  than all authenticated requests

# Next step

Apply a small follow-up patch to add the missing non-retriable error test, then rerun
the auth refresh test suite. After that, this change is likely ready to approve.

# Handoff coverage

- Token refresh retries on transient failure with exponential backoff    MET
- Retry count and delay policy are explicit in code                      MET
- Non-transient failures still fail promptly                             UNTESTED
- Existing authenticated request flow unchanged from caller perspective  MET
- Tests cover success after retry                                        MET
- Tests cover terminal failure                                           MET
- Tests cover non-retriable failure behavior                             NOT_MET
