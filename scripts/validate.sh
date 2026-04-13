#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Checking required files"
required_files=(
  ".claude-plugin/plugin.json"
  "README.md"
  "README.zh-CN.md"
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
  first_line="$(sed -n '1p' "$path")"
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

echo "==> Running fixture evals"
bash scripts/eval-fixtures.sh

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
