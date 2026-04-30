# AGENTS.md

## Visao Geral

- Modulo compartilhado da API.
- Centraliza infraestrutura HTTP, registro de modulos, envelope de resposta e utilitarios comuns.
- Nao coloque regra de negocio especifica de `audio_control` aqui.

## Estrutura Importante

- `registry/module_registry.rs`: registro e composicao das rotas dos modulos.
- `traits/module_handler.rs`: contrato dos modulos HTTP.
- `response/response_builder.rs`: cria respostas de sucesso e erro no formato padrao.
- `models/api_response.rs`: tipos do envelope `{ data, headers }`.
- `errors/`: erros compartilhados da camada HTTP.
- `tests_support/`: helpers para testes de servidor.
- `broadcasting/`: legado de eventos; nao trate como fluxo principal sem confirmar necessidade real.

## Regras de Alteracao

- Preserve o envelope HTTP padrao:
  - sucesso: `{ "data": ..., "headers": { "timestamp": ..., "count": ...? } }`
  - erro: `{ "code": ..., "message": ..., "details": ... }`
- Novas capacidades compartilhadas devem ser genericas e reutilizaveis por mais de um modulo.
- Se um helper serve apenas ao audio, mantenha em `audio_control/` em vez de mover para `core/`.
- Mudancas em registro de rotas ou `ModuleHandler` podem impactar todos os modulos; revise a composicao da API inteira antes de finalizar.
- Prefira manter utilitarios pequenos e testaveis, sem acoplamento ao Windows real.

## Testes

- Quando alterar `response/`, `registry/` ou `traits/`, valide os testes HTTP dos modulos consumidores.
- Se criar helpers de teste em `tests_support/`, mantenha a API simples e focada em cenarios de integracao.
