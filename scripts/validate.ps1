$ErrorActionPreference = "Stop"

$rootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $rootDir

Write-Host "==> Checking required files"
$requiredFiles = @(
    ".claude-plugin/plugin.json",
    ".claude-plugin/marketplace.json",
    "README.md",
    "README.zh-CN.md",
    "CONTRIBUTING.md",
    "CONTRIBUTING.zh-CN.md",
    "agents/repo-analyst.md",
    "eval/fixtures/handoff-bugfix-en.json",
    "eval/fixtures/handoff-bugfix-zh-CN.json",
    "eval/fixtures/handoff-feature-en.json",
    "eval/fixtures/handoff-feature-zh-CN.json",
    "eval/fixtures/review-output-en.json",
    "eval/fixtures/review-output-zh-CN.json",
    "docs/examples/README.md",
    "docs/examples/feature-handoff.en.md",
    "docs/examples/feature-handoff.zh-CN.md",
    "docs/examples/bugfix-handoff.en.md",
    "docs/examples/bugfix-handoff.zh-CN.md",
    "docs/examples/review-output.en.md",
    "docs/examples/review-output.zh-CN.md",
    "scripts/eval-fixtures.sh",
    "scripts/eval-fixtures.ps1",
    "scripts/validate.sh",
    "scripts/validate.ps1",
    "skills/handoff/SKILL.md",
    "skills/review/SKILL.md",
    "docs/WORKFLOW.en.md",
    "docs/WORKFLOW.zh-CN.md"
)

foreach ($path in $requiredFiles) {
    if (-not (Test-Path $path)) {
        throw "Missing required file: $path"
    }
}

Write-Host "==> Validating plugin manifest JSON"
$null = Get-Content -Raw ".claude-plugin/plugin.json" | ConvertFrom-Json
$null = Get-Content -Raw ".claude-plugin/marketplace.json" | ConvertFrom-Json

Write-Host "==> Checking frontmatter markers"
$frontmatterFiles = @(
    "agents/repo-analyst.md",
    "skills/handoff/SKILL.md",
    "skills/review/SKILL.md"
)

foreach ($path in $frontmatterFiles) {
    $firstLine = (Get-Content -Path $path -TotalCount 1).Trim([char]0xFEFF, [char]0x0D, [char]0x0A)
    if ($firstLine -ne "---") {
        throw "Frontmatter missing in $path"
    }
}

Write-Host "==> Checking plugin name and version fields"
$plugin = Get-Content -Raw ".claude-plugin/plugin.json" | ConvertFrom-Json
$marketplace = Get-Content -Raw ".claude-plugin/marketplace.json" | ConvertFrom-Json

if ($plugin.name -ne "codex-handoff") {
    throw "Unexpected plugin name: $($plugin.name)"
}
if ([string]::IsNullOrWhiteSpace($plugin.version)) {
    throw "Plugin version is missing"
}
if ($plugin.version -ne $marketplace.plugins[0].version) {
    throw "Version mismatch: plugin.json=$($plugin.version), marketplace.json=$($marketplace.plugins[0].version)"
}

Write-Host "==> Running fixture evals"
& (Join-Path $PSScriptRoot "eval-fixtures.ps1")

Write-Host "==> Checking pipeline contract"
$handoffSkill = Get-Content -Raw "skills/handoff/SKILL.md"
$reviewSkill = Get-Content -Raw "skills/review/SKILL.md"

if (-not $handoffSkill.Contains("codex:rescue")) {
    throw "Handoff skill does not reference codex:rescue"
}
if (-not $handoffSkill.Contains("codex-handoff:review")) {
    throw "Handoff skill does not reference codex-handoff:review"
}
if (-not $handoffSkill.Contains("--no-exec")) {
    throw "Handoff skill missing --no-exec flag"
}
foreach ($flag in @("--background", "--model", "--effort")) {
    if (-not $handoffSkill.Contains($flag)) {
        throw "Handoff skill missing flag: $flag"
    }
}
if (-not $handoffSkill.Contains(".codex-handoff/latest.md")) {
    throw "Handoff skill does not reference .codex-handoff/latest.md"
}
if (-not $reviewSkill.Contains(".codex-handoff/latest.md")) {
    throw "Review skill does not reference .codex-handoff/latest.md"
}
if ($handoffSkill -match "codex-handoff v[0-9]") {
    throw "Handoff skill has hardcoded version in metadata comment"
}
foreach ($example in Get-ChildItem "docs/examples" -Filter "*-handoff.*.md") {
    $content = Get-Content -Raw $example.FullName
    if ($content -match "codex-handoff v[0-9]") {
        throw "Example $($example.FullName) has hardcoded version in metadata comment"
    }
}
if ($handoffSkill -notmatch "allowed-tools:.*Skill") {
    throw "Handoff skill frontmatter missing 'Skill' in allowed-tools"
}
if (-not $handoffSkill.Contains("# CODEX_HANDOFF")) {
    throw "Handoff skill missing # CODEX_HANDOFF boundary marker"
}

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "==> Running Claude CLI plugin validation"
    & claude plugins validate .

    Write-Host "==> Checking that plugin agent loads in Claude CLI"
    $agentOutput = & claude --plugin-dir . agents
    $agentOutput | ForEach-Object { Write-Host $_ }

    if (-not ($agentOutput -join "`n").Contains("codex-handoff:repo-analyst")) {
        throw "Plugin agent was not detected by Claude CLI"
    }
}
else {
    Write-Host "==> Skipping Claude CLI validation because 'claude' is not installed"
}

Write-Host "Validation passed."
