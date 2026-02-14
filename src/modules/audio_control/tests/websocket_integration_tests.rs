use super::test_server::TestServer;
use serde_json::{json, Value};

fn parse_json(response: &str) -> Value {
    serde_json::from_str(response).expect("response should be valid JSON")
}

#[tokio::test]
async fn test_websocket_get_volume() {
    let mut server = TestServer::new().await;

    let request = json!({
        "module": "audio",
        "payload": {
            "action": "get_volume"
        }
    });

    server.send_message(&request.to_string()).await;

    let response = server.receive_message().await;
    let json = parse_json(&response);

    assert_eq!(json["data"], 55.0);
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_websocket_devices_list() {
    let mut server = TestServer::new().await;

    let request = json!({
        "module": "audio",
        "payload": {
            "action": "devices_list"
        }
    });

    server.send_message(&request.to_string()).await;

    let response = server.receive_message().await;
    let json = parse_json(&response);

    assert_eq!(
        json["data"]
            .as_array()
            .expect("data should be an array")
            .len(),
        0
    );
    assert_eq!(json["headers"]["count"], 0);
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_websocket_session_list_with_valid_device() {
    let mut server = TestServer::new().await;

    let request_sessions = json!({
        "module": "audio",
        "payload": {
            "action": "session_list",
            "device_id": "mock-device-id"
        }
    });

    server.send_message(&request_sessions.to_string()).await;
    let sessions_response = server.receive_message().await;

    let json = parse_json(&sessions_response);
    let sessions = json["data"].as_array().expect("data should be an array");

    assert_eq!(sessions.len(), 1);
    assert_eq!(sessions[0]["id"], "11111111-1111-1111-1111-111111111111");
    assert_eq!(json["headers"]["count"], 1);
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_websocket_set_group_volume_with_valid_request() {
    let mut server = TestServer::new().await;

    let request_set_volume = json!({
        "module": "audio",
        "payload": {
            "action": "set_group_volume",
            "device_id": "mock-device-id",
            "group_id": "11111111-1111-1111-1111-111111111111",
            "volume": 50.0
        }
    });

    server.send_message(&request_set_volume.to_string()).await;
    let response = server.receive_message().await;

    let json = parse_json(&response);

    assert_eq!(json["data"], "Group volume set successfully");
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_websocket_invalid_json() {
    let mut server = TestServer::new().await;

    server.send_message("{invalid json}").await;

    let response = server.receive_message().await;
    let json = parse_json(&response);

    assert_eq!(json["code"], 400);
    assert_eq!(json["message"], "Invalid request format");
}

#[tokio::test]
async fn test_websocket_missing_payload() {
    let mut server = TestServer::new().await;

    let request = json!({
        "module": "audio"
    });

    server.send_message(&request.to_string()).await;

    let response = server.receive_message().await;
    let json = parse_json(&response);

    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .expect("error message should be string")
        .contains("Payload is missing"));
}

#[tokio::test]
async fn test_websocket_invalid_module() {
    let mut server = TestServer::new().await;

    let request = json!({
        "module": "display",
        "payload": {
            "action": "get_volume"
        }
    });

    server.send_message(&request.to_string()).await;

    let response = server.receive_message().await;
    let json = parse_json(&response);

    assert_eq!(json["code"], 404);
    assert_eq!(json["message"], "Resource not found");
}

#[tokio::test]
async fn test_websocket_set_group_volume_invalid_low() {
    let mut server = TestServer::new().await;

    let request = json!({
        "module": "audio",
        "payload": {
            "action": "set_group_volume",
            "device_id": "{0.0.0.00000000}.{0a7155bb-2c0b-45a0-b6e4-4c7c08d0a5a7}",
            "group_id": "{00000000-0000-0000-0000-000000000000}",
            "volume": -0.1
        }
    });

    server.send_message(&request.to_string()).await;

    let response = server.receive_message().await;
    let json = parse_json(&response);

    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .expect("error message should be string")
        .contains("Failed to parse audio request"));
}

#[tokio::test]
async fn test_websocket_set_group_volume_invalid_high() {
    let mut server = TestServer::new().await;

    let request = json!({
        "module": "audio",
        "payload": {
            "action": "set_group_volume",
            "device_id": "{0.0.0.00000000}.{0a7155bb-2c0b-45a0-b6e4-4c7c08d0a5a7}",
            "group_id": "{00000000-0000-0000-0000-000000000000}",
            "volume": 100.1
        }
    });

    server.send_message(&request.to_string()).await;

    let response = server.receive_message().await;
    let json = parse_json(&response);

    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .expect("error message should be string")
        .contains("Failed to parse audio request"));
}
