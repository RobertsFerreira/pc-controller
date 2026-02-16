use axum::http::StatusCode;
use serde_json::{json, Value};

use super::test_server::TestServer;

async fn json_body(response: reqwest::Response) -> Value {
    response
        .json::<Value>()
        .await
        .expect("response should be valid JSON")
}

#[tokio::test]
async fn test_http_get_volume() {
    let server = TestServer::new().await;

    let response = server.get("/api/v1/get_volume").await;
    assert_eq!(response.status(), StatusCode::OK);

    let json = json_body(response).await;
    assert_eq!(json["data"], 55.0);
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_http_list_device() {
    let server = TestServer::new().await;

    let response = server.get("/api/v1/list_device").await;
    assert_eq!(response.status(), StatusCode::OK);

    let json = json_body(response).await;
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
async fn test_http_list_session_with_valid_device() {
    let server = TestServer::new().await;

    let response = server.get("/api/v1/list_session/mock-device-id").await;
    assert_eq!(response.status(), StatusCode::OK);

    let json = json_body(response).await;
    let sessions = json["data"].as_array().expect("data should be an array");

    assert_eq!(sessions.len(), 1);
    assert_eq!(sessions[0]["id"], "11111111-1111-1111-1111-111111111111");
    assert_eq!(json["headers"]["count"], 1);
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_http_set_group_volume_with_valid_request() {
    let server = TestServer::new().await;

    let response = server
        .post_json(
            "/api/v1/set_group_volume",
            json!({
                "device_id": "mock-device-id",
                "group_id": "11111111-1111-1111-1111-111111111111",
                "volume": 50.0
            }),
        )
        .await;
    assert_eq!(response.status(), StatusCode::OK);

    let json = json_body(response).await;
    assert_eq!(json["data"], "Group volume set successfully");
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_http_set_group_volume_invalid_json() {
    let server = TestServer::new().await;

    let response = server
        .post_raw("/api/v1/set_group_volume", "{invalid")
        .await;
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    let json = json_body(response).await;
    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .expect("error message should be string")
        .contains("Invalid request body"));
}

#[tokio::test]
async fn test_http_set_group_volume_missing_payload_field() {
    let server = TestServer::new().await;

    let response = server
        .post_json(
            "/api/v1/set_group_volume",
            json!({
                "device_id": "mock-device-id",
                "group_id": "11111111-1111-1111-1111-111111111111"
            }),
        )
        .await;
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    let json = json_body(response).await;
    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .expect("error message should be string")
        .contains("Invalid request body"));
}

#[tokio::test]
async fn test_http_set_group_volume_invalid_low() {
    let server = TestServer::new().await;

    let response = server
        .post_json(
            "/api/v1/set_group_volume",
            json!({
                "device_id": "mock-device-id",
                "group_id": "11111111-1111-1111-1111-111111111111",
                "volume": -0.1
            }),
        )
        .await;
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    let json = json_body(response).await;
    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .expect("error message should be string")
        .contains("Volume must be between 0.0 and 100.0"));
}

#[tokio::test]
async fn test_http_set_group_volume_invalid_high() {
    let server = TestServer::new().await;

    let response = server
        .post_json(
            "/api/v1/set_group_volume",
            json!({
                "device_id": "mock-device-id",
                "group_id": "11111111-1111-1111-1111-111111111111",
                "volume": 100.1
            }),
        )
        .await;
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    let json = json_body(response).await;
    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .expect("error message should be string")
        .contains("Volume must be between 0.0 and 100.0"));
}

#[tokio::test]
async fn test_http_not_found() {
    let server = TestServer::new().await;

    let response = server.get("/api/v1/unknown_route").await;
    assert_eq!(response.status(), StatusCode::NOT_FOUND);

    let json = json_body(response).await;
    assert_eq!(json["code"], 404);
    assert_eq!(json["message"], "Resource not found");
}
