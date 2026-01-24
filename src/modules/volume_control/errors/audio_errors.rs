use std::string::FromUtf16Error;
use thiserror::Error;

use crate::modules::core::error::error_codes;

#[derive(Debug, Error)]
pub enum AudioError {
    #[error("COM initialization failed")]
    ComInitFailed(#[source] windows::core::Error),

    #[error("Device not found: {device_id}")]
    DeviceNotFound { device_id: String },

    #[error("Session manager failed")]
    SessionManagerFailed(#[source] windows::core::Error),

    #[error("Session enumeration failed")]
    SessionEnumFailed(#[source] windows::core::Error),

    #[error("No sessions found")]
    NoSessionsFound,

    #[error("Invalid device ID")]
    InvalidDeviceId,

    #[error("Windows API error: {0}")]
    WindowsError(#[from] windows::core::Error),

    #[error("UTF-16 conversion error: {0}")]
    Utf16Error(#[from] FromUtf16Error),
}

impl AudioError {
    /// Converte erros anyhow para códigos de erro HTTP
    pub fn error_response_from_anyhow(error: &anyhow::Error) -> (u16, Option<String>) {
        if let Some(session_err) = error.downcast_ref::<AudioError>() {
            match session_err {
                AudioError::DeviceNotFound { .. } => (error_codes::NOT_FOUND, None),
                AudioError::InvalidDeviceId => (error_codes::BAD_REQUEST, None),
                AudioError::NoSessionsFound => (error_codes::NOT_FOUND, None),
                _ => (error_codes::INTERNAL_ERROR, Some(session_err.to_string())),
            }
        } else {
            (error_codes::INTERNAL_ERROR, Some(error.to_string()))
        }
    }
}
