# VCOS

<p align="center">
  <img src="web/icons/Icon-192.png" alt="Ícone do VCOS" width="120" />
  <img src="web/icons/Icon-maskable-192.png" alt="Ícone maskable do VCOS" width="120" />
</p>

<p align="center">
  <strong>Aplicativo Flutter para gestão simples de vendas, gastos e resultados de um ateliê artesanal.</strong>
</p>

<p align="center">
  <img alt="CI/CD" src="https://github.com/EricksonDutra/VCOS/actions/workflows/ci-cd.yml/badge.svg" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44.1-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white" />
  <img alt="Licença" src="https://img.shields.io/badge/licença-MIT-green?style=flat-square" />
  <img alt="Status" src="https://img.shields.io/badge/status-em%20desenvolvimento-F2B705?style=flat-square" />
</p>

## Sobre o Projeto

O **VCOS** centraliza a rotina financeira de um ateliê em uma experiência mobile limpa, acessível e preparada para funcionar offline. A proposta é permitir que a artesã registre vendas, acompanhe gastos, visualize indicadores e mantenha os dados essenciais do negócio mesmo antes da integração definitiva com uma API.

## Funcionalidades

- **Início:** resumo financeiro do ateliê com saldo, total de vendas, total de gastos e status de sincronização.
- **Vendas:** cadastro, edição e exclusão lógica de vendas, com cliente, valor, data e sugestões de preenchimento.
- **Gastos:** cadastro, edição, exclusão lógica e visualização detalhada de despesas, incluindo suporte a fotos.
- **Relatórios:** visão consolidada de entradas, saídas, saldo e proporção dos gastos sobre as vendas.
- **Configurações:** dados do ateliê, responsável, telefone, sincronização automática e preferência de alto contraste.
- **Offline-first:** persistência local com `sqflite` e fila de sincronização para integração futura.

## Stack

- **Flutter / Dart** para aplicação multiplataforma.
- **Provider** para gerenciamento de estado.
- **sqflite** para armazenamento local.
- **intl** para formatação.
- **image_picker** para anexos de imagens.
- **pdf**, **printing** e **share_plus** para evolução de exportação e compartilhamento.
- **flutter_test** e **integration_test** para testes automatizados.

## Estrutura

```text
lib/
  app/
    vcos_app.dart
  core/
    data/
    models/
    state/
    sync/
    theme/
    widgets/
  features/
    expenses/
    home/
    reports/
    sales/
    settings/
    shared/
    shell/
test/
integration_test/
web/
android/
```

## Imagens do Projeto

Os ícones abaixo fazem parte do pacote web do aplicativo e representam a identidade visual usada no projeto.

| Ícone principal | Ícone PWA | Ícone maskable |
| --- | --- | --- |
| <img src="web/icons/Icon-512.png" alt="Ícone principal do VCOS" width="160" /> | <img src="web/icons/Icon-192.png" alt="Ícone PWA do VCOS" width="160" /> | <img src="web/icons/Icon-maskable-512.png" alt="Ícone maskable do VCOS" width="160" /> |

> Para screenshots de telas, salve as imagens em `docs/images/` e referencie-as neste README usando caminhos relativos, por exemplo: `docs/images/home.png`.

## Requisitos

- Flutter 3.44.1 ou versão compatível com o SDK definido em `pubspec.yaml`.
- Dart 3.x.
- Android SDK configurado para execução em emulador ou dispositivo físico.

O projeto também possui `.fvmrc`, então é possível usar FVM caso ele esteja instalado no ambiente.

## Como Rodar

Instale as dependências:

```bash
flutter pub get
```

Execute o app:

```bash
flutter run
```

Execute os testes:

```bash
flutter test
```

Analise o código:

```bash
flutter analyze
```

## Fluxo de Desenvolvimento

Crie uma branch a partir da branch principal antes de iniciar qualquer alteração:

```bash
git checkout main
git pull
git checkout -b feature/nome-da-funcionalidade
```

Mantenha commits pequenos, objetivos e relacionados a uma única mudança. Antes de abrir um pull request, rode:

```bash
dart format --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

## CI/CD

O projeto possui um workflow em `.github/workflows/ci-cd.yml` para garantir qualidade e padronização antes de fazer merge ou publicar uma versão.

- Valida nomes de branches.
- Valida mensagens de commit.
- Executa `dart format --set-exit-if-changed lib test integration_test`.
- Executa `flutter analyze`.
- Executa `flutter test --coverage`.
- Publica o arquivo `coverage/lcov.info` como artefato.
- Gera APK release automaticamente quando uma tag `vX.Y.Z` é publicada.

As regras completas estão em `CONTRIBUTING.md`.

## Padrão de Branches e Commits

Use os prefixos abaixo para organizar branches e commits. O nome deve ser curto, em minúsculo e separado por hífen.

### Features

```text
feature/login
feature/dashboard
feature/usuarios
```

### Fixes

```text
fix/correcao-api
fix/correcao-validacao
```

### Hotfixes

```text
hotfix/crash-android
```

### Refactors

```text
refactor/camada-dados
refactor/repositorios
```

### Documentação

```text
docs/readme-inicial
```

Exemplos de commits seguindo o mesmo padrão:

```bash
git commit -m "feature/dashboard: adiciona cards de resumo"
git commit -m "fix/correcao-validacao: ajusta validacao de valores"
git commit -m "docs/readme-inicial: documenta fluxo de releases"
```

## Tags do GitHub

As tags devem marcar pontos estáveis do projeto e seguir versionamento semântico:

```text
v0.1.0
v0.2.0
v1.0.0
```

Padrão recomendado:

- **MAJOR:** mudanças incompatíveis ou grandes reestruturações.
- **MINOR:** novas funcionalidades sem quebrar compatibilidade.
- **PATCH:** correções, ajustes pequenos e melhorias internas.

Criação de tag:

```bash
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0
```

Listagem de tags:

```bash
git tag
```

## Releases do GitHub

Cada release deve ser criada a partir de uma tag publicada. Use a área **Releases** do GitHub para documentar o que mudou e anexar artefatos quando existirem builds distribuíveis.

Modelo recomendado de release:

```markdown
## v0.1.0

### Novidades
- Cadastro local de vendas
- Cadastro local de gastos
- Dashboard financeiro inicial

### Correções
- Ajustes de validação nos formulários

### Observações
- Sincronização com API ainda pendente
```

Boas práticas:

- Crie releases apenas para versões testadas.
- Relacione a release a uma tag `vX.Y.Z`.
- Inclua notas claras para usuários e desenvolvedores.
- Anexe APKs, relatórios ou outros artefatos quando aplicável.

## Qualidade

Antes de fazer merge, valide:

- `dart format --set-exit-if-changed lib test integration_test`
- `flutter analyze`
- `flutter test`
- Navegação principal do app
- Cadastro e edição de vendas
- Cadastro e edição de gastos
- Persistência local e mensagens de sincronização pendente

## Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.
