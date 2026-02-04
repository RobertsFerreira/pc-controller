# PC Controller

API WebSocket para controle de dispositivos de áudio e sessões de áudio no Windows.

## Características

- Controle de volume de dispositivos de saída de áudio
- Listagem de dispositivos de áudio disponíveis
- Gerenciamento de sessões de áudio por aplicativo
- Comunicação via WebSocket para tempo real
- API JSON simples e intuitiva

## Pré-requisitos

- Windows 10 ou superior
- Rust 2021 edition
- Cargo (vem com Rust)

## Instalação

```bash
git clone https://github.com/RobertsFerreira/pc-controller

cd pc-controller
cargo build --release
```

## Como Usar

### Iniciar o Servidor

```bash
cargo run
```

O servidor iniciará em `ws://localhost:3000/ws`

### Conectar via WebSocket

Conecte-se ao endpoint `/ws` e envie mensagens JSON:

```json
{
  "module": "audio",
  "action": "devices_list"
}
```

## Estrutura do Projeto

```MD
src/
├── main.rs                    # Entry point - WebSocket server
└── modules/
    ├── core/                  # Funcionalidades globais
    │   ├── broadcast.rs       # Sistema de broadcast para clientes
    │   ├── global_handler.rs  # Roteador de mensagens
    │   ├── response_builder.rs # Construtor de respostas JSON
    │   └── models/            # Tipos globais
    └── volume_control/        # Controle de áudio
        ├── audio_handlers.rs  # Handlers de mensagens WebSocket
        ├── com_utils.rs       # Utilitários COM do Windows
        ├── sound_device_service.rs    # Controle de dispositivos
        ├── sound_session_service.rs   # Controle de sessões
        ├── volume_control_command.rs  # Comandos de controle
        └── models/            # Tipos relacionados a áudio
```

## Desenvolvimento

### Comandos de Build

```bash
cargo build                    # Debug build
cargo build --release          # Release build
cargo run                      # Build e run
```

### Linting

```bash
cargo clippy                   # Verifica código
cargo fmt                      # Formata código
```

### Testes

```bash
cargo test                     # Executa todos os testes
```

### Documentação

```bash
cargo doc --open               # Gera e abre documentação
```

## Documentação Adicional

- [EXAMPLES.md](EXAMPLES.md) - Exemplos completos da API
- [AGENTS.md](AGENTS.md) - Guia de desenvolvimento e padrões

## Tecnologias

- **axum** - Web framework com suporte WebSocket
- **tokio** - Runtime async
- **serde** - Serialização/deserialização JSON
- **windows** - Bindings para Windows API
- **anyhow** - Error handling
- **thiserror** - Custom error types
