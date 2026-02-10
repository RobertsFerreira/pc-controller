use futures::{SinkExt, StreamExt};
use std::future::IntoFuture;
use tokio::net::TcpStream;
use tokio_tungstenite::{tungstenite::Message, MaybeTlsStream, WebSocketStream};

use crate::modules::app_router::app;

pub struct TestServer {
    socket: WebSocketStream<MaybeTlsStream<TcpStream>>,
}

impl TestServer {
    pub async fn new() -> Self {
        let address = String::from("127.0.0.1:0");
        let listener = tokio::net::TcpListener::bind(address).await.unwrap();

        let addr = listener.local_addr().unwrap();
        tokio::spawn(axum::serve(listener, app()).into_future());

        let (socket, _response) =
            tokio_tungstenite::connect_async(format!("ws://{addr}/ws"))
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
