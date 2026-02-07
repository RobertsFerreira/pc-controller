use crate::modules::audio_control::{
    models::audio_requests::ActionSoundRequest, services, types::GroupId,
};
use crate::modules::core::errors::error_codes;
use crate::modules::core::response::{create_error_response, create_response};
use crate::modules::core::traits::module_handler::ModuleResponse;
use anyhow::Context;

/// Handler principal para requisições de áudio
///
/// Roteia para o handler apropriado baseado na ação solicitada.
pub async fn handle_action_sound_request(action: ActionSoundRequest) -> ModuleResponse {
    match action {
        ActionSoundRequest::GetVolume => handle_get_volume().await,
        ActionSoundRequest::DevicesList => handle_list_devices().await,
        ActionSoundRequest::SessionList { device_id } => handle_list_sessions(device_id).await,
        ActionSoundRequest::SetGroupVolume {
            device_id,
            group_id,
            volume,
        } => handle_set_group_volume(device_id, group_id, volume.into()).await,
    }
}

async fn handle_get_volume() -> ModuleResponse {
    let volume = services::get_actual_volume().context("Failed to get volume")?;
    Ok(create_response(volume, None))
}

async fn handle_list_sessions(device_id: String) -> ModuleResponse {
    let sessions = services::get_session_for_device(&device_id)
        .context("Failed to get sessions for device")?;
    let size = sessions.len();
    Ok(create_response(sessions, Some(size)))
}

async fn handle_set_group_volume(
    device_id: String,
    group_id: GroupId,
    volume: f32,
) -> ModuleResponse {
    if !(0.0..=1.0).contains(&volume) {
        return Ok(create_error_response(
            error_codes::BAD_REQUEST,
            "Volume must be between 0.0 and 1.0",
            None,
        ));
    }

    services::set_group_volume(&group_id, &device_id, volume)
        .context("Failed to set group volume")?;
    Ok(create_response("Group volume set successfully", None))
}

async fn handle_list_devices() -> ModuleResponse {
    let devices = services::list_output_devices().context("Failed to get output devices")?;
    let size = devices.len();
    Ok(create_response(devices, Some(size)))
}
