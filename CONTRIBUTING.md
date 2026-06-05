# Guia de Contribuicao

Este projeto usa um fluxo simples para manter qualidade, rastreabilidade e padronizacao entre
desenvolvimento, testes e releases.

## Branches

Use nomes curtos, em minusculo e separados por hifen:

```text
feature/login
feature/dashboard
feature/usuarios
fix/correcao-api
fix/correcao-validacao
hotfix/crash-android
refactor/camada-dados
refactor/repositorios
docs/readme-inicial
```

Branches estruturais aceitas pelo CI:

```text
main
develop
release/*
```

## Commits

Use mensagens curtas e objetivas. O CI aceita tres formatos:

```bash
git commit -m "feature/dashboard: adiciona cards de resumo"
git commit -m "feat(dashboard): adiciona cards de resumo"
git commit -m "Improve dashboard accessibility"
```

Evite mensagens genericas como `wip`, `teste`, `ajustes` ou `alteracoes`.

## Qualidade local

Antes de abrir um pull request, rode:

```bash
flutter pub get
powershell -NoProfile -ExecutionPolicy Bypass -File .github/scripts/dart_format_check.ps1
flutter analyze
flutter test
pip install -r backend/requirements-dev.txt
python -m compileall backend/app
ruff format --check backend/app
ruff check backend/app
npx --yes prettier@3.5.3 --check "**/*.{md,yml,yaml,json}"
```

## CI/CD

O GitHub Actions executa:

- Validacao do nome da branch.
- Validacao das mensagens de commit.
- Instalacao das dependencias Flutter.
- Verificacao de formatacao com `.github/scripts/dart_format_check.ps1`.
- Analise estatica com `flutter analyze`.
- Testes automatizados com `flutter test --coverage`.
- Verificacao Python com `ruff format --check backend/app` e `ruff check backend/app`.
- Verificacao de docs/configs com `prettier`.
- Build de APK release quando uma tag `vX.Y.Z` for publicada.

## Tags e releases

Tags devem seguir versionamento semantico:

```text
v0.1.0
v0.2.0
v1.0.0
```

Para publicar:

```bash
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0
```

Ao publicar a tag, o workflow gera o APK de release como artefato do GitHub Actions.
