use axum::{
    extract::{
        ws::{Message as AxumMessage, WebSocket, WebSocketUpgrade},
        State,
    },
    response::IntoResponse,
    routing::get,
    Router,
};
use futures::{SinkExt, StreamExt};
use std::future::IntoFuture;
use std::sync::Arc;
use tokio::net::TcpStream;
use tokio_tungstenite::{tungstenite::Message, MaybeTlsStream, WebSocketStream};

use crate::modules::core::{handle_message, Broadcaster, ModuleRegistry};

pub struct BaseTestServer {
    socket: WebSocketStream<MaybeTlsStream<TcpStream>>,
}

#[derive(Clone)]
struct TestAppState {
    broadcaster: Arc<Broadcaster>,
    registry: Arc<ModuleRegistry>,
}

fn app(registry: ModuleRegistry) -> Router {
    let state = TestAppState {
        broadcaster: Arc::new(Broadcaster::new(100)),
        registry: Arc::new(registry),
    };

    Router::new()
        .route("/ws", get(ws_handler))
        .with_state(state)
}

async fn ws_handler(ws: WebSocketUpgrade, State(state): State<TestAppState>) -> impl IntoResponse {
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
                            return;
                        }
                    }
                    Some(Err(_)) | None => {
                        return;
                    }
                }
            }
            event_result = event_rx.recv() => {
                match event_result {
                    Ok(event) => {
                        if let Ok(event_json) = event.to_json() {
                            if socket.send(AxumMessage::text(event_json)).await.is_err() {
                                return;
                            }
                        }
                    }
                    Err(tokio::sync::broadcast::error::RecvError::Lagged(_)) => {}
                    Err(tokio::sync::broadcast::error::RecvError::Closed) => {
                        return;
                    }
                }
            }
        }
    }
}

impl BaseTestServer {
    pub async fn new_with_registry<F>(configure_registry: F) -> Self
    where
        F: FnOnce(&mut ModuleRegistry),
    {
        let mut registry = ModuleRegistry::new();
        configure_registry(&mut registry);

        let address = String::from("127.0.0.1:0");
        let listener = tokio::net::TcpListener::bind(address).await.unwrap();

        let addr = listener.local_addr().unwrap();
        tokio::spawn(axum::serve(listener, app(registry)).into_future());

        let (socket, _response) = tokio_tungstenite::connect_async(format!("ws://{addr}/ws"))
            .await
            .unwrap();

        Self { socket }
    }

    pub async fn send_message(&mut self, message: &str) {
        let message = Message::text(message);

        self.socket.send(message).await.unwrap();
    }

    pub async fn receive_message(&mut self) -> String {
        let message = self.socket.next().await.unwrap().unwrap();

        match message {
            Message::Text(text) => text.to_string(),
            _ => panic!("Expected a text message"),
        }
    }
}
