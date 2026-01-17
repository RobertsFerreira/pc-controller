use anyhow::{Context, Result};
use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};

pub mod modules;
use crate::modules::volume_control::device_controller;
use crate::modules::volume_control::models::{
    error_codes, ErrorResponse, ResponseHeaders, SessionListRequest, SessionListResponse,
};

#[tokio::main]
async fn main() {
    const PORT_SERVER: u16 = 3000;
    let app = Router::new().route("/ws", get(ws_handler));

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{PORT_SERVER}"))
        .await
        .expect("Failed to bind TCP listener");

    println!("API iniciada na porta {}", PORT_SERVER);

    axum::serve(listener, app)
        .await
        .expect("Failed to start server");
}

async fn ws_handler(ws: WebSocketUpgrade) -> impl IntoResponse {
    ws.on_upgrade(handle_socket)
}

async fn handle_socket(mut socket: WebSocket) {
    while let Some(msg_received) = socket.recv().await {
        let message_send = if let Ok(extracted_message) = msg_received {
            handle_message(extracted_message).await
        } else {
            println!("Client disconnected");
            return;
        };
        if socket.send(message_send).await.is_err() {
            println!("Client disconnected");
            return;
        }
    }
}

// Handle incoming messages from the client
async fn handle_message(msg: Message) -> Message {
    let message_send = msg.to_text().unwrap_or("Error converting message to text");

    if message_send == "get_volume" {
        let message = device_controller::get_actual_volume()
            .map(|volume| format!("Volume: {volume}"))
            .unwrap_or_else(|e| {
                println!("Error getting volume: {e}");
                "Error getting volume".to_string()
            });
        Message::text(message)
    } else if message_send == "list_devices" {
        let message = device_controller::list_output_devices().map(|devices| {
            devices
                .iter()
                .map(|device| format!("{}", device))
                .collect::<Vec<_>>()
                .join("\n")
        });
        let message_send = message.unwrap_or_else(|e| {
            println!("Error listing devices: {e}");
            "Error listing devices".to_string()
        });
        Message::text(message_send)
    } else if let Ok(request) = serde_json::from_str::<SessionListRequest>(message_send) {
        if request.action == "list_sessions" {
            return handle_list_sessions(&request).await;
        }
        msg
    } else {
        println!("Received message: {}", message_send);
        msg
    }
}

async fn handle_list_sessions(request: &SessionListRequest) -> Message {
    match list_sessions_response(request).await {
        Ok(response) => Message::text(response),
        Err(e) => {
            tracing::error!("Failed to list sessions: {:?}", e);

            let (code, details) = error_response_from_anyhow(&e);
            let error = ErrorResponse {
                code,
                message: e.to_string(),
                details,
            };
            Message::text(serde_json::to_string(&error).unwrap())
        }
    }
}

async fn list_sessions_response(request: &SessionListRequest) -> Result<String> {
    let sessions = device_controller::list_sessions_for_device(&request.device_id)
        .context("Failed to get sessions for device")?;

    let headers = ResponseHeaders {
        timestamp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs(),
        device_id: request.device_id.clone(),
        session_count: sessions.len(),
    };

    let response = SessionListResponse {
        data: sessions,
        headers: Some(headers),
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
