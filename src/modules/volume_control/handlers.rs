use anyhow::{Context, Result};
use axum::extract::ws::Message;

use crate::modules::volume_control::device_controller;
use crate::modules::volume_control::models::requests::ActionRequest;
use crate::modules::volume_control::models::responses::{
    error_codes, DeviceListResponse, ErrorResponse, ResponseHeaders, SessionListResponse,
    VolumeResponse, VolumeResponseHeaders,
};

pub async fn handle_message(msg: Message) -> Message {
    let text = msg.to_text().unwrap_or("Error converting message to text");
    println!("Received message: {}", text);

    let action_request: Result<ActionRequest> = serde_json::from_str(text)
        .context("Failed to deserialize incoming message to ActionRequest");

    match action_request {
        Ok(ActionRequest::GetVolume) => return handle_get_volume().await,
        Ok(ActionRequest::DevicesList) => return handle_list_devices().await,
        Ok(ActionRequest::SessionList { device_id }) => {
            return handle_list_sessions(device_id).await
        }
        Err(e) => {
            tracing::error!("Failed to deserialize action request: {:?}", e);
            return create_error_response(error_codes::BAD_REQUEST, &e.to_string());
        }
    }
}

async fn handle_get_volume() -> Message {
    match get_volume_response().await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed to get volume: {:?}", e);
            create_error_response(error_codes::INTERNAL_ERROR, &e.to_string())
        }
    }
}

async fn get_volume_response() -> Result<String> {
    let volume = device_controller::get_actual_volume().context("Failed to get volume")?;

    let headers = VolumeResponseHeaders {
        timestamp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs(),
    };

    let response = VolumeResponse {
        data: volume,
        headers: headers,
    };

    serde_json::to_string(&response).context("Failed to serialize volume response")
}

pub async fn handle_list_sessions(device_id: String) -> Message {
    match list_sessions_response(device_id).await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed to list sessions: {:?}", e);
            let (code, details) = error_response_from_anyhow(&e);
            create_error_response_with_details(code, &e.to_string(), details)
        }
    }
}

async fn list_sessions_response(device_id: String) -> Result<String> {
    let sessions = device_controller::get_session_for_device(&device_id)
        .context("Failed to get sessions for device")?;

    let headers = ResponseHeaders {
        timestamp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs(),
        count: sessions.len(),
    };

    let response = SessionListResponse {
        data: sessions,
        headers: headers,
    };

    serde_json::to_string(&response).context("Failed to serialize response")
}

pub async fn handle_list_devices() -> Message {
    match list_devices_response().await {
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

async fn list_devices_response() -> Result<String> {
    let devices =
        device_controller::list_output_devices().context("Failed to get output devices")?;

    let headers = ResponseHeaders {
        timestamp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs(),
        count: devices.len(),
    };

    let response = DeviceListResponse {
        data: devices,
        headers: headers,
    };

    serde_json::to_string(&response).context("Failed to serialize response")
}

fn error_response_from_anyhow(error: &anyhow::Error) -> (u16, Option<String>) {
    use crate::modules::volume_control::models::SessionError;

    if let Some(session_err) = error.downcast_ref::<SessionError>() {
        match session_err {
            SessionError::DeviceNotFound { .. } => (error_codes::NOT_FOUND, None),
            SessionError::InvalidDeviceId => (error_codes::BAD_REQUEST, None),
            SessionError::NoSessionsFound => (error_codes::NOT_FOUND, None),
            _ => (error_codes::INTERNAL_ERROR, Some(session_err.to_string())),
        }
    } else {
        (error_codes::INTERNAL_ERROR, Some(error.to_string()))
    }
}

fn create_error_response(code: u16, message: &str) -> Message {
    create_error_response_with_details(code, message, None)
}

fn create_error_response_with_details(
    code: u16,
    message: &str,
    details: Option<String>,
) -> Message {
    let error = ErrorResponse {
        code,
        message: message.to_string(),
        details,
    };
    Message::text(serde_json::to_string(&error).unwrap())
}
