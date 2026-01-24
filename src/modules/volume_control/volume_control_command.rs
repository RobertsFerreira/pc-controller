use crate::modules::{
    core::response_builder::create_response,
    volume_control::{sound_device_service, sound_session_service},
};
use anyhow::{Context, Result};
use axum::extract::ws::Message;

pub async fn get_volume_response() -> Result<Message> {
    let volume = sound_device_service::get_actual_volume().context("Failed to get volume")?;

    create_response(volume, None)
}

pub async fn list_sessions_response(device_id: String) -> Result<Message> {
    let sessions = sound_session_service::get_session_for_device(&device_id)
        .context("Failed to get sessions for device")?;
    let size = sessions.len();

    create_response(sessions, Some(size))
}

pub async fn set_group_volume_response(
    device_id: String,
    group_id: String,
    volume: f32,
) -> Result<Message> {
    sound_session_service::set_group_volume(&group_id, &device_id, volume)
        .context("Failed to set group volume")?;

    create_response("Volume set successfully", None)
}

pub async fn list_devices_response() -> Result<Message> {
    let devices =
        sound_device_service::list_output_devices().context("Failed to get output devices")?;
    let size = devices.len();

    create_response(devices, Some(size))
}
