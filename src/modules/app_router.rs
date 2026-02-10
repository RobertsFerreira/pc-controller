use std::sync::Arc;

use axum::{
    extract::{
        ws::{Message, WebSocket},
        State, WebSocketUpgrade,
    },
    response::IntoResponse,
    routing::get,
    Router,
};

use crate::modules::audio_control::AudioModule;
use crate::modules::core::Broadcaster;
use crate::modules::core::{handle_message, ModuleRegistry};

#[derive(Clone)]
struct AppState {
    broadcaster: Arc<Broadcaster>,
    registry: Arc<ModuleRegistry>,
}

fn app_state() -> AppState {
    let mut registry = ModuleRegistry::new();
    registry.register("audio", Arc::new(AudioModule));

    AppState {
        broadcaster: Arc::new(Broadcaster::new(100)),
        registry: Arc::new(registry),
    }
}

pub fn app() -> Router {
    Router::new()
        .route("/ws", get(ws_handler))
        .with_state(app_state())
}

async fn ws_handler(ws: WebSocketUpgrade, State(state): State<AppState>) -> impl IntoResponse {
    ws.on_upgrade(move |socket| handle_socket(socket, state.broadcaster, state.registry))
}

async fn handle_socket(
    mut socket: WebSocket,
    broadcaster: Arc<Broadcaster>,
    registry: Arc<ModuleRegistry>,
) {
    let mut event_rx = broadcaster.subscribe();

    loop {
        tokio::select! {
            msg_result = socket.recv() => {
                match msg_result {
                    Some(Ok(msg)) => {
                        let response = handle_message(msg, Arc::clone(&registry)).await;
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
                        match event.to_json() {
                            Ok(event_json) => {
                                if socket.send(Message::text(event_json)).await.is_err() {
                                    println!("Client disconnected");
                                    return;
                                }
                            }
                            Err(e) => {
                                eprintln!("Failed to serialize event: {}", e);
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
