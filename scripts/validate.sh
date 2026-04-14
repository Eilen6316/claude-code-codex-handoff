#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Checking dependencies"
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed." >&2
  echo "Install it with: brew install jq (macOS) or apt-get install jq (Ubuntu)" >&2
  exit 1
fi

echo "==> Checking required files"
required_files=(
  ".claude-plugin/plugin.json"
  "README.md"
  "README.zh-CN.md"
  "CONTRIBUTING.md"
  "CONTRIBUTING.zh-CN.md"
  "agents/repo-analyst.md"
  "eval/fixtures/handoff-bugfix-en.json"
  "eval/fixtures/handoff-bugfix-zh-CN.json"
  "eval/fixtures/handoff-feature-en.json"
  "eval/fixtures/handoff-feature-zh-CN.json"
  "eval/fixtures/review-output-en.json"
  "eval/fixtures/review-output-zh-CN.json"
  "docs/examples/README.md"
  "docs/examples/feature-handoff.en.md"
  "docs/examples/feature-handoff.zh-CN.md"
  "docs/examples/bugfix-handoff.en.md"
  "docs/examples/bugfix-handoff.zh-CN.md"
  "docs/examples/review-output.en.md"
  "docs/examples/review-output.zh-CN.md"
  "scripts/eval-fixtures.sh"
  "skills/handoff/SKILL.md"
  "skills/review/SKILL.md"
  "docs/WORKFLOW.en.md"
  "docs/WORKFLOW.zh-CN.md"
)

for path in "${required_files[@]}"; do
  [[ -f "$path" ]] || {
    echo "Missing required file: $path" >&2
    exit 1
  }
done

echo "==> Validating plugin manifest JSON"
jq empty .claude-plugin/plugin.json

echo "==> Checking frontmatter markers"
frontmatter_files=(
  "agents/repo-analyst.md"
  "skills/handoff/SKILL.md"
  "skills/review/SKILL.md"
)

for path in "${frontmatter_files[@]}"; do
  first_line="$(sed -n '1p' "$path" | tr -d '\xEF\xBB\xBF\r')"
  if [[ "$first_line" != "---" ]]; then
    echo "Frontmatter missing in $path" >&2
    exit 1
  fi
done

echo "==> Checking plugin name and version fields"
plugin_name="$(jq -r '.name' .claude-plugin/plugin.json)"
plugin_version="$(jq -r '.version' .claude-plugin/plugin.json)"
[[ "$plugin_name" == "codex-handoff" ]] || {
  echo "Unexpected plugin name: $plugin_name" >&2
  exit 1
}
[[ -n "$plugin_version" && "$plugin_version" != "null" ]] || {
  echo "Plugin version is missing" >&2
  exit 1
}
marketplace_version="$(jq -r '.plugins[0].version' .claude-plugin/marketplace.json)"
if [[ "$plugin_version" != "$marketplace_version" ]]; then
  echo "Version mismatch: plugin.json=$plugin_version, marketplace.json=$marketplace_version" >&2
  exit 1
fi

echo "==> Running fixture evals"
bash scripts/eval-fixtures.sh

echo "==> Checking pipeline contract"
# Cross-skill references
grep -q 'codex:rescue' skills/handoff/SKILL.md || {
  echo "Handoff skill does not reference codex:rescue" >&2
  exit 1
}
grep -q 'codex-handoff:review' skills/handoff/SKILL.md || {
  echo "Handoff skill does not reference codex-handoff:review" >&2
  exit 1
}
# Flags
grep -q '\-\-no-exec' skills/handoff/SKILL.md || {
  echo "Handoff skill missing --no-exec flag" >&2
  exit 1
}
for flag in "--background" "--model" "--effort"; do
  grep -q -- "$flag" skills/handoff/SKILL.md || {
    echo "Handoff skill missing flag: $flag" >&2
    exit 1
  }
done
# File linkage
grep -q '.codex-handoff/latest.md' skills/handoff/SKILL.md || {
  echo "Handoff skill does not reference .codex-handoff/latest.md" >&2
  exit 1
}
grep -q '.codex-handoff/latest.md' skills/review/SKILL.md || {
  echo "Review skill does not reference .codex-handoff/latest.md" >&2
  exit 1
}
# No hardcoded version in metadata
if grep -q 'codex-handoff v[0-9]' skills/handoff/SKILL.md; then
  echo "Handoff skill has hardcoded version in metadata comment" >&2
  exit 1
fi
for ex in docs/examples/*-handoff.*.md; do
  if grep -q 'codex-handoff v[0-9]' "$ex"; then
    echo "Example $ex has hardcoded version in metadata comment" >&2
    exit 1
  fi
done
# Skill tool permission
handoff_frontmatter="$(sed -n '1,/^---$/{ /^---$/d; p; }' skills/handoff/SKILL.md | tail -n +2)"
if ! echo "$handoff_frontmatter" | grep -q 'allowed-tools:.*Skill'; then
  echo "Handoff skill frontmatter missing 'Skill' in allowed-tools" >&2
  exit 1
fi
# CODEX_HANDOFF boundary marker
grep -q '# CODEX_HANDOFF' skills/handoff/SKILL.md || {
  echo "Handoff skill missing # CODEX_HANDOFF boundary marker" >&2
  exit 1
}

if command -v claude >/dev/null 2>&1; then
  echo "==> Running Claude CLI plugin validation"
  claude plugins validate .

  echo "==> Checking that plugin agent loads in Claude CLI"
  agent_output="$(claude --plugin-dir . agents)"
  printf '%s\n' "$agent_output"
  grep -q "codex-handoff:repo-analyst" <<<"$agent_output" || {
    echo "Plugin agent was not detected by Claude CLI" >&2
    exit 1
  }
else
  echo "==> Skipping Claude CLI validation because 'claude' is not installed"
fi

echo "Validation passed."
