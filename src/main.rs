use axum::{
    extract::ws::{WebSocket, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};

pub mod modules;
use crate::modules::volume_control::handlers;

#[tokio::main]
async fn main() {
    const PORT_SERVER: u16 = 3000;
    let app = Router::new().route("/ws", get(ws_handler));

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{PORT_SERVER}"))
        .await
        .expect("Failed to bind TCP listener");

    println!("Server running on http://0.0.0.0/{}", PORT_SERVER);

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
            handlers::handle_message(extracted_message).await
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
