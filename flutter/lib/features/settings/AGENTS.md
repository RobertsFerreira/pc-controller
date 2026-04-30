# AGENTS.md

## Visao Geral

- Espaco reservado para a futura feature de configuracoes.
- O diretorio existe, mas ainda nao tem implementacao ativa.

## Regras de Implementacao

- Antes de criar UI, confirme quais configuracoes pertencem ao app Flutter, ao backend ou ao ambiente.
- Ao iniciar a feature, prefira esta estrutura:
  - `settings_feature_module.dart` para DI e navegacao
  - `services/` para integracoes
  - `state/` para estado observavel, se necessario
  - `models/` para contratos locais
  - paginas em `lib/features/settings/`
- Se houver chamadas HTTP, use `HttpClient` e preserve o envelope `{ data, headers }`.
- Evite assumir endpoints de configuracao sem confirmar que eles existem no backend.

## Testes

- Crie testes junto com os primeiros arquivos reais da feature.
- Prefira mocks de `HttpClient` ou de services, sem dependencia de backend real.
