$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$fvmDart = Join-Path $repoRoot '.fvm\flutter_sdk\bin\cache\dart-sdk\bin\dart.exe'
$dartCommand = if (Test-Path $fvmDart) { $fvmDart } else { 'dart' }

$localToolHome = Join-Path $repoRoot '.dart-cli-home'
$env:APPDATA = Join-Path $localToolHome 'Roaming'
$env:LOCALAPPDATA = Join-Path $localToolHome 'Local'
$env:DART_SUPPRESS_ANALYTICS = 'true'

New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA | Out-Null

& $dartCommand format `
  --page-width 80 `
  --trailing-commas automate `
  --language-version 3.3 `
  --set-exit-if-changed `
  lib `
  test `
  integration_test

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
