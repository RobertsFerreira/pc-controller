use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};

pub mod modules;
use crate::modules::volume_control::device_controller;

#[tokio::main]
async fn main() {
    const PORT_SERVER: u16 = 3000;
    let app = Router::new().route("/ws", get(ws_handler));

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{PORT_SERVER}"))
        .await
        .expect("Failed to bind TCP listener");

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
    let message_send = msg
        .to_text()
        .unwrap_or_else(|_| "Error converting message to text");

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
    } else {
        println!("Received message: {}", message_send);
        msg
    }
}
