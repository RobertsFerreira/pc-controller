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
