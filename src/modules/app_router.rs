use std::sync::Arc;

use axum::{response::Response, Router};

use crate::modules::audio_control::AudioModule;
use crate::modules::core::errors::error_codes;
use crate::modules::core::response::create_error_response;
use crate::modules::core::ModuleRegistry;

fn default_registry() -> ModuleRegistry {
    let mut registry = ModuleRegistry::new();
    registry.register("audio", Arc::new(AudioModule::default()));
    registry
}

pub fn app() -> Router {
    app_with_registry(default_registry())
}

pub fn app_with_registry(registry: ModuleRegistry) -> Router {
    registry.http_routes().fallback(not_found)
}

async fn not_found() -> Response {
    error_response(error_codes::NOT_FOUND, "Resource not found", None)
}

fn error_response(code: u16, message: &str, details: Option<String>) -> Response {
    create_error_response(code, message, details)
}
