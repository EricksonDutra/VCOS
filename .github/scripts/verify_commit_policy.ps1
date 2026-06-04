$ErrorActionPreference = 'Stop'

$branchPattern = '^(feature|fix|hotfix|refactor|docs)\/[a-z0-9]+(-[a-z0-9]+)*$'
$commitPattern = '^(feature|fix|hotfix|refactor|docs)\/[a-z0-9]+(-[a-z0-9]+)*: .+$'
$tagPattern = '^v[0-9]+\.[0-9]+\.[0-9]+$'
$defaultBase = if ($env:GITHUB_BASE_REF) { $env:GITHUB_BASE_REF } else { 'main' }
$currentRef = if ($env:GITHUB_HEAD_REF) { $env:GITHUB_HEAD_REF } else { $env:GITHUB_REF_NAME }

function Write-Policy {
  Write-Host 'Padrao esperado:'
  Write-Host '- Branches: feature/login, fix/correcao-api, hotfix/crash-android, refactor/camada-dados, docs/readme-inicial'
  Write-Host '- Commits:  feature/login: adiciona tela de login'
  Write-Host '- Tags:     v0.1.0, v1.2.3'
}

function Assert-BranchPolicy {
  param([string] $Branch)

  if ([string]::IsNullOrWhiteSpace($Branch)) {
    Write-Error 'Branch nao informada pelo GitHub Actions.'
    Write-Policy
    exit 1
  }

  if ($Branch -match '^(main|master|develop|release\/.+)$') {
    Write-Host "Branch protegida/estrutural aceita: $Branch"
    return
  }

  if ($Branch -notmatch $branchPattern) {
    Write-Error "Nome de branch fora do padrao: $Branch"
    Write-Policy
    exit 1
  }

  Write-Host "Branch valida: $Branch"
}

function Assert-TagPolicy {
  param([string] $Tag)

  if ($Tag -notmatch $tagPattern) {
    Write-Error "Tag fora do padrao semantico: $Tag"
    Write-Policy
    exit 1
  }

  Write-Host "Tag valida: $Tag"
}

function Assert-CommitPolicy {
  param([string] $Range)

  $subjects = git log --format=%s $Range
  if ($LASTEXITCODE -ne 0) {
    throw "Falha ao ler commits no intervalo: $Range"
  }

  $invalid = $false
  foreach ($subject in $subjects) {
    if ([string]::IsNullOrWhiteSpace($subject)) {
      continue
    }

    if ($subject -match '^Merge ' -or $subject -match '^Revert ') {
      Write-Host "Commit estrutural aceito: $subject"
      continue
    }

    if ($subject -notmatch $commitPattern) {
      Write-Host "Commit fora do padrao: $subject"
      $invalid = $true
    }
  }

  if ($invalid) {
    Write-Policy
    exit 1
  }

  Write-Host 'Mensagens de commit validas.'
}

if ($env:GITHUB_REF_TYPE -eq 'tag') {
  Assert-TagPolicy -Tag $currentRef
  exit 0
}

Assert-BranchPolicy -Branch $currentRef

if ($env:GITHUB_EVENT_NAME -eq 'pull_request') {
  git fetch --no-tags --depth=50 origin $defaultBase
  if ($LASTEXITCODE -ne 0) {
    throw "Falha ao buscar base do pull request: $defaultBase"
  }
  Assert-CommitPolicy -Range "origin/$defaultBase..HEAD"
} elseif ($env:GITHUB_EVENT_BEFORE -and $env:GITHUB_EVENT_BEFORE -ne '0000000000000000000000000000000000000000') {
  Assert-CommitPolicy -Range "$env:GITHUB_EVENT_BEFORE..HEAD"
} else {
  Assert-CommitPolicy -Range '-1'
}
