use crate::modules::{
    core::helper,
    volume_control::{
        models::audio_responses::{
            DeviceListResponse, ResponseHeaders, SessionListResponse, VolumeResponse,
            VolumeResponseHeaders,
        },
        sound_device_service, sound_session_service,
    },
};
use anyhow::{Context, Result};

pub async fn get_volume_response() -> Result<String> {
    let volume = sound_device_service::get_actual_volume().context("Failed to get volume")?;

    let headers = VolumeResponseHeaders {
        timestamp: helper::get_timestamp(),
    };

    let response = VolumeResponse {
        data: volume,
        headers,
    };

    serde_json::to_string(&response).context("Failed to serialize volume response")
}

pub async fn list_sessions_response(device_id: String) -> Result<String> {
    let sessions = sound_session_service::get_session_for_device(&device_id)
        .context("Failed to get sessions for device")?;

    let headers = ResponseHeaders {
        timestamp: helper::get_timestamp(),
        count: sessions.len(),
    };

    let response = SessionListResponse {
        data: sessions,
        headers,
    };

    serde_json::to_string(&response).context("Failed to serialize response")
}

pub async fn set_group_volume_response(
    device_id: String,
    group_id: String,
    volume: f32,
) -> Result<String> {
    sound_session_service::set_group_volume(&group_id, &device_id, volume)
        .context("Failed to set group volume")?;

    let response = serde_json::json!({
        "data": { "success": true, "volume": volume },
        "headers": {
            "timestamp": helper::get_timestamp()
        }
    });

    serde_json::to_string(&response).context("Failed to serialize response")
}

pub async fn list_devices_response() -> Result<String> {
    let devices =
        sound_device_service::list_output_devices().context("Failed to get output devices")?;

    let headers = ResponseHeaders {
        timestamp: helper::get_timestamp(),
        count: devices.len(),
    };

    let response = DeviceListResponse {
        data: devices,
        headers,
    };

    serde_json::to_string(&response).context("Failed to serialize response")
}
