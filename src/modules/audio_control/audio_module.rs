use crate::modules::audio_control::audio_handlers;
use crate::modules::audio_control::models::audio_requests::ActionSoundRequest;
use crate::modules::core::errors::error_codes;
use crate::modules::core::response::create_error_response;
use crate::modules::core::traits::ModuleHandler;
use async_trait::async_trait;
use axum::extract::ws::Message;

pub struct AudioModule;

#[async_trait]
impl ModuleHandler for AudioModule {
    async fn handle(&self, request: &str) -> Message {
        let audio_request: Result<ActionSoundRequest, serde_json::Error> =
            serde_json::from_str(request);

        match audio_request {
            Ok(request) => audio_handlers::handle_action_sound_request(request).await,
            Err(e) => create_error_response(
                error_codes::BAD_REQUEST,
                &format!("Failed to parse audio request: {}", e),
                None,
            ),
        }
    }
}
