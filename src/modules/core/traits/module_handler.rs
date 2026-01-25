use async_trait::async_trait;
use axum::extract::ws::Message;

#[async_trait]
pub trait ModuleHandler: Send + Sync {
    async fn handle(&self, request: &str) -> Message;
}
