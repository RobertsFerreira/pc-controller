use crate::modules::{
    core::response_builder::{create_error_response, create_response},
    volume_control::{errors::AudioError, sound_device_service, sound_session_service},
};
use anyhow::Context;
use axum::extract::ws::Message;

pub async fn get_volume_response() -> Message {
    let volume = sound_device_service::get_actual_volume().context("Failed to get volume");

    match volume {
        Ok(volume) => create_response(volume, None),
        Err(error) => {
            let (code, details) = AudioError::error_response_from_anyhow(&error);
            create_error_response(code, &error.to_string(), details)
        }
    }
}

pub async fn list_sessions_response(device_id: String) -> Message {
    let sessions = sound_session_service::get_session_for_device(&device_id)
        .context("Failed to get sessions for device");
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

pub async fn set_group_volume_response(
    device_id: String,
    group_id: String,
    volume: f32,
) -> Message {
    let sound = sound_session_service::set_group_volume(&group_id, &device_id, volume)
        .context("Failed to set group volume");

    match sound {
        Ok(_) => create_response("Group volume set successfully", None),
        Err(error) => {
            let (code, details) = AudioError::error_response_from_anyhow(&error);
            create_error_response(code, &error.to_string(), details)
        }
    }
}

pub async fn list_devices_response() -> Message {
    let devices =
        sound_device_service::list_output_devices().context("Failed to get output devices");

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
