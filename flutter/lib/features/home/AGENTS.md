# AGENTS.md

## Visao Geral

- Feature de entrada da aplicacao.
- Hoje e um modulo leve e principalmente apresentacional.
- Navegacao do modulo fica em `home_feature_module.dart`.

## Regras de Alteracao

- Mantenha a Home simples enquanto ela for apenas uma porta de entrada para outras areas.
- Nao adicione acesso direto a API sem uma necessidade clara de produto.
- Se a feature ganhar estado ou integracao, siga o padrao usado em `features/audio/`:
  - service para acesso a dados
  - controller ou state holder para estado
  - testes dedicados
- Preserve o uso dos tokens de tema e layout compartilhados.

## Testes

- Se a Home continuar estatica, testes podem focar em renderizacao e navegacao.
- Se passar a ter comportamento, crie testes de widget ou controller no mesmo estilo das demais features.
