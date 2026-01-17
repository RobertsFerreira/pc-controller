use std::string::FromUtf16Error;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum SessionError {
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

pub type SessionResult<T> = Result<T, SessionError>;
