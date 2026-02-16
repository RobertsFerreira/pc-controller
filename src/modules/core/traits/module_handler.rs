use std::sync::Arc;

use axum::{response::Response, Router};

pub type ModuleResponse = Result<Response, anyhow::Error>;

pub trait ModuleHandler: Send + Sync {
    fn routes(self: Arc<Self>) -> Router;
}
