use crate::modules::app_router::app;

pub mod modules;

#[tokio::main]
async fn main() {
    const PORT_SERVER: u16 = 3000;

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", PORT_SERVER))
        .await
        .expect("Failed to bind TCP listener");

    println!("Server running on http://0.0.0.0:{}", PORT_SERVER);

    axum::serve(listener, app())
        .await
        .expect("Failed to start server");
}
