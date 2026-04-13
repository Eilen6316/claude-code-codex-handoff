# Bugfix Handoff Example

## Raw user request

Fix the bug where the search filter resets after pagination. Preserve the current
URL format if possible. Add a regression test.

## Repository findings

- Search state appears to live in `src/features/search/useSearchState.ts`
- Pagination UI likely updates query params in `src/features/search/SearchResults.tsx`
- Router helpers appear to be shared from `src/lib/router/query.ts`
- Existing search state tests appear to live in `tests/search/search-state.test.ts`

## Structured brief

### Goal

Fix the search filter reset bug that occurs after pagination.

### Repo context

Search state appears to be derived from query parameters in `src/features/search/useSearchState.ts`. Pagination behavior likely updates the URL from `src/features/search/SearchResults.tsx`. Shared query parameter helpers seem to live in `src/lib/router/query.ts`.

### Constraints

- Preserve the existing URL format if possible
- Keep the fix scoped to search state and pagination synchronization
- Avoid rewriting the search page architecture
- Add a regression test for the failing flow

### Non-goals

- Do not redesign search routing
- Do not rename query parameter keys unless absolutely necessary
- Do not refactor unrelated pagination components

### Acceptance criteria

- Active filters remain applied after moving to the next or previous page
- URL parameters continue to represent the active search state
- Existing non-filter pagination behavior still works
- Regression test covers the original bug

### Files likely involved

- `src/features/search/useSearchState.ts`
- `src/features/search/SearchResults.tsx`
- `src/lib/router/query.ts`
- `tests/search/search-state.test.ts`

### Test plan

- Reproduce the bug locally through the current search page flow
- Add or update a regression test covering filter persistence across pagination
- Verify pagination still updates page index correctly
- Verify direct URL navigation with filters still hydrates correctly

### Review focus

- Is the fix preserving URL compatibility?
- Does pagination merge state rather than overwrite it?
- Are filters and page index derived consistently from the same source?
- Is the regression test representative of the real failure?

## Final CODEX_HANDOFF

Fix the bug where active search filters reset after pagination.
Focus on how pagination updates query parameters and how search state is rehydrated from the URL.
Prefer the smallest safe fix that keeps the current URL format intact.
Investigate `src/features/search/useSearchState.ts`, `src/features/search/SearchResults.tsx`, and any shared query helpers in `src/lib/router/query.ts`.
Add a regression test in `tests/search/search-state.test.ts` that proves filters persist when moving between pages.
Do not expand this into a broad search routing refactor.
