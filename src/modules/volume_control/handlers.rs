use anyhow::{Context, Result};
use axum::extract::ws::Message;

use crate::modules::volume_control::helper::{
    create_error_response, create_error_response_with_details, error_response_from_anyhow,
};
use crate::modules::volume_control::models::requests::ActionSoundRequest;
use crate::modules::volume_control::models::responses::error_codes;
use crate::modules::volume_control::volume_control_command;

pub async fn handle_message(msg: Message) -> Message {
    let text = msg.to_text().unwrap_or("Error converting message to text");
    println!("Received message: {}", text);

    let action_request: Result<ActionSoundRequest> = serde_json::from_str(text)
        .context("Failed to deserialize incoming message to ActionRequest");

    match action_request {
        Ok(ActionSoundRequest::GetVolume) => handle_get_volume().await,
        Ok(ActionSoundRequest::DevicesList) => handle_list_devices().await,
        Ok(ActionSoundRequest::SessionList { device_id }) => handle_list_sessions(device_id).await,
        Ok(ActionSoundRequest::SetGroupVolume {
            device_id,
            group_id,
            volume,
        }) => handle_set_group_volume(device_id, group_id, volume).await,
        Err(e) => {
            tracing::error!("Failed to deserialize action request: {:?}", e);
            create_error_response(error_codes::BAD_REQUEST, &e.to_string())
        }
    }
}

async fn handle_get_volume() -> Message {
    match volume_control_command::get_volume_response().await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed to get volume: {:?}", e);
            create_error_response(error_codes::INTERNAL_ERROR, &e.to_string())
        }
    }
}

async fn handle_list_sessions(device_id: String) -> Message {
    match volume_control_command::list_sessions_response(device_id).await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed to list sessions: {:?}", e);
            let (code, details) = error_response_from_anyhow(&e);
            create_error_response_with_details(code, &e.to_string(), details)
        }
    }
}

async fn handle_set_group_volume(device_id: String, group_id: String, volume: f32) -> Message {
    match volume_control_command::set_group_volume_response(device_id, group_id, volume).await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed to set group volume: {:?}", e);
            let (code, details) = error_response_from_anyhow(&e);
            create_error_response_with_details(code, &e.to_string(), details)
        }
    }
}

async fn handle_list_devices() -> Message {
    match volume_control_command::list_devices_response().await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed to list devices: {:?}", e);
            create_error_response_with_details(
                error_codes::INTERNAL_ERROR,
                &e.to_string(),
                Some("Failed to retrieve audio devices".to_string()),
            )
        }
    }
}
