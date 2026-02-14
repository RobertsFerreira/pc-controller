use crate::modules::audio_control::{
    models::{SessionGroup, SessionState},
    platform::audio_system_interface::{AudioOutputDeviceControl, AudioSessionControl},
    types::GroupId,
};

#[derive(Default)]
pub struct MockAudioSystem;

impl AudioOutputDeviceControl for MockAudioSystem {
    fn list_output_devices(
        &self,
    ) -> crate::modules::audio_control::types::AudioResult<
        Vec<crate::modules::audio_control::models::DeviceSound>,
    > {
        Ok(vec![])
    }

    fn get_actual_volume(&self) -> crate::modules::audio_control::types::AudioResult<f32> {
        Ok(55.0)
    }
}

impl AudioSessionControl for MockAudioSystem {
    fn get_sessions_for_device(
        &self,
        _device_id: &str,
    ) -> crate::modules::audio_control::types::AudioResult<Vec<SessionGroup>> {
        Ok(vec![SessionGroup {
            id: GroupId::new("11111111-1111-1111-1111-111111111111".to_string()),
            display_name: "mock-session".to_string(),
            volume_level: 55.0,
            state: SessionState::Active,
            muted: false,
        }])
    }

    fn set_group_volume(
        &self,
        _group_id: &GroupId,
        _device_id: &str,
        _volume: f32,
    ) -> crate::modules::audio_control::types::AudioResult<()> {
        Ok(())
    }
}
