use serde::Serialize;
use std::fmt::Display;
use windows::Win32::Media::Audio::IMMDevice;

#[derive(Debug, Serialize)]
pub struct DeviceSound {
    pub id: String,
    pub name: String,
    #[serde(skip_serializing)]
    pub endpoint: IMMDevice,
}

impl Display for DeviceSound {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "ID: {} - Device Name: {}", self.id, self.name)
    }
}
