use async_trait::async_trait;
use axum::extract::ws::Message;

pub type ModuleResponse = Result<Message, anyhow::Error>;

#[async_trait]
pub trait ModuleHandler: Send + Sync {
    async fn handle(&self, request: &str) -> Result<Message, anyhow::Error>;
}
