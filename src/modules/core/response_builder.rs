use axum::extract::ws::Message;
use serde::Serialize;
use std::time::SystemTime;

use crate::modules::core::ErrorResponse;

pub fn get_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs()
}

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

pub fn create_simple_response<T: Serialize>(data: T) -> Result<String, anyhow::Error> {
    create_response(data, None)
}

pub fn create_counted_response<T: Serialize>(
    data: T,
    count: usize,
) -> Result<String, anyhow::Error> {
    create_response(data, Some(count))
}

pub fn create_error_response(code: u16, message: &str) -> Message {
    create_error_response_with_details(code, message, None)
}

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
