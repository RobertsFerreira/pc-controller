use serde::Serialize;

#[derive(Serialize, Debug)]
pub struct ResponseHeaders {
    pub timestamp: u64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub count: Option<usize>,
}

#[derive(Serialize, Debug)]
pub struct ApiResponse<T> {
    pub data: T,
    pub headers: ResponseHeaders,
}

impl<T> ApiResponse<T>
where
    T: Serialize,
{
    pub fn to_json(&self) -> Result<String, anyhow::Error> {
        serde_json::to_string(&self).map_err(anyhow::Error::from)
    }
}
