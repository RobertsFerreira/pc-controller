use std::fmt::Display;
use windows::Win32::Media::Audio::IMMDevice;

//Device Model definition
#[derive(Debug)]
pub struct DeviceSound {
    pub id: String,
    pub name: String,
    pub endpoint: IMMDevice,
}

impl Display for DeviceSound {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Device Name: {}", self.name)
    }
}
