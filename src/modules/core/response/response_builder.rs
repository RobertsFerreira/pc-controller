use axum::{body::Body, http::header::CONTENT_TYPE, response::Response};
use serde::Serialize;

use crate::modules::core::{
    errors::ErrorResponse,
    models::api_response::{ApiResponse, ResponseHeaders},
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
pub fn create_response<T: Serialize>(data: T, count: Option<usize>) -> Response {
    let response = ApiResponse {
        data,
        headers: ResponseHeaders {
            timestamp: get_timestamp(),
            count,
        },
    };

    match response.to_json() {
        Ok(json) => build_response(200, json),
        Err(e) => {
            tracing::error!("Failed to serialize success response: {:?}", e);
            create_error_response(
                500,
                "Failed to serialize success response",
                None, // Don't expose internal error details to client
            )
        }
    }
}

/// Cria uma resposta de erro HTTP com detalhes
///
/// # Arguments
/// * `code` - Código de erro HTTP
/// * `message` - Mensagem de erro descritiva
/// * `details` - Detalhes adicionais opcionais
pub fn create_error_response(code: u16, message: &str, details: Option<String>) -> Response {
    let error = ErrorResponse {
        code,
        message: message.to_string(),
        details,
    };

    match error.to_json() {
        Ok(json) => build_response(code, json),
        Err(e) => {
            tracing::error!("Failed to serialize error response: {:?}", e);
            build_response(
                500,
                "{\"code\":500,\"message\":\"Failed to serialize error response\"}".to_string(),
            )
        }
    }
}

fn build_response(status: u16, body: String) -> Response {
    Response::builder()
        .status(status)
        .header(CONTENT_TYPE, "application/json")
        .body(Body::from(body))
        .expect("failed to build HTTP response")
}
