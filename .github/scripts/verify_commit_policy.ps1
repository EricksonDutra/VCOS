$ErrorActionPreference = 'Stop'

$branchSegment = '[a-z0-9]+(-[a-z0-9]+)*'
$branchPattern = "^(feature|fix|hotfix|refactor|docs)\/$branchSegment(\/$branchSegment)*$"
$legacyCommitPattern = "^(feature|fix|hotfix|refactor|docs)\/$branchSegment(\/$branchSegment)*: .{3,}$"
$conventionalCommitPattern = '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|hotfix)(\([a-z0-9]+(-[a-z0-9]+)*\))?: .{3,}$'
$descriptiveCommitPattern = '^[\p{L}\p{N}][\p{L}\p{N}\s.,:;!?()\[\]\/+"-]{9,119}$'
$blockedCommitPattern = '^(wip|tmp|temp|teste?|test|asdf|alteracoes?|ajustes?)$'
$tagPattern = '^v[0-9]+\.[0-9]+\.[0-9]+$'
$defaultBase = if ($env:GITHUB_BASE_REF) { $env:GITHUB_BASE_REF } else { 'main' }
$currentRef = if ($env:GITHUB_HEAD_REF) { $env:GITHUB_HEAD_REF } else { $env:GITHUB_REF_NAME }

function Write-Policy {
  Write-Host 'Padrao esperado:'
  Write-Host '- Branches: feature/minha-tarefa, fix/correcao-api, hotfix/crash-android, refactor/camada-dados, docs/readme-inicial'
  Write-Host '- Commits:  feature/minha-tarefa: adiciona tela, feat(tela): adiciona tela, ou titulo descritivo objetivo'
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

    if (-not (Test-CommitSubject -Subject $subject)) {
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

function Test-CommitSubject {
  param([string] $Subject)

  $normalized = $Subject.Trim()
  if ([string]::IsNullOrWhiteSpace($normalized)) {
    return $false
  }

  if ($normalized -match $blockedCommitPattern) {
    return $false
  }

  return (
    $normalized -match $legacyCommitPattern -or
    $normalized -match $conventionalCommitPattern -or
    $normalized -match $descriptiveCommitPattern
  )
}

function Test-GitRevision {
  param([string] $Revision)

  git rev-parse --verify --quiet "$Revision^{commit}" *> $null
  return $LASTEXITCODE -eq 0
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
  if (Test-GitRevision -Revision $env:GITHUB_EVENT_BEFORE) {
    Assert-CommitPolicy -Range "$env:GITHUB_EVENT_BEFORE..HEAD"
  } else {
    Write-Host "Commit base nao disponivel no checkout: $env:GITHUB_EVENT_BEFORE"
    Assert-CommitPolicy -Range '-1'
  }
} else {
  Assert-CommitPolicy -Range '-1'
}
