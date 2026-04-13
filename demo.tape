# codex-handoff demo recording
# Usage: vhs demo.tape
# Requires: vhs (https://github.com/charmbracelet/vhs)
#
# NOTE: This tape simulates the workflow using echo/cat to display
# pre-written output, because Claude Code is an interactive AI session
# that VHS cannot drive end-to-end. The result is a clean demo GIF
# that shows what the real workflow looks like.

Output docs/assets/demo.gif
Output docs/assets/demo.webm

Set Shell "zsh"
Set FontSize 16
Set FontFamily "JetBrains Mono"
Set Width 1400
Set Height 800
Set Padding 20
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms

# ============================================================
# Scene 1: Title
# ============================================================

Type "# codex-handoff: Claude plans, Codex implements"
Sleep 500ms
Enter
Sleep 1s
Type "clear"
Enter
Sleep 500ms

# ============================================================
# Scene 2: Load the plugin
# ============================================================

Type "claude --plugin-dir /path/to/claude-code-codex-handoff"
Sleep 2s
Enter
Sleep 1s

# Simulate Claude Code startup banner
Type "echo ''"
Enter
Type@0ms "echo '  ╭──────────────────────────────────────────╮'"
Enter
Type@0ms "echo '  │  Claude Code          plugin loaded      │'"
Enter
Type@0ms "echo '  │  codex-handoff v1.4.0                    │'"
Enter
Type@0ms "echo '  │                                          │'"
Enter
Type@0ms "echo '  │  Skills:                                 │'"
Enter
Type@0ms "echo '  │    /codex-handoff:handoff [task]         │'"
Enter
Type@0ms "echo '  │    /codex-handoff:review  [scope]        │'"
Enter
Type@0ms "echo '  │                                          │'"
Enter
Type@0ms "echo '  │  Agent:                                  │'"
Enter
Type@0ms "echo '  │    codex-handoff:repo-analyst            │'"
Enter
Type@0ms "echo '  │  ╰──────────────────────────────────────────╯'"
Enter
Sleep 2s

# ============================================================
# Scene 3: Generate handoff
# ============================================================

Type "# Step 1: Describe your task — Claude analyzes the repo"
Enter
Sleep 1s

Set TypingSpeed 30ms
Type "/codex-handoff:handoff Add retry with exponential backoff to the token refresh flow"
Sleep 1s
Enter
Sleep 2s

# Simulate repo-analyst output
Hide
Type "cat << 'DEMO'"
Enter
Type ""
Enter
Type "⠋ Running repo-analyst..."
Enter
Type ""
Enter
Type "# Goal"
Enter
Type "Add retry with exponential backoff to the token refresh path"
Enter
Type "used during authenticated API requests."
Enter
Type ""
Enter
Type "# Repo context"
Enter
Type "Token refresh is in src/auth/refresh.ts, called from src/api/client.ts."
Enter
Type "Reusable retry utility exists at src/lib/retry.ts."
Enter
Type "Tests: tests/auth/refresh.test.ts."
Enter
Type ""
Enter
Type "# Files inspected"
Enter
Type "- read: src/auth/refresh.ts"
Enter
Type "- read: src/api/client.ts"
Enter
Type "- read: src/lib/retry.ts"
Enter
Type "- read: tests/auth/refresh.test.ts"
Enter
Type "- searched: src/auth/**"
Enter
Type ""
Enter
Type "# Constraints"
Enter
Type "- Reuse existing retry helper if it fits"
Enter
Type "- Do not change auth client public API"
Enter
Type "- Keep retry scoped to token refresh only"
Enter
Type ""
Enter
Type "# Do not touch"
Enter
Type "- Public auth client interfaces"
Enter
Type "- Token storage semantics outside refresh path"
Enter
Type ""
Enter
Type "# Acceptance criteria"
Enter
Type "- Token refresh retries on transient failure with exponential backoff"
Enter
Type "- Retry count and delay policy are explicit"
Enter
Type "- Non-transient failures still fail fast"
Enter
Type "- Tests cover: retry-then-success, max-retry failure, non-retriable error"
Enter
Type ""
Enter
Type "# CODEX_HANDOFF"
Enter
Type "Implement retry with exponential backoff for token refresh."
Enter
Type "Reuse src/lib/retry.ts. Smallest safe change in src/auth/refresh.ts."
Enter
Type "Preserve public behavior. Add tests in tests/auth/refresh.test.ts."
Enter
Type "DEMO"
Enter
Show
Sleep 5s

# ============================================================
# Scene 4: Hand off to Codex
# ============================================================

Type "# Step 2: Copy CODEX_HANDOFF → paste into Codex"
Enter
Sleep 1s

Type "/codex:rescue"
Sleep 500ms
Enter
Sleep 1s

# Simulate Codex working
Hide
Type "cat << 'DEMO'"
Enter
Type ""
Enter
Type "⠋ Codex implementing..."
Enter
Type ""
Enter
Type "✓ Modified src/auth/refresh.ts  — added retry wrapper"
Enter
Type "✓ Modified src/api/client.ts    — integrated retry on refresh"
Enter
Type "✓ Updated  tests/auth/refresh.test.ts — 3 new test cases"
Enter
Type "✓ All tests passing (14/14)"
Enter
Type ""
Enter
Type "Implementation complete."
Enter
Type "DEMO"
Enter
Show
Sleep 3s

# ============================================================
# Scene 5: Review
# ============================================================

Type "# Step 3: Claude reviews the implementation"
Enter
Sleep 1s

Set TypingSpeed 30ms
Type "/codex-handoff:review check for regressions and missing tests"
Sleep 500ms
Enter
Sleep 2s

# Simulate review output
Hide
Type "cat << 'DEMO'"
Enter
Type ""
Enter
Type "# Verdict"
Enter
Type "MINOR_FIX"
Enter
Type ""
Enter
Type "# Summary"
Enter
Type "Retry logic is correct and scoped. One edge case needs a guard."
Enter
Type ""
Enter
Type "# Findings"
Enter
Type "- refresh.ts:42 — missing guard for null refresh token before retry"
Enter
Type ""
Enter
Type "# Regression risks"
Enter
Type "- Low. Changes are isolated to the refresh path."
Enter
Type ""
Enter
Type "# Missing tests"
Enter
Type "- No test for null/expired token edge case"
Enter
Type ""
Enter
Type "# Next step"
Enter
Type "Small follow-up: add null-token guard and one test case."
Enter
Type ""
Enter
Type "# Handoff coverage"
Enter
Type "- Retry on transient failure          MET"
Enter
Type "- Explicit retry policy               MET"
Enter
Type "- Non-transient fails fast            MET"
Enter
Type "- Public behavior preserved           MET"
Enter
Type "- Test: retry-then-success            MET"
Enter
Type "- Test: max-retry failure             MET"
Enter
Type "- Test: non-retriable error           MET"
Enter
Type "DEMO"
Enter
Show
Sleep 5s

# ============================================================
# Scene 6: Summary
# ============================================================

Type "clear"
Enter
Sleep 500ms

Hide
Type "cat << 'DEMO'"
Enter
Type ""
Enter
Type "  ╭──────────────────────────────────────────────────────╮"
Enter
Type "  │                                                      │"
Enter
Type "  │   codex-handoff workflow                             │"
Enter
Type "  │                                                      │"
Enter
Type "  │   1. /codex-handoff:handoff  →  Claude plans         │"
Enter
Type "  │   2. /codex:rescue           →  Codex implements     │"
Enter
Type "  │   3. /codex-handoff:review   →  Claude reviews       │"
Enter
Type "  │                                                      │"
Enter
Type "  │   github.com/Eilen6316/claude-code-codex-handoff     │"
Enter
Type "  │                                                      │"
Enter
Type "  ╰──────────────────────────────────────────────────────╯"
Enter
Type ""
Enter
Type "DEMO"
Enter
Show
Sleep 4s
