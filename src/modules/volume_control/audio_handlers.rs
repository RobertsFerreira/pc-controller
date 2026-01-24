use axum::extract::ws::Message;

use crate::modules::core::error::error_codes;
use crate::modules::core::response_builder::create_error_response;
use crate::modules::volume_control::com_utils::error_response_from_anyhow;
use crate::modules::volume_control::models::audio_requests::ActionSoundRequest;
use crate::modules::volume_control::volume_control_command;

/// Handler principal para requisições de áudio
///
/// Roteia para o handler apropriado baseado na ação solicitada.
pub async fn handle_action_sound_request(action: ActionSoundRequest) -> Message {
    match action {
        ActionSoundRequest::GetVolume => handle_get_volume().await,
        ActionSoundRequest::DevicesList => handle_list_devices().await,
        ActionSoundRequest::SessionList { device_id } => handle_list_sessions(device_id).await,
        ActionSoundRequest::SetGroupVolume {
            device_id,
            group_id,
            volume,
        } => handle_set_group_volume(device_id, group_id, volume).await,
    }
}

async fn handle_get_volume() -> Message {
    match volume_control_command::get_volume_response().await {
        Ok(response) => response,
        Err(e) => {
            tracing::error!("Failed to get volume: {:?}", e);
            create_error_response(error_codes::INTERNAL_ERROR, &e.to_string(), None)
        }
    }
}

async fn handle_list_sessions(device_id: String) -> Message {
    match volume_control_command::list_sessions_response(device_id).await {
        Ok(response) => response,
        Err(e) => {
            tracing::error!("Failed to list sessions: {:?}", e);
            let (code, details) = error_response_from_anyhow(&e);
            create_error_response(code, &e.to_string(), details)
        }
    }
}

async fn handle_set_group_volume(device_id: String, group_id: String, volume: f32) -> Message {
    match volume_control_command::set_group_volume_response(device_id, group_id, volume).await {
        Ok(response) => response,
        Err(e) => {
            tracing::error!("Failed to set group volume: {:?}", e);
            let (code, details) = error_response_from_anyhow(&e);
            create_error_response(code, &e.to_string(), details)
        }
    }
}

async fn handle_list_devices() -> Message {
    match volume_control_command::list_devices_response().await {
        Ok(response) => response,
        Err(e) => {
            tracing::error!("Failed to list devices: {:?}", e);
            create_error_response(
                error_codes::INTERNAL_ERROR,
                &e.to_string(),
                Some("Failed to retrieve audio devices".to_string()),
            )
        }
    }
}
