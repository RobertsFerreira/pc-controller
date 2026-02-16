use crate::modules::audio_control::{
    platform::audio_system_interface::AudioSystemInterface, types::GroupId,
};
use crate::modules::core::errors::error_codes;
use crate::modules::core::response::{create_error_response, create_response};
use crate::modules::core::traits::module_handler::ModuleResponse;
use anyhow::Context;

pub fn handle_get_volume(audio_system: &dyn AudioSystemInterface) -> ModuleResponse {
    let volume = audio_system
        .get_actual_volume()
        .context("Failed to get volume")?;
    Ok(create_response(volume, None))
}

pub fn handle_list_sessions(
    audio_system: &dyn AudioSystemInterface,
    device_id: String,
) -> ModuleResponse {
    let sessions = audio_system
        .get_sessions_for_device(&device_id)
        .context("Failed to get sessions for device")?;
    let size = sessions.len();
    Ok(create_response(sessions, Some(size)))
}

pub fn handle_set_group_volume(
    audio_system: &dyn AudioSystemInterface,
    device_id: String,
    group_id: GroupId,
    volume: f32,
) -> ModuleResponse {
    if !(0.0..=100.0).contains(&volume) {
        return Ok(create_error_response(
            error_codes::BAD_REQUEST,
            "Volume must be between 0.0 and 100.0",
            None,
        ));
    }

    audio_system
        .set_group_volume(&group_id, &device_id, volume)
        .context("Failed to set group volume")?;
    Ok(create_response("Group volume set successfully", None))
}

pub fn handle_list_devices(audio_system: &dyn AudioSystemInterface) -> ModuleResponse {
    let devices = audio_system
        .list_output_devices()
        .context("Failed to get output devices")?;
    let size = devices.len();
    Ok(create_response(devices, Some(size)))
}
