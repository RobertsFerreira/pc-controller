use axum::extract::ws::Message;
use serde::Serialize;

use crate::modules::core::{
    errors::ErrorResponse,
    models::global_response::{ResponseHeaders, SuccessResponse},
    utils::get_timestamp,
};

/// Cria uma resposta JSON padronizada
///
/// # Arguments
/// * `data` - Dados a serem incluídos na resposta
/// * `count` - Opcional: número de itens (usado para listas)
///
/// # Returns
/// JSON string no formato `{ data, headers: { timestamp, count? } }`
pub fn create_response<T: Serialize>(data: T, count: Option<usize>) -> Message {
    let response = SuccessResponse {
        data,
        headers: ResponseHeaders {
            timestamp: get_timestamp(),
            count,
        },
    };

    match response.to_json() {
        Ok(msg) => msg,
        Err(e) => {
            tracing::error!("Failed to serialize success response: {:?}", e);
            create_error_response(
                500,
                "Failed to serialize success response",
                Some(e.to_string()),
            )
        }
    }
}

/// Cria uma mensagem de erro WebSocket com detalhes
///
/// # Arguments
/// * `code` - Código de erro HTTP
/// * `message` - Mensagem de erro descritiva
/// * `details` - Detalhes adicionais opcionais
pub fn create_error_response(code: u16, message: &str, details: Option<String>) -> Message {
    let error = ErrorResponse {
        code,
        message: message.to_string(),
        details,
    };

    match error.to_json() {
        Ok(err_msg) => err_msg,
        Err(e) => {
            tracing::error!("Failed to serialize error response: {:?}", e);
            Message::text("Failed to serialize error response")
        }
    }
}
