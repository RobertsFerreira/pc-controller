use std::fmt::{Debug, Display};
use windows::{
    core::*,
    Win32::{
        Devices::FunctionDiscovery::PKEY_Device_FriendlyName,
        // Foundation::*,
        Media::Audio::{Endpoints::IAudioEndpointVolume, *},
        System::Com::{
            CoCreateInstance, CoInitializeEx, CoUninitialize, StructuredStorage::PROPVARIANT,
            CLSCTX_ALL, COINIT_MULTITHREADED, STGM_READ,
        },
        // System::Variant::VT_LPWSTR,
    },
};

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

// This function initializes COM Interface.
fn initialize() -> Result<()> {
    unsafe {
        CoInitializeEx(None, COINIT_MULTITHREADED).ok()?;
    }
    Ok(())
}

// This function shutdown COM Interface.
fn uninitialize() {
    unsafe { CoUninitialize() };
}

pub fn list_output_devices() -> Result<Vec<DeviceSound>> {
    initialize()?;
    unsafe {
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;

        let device_collection: IMMDeviceCollection =
            device_enumerator.EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE)?;
        let device_count = device_collection.GetCount()?;

        if device_count == 0 {
            print!("no devices found");
            return Ok(Vec::new());
        }

        let mut devices: Vec<DeviceSound> = Vec::new();
        for index in 0..device_count {
            let device: IMMDevice = device_collection.Item(index)?;
            let id = device.GetId()?.to_string();
            let property_store = device.OpenPropertyStore(STGM_READ)?;
            let name_value: PROPVARIANT = property_store.GetValue(&PKEY_Device_FriendlyName)?;
            let device_name = name_value.to_string();

            let device_sound = DeviceSound {
                id: id.unwrap_or_default(),
                name: device_name.clone(),
                endpoint: device.clone(),
            };
            println!("{}", format!("Device {} pushed", device_sound.name));
            devices.push(device_sound);
        }
        uninitialize();
        Ok(devices)
    }
}

// Return the current volume level of the default audio device
pub fn get_actual_volume() -> Result<f32> {
    initialize()?;
    unsafe {
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;
        let device_default = device_enumerator.GetDefaultAudioEndpoint(eRender, eConsole)?;
        let volume_device_controller: IAudioEndpointVolume =
            device_default.Activate(CLSCTX_ALL, None)?;
        let current_volume = volume_device_controller.GetMasterVolumeLevelScalar()?;
        let volume = if current_volume.is_nan() {
            0.0
        } else {
            current_volume * 100.0
        };
        println!("Volume: {}", volume);
        uninitialize();
        Ok(volume)
    }
}
