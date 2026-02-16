use serde_json::Value;
use std::future::IntoFuture;
use std::time::Duration;

use crate::modules::app_router::app_with_registry;
use crate::modules::core::ModuleRegistry;

pub struct BaseTestServer {
    base_url: String,
    client: reqwest::Client,
}

impl BaseTestServer {
    pub async fn new_with_registry<F>(configure_registry: F) -> Self
    where
        F: FnOnce(&mut ModuleRegistry),
    {
        let mut registry = ModuleRegistry::new();
        configure_registry(&mut registry);

        let address = String::from("127.0.0.1:0");
        let listener = tokio::net::TcpListener::bind(address).await.unwrap();

        let addr = listener.local_addr().unwrap();
        tokio::spawn(axum::serve(listener, app_with_registry(registry)).into_future());
        tokio::time::sleep(Duration::from_millis(25)).await;

        Self {
            base_url: format!("http://{addr}"),
            client: reqwest::Client::new(),
        }
    }

    pub async fn get(&self, path: &str) -> reqwest::Response {
        self.client
            .get(format!("{}{}", self.base_url, path))
            .send()
            .await
            .unwrap()
    }

    pub async fn post_json(&self, path: &str, body: Value) -> reqwest::Response {
        self.client
            .post(format!("{}{}", self.base_url, path))
            .json(&body)
            .send()
            .await
            .unwrap()
    }

    pub async fn post_raw(&self, path: &str, body: &str) -> reqwest::Response {
        self.client
            .post(format!("{}{}", self.base_url, path))
            .header("content-type", "application/json")
            .body(body.to_string())
            .send()
            .await
            .unwrap()
    }
}
