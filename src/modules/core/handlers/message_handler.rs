use anyhow::{Context, Result};
use axum::extract::ws::Message;
use std::sync::Arc;
use tracing::error;

use crate::modules::core::{
    errors::error_codes, models::module_request::ModuleRequest, registry::ModuleRegistry,
    response::create_error_response,
};

pub async fn handle_message(msg: Message, registry: Arc<ModuleRegistry>) -> Message {
    let text = match msg.to_text() {
        Ok(text) => text,
        Err(e) => {
            let err_msg = format!("Failed to convert message to text: {:?}", e);
            error!("{}", err_msg);
            return create_error_response(error_codes::BAD_REQUEST, &err_msg, None);
        }
    };

    let request: Result<ModuleRequest> =
        serde_json::from_str(text).context("Failed to deserialize global request");

    match request {
        Ok(request) => {
            let payload = match request.payload {
                Some(payload) => payload.to_string(),
                None => {
                    let err_msg = "Payload is missing in the request".to_string();
                    error!("{}", err_msg);
                    return create_error_response(error_codes::BAD_REQUEST, &err_msg, None);
                }
            };

            let module = request.module.to_string();

            match registry.handle(&module, &payload).await {
                Ok(msg) => msg,
                Err(error) => {
                    let err_msg = format!("Failed to handle request for module '{}'", module);
                    error!("{}: {:?}", err_msg, error);
                    create_error_response(error_codes::INTERNAL_ERROR, &err_msg, None)
                }
            }
        }
        Err(e) => {
            error!("Failed to deserialize global request: {:?}", e);
            create_error_response(error_codes::BAD_REQUEST, "Invalid request format", None)
        }
    }
}
