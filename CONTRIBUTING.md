# Guia de Contribuicao

Este projeto usa um fluxo simples para manter qualidade, rastreabilidade e padronizacao entre desenvolvimento, testes e releases.

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

Use o mesmo prefixo da branch no inicio da mensagem:

```bash
git commit -m "feature/dashboard: adiciona cards de resumo"
git commit -m "fix/correcao-validacao: ajusta campos obrigatorios"
git commit -m "docs/readme-inicial: documenta padrao de releases"
```

## Qualidade local

Antes de abrir um pull request, rode:

```bash
flutter pub get
dart format --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

## CI/CD

O GitHub Actions executa:

- Validacao do nome da branch.
- Validacao das mensagens de commit.
- Instalacao das dependencias Flutter.
- Verificacao de formatacao com `dart format --set-exit-if-changed lib test integration_test`.
- Analise estatica com `flutter analyze`.
- Testes automatizados com `flutter test --coverage`.
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
