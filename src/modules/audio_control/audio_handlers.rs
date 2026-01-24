use axum::extract::ws::Message;

use crate::modules::audio_control::{
    errors::AudioError, models::audio_requests::ActionSoundRequest, services,
};
use crate::modules::core::response::{create_error_response, create_response};
use anyhow::Context;

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
    let volume = services::get_actual_volume().context("Failed to get volume");

    match volume {
        Ok(volume) => create_response(volume, None),
        Err(error) => {
            let (code, details) = AudioError::error_response_from_anyhow(&error);
            create_error_response(code, &error.to_string(), details)
        }
    }
}

async fn handle_list_sessions(device_id: String) -> Message {
    let sessions =
        services::get_session_for_device(&device_id).context("Failed to get sessions for device");
    match sessions {
        Ok(sessions) => {
            let size = sessions.len();
            create_response(sessions, Some(size))
        }
        Err(error) => {
            let (code, details) = AudioError::error_response_from_anyhow(&error);
            create_error_response(code, &error.to_string(), details)
        }
    }
}

async fn handle_set_group_volume(device_id: String, group_id: String, volume: f32) -> Message {
    let sound = services::set_group_volume(&group_id, &device_id, volume)
        .context("Failed to set group volume");

    match sound {
        Ok(_) => create_response("Group volume set successfully", None),
        Err(error) => {
            let (code, details) = AudioError::error_response_from_anyhow(&error);
            create_error_response(code, &error.to_string(), details)
        }
    }
}

async fn handle_list_devices() -> Message {
    let devices = services::list_output_devices().context("Failed to get output devices");

    match devices {
        Ok(devices) => {
            let size = devices.len();
            create_response(devices, Some(size))
        }
        Err(error) => {
            let (code, details) = AudioError::error_response_from_anyhow(&error);
            create_error_response(code, &error.to_string(), details)
        }
    }
}
