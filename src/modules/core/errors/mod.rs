use serde::Serialize;

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

impl ErrorResponse {
    pub fn to_json(&self) -> Result<String, anyhow::Error> {
        serde_json::to_string(&self).map_err(anyhow::Error::from)
    }
}
