use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "action", rename_all = "snake_case")]
pub enum ActionRequest {
    GetVolume,
    DevicesList,
    SessionList { device_id: String },
}
