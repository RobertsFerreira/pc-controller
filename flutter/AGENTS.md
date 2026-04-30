# AGENTS.md

## Visao Geral

- Cliente Flutter desktop para consumir a API do backend em `http://localhost:3000/api/{version}`.
- Arquitetura baseada em:
  - `core/` para infraestrutura compartilhada
  - `features/` para modulos funcionais
  - DI com `get_it`
  - navegacao por `FeatureModule` e `AppModuleNode`

## Comandos uteis

```bash
flutter pub get
flutter analyze
flutter test
dart format lib test
flutter run
```

## Configuracao

- O app depende de `--dart-define`, principalmente:
  - `CLIENT_URL`
  - `API_VERSION`
  - chaves de log descritas em `flutter/README.md`
- Exemplo comum:

```bash
flutter run --dart-define=CLIENT_URL=http://localhost:3000 --dart-define=API_VERSION=v1
```

## Convencoes importantes

- Inicializacao central em `lib/main.dart` chamando `setupDependencies()`.
- Registros de DI ficam em `lib/core/di/injection_container.dart`.
- A UI nao deve falar direto com `Dio`; acesso a API passa por `HttpClient`.
- Servicos de feature ficam em `lib/features/*/services/`.
- Navegacao e menu devem ser registrados por modulo, nao espalhados manualmente pela UI.
- Preserve o contrato esperado da API:
  - sucesso: `{ data, headers }`
  - erro: `{ code, message, details }`

## Estado atual

- O modulo `audio` ja tem `AudioService` e testes de servico.
- Parte da UI ainda esta em modo placeholder, principalmente as paginas em `lib/features/audio/`.
- Antes de expandir a interface, confirme se a rota backend e o payload ja existem.

## Testes

- Testes atuais ficam em `test/core/` e `test/features/`.
- Prefira mockar `HttpClient` ou servicos, evitando dependencia de backend real.
- Quando mocks e fakes forem igualmente viaveis, prefira `mocktail` para manter os testes menores e com menos helpers customizados.
- Use fakes apenas quando o comportamento sob teste ficar mais claro com um dublê simples do que com stubs/verifies de mock.
- Se alterar contrato HTTP, atualize testes de servico junto.
