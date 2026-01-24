use axum::extract::ws::Message;
use serde::Serialize;

#[derive(Serialize, Debug)]
pub struct ResponseHeaders {
    pub timestamp: u64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub count: Option<usize>,
}

#[derive(Serialize, Debug)]
pub struct SuccessResponse<T> {
    pub data: T,
    pub headers: ResponseHeaders,
}

impl<T> SuccessResponse<T>
where
    T: Serialize,
{
    pub fn to_json(&self) -> Result<Message, anyhow::Error> {
        serde_json::to_string(&self)
            .map(Message::text)
            .map_err(anyhow::Error::from)
    }
}
