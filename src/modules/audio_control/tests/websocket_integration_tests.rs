use super::test_server::TestServer;
// use futures::{SinkExt, StreamExt};
use serde_json::{json, Value};

fn extract_device_id_by_name(response: &str, name: &str) -> Option<String> {
    let json: Value = serde_json::from_str(response).ok()?;
    json.get("data")?
        .as_array()?
        .iter()
        .find_map(|device| {
            let device_name = device.get("name")?.as_str()?;
            if device_name == name {
                device.get("id")?.as_str().map(str::to_string)
            } else {
                None
            }
        })
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
    let json: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_number());
    assert!(json.get("headers").is_some());
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

    let json: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_array());
    assert!(json.get("headers").is_some());
    assert!(json["headers"]["timestamp"].is_number());
    assert!(json["headers"]["count"].is_number());
}

#[tokio::test]
async fn test_websocket_session_list() {
    let mut server = TestServer::new().await;

    let request_devices = json!({
        "module": "audio",
        "payload": {
            "action": "devices_list"
        }
    });

    server.send_message(&request_devices.to_string()).await;

    let response = server.receive_message().await;

    let json: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(json["code"], 400);
    assert!(json["message"]
        .as_str()
        .unwrap()
        .contains("Failed to parse audio request"));
}

#[tokio::test]
async fn test_websocket_set_group_volume() {
    let mut server = TestServer::new().await;

    let request_devices = json!({
        "module": "audio",
        "payload": {
            "action": "devices_list"
        }
    });

    server.send_message(&request_devices.to_string()).await;

    let response_device = server.receive_message().await;
    let device_id = match extract_device_id_by_name(
        &response_device,
        "ZOWIE RL LCD (NVIDIA High Definition Audio)",
    ) {
        Some(id) => id,
        None => return,
    };

    let request_sessions = json!({
        "module": "audio",
        "payload": {
            "action": "session_list",
            "device_id": device_id
        }
    });

    server.send_message(&request_sessions.to_string()).await;
    let response_session = server.receive_message().await;

    let sessions: Value = serde_json::from_str(&response_session).unwrap();
    println!("{}", sessions.to_string());

    // let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();
    // let sessions = json
    //     .get("data")
    //     .and_then(|data| data.as_array())
    //     .cloned()
    //     .unwrap();

    // if sessions.is_empty() {
    //     return;
    // }

    // let session_id = sessions[0].get("id").and_then(|id| id.as_str()).unwrap();

    // let request = json!({
    //     "module": "audio",
    //     "payload": {
    //         "action": "set_group_volume",
    //         "device_id": device_id,
    //         "group_id": session_id,
    //         "volume": 0.5
    //     }
    // });

    // ws_stream
    //     .send(tokio_tungstenite::tungstenite::Message::Text(
    //         request.to_string().into(),
    //     ))
    //     .await
    //     .unwrap();

    // let response = ws_stream.next().await.unwrap().unwrap();
    // let response_text = match response {
    //     tokio_tungstenite::tungstenite::Message::Text(text) => text,
    //     _ => panic!("Expected text message"),
    // };

    // let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

    // if json.get("code").is_some() {
    //     assert_eq!(json["code"], 500);
    // } else {
    //     assert_eq!(json["data"], "Group volume set successfully");
    //     assert!(json.get("headers").is_some());
    //     assert!(json["headers"]["timestamp"].is_number());
    // }
}

// #[tokio::test]
// async fn test_websocket_invalid_json() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert_eq!(json["code"], 400);
//     assert!(json["message"]
//         .as_str()
//         .unwrap()
//         .contains("Invalid request format"));
// }

// #[tokio::test]
// async fn test_websocket_missing_payload() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request = json!({
//         "module": "audio"
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert_eq!(json["code"], 400);
//     assert!(json["message"]
//         .as_str()
//         .unwrap()
//         .contains("Payload is missing"));
// }

// #[tokio::test]
// async fn test_websocket_invalid_module() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request = json!({
//         "module": "display",
//         "payload": {
//             "action": "get_volume"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert_eq!(json["code"], 404);
// }

// #[tokio::test]
// async fn test_websocket_volume_validation_low() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request_devices = json!({
//         "module": "audio",
//         "payload": {
//             "action": "devices_list"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request_devices.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();
//     let devices = json
//         .get("data")
//         .and_then(|data| data.as_array())
//         .cloned()
//         .unwrap();

//     if devices.is_empty() {
//         return;
//     }

//     let device_id = devices[0].get("id").and_then(|id| id.as_str()).unwrap();

//     let request = json!({
//         "module": "audio",
//         "payload": {
//             "action": "set_group_volume",
//             "device_id": device_id,
//             "group_id": "{00000000-0000-0000-0000-000000000000}",
//             "volume": -0.1
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert_eq!(json["code"], 400);
//     assert!(json["message"]
//         .as_str()
//         .unwrap()
//         .contains("Failed to parse audio request"));
// }

// #[tokio::test]
// async fn test_websocket_volume_validation_high() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request_devices = json!({
//         "module": "audio",
//         "payload": {
//             "action": "devices_list"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request_devices.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();
//     let devices = json
//         .get("data")
//         .and_then(|data| data.as_array())
//         .cloned()
//         .unwrap();

//     if devices.is_empty() {
//         return;
//     }

//     let device_id = devices[0].get("id").and_then(|id| id.as_str()).unwrap();

//     let request = json!({
//         "module": "audio",
//         "payload": {
//             "action": "set_group_volume",
//             "device_id": device_id,
//             "group_id": "{00000000-0000-0000-0000-000000000000}",
//             "volume": 1.1
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert_eq!(json["code"], 400);
//     assert!(json["message"]
//         .as_str()
//         .unwrap()
//         .contains("Failed to parse audio request"));
// }

// #[tokio::test]
// async fn test_websocket_invalid_payload_action() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request = json!({
//         "module": "audio",
//         "payload": {
//             "action": "invalid_action"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert_eq!(json["code"], 400);
// }

// #[tokio::test]
// async fn test_response_format_valid() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request = json!({
//         "module": "audio",
//         "payload": {
//             "action": "get_volume"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert!(json.get("data").is_some());
//     assert!(json.get("headers").is_some());
//     assert!(json["headers"].get("timestamp").is_some());
// }

// #[tokio::test]
// async fn test_error_response_format() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request = json!({
//         "module": "display",
//         "payload": {
//             "action": "get_volume"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response = ws_stream.next().await.unwrap().unwrap();
//     let response_text = match response {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json: serde_json::Value = serde_json::from_str(&response_text).unwrap();

//     assert_eq!(json["code"], 404);
//     assert!(json.get("message").is_some());
//     assert!(json.get("details").is_none());
// }

// #[tokio::test]
// async fn test_multiple_requests() {
//     let server = TestServer::new().await;
//     let mut ws_stream = server.connect().await;

//     let request1 = json!({
//         "module": "audio",
//         "payload": {
//             "action": "get_volume"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request1.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let request2 = json!({
//         "module": "audio",
//         "payload": {
//             "action": "devices_list"
//         }
//     });

//     ws_stream
//         .send(tokio_tungstenite::tungstenite::Message::Text(
//             request2.to_string().into(),
//         ))
//         .await
//         .unwrap();

//     let response1 = ws_stream.next().await.unwrap().unwrap();
//     let response_text1 = match response1 {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json1: serde_json::Value = serde_json::from_str(&response_text1).unwrap();
//     assert!(json1["data"].is_number());

//     let response2 = ws_stream.next().await.unwrap().unwrap();
//     let response_text2 = match response2 {
//         tokio_tungstenite::tungstenite::Message::Text(text) => text,
//         _ => panic!("Expected text message"),
//     };

//     let json2: serde_json::Value = serde_json::from_str(&response_text2).unwrap();
//     assert!(json2["data"].is_array());
// }
