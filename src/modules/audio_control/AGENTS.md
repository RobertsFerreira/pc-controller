# AGENTS.md

## Visao Geral

- Modulo de audio da API HTTP.
- Responsavel por expor rotas de volume, dispositivos e sessoes usando `axum`.
- O ponto de entrada do modulo e `audio_module.rs`.

## Estrutura Importante

- `audio_module.rs`: registra rotas e converte erros em respostas HTTP.
- `audio_handlers.rs`: orchestration fina dos casos de uso HTTP.
- `services/`: regras de aplicacao para dispositivos e sessoes.
- `platform/`: integracao com Windows e trait `AudioSystemInterface`.
- `models/`, `types/` e `errors/`: contrato interno do modulo.
- `tests/`: mocks e testes HTTP/integracao do modulo.

## Regras de Alteracao

- Preserve as rotas reais do modulo:
  - `GET /api/v1/get_volume`
  - `GET /api/v1/list_devices`
  - `GET /api/v1/list_session/{device_id}`
  - `POST /api/v1/set_group_volume`
- Sempre devolva respostas usando o envelope padrao via helpers do modulo `core`.
- Mantenha acesso ao Windows e COM atras de `AudioSystemInterface` e adapters.
- Ao adicionar uma nova operacao HTTP, atualize em conjunto:
  - `audio_module.rs`
  - `audio_handlers.rs`
  - `services/` ou `models/`, se necessario
  - `tests/`
- Prefira erros de dominio em `errors/` quando a falha precisar mapear status HTTP ou mensagem clara para o cliente.

## Testes

- Prefira mockar o sistema de audio via `tests/mocks.rs`.
- Use `tests/test_server.rs` quando precisar validar contrato HTTP de ponta a ponta.
- Ao alterar contrato, cubra:
  - caminho feliz
  - payload invalido
  - falha de integracao
- Existe drift historico em nomes antigos; valide sempre a rota real antes de ajustar testes ou exemplos.
