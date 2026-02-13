use crate::modules::audio_control::types::GroupId;
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
        group_id: GroupId,
        /// Volume level, expected range: 0.0 to 100.0
        volume: Volume,
    },
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(try_from = "f32")]
pub struct Volume(f32);

impl TryFrom<f32> for Volume {
    type Error = &'static str;
    fn try_from(v: f32) -> Result<Self, Self::Error> {
        if (0.0..=100.0).contains(&v) {
            Ok(Volume(v))
        } else {
            Err("volume must be between 0.0 and 100.0")
        }
    }
}

impl From<Volume> for f32 {
    fn from(val: Volume) -> Self {
        val.0
    }
}
