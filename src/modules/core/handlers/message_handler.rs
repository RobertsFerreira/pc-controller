use axum::{extract::ws::Message, response::Response};
use std::sync::Arc;

use crate::modules::core::{
    errors::error_codes, registry::ModuleRegistry, response::create_error_response,
};

pub async fn handle_message(_msg: Message, _registry: Arc<ModuleRegistry>) -> Response {
    create_error_response(
        error_codes::BAD_REQUEST,
        "WebSocket request dispatch is disabled; use HTTP routes",
        None,
    )
}
