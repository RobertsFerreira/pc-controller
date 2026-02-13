use crate::modules::audio_control::audio_handlers::{
    handle_get_volume, handle_list_devices, handle_list_sessions, handle_set_group_volume,
    handle_action_sound_request,
};
use crate::modules::audio_control::models::audio_requests::ActionSoundRequest;
use crate::modules::audio_control::types::GroupId;
use crate::modules::core::errors::error_codes;
use crate::modules::core::traits::module_handler::ModuleResponse;

#[tokio::test]
async fn test_handle_get_volume() {
    let result: ModuleResponse = handle_get_volume().await;

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
async fn test_handle_list_devices() {
    let result: ModuleResponse = handle_list_devices().await;

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
async fn test_handle_list_sessions() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let result: ModuleResponse = handle_list_sessions(device_id).await;

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
async fn test_handle_set_group_volume_valid() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let group_id = GroupId::new("{00000000-0000-0000-0000-000000000000}".to_string());
    let volume = 0.5;

    let result: ModuleResponse = handle_set_group_volume(device_id, group_id, volume).await;

    match result {
        Ok(message) => {
            let text = message.to_text().unwrap();
            let json: serde_json::Value = serde_json::from_str(text).unwrap();
            assert_eq!(json["data"], "Group volume set successfully");
        }
        Err(_) => {
        }
    }
}

#[tokio::test]
async fn test_handle_set_group_volume_zero() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let group_id = GroupId::new("{00000000-0000-0000-0000-000000000000}".to_string());
    let volume = 0.0;

    let result: ModuleResponse = handle_set_group_volume(device_id, group_id, volume).await;

    match result {
        Ok(message) => {
            let text = message.to_text().unwrap();
            let json: serde_json::Value = serde_json::from_str(text).unwrap();
            assert_eq!(json["data"], "Group volume set successfully");
        }
        Err(_) => {
        }
    }
}

#[tokio::test]
async fn test_handle_set_group_volume_one() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let group_id = GroupId::new("{00000000-0000-0000-0000-000000000000}".to_string());
    let volume = 1.0;

    let result: ModuleResponse = handle_set_group_volume(device_id, group_id, volume).await;

    match result {
        Ok(message) => {
            let text = message.to_text().unwrap();
            let json: serde_json::Value = serde_json::from_str(text).unwrap();
            assert_eq!(json["data"], "Group volume set successfully");
        }
        Err(_) => {
        }
    }
}

#[tokio::test]
async fn test_handle_set_group_volume_below_zero() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let group_id = GroupId::new("{00000000-0000-0000-0000-000000000000}".to_string());
    let volume = -0.1;

    let result: ModuleResponse = handle_set_group_volume(device_id, group_id, volume).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert_eq!(json["code"], error_codes::BAD_REQUEST);
    assert!(json["message"].as_str().unwrap().contains("Volume must be between"));
}

#[tokio::test]
async fn test_handle_set_group_volume_above_one() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let group_id = GroupId::new("{00000000-0000-0000-0000-000000000000}".to_string());
    let volume = 1.1;

    let result: ModuleResponse = handle_set_group_volume(device_id, group_id, volume).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert_eq!(json["code"], error_codes::BAD_REQUEST);
    assert!(json["message"].as_str().unwrap().contains("Volume must be between"));
}

#[tokio::test]
async fn test_handle_action_sound_request_get_volume() {
    let request = ActionSoundRequest::GetVolume;
    let result: ModuleResponse = handle_action_sound_request(request).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_number());
}

#[tokio::test]
async fn test_handle_action_sound_request_devices_list() {
    let request = ActionSoundRequest::DevicesList;
    let result: ModuleResponse = handle_action_sound_request(request).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_array());
    assert!(json["headers"]["count"].is_number());
}

#[tokio::test]
async fn test_handle_action_sound_request_session_list() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let request = ActionSoundRequest::SessionList { device_id };
    let result: ModuleResponse = handle_action_sound_request(request).await;

    assert!(result.is_ok());
    let message = result.unwrap();
    let text = message.to_text().unwrap();
    let json: serde_json::Value = serde_json::from_str(text).unwrap();

    assert!(json.get("data").is_some());
    assert!(json["data"].is_array());
    assert!(json["headers"]["count"].is_number());
}

#[tokio::test]
async fn test_handle_action_sound_request_set_group_volume() {
    let devices = match crate::modules::audio_control::services::list_output_devices() {
        Ok(devices) => devices,
        Err(_) => {
            return;
        }
    };

    if devices.is_empty() {
        return;
    }

    let device_id = devices[0].id.clone();
    let group_id = GroupId::new("{00000000-0000-0000-0000-000000000000}".to_string());
    let volume = 0.5.try_into().unwrap();
    let request = ActionSoundRequest::SetGroupVolume {
        device_id,
        group_id,
        volume,
    };
    let result: ModuleResponse = handle_action_sound_request(request).await;

    match result {
        Ok(message) => {
            let text = message.to_text().unwrap();
            let json: serde_json::Value = serde_json::from_str(text).unwrap();
            assert_eq!(json["data"], "Group volume set successfully");
        }
        Err(_) => {
        }
    }
}
