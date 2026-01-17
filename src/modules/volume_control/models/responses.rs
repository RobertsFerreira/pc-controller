use crate::modules::volume_control::models::session_sound::SessionSound;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct SessionListRequest {
    pub action: String,
    pub device_id: String,
}

#[derive(Debug, Serialize)]
pub struct SessionListResponse {
    pub data: Vec<SessionSound>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub headers: Option<ResponseHeaders>,
}

#[derive(Debug, Serialize)]
pub struct ResponseHeaders {
    pub timestamp: u64,
    pub device_id: String,
    pub session_count: usize,
}

#[derive(Debug, Serialize)]
pub struct ErrorResponse {
    pub code: u16,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub details: Option<String>,
}

pub mod error_codes {
    pub const BAD_REQUEST: u16 = 400;
    pub const NOT_FOUND: u16 = 404;
    pub const INTERNAL_ERROR: u16 = 500;
}
