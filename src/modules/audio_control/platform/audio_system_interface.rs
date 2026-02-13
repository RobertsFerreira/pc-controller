use crate::modules::audio_control::{
    models::{DeviceSound, SessionGroup},
    types::{AudioResult, GroupId},
};

pub trait AudioSystemInterface:
    AudioOutPutDeviceControl + AudioSessionControl + Send + Sync
{
}
impl<T> AudioSystemInterface for T where T: AudioOutPutDeviceControl + AudioSessionControl {}

pub trait AudioOutPutDeviceControl: Send + Sync {
    /// Lists all active audio output devices available on the system.
    ///
    fn list_output_devices(&self) -> AudioResult<Vec<DeviceSound>>;

    /// Retrieves the master volume level from the system's current
    /// default audio output device.
    ///
    /// Returns the master volume as a percentage value
    /// between 0.0 and 100.0.
    fn get_actual_volume(&self) -> AudioResult<f32>;
}

pub trait AudioSessionControl: Send + Sync {
    /// Returns all audio sessions associated with the specified output device.
    fn get_sessions_for_device(&self, device_id: &str) -> AudioResult<Vec<SessionGroup>>;

    /// Sets the volume of a session associated with the specified output device.
    ///
    /// # Arguments
    /// * `group_id` - Unique identifier of the session.
    /// * `volume` - Volume level between 0.0 and 100.0.
    fn set_group_volume(&self, group_id: &GroupId, device_id: &str, volume: f32)
        -> AudioResult<()>;
}
