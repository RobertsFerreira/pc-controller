use crate::modules::audio_control::{
    models::{DeviceSound, SessionGroup},
    platform::audio_system_interface::{AudioOutPutDeviceControl, AudioSessionControl},
    services as windows_audio_service,
    types::{AudioResult, GroupId},
};

pub struct WindowsAudioAdapter {
    devices_control: WindowsAudioDeviceControl,
    audio_session: WindowsAudioSession,
}

impl WindowsAudioAdapter {
    pub fn new() -> Self {
        Self {
            devices_control: WindowsAudioDeviceControl::new(),
            audio_session: WindowsAudioSession::new(),
        }
    }
}

impl AudioOutPutDeviceControl for WindowsAudioAdapter {
    fn list_output_devices(&self) -> AudioResult<Vec<DeviceSound>> {
        self.devices_control.list_output_devices()
    }

    fn get_actual_volume(&self) -> AudioResult<f32> {
        self.devices_control.get_actual_volume()
    }
}

impl AudioSessionControl for WindowsAudioAdapter {
    fn get_sessions_for_device(&self, device_id: &str) -> AudioResult<Vec<SessionGroup>> {
        self.audio_session.get_sessions_for_device(device_id)
    }

    fn set_group_volume(
        &self,
        group_id: &GroupId,
        device_id: &str,
        volume: f32,
    ) -> AudioResult<()> {
        self.audio_session
            .set_group_volume(group_id, device_id, volume)
    }
}

struct WindowsAudioDeviceControl;

impl WindowsAudioDeviceControl {
    pub fn new() -> Self {
        Self
    }
}

impl AudioOutPutDeviceControl for WindowsAudioDeviceControl {
    fn list_output_devices(&self) -> AudioResult<Vec<DeviceSound>> {
        windows_audio_service::list_output_devices()
    }

    fn get_actual_volume(&self) -> AudioResult<f32> {
        windows_audio_service::get_actual_volume()
    }
}

struct WindowsAudioSession;

impl WindowsAudioSession {
    pub fn new() -> Self {
        Self
    }
}

impl AudioSessionControl for WindowsAudioSession {
    fn get_sessions_for_device(&self, device_id: &str) -> AudioResult<Vec<SessionGroup>> {
        windows_audio_service::get_session_for_device(device_id)
    }

    fn set_group_volume(
        &self,
        group_id: &GroupId,
        device_id: &str,
        volume: f32,
    ) -> AudioResult<()> {
        windows_audio_service::set_group_volume(group_id, device_id, volume)
    }
}
