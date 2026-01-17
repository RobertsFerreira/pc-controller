use serde::Serialize;
use std::path::PathBuf;
use windows::Win32::Media::Audio::AudioSessionState;

#[derive(Debug, Serialize)]
pub struct SessionSound {
    pub id: String,
    pub display_name: String,
    pub process_id: u32,
    pub volume_level: f32,
    pub state: SessionState,
    pub icon_path: Option<PathBuf>,
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
