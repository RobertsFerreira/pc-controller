use std::sync::Arc;

use crate::modules::audio_control::audio_handlers;
use crate::modules::audio_control::models::audio_requests::ActionSoundRequest;
use crate::modules::audio_control::platform::{
    audio_system_interface::AudioSystemInterface, windows_audio_adapter::WindowsAudioAdapter,
};
use crate::modules::core::errors::error_codes;
use crate::modules::core::response::create_error_response;
use crate::modules::core::traits::module_handler::{ModuleHandler, ModuleResponse};
use async_trait::async_trait;

pub struct AudioModule {
    audio_system: Arc<dyn AudioSystemInterface>,
}

impl AudioModule {
    pub fn new(audio_system: Arc<dyn AudioSystemInterface>) -> Self {
        Self { audio_system }
    }
}

impl Default for AudioModule {
    fn default() -> Self {
        Self::new(Arc::new(WindowsAudioAdapter::new()))
    }
}

#[async_trait]
impl ModuleHandler for AudioModule {
    async fn handle(&self, request: &str) -> ModuleResponse {
        let audio_request: Result<ActionSoundRequest, serde_json::Error> =
            serde_json::from_str(request);

        match audio_request {
            Ok(request) => {
                audio_handlers::handle_action_sound_request(self.audio_system.as_ref(), request)
                    .await
            }
            Err(e) => {
                let error_response = create_error_response(
                    error_codes::BAD_REQUEST,
                    &format!("Failed to parse audio request: {}", e),
                    None,
                );
                Ok(error_response)
            }
        }
    }
}
