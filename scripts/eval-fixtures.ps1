$ErrorActionPreference = "Stop"

$rootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $rootDir

Write-Host "==> Evaluating handoff example fixtures"

$fixtures = Get-ChildItem -Path "eval/fixtures" -Filter "*.json" | Sort-Object Name

foreach ($fixture in $fixtures) {
    $fixtureData = Get-Content -Raw -Path $fixture.FullName | ConvertFrom-Json
    $exampleFile = $fixtureData.example_file
    $examplePath = Join-Path $rootDir $exampleFile

    if (-not (Test-Path $examplePath)) {
        throw "Fixture points to missing file: $exampleFile"
    }

    Write-Host "Checking $($fixture.Name) against $exampleFile"

    $exampleContent = Get-Content -Raw -Path $examplePath

    foreach ($requiredString in $fixtureData.required_strings) {
        if ([string]::IsNullOrWhiteSpace($requiredString)) {
            continue
        }
        if (-not $exampleContent.Contains($requiredString)) {
            throw "Missing required section '$requiredString' in $exampleFile"
        }
    }
}

Write-Host "Fixture evals passed."
