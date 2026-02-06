use crate::modules::audio_control::types::GroupId;
use serde::Serialize;
use windows::Win32::Media::Audio::AudioSessionState;

#[derive(Debug, Serialize)]
pub struct SessionGroup {
    pub id: GroupId,
    pub display_name: String,
    pub volume_level: f32,
    pub state: SessionState,
    pub muted: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum SessionState {
    Active,
    Inactive,
    Expired,
}

impl From<AudioSessionState> for SessionState {
    fn from(state: AudioSessionState) -> Self {
        match state.0 {
            0 => SessionState::Active,
            1 => SessionState::Inactive,
            _ => SessionState::Expired,
        }
    }
}
