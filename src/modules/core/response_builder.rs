use axum::extract::ws::Message;
use serde::Serialize;
use std::time::SystemTime;

use crate::modules::core::ErrorResponse;

/// Retorna o timestamp atual em segundos Unix
pub fn get_timestamp() -> u64 {
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
) -> Result<String, anyhow::Error> {
    let response = match count {
        Some(c) => serde_json::json!({
            "data": data,
            "headers": {
                "timestamp": get_timestamp(),
                "count": c
            }
        }),
        None => serde_json::json!({
            "data": data,
            "headers": {
                "timestamp": get_timestamp()
            }
        }),
    };
    serde_json::to_string(&response).map_err(anyhow::Error::from)
}

/// Cria uma resposta JSON simples sem contagem
pub fn create_simple_response<T: Serialize>(data: T) -> Result<String, anyhow::Error> {
    create_response(data, None)
}

/// Cria uma resposta JSON com contagem de itens
pub fn create_counted_response<T: Serialize>(
    data: T,
    count: usize,
) -> Result<String, anyhow::Error> {
    create_response(data, Some(count))
}

/// Cria uma mensagem de erro WebSocket simples
///
/// # Arguments
/// * `code` - Código de erro HTTP
/// * `message` - Mensagem de erro descritiva
pub fn create_error_response(code: u16, message: &str) -> Message {
    create_error_response_with_details(code, message, None)
}

/// Cria uma mensagem de erro WebSocket com detalhes
///
/// # Arguments
/// * `code` - Código de erro HTTP
/// * `message` - Mensagem de erro descritiva
/// * `details` - Detalhes adicionais opcionais
pub fn create_error_response_with_details(
    code: u16,
    message: &str,
    details: Option<String>,
) -> Message {
    let error = ErrorResponse {
        code,
        message: message.to_string(),
        details,
    };
    Message::text(serde_json::to_string(&error).unwrap())
}
