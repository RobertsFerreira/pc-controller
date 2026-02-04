use serde::{Deserialize, Serialize};

/// Tipos de ações para controle de áudio
#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "action", rename_all = "snake_case")]
pub enum ActionSoundRequest {
    GetVolume,
    DevicesList,
    SessionList {
        device_id: String,
    },
    SetGroupVolume {
        device_id: String,
        group_id: String,
        /// Volume level, expected range: 0.0 to 1.0
        volume: f32,
    },
}
