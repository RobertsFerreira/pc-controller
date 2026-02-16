use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct SetGroupVolumeRequest {
    pub device_id: String,
    pub group_id: String,
    pub volume: Volume,
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
