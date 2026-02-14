# AGENTS.md

## Build, Lint, and Test Commands

### Build

```bash
cargo build                    # Debug build
cargo build --release          # Release build
cargo run                      # Build and run
```

### Linting

```bash
cargo clippy                   # Run clippy linter
cargo fmt                      # Format code (rustfmt)
cargo fmt --check              # Check formatting without making changes
```

### Testing

```bash
cargo test                     # Run all tests
cargo test <test_name>         # Run single test
cargo test --lib               # Run library tests only
cargo test --bins              # Run binary tests only
cargo test -- --nocapture      # Show test output
```

## Code Style Guidelines

### Imports and Modules

- Group imports: std → external crates → internal crate
- Use `use crate::` prefix for internal imports
- Module structure: each module directory contains `mod.rs` with submodule declarations (except top-level modules which use implicit module discovery)
- Re-export commonly used types in `mod.rs` with `pub use`

Example:

```rust
use std::{collections::HashMap, path::Path};
use windows::Win32::Media::Audio::*;
use crate::modules::audio_control::errors::AudioError;
```

### Formatting

- Rust 2021 edition
- 4-space indentation
- Struct fields on separate lines for clarity
- Blank line between function definitions
- Match arms and if-else blocks with consistent indentation

### Types and Serde

- Use `anyhow::Result<T>` for most error handling
- Custom errors with `thiserror::Error` derive macro
- Serde derives: `#[derive(Debug, Serialize, Deserialize)]`
- Enum variants with `#[serde(tag = "action", rename_all = "snake_case")]`
- Use `#[serde(skip)]` for fields that shouldn't be serialized or deserialized
- Use `#[serde(skip_serializing_if = "path")]` for fields that should be conditionally skipped during serialization

Example:

```rust
#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "action", rename_all = "snake_case")]
pub enum ActionRequest {
    GetVolume,
    DevicesList,
    SessionList { device_id: String },
    SetGroupVolume { device_id: String, group_id: String, volume: f32 },
}
```

### Naming Conventions

- Functions and modules: `snake_case`
- Types, structs, enums: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Error types: end with `Error` (e.g., `SessionError`)
- Result types: `TypeName + Result` (e.g., `SessionResult<T>`)
- Handler functions: prefix with `handle_` (e.g., `handle_get_volume`)

### Error Handling

- Use `anyhow::Result<T>` as default return type
- Add context with `.context("description")`
- Log errors with `tracing::error!("message: {:?}", e)` before returning
- Convert errors to appropriate HTTP status codes in handlers
- Custom error types in `models::errors` module using `thiserror`
- Pattern match on errors to provide specific responses

Example:

```rust
use anyhow::{Context, Result};

async fn get_volume() -> Result<f32> {
    device_controller::get_volume()
        .context("Failed to get volume")?
}
```

### Windows-Specific Patterns

- Wrap Windows API calls in `unsafe` blocks
- COM initialization: use `ComContext::new()` for RAII-style COM management (auto-cleanup on drop)
- Use `?` operator for HRESULT to Result conversion via windows crate
- Use `format!("{:?}", guid)` to convert GUIDs to string representation
- ComContext automatically handles COM cleanup in all paths via Drop trait

### Async Functions

- All handlers are async: `pub async fn handler_name() -> Message`
- Use `await` on async calls
- Return `Message` type from WebSocket handlers
- Pattern: `handle_` → separate `_response` function → return Message

Example:

```rust
pub async fn handle_get_volume() -> Message {
    match get_volume_response().await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed: {:?}", e);
            create_error_response(500, &e.to_string())
        }
    }
}
```

### Structs and Data Models

- All public structs derive `Debug`
- Add `Serialize` for any data sent to clients
- Add `Display` impl for user-friendly string representation
- Group related structs in same module (e.g., `models/requests.rs`, `models/responses.rs`)
- Use timestamp in response headers as Unix timestamp seconds

### Logging

- Use `println!` for basic debugging output
- Use `tracing::error!` for errors
- Use `tracing::info!` for informational messages (when needed)

### WebSocket Message Handling

- Convert incoming messages with `msg.to_text().unwrap_or(...)`
- Deserialize JSON with `serde_json::from_str(text).context(...)`
- Return `Message::text(...)` for responses
- Match on enum variants to route to appropriate handlers

### Response Structure

Standard response format:

```rust
{
    "data": <payload>,
    "headers": {
        "timestamp": <u64>,
        "count": <usize>  // optional for lists
    }
}
```

Standard error format:

```rust
{
    "code": <u16>,
    "message": <string>,
    "details": <Option<string>>
}
```

### Rust Testing

- Add `#[cfg(test)]` modules within source files
- Use `cargo test <test_name>` to run specific tests
- Tests should cover: success paths, error paths, edge cases

## Project Structure

```md
src/
├── main.rs                    # Entry point with WebSocket server
├── lib.rs                     # Library exports
└── modules/
    ├── mod.rs                 # Module declarations
    ├── app_router.rs          # WebSocket router and handlers
    ├── audio_control/         # Audio control module
    │   ├── mod.rs             # Audio control exports
    │   ├── audio_handlers.rs  # WebSocket message handlers
    │   ├── audio_module.rs    # Audio module implementation
    │   ├── errors/            # Audio-specific errors
    │   │   ├── mod.rs
    │   │   └── audio_errors.rs
    │   ├── models/            # Data models
    │   │   ├── mod.rs
    │   │   ├── audio_requests.rs
    │   │   ├── device_sound.rs
    │   │   └── session_sound.rs
    │   ├── services/          # Business logic
    │   │   ├── mod.rs
    │   │   ├── audio_device_service.rs
    │   │   └── audio_session_service.rs
    │   ├── platform/          # Platform-specific implementations
    │   │   ├── mod.rs
    │   │   ├── audio_system_interface.rs
    │   │   └── windows_audio_adapter.rs
    │   ├── types/             # Type definitions
    │   │   ├── mod.rs
    │   │   ├── audio_result.rs
    │   │   └── group_id.rs
    │   ├── utils/             # Utility functions
    │   │   ├── mod.rs
    │   │   └── audio_process_utils.rs
    │   └── tests/             # Audio module tests
    │       ├── mod.rs
    │       ├── audio_handlers_tests.rs
    │       ├── audio_module_tests.rs
    │       ├── test_server.rs
    │       └── websocket_integration_tests.rs
    └── core/                  # Core infrastructure
        ├── mod.rs             # Core exports
        ├── broadcasting/      # Event broadcasting
        │   ├── mod.rs
        │   └── event_broadcaster.rs
        ├── com/               # COM utilities
        │   ├── mod.rs
        │   └── com_wrapper.rs
        ├── errors/            # Core error types
        │   └── mod.rs
        ├── handlers/          # Message handling
        │   ├── mod.rs
        │   └── message_handler.rs
        ├── models/            # Core data models
        │   ├── mod.rs
        │   ├── api_response.rs
        │   ├── module_request.rs
        │   └── server_events.rs
        ├── registry/          # Module registration
        │   ├── mod.rs
        │   └── module_registry.rs
        ├── response/          # Response building
        │   ├── mod.rs
        │   └── response_builder.rs
        ├── traits/            # Core traits
        │   ├── mod.rs
        │   └── module_handler.rs
        └── utils/             # Utility functions
            ├── mod.rs
            └── timestamp_utils.rs
```

## Key Dependencies

- `anyhow` - Error handling
- `thiserror` - Custom error derive
- `async-trait` - Async trait support
- `axum` - Web framework with WebSocket support (ws feature)
- `tokio` - Async runtime
- `tokio-tungstenite` - WebSocket client/server library
- `serde` + `serde_json` - Serialization
- `windows` - Windows API bindings
- `tracing` - Structured logging
- `futures` - Async utilities

## Agent Workflow

Use the three agents below in sequence for feature work.

### Agent 1: Idea Refiner

Goal:

- Turn a raw request into a clear implementation brief.

Inputs:

- User goal and constraints
- Current code context

Outputs:

- Problem statement (1-3 lines)
- Scope (in scope / out of scope)
- Technical approach summary
- Acceptance criteria checklist
- Risks and unknowns list

Definition of done:

- The brief is specific enough that another agent can implement without guessing behavior.

### Agent 2: Implementer (with Tests)

Goal:

- Implement the approved brief and add/adjust tests.

Inputs:

- Idea Refiner brief
- Existing project standards in this file

Outputs:

- Code changes for feature behavior
- Automated tests covering happy path, error path, and edge cases
- Notes on tradeoffs and any intentional limitations

Required checks:

- `cargo fmt --check`
- `cargo clippy`
- `cargo test`

Definition of done:

- Feature works as described by acceptance criteria and tests pass locally.

### Agent 3: QA Reviewer

Goal:

- Validate quality, regressions, and behavior against acceptance criteria.

Inputs:

- Idea Refiner brief
- Implementer diff and test results

Outputs:

- Findings list ordered by severity (critical/high/medium/low)
- Reproduction steps for each issue
- Final status: approved or changes requested

QA checklist:

- Functional correctness vs acceptance criteria
- Regression risk in touched modules
- Error handling and response format consistency
- Test quality and missing coverage
- Logging and observability for failures

Definition of done:

- Either explicit approval or a concrete, actionable bug list.

### Handoff Contract

For each handoff, include:

- Context summary (max 10 lines)
- Exact files touched or reviewed
- Commands executed and key results
- Open questions (if any)
