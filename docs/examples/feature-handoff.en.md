# Feature Handoff Example

## Raw user request

Add retry with exponential backoff to the token refresh flow used by authenticated
API requests. Reuse any existing retry helper if available. Do not change public
API behavior. Add or update tests.

## Repository findings

- Token refresh logic appears to live in `src/auth/refresh.ts`
- The authenticated request wrapper likely calls refresh logic from `src/api/client.ts`
- There is an existing retry helper in `src/lib/retry.ts`
- Tests covering auth refresh behavior exist in `tests/auth/refresh.test.ts`
- Public callers seem to depend on current error shape and current refresh entrypoint

## Structured brief

### Goal

Add retry with exponential backoff to the token refresh path used during authenticated API requests.

### Repo context

The current token refresh implementation appears centered in `src/auth/refresh.ts`, and is likely invoked from the authenticated API client in `src/api/client.ts`. There is already a reusable retry utility in `src/lib/retry.ts`. Existing tests for refresh behavior appear in `tests/auth/refresh.test.ts`.

### Files inspected

- `read`: `src/auth/refresh.ts`
- `read`: `src/api/client.ts`
- `read`: `src/lib/retry.ts`
- `read`: `tests/auth/refresh.test.ts`
- `searched`: `src/auth/**`
- `searched`: `tests/auth/**`

### Constraints

- Reuse the existing retry helper if it is a good fit
- Do not change the public API of the auth client
- Preserve existing error shape unless a test update is clearly justified
- Keep retry logic scoped to token refresh only
- Avoid introducing retry loops around all API requests

### Do not touch

- Public auth client interfaces exposed to external callers
- Token storage semantics outside the refresh path

### Non-goals

- Do not redesign authentication flow
- Do not change token storage semantics
- Do not add retry behavior to unrelated network calls
- Do not refactor broad auth architecture unless necessary for a small extraction

### Ambiguities

- It still needs confirmation whether `src/lib/retry.ts` can express the desired backoff policy without extension
- It is not yet proven whether all transient refresh failures share the same error classification path

### Acceptance criteria

- Token refresh retries on transient failure using exponential backoff
- Retry count and delay policy are explicit in code
- Non-transient failures still fail promptly
- Existing authenticated request flow continues to behave the same from the caller perspective
- Tests cover success after retry, terminal failure, and non-retriable failure behavior

### Files likely involved

- `src/auth/refresh.ts`
- `src/api/client.ts`
- `src/lib/retry.ts`
- `tests/auth/refresh.test.ts`

### Test plan

- Update or add unit tests for refresh retry behavior
- Verify success when the first refresh attempt fails transiently and a later one succeeds
- Verify failure after max retry attempts
- Verify non-retriable errors do not loop
- Run targeted auth-related tests first, then broader affected suite if available

### Review focus

- Is retry scoped only to refresh, not all outbound requests?
- Are backoff parameters reasonable and readable?
- Is existing helper reused cleanly instead of duplicating retry logic?
- Are public behavior and error contracts preserved?
- Are tests deterministic rather than timing-fragile?

## Final CODEX_HANDOFF

Implement retry with exponential backoff for token refresh in the authenticated request flow.
Start by confirming whether `src/lib/retry.ts` can be reused directly. Prefer reusing it over introducing a second retry abstraction.
Make the smallest safe change centered on `src/auth/refresh.ts`, with only minimal integration changes in `src/api/client.ts` if needed.
Preserve public behavior for callers. Do not broaden retry behavior to unrelated request paths.
Do not touch public auth client interfaces or token storage semantics outside the refresh path.
Before changing retry behavior, verify whether `src/lib/retry.ts` can express the required backoff policy and how transient refresh failures are currently classified.
Add or update tests in `tests/auth/refresh.test.ts` to cover:
1. success after one transient refresh failure
2. terminal failure after max retries
3. immediate failure for non-retriable errors
Keep the implementation easy to review and avoid large refactors.
