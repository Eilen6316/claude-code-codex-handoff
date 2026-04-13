#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Evaluating handoff example fixtures"

for fixture in eval/fixtures/*.json; do
  example_file="$(jq -r '.example_file' "$fixture")"
  example_path="$ROOT_DIR/$example_file"

  [[ -f "$example_path" ]] || {
    echo "Fixture points to missing file: $example_file" >&2
    exit 1
  }

  echo "Checking $(basename "$fixture") against $example_file"

  while IFS= read -r section; do
    [[ -n "$section" ]] || continue
    grep -Fq "$section" "$example_path" || {
      echo "Missing required section '$section' in $example_file" >&2
      exit 1
    }
  done < <(jq -r '.required_strings[]' "$fixture")
done

echo "Fixture evals passed."
