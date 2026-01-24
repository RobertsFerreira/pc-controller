use axum::extract::ws::Message;

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
    volume_control_command::get_volume_response().await
}

async fn handle_list_sessions(device_id: String) -> Message {
    volume_control_command::list_sessions_response(device_id).await
}

async fn handle_set_group_volume(device_id: String, group_id: String, volume: f32) -> Message {
    volume_control_command::set_group_volume_response(device_id, group_id, volume).await
}

async fn handle_list_devices() -> Message {
    volume_control_command::list_devices_response().await
}
