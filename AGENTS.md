# AGENTS.md

## Visao Geral

- Repositorio com dois blocos principais:
  - `src/`: backend Rust para controle de audio no Windows
  - `flutter/`: cliente Flutter desktop
- O backend ativo hoje e HTTP com `axum`. WebSocket existe como legado e nao deve ser tratado como fluxo principal.
- Se a tarefa for no Flutter, leia tambem `flutter/AGENTS.md`.

## Backend Rust

### Fluxo principal

- Entrada em `src/main.rs`
- App HTTP em `src/modules/app_router.rs`
- Registro de modulos em `src/modules/core/registry/module_registry.rs`
- Modulo principal atual: `audio` em `src/modules/audio_control/`
- Adaptacao com Windows API via `AudioSystemInterface` e `WindowsAudioAdapter`

### Rotas reais

- `GET /api/v1/get_volume`
- `GET /api/v1/list_devices`
- `GET /api/v1/list_session/{device_id}`
- `POST /api/v1/set_group_volume`

### Comandos uteis

```bash
cargo build
cargo fmt --check
cargo clippy
cargo test
```

### Convencoes importantes

- Use `anyhow::Result<T>` como padrao e `thiserror` para erros de dominio quando fizer sentido.
- Preserve o envelope de resposta HTTP:
  - sucesso: `{ "data": ..., "headers": { "timestamp": ..., "count": ...? } }`
  - erro: `{ "code": ..., "message": ..., "details": ... }`
- Novos modulos HTTP devem implementar `ModuleHandler` e ser registrados no `ModuleRegistry`.
- Prefira isolar acesso ao Windows/COM atras de traits e adapters para manter testes mockaveis.
- Mantenha imports agrupados em `std -> crates externas -> crate interna`.
- Nomeacao: `snake_case` para funcoes/modulos, `PascalCase` para tipos, sufixo `Error` para erros.

### Testes

- Testes do backend ficam principalmente em `src/modules/audio_control/tests/`.
- Prefira mockar `AudioSystemInterface` em vez de depender do Windows real.
- Ao alterar handlers, rotas ou contratos, cubra:
  - caminho feliz
  - erro de validacao
  - erro de integracao

## Estrutura resumida

```text
src/
  main.rs
  modules/
    app_router.rs
    audio_control/
    core/
flutter/
  lib/
  test/
PC-Controller/
  *.bru
```

## Notas de manutencao

- Alguns nomes e comentarios antigos ainda citam WebSocket; confira o codigo real antes de seguir a documentacao.
- Existe sinal de drift em partes do projeto, entao valide nomes de rota e arquivos antes de editar testes ou exemplos.
