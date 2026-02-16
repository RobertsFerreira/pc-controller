use crate::modules::audio_control::models::audio_requests::Volume;
use crate::modules::audio_control::{
    platform::audio_system_interface::AudioSystemInterface, types::GroupId,
};
use crate::modules::core::response::create_response;
use crate::modules::core::traits::module_handler::ModuleResponse;
use anyhow::anyhow;

pub fn handle_get_volume(audio_system: &dyn AudioSystemInterface) -> ModuleResponse {
    let volume = audio_system.get_actual_volume().map_err(|e| anyhow!(e))?;
    Ok(create_response(volume, None))
}

pub fn handle_list_sessions(
    audio_system: &dyn AudioSystemInterface,
    device_id: String,
) -> ModuleResponse {
    let sessions = audio_system
        .get_sessions_for_device(&device_id)
        .map_err(|e| anyhow!(e))?;
    let size = sessions.len();
    Ok(create_response(sessions, Some(size)))
}

pub fn handle_set_group_volume(
    audio_system: &dyn AudioSystemInterface,
    device_id: String,
    group_id: GroupId,
    volume: Volume,
) -> ModuleResponse {
    audio_system
        .set_group_volume(&group_id, &device_id, volume.into())
        .map_err(|e| anyhow!(e))?;
    Ok(create_response("Group volume set successfully", None))
}

pub fn handle_list_devices(audio_system: &dyn AudioSystemInterface) -> ModuleResponse {
    let devices = audio_system.list_output_devices().map_err(|e| anyhow!(e))?;
    let size = devices.len();
    Ok(create_response(devices, Some(size)))
}
