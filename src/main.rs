use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    response::IntoResponse,
    routing::get,
    Router,
};
use std::sync::Arc;

pub mod modules;
use crate::modules::core::handle_global_message;
use crate::modules::core::Broadcaster;

#[derive(Clone)]
struct AppState {
    broadcaster: Arc<Broadcaster>,
}

#[tokio::main]
async fn main() {
    const PORT_SERVER: u16 = 3000;

    let app_state = AppState {
        broadcaster: Arc::new(Broadcaster::new(100)),
    };

    let app = Router::new()
        .route("/ws", get(ws_handler))
        .with_state(app_state);

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{PORT_SERVER}"))
        .await
        .expect("Failed to bind TCP listener");

    println!("Server running on http://0.0.0.0/{}", PORT_SERVER);

    axum::serve(listener, app)
        .await
        .expect("Failed to start server");
}

async fn ws_handler(ws: WebSocketUpgrade, State(state): State<AppState>) -> impl IntoResponse {
    ws.on_upgrade(move |socket| handle_socket(socket, state.broadcaster))
}

async fn handle_socket(mut socket: WebSocket, broadcaster: Arc<Broadcaster>) {
    let mut event_rx = broadcaster.subscribe();

    loop {
        tokio::select! {
            msg_result = socket.recv() => {
                match msg_result {
                    Some(Ok(msg)) => {
                        let response = handle_global_message(msg).await;
                        if socket.send(response).await.is_err() {
                            println!("Client disconnected");
                            return;
                        }
                    }
                    Some(Err(_)) | None => {
                        println!("Client disconnected");
                        return;
                    }
                }
            }
            event_result = event_rx.recv() => {
                match event_result {
                    Ok(event) => {
                        if let Ok(event_json) = event.to_json() {
                            if socket.send(Message::text(event_json)).await.is_err() {
                                println!("Client disconnected");
                                return;
                            }
                        }
                    }
                    Err(tokio::sync::broadcast::error::RecvError::Lagged(n)) => {
                        eprintln!("Client lagged, missed {} events", n);
                    }
                    Err(tokio::sync::broadcast::error::RecvError::Closed) => {
                        println!("Broadcast channel closed");
                        return;
                    }
                }
            }
        }
    }
}
