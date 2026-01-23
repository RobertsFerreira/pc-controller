use crate::modules::volume_control::models::{
    device_sound::DeviceSound, session_sound::SessionGroup,
};
use serde::Serialize;

//------------Volume current output sound---------------//
#[derive(Debug, Serialize)]
pub struct VolumeResponseHeaders {
    pub timestamp: u64,
}
#[derive(Debug, Serialize)]
pub struct VolumeResponse {
    pub data: f32,
    pub headers: VolumeResponseHeaders,
}

//-----------Base Response----------------//
#[derive(Debug, Serialize)]
pub struct ResponseHeaders {
    pub timestamp: u64,
    pub count: usize,
}

//---------------- Session List Response ----------------//
#[derive(Debug, Serialize)]
pub struct SessionListResponse {
    pub data: Vec<SessionGroup>,
    pub headers: ResponseHeaders,
}

//---------------- Device List Response ----------------//
#[derive(Debug, Serialize)]
pub struct DeviceListResponse {
    pub data: Vec<DeviceSound>,
    pub headers: ResponseHeaders,
}

//---------------- Error Response ----------------//
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
