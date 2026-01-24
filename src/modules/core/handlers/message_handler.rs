use anyhow::{Context, Result};
use axum::extract::ws::Message;
use tracing::error;

use crate::modules::core::{
    errors::error_codes, models::api_request::ApiRequest, response::create_error_response,
};
use crate::modules::volume_control::audio_handlers;
use crate::modules::volume_control::models::audio_requests::ActionSoundRequest;

pub async fn handle_global_message(msg: Message) -> Message {
    let text = msg.to_text().unwrap_or("Error converting message to text");
    println!("Received message: {}", text);

    let global_request: Result<ApiRequest> =
        serde_json::from_str(text).context("Failed to deserialize global request");

    match global_request {
        Ok(global_request) => match global_request {
            ApiRequest::Audio { request } => handle_audio_message(request).await,
            _ => create_error_response(error_codes::INTERNAL_ERROR, "Module not implemented", None),
        },
        Err(e) => {
            println!("Failed to deserialize global request: {:?}", e);
            error!("Failed to deserialize global request: {:?}", e);
            create_error_response(error_codes::BAD_REQUEST, &e.to_string(), None)
        }
    }
}

async fn handle_audio_message(request: ActionSoundRequest) -> Message {
    audio_handlers::handle_action_sound_request(request).await
}
