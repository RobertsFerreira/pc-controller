# AGENTS.md

## Visao Geral

- Feature principal do cliente Flutter hoje.
- Exibe dispositivos e sessoes de audio consumindo a API do backend.
- Registro de DI e navegacao ficam em `audio_feature_module.dart`.

## Estrutura Importante

- `audio_feature_module.dart`: registra `AudioService` e `AudioBrowserController`.
- `audio_page.dart`: pagina unica da feature com selecao de saida e lista de sessoes.
- `services/audio_service.dart`: conversa com a API via `HttpClient`.
- `state/audio_browser_controller.dart`: orquestra carregamento e selecao.
- `state/audio_browser_state.dart`: estado observado pela UI.
- `models/` e `errors/`: contrato e tratamento local da feature.
- `widgets/`: componentes visuais reutilizaveis da feature.

## Regras de Alteracao

- A UI nao deve acessar `Dio` nem montar requests direto; use `HttpClient` via `AudioService`.
- Preserve o fluxo atual:
  - service busca dados
  - controller traduz para estado
  - page observa estado e renderiza
- Se mudar rota, payload ou parsing, atualize em conjunto:
  - `services/audio_service.dart`
  - `models/`
  - `state/`
  - testes da feature
- Mantenha a pagina unica de audio enxuta, delegando a apresentacao para os componentes em `widgets/`.
- Preserve tokens de layout e tema via `theme_context.dart`; evite estilos soltos na feature.
- Textos visiveis para o usuario devem sair do catalogo em `assets/i18n/`.

## Testes

- Testes atuais ficam em `flutter/test/features/audio/`.
- Prefira mockar `HttpClient` nos testes de service e `AudioService` nos testes de controller.
- Ao alterar comportamento, cubra:
  - resposta com dados
  - resposta vazia
  - erro propagado ou traduzido para estado

## Integracao

- Esta feature depende do contrato HTTP do backend em `/api/v1`.
- Antes de implementar nova acao, confirme se a rota backend ja existe e se segue o envelope `{ data, headers }`.
