use crate::modules::volume_control::models::{
    device_sound::DeviceSound, session_sound::SessionGroup,
};
use serde::Serialize;

/// Headers para resposta de volume
#[derive(Debug, Serialize)]
pub struct VolumeResponseHeaders {
    pub timestamp: u64,
}

/// Resposta contendo o volume atual
#[derive(Debug, Serialize)]
pub struct VolumeResponse {
    pub data: f32,
    pub headers: VolumeResponseHeaders,
}

/// Headers para respostas com múltiplos itens
#[derive(Debug, Serialize)]
pub struct ResponseHeaders {
    pub timestamp: u64,
    pub count: usize,
}

/// Resposta contendo lista de sessões de áudio
#[derive(Debug, Serialize)]
pub struct SessionListResponse {
    pub data: Vec<SessionGroup>,
    pub headers: ResponseHeaders,
}

/// Resposta contendo lista de dispositivos de áudio
#[derive(Debug, Serialize)]
pub struct DeviceListResponse {
    pub data: Vec<DeviceSound>,
    pub headers: ResponseHeaders,
}

/// Resposta de erro padrão
#[derive(Debug, Serialize)]
pub struct ErrorResponse {
    pub code: u16,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub details: Option<String>,
}

/// Códigos de erro HTTP padrão
pub mod error_codes {
    pub const BAD_REQUEST: u16 = 400;
    pub const NOT_FOUND: u16 = 404;
    pub const INTERNAL_ERROR: u16 = 500;
}
