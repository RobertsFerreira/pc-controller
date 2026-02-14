use std::sync::Arc;

use super::mocks::MockAudioSystem;
use crate::modules::audio_control::audio_module::AudioModule;
use crate::modules::core::tests_support::base_test_server::BaseTestServer;

pub struct TestServer {
    inner: BaseTestServer,
}

impl TestServer {
    pub async fn new() -> Self {
        let inner = BaseTestServer::new_with_registry(|registry| {
            let audio_module = AudioModule::new(Arc::new(MockAudioSystem));
            registry.register("audio", Arc::new(audio_module));
        })
        .await;

        Self { inner }
    }

    pub async fn send_message(&mut self, message: &str) {
        self.inner.send_message(message).await;
    }

    pub async fn receive_message(&mut self) -> String {
        self.inner.receive_message().await
    }
}
