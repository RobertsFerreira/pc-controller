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
