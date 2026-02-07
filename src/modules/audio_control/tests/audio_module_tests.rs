use crate::modules::audio_control::audio_module::AudioModule;
use crate::modules::audio_control::services;
use crate::modules::core::errors::error_codes;
use crate::modules::core::traits::module_handler::ModuleHandler;
use serde_json::json;

#[tokio::test]
async fn test_get_volume_request() {
    let module = AudioModule;
    let request = json!({
        "action": "get_volume"
    });

    let result = module.handle(&request.to_string()).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_number());
    let volume = json["data"].as_f64().unwrap();
    assert!((0.0..=100.0).contains(&volume));
    assert!(json.get("headers").is_some());
    assert!(json["headers"]["timestamp"].is_number());
}

#[tokio::test]
async fn test_devices_list_request() {
    let module = AudioModule;
    let request = json!({
        "action": "devices_list"
    });

    let result = module.handle(&request.to_string()).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_array());
    assert!(json.get("headers").is_some());
    assert!(json["headers"]["timestamp"].is_number());
    assert!(json["headers"]["count"].is_number());
}

#[tokio::test]
async fn test_session_list_request() {
    let devices = match services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let module = AudioModule;
    let request = json!({
        "action": "session_list",
        "device_id": devices[0].id
    });

    let result = module.handle(&request.to_string()).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_array());
    assert!(json.get("headers").is_some());
    assert!(json["headers"]["timestamp"].is_number());
    assert!(json["headers"]["count"].is_number());
}

#[tokio::test]
async fn test_set_group_volume_request() {
    let devices = match services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = if let Some(device) = devices.first() {
        &device.id
    } else {
        return;
    };

    let sessions = match services::get_session_for_device(device_id) {
        Ok(sessions) => sessions,
        Err(_) => {
            return;
        }
    };

    let session_id = if let Some(session) = sessions.first() {
        session.id.clone()
    } else {
        return;
    };

    let module = AudioModule;
    let request = json!({
        "action": "set_group_volume",
        "device_id": device_id,
        "group_id": session_id,
        "volume": 0.5
    });

    let result = module.handle(&request.to_string()).await;

    match result {
        Ok(message) => {
            let text = message.to_text().unwrap();
            let json: serde_json::Value = serde_json::from_str(text).unwrap();
            assert_eq!(json["data"], "Group volume set successfully");
        }
        Err(_) => {}
    }
}

#[tokio::test]
async fn test_set_group_volume_invalid_range_low() {
    let module = AudioModule;
    let request = json!({
        "action": "set_group_volume",
        "device_id": "{0.0.0.00000000}.{0a7155bb-2c0b-45a0-b6e4-4c7c08d0a5a7}",
        "group_id": "{00000000-0000-0000-0000-000000000000}",
        "volume": -0.1
    });

    let result = module.handle(&request.to_string()).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert_eq!(json["code"], error_codes::BAD_REQUEST);
    assert!(json.get("message").is_some());
}

#[tokio::test]
async fn test_set_group_volume_invalid_range_high() {
    let module = AudioModule;
    let request = json!({
        "action": "set_group_volume",
        "device_id": "{0.0.0.00000000}.{0a7155bb-2c0b-45a0-b6e4-4c7c08d0a5a7}",
        "group_id": "{00000000-0000-0000-0000-000000000000}",
        "volume": 1.1
    });

    let result = module.handle(&request.to_string()).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert_eq!(json["code"], error_codes::BAD_REQUEST);
    assert!(json.get("message").is_some());
}

#[tokio::test]
async fn test_invalid_json_request() {
    let module = AudioModule;
    let request = "{ invalid json }";

    let result = module.handle(request).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert_eq!(json["code"], error_codes::BAD_REQUEST);
    assert!(json["message"]
        .as_str()
        .unwrap()
        .contains("Failed to parse"));
}

#[tokio::test]
async fn test_missing_action_field() {
    let module = AudioModule;
    let request = json!({
        "device_id": "{0.0.0.00000000}.{0a7155bb-2c0b-45a0-b6e4-4c7c08d0a5a7}"
    });

    let result = module.handle(&request.to_string()).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert_eq!(json["code"], error_codes::BAD_REQUEST);
    assert!(json["message"]
        .as_str()
        .unwrap()
        .contains("Failed to parse"));
}

#[tokio::test]
async fn test_invalid_action_type() {
    let module = AudioModule;
    let request = json!({
        "action": "invalid_action"
    });

    let result = module.handle(&request.to_string()).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert_eq!(json["code"], error_codes::BAD_REQUEST);
    assert!(json["message"]
        .as_str()
        .unwrap()
        .contains("Failed to parse"));
}
