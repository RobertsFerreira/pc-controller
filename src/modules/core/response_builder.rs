use axum::extract::ws::Message;
use serde::Serialize;
use std::time::SystemTime;

use crate::modules::core::{
    error::ErrorResponse,
    models::global_response::{ResponseHeaders, SuccessResponse},
};

/// Retorna o timestamp atual em segundos Unix
fn get_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs()
}

/// Cria uma resposta JSON padronizada
///
/// # Arguments
/// * `data` - Dados a serem incluídos na resposta
/// * `count` - Opcional: número de itens (usado para listas)
///
/// # Returns
/// JSON string no formato `{ data, headers: { timestamp, count? } }`
pub fn create_response<T: Serialize>(
    data: T,
    count: Option<usize>,
) -> Result<Message, anyhow::Error> {
    let response = SuccessResponse {
        data,
        headers: ResponseHeaders {
            timestamp: get_timestamp(),
            count,
        },
    };

    serde_json::to_string(&response)
        .map(Message::text)
        .map_err(anyhow::Error::from)
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

    let error = serde_json::to_string(&error).map_err(anyhow::Error::from);

    match error {
        Ok(err_msg) => Message::text(err_msg),
        Err(e) => {
            tracing::error!("Failed to serialize error response: {:?}", e);
            Message::text("Failed to serialize error response")
        }
    }
}
