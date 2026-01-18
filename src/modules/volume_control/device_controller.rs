use crate::modules::volume_control::models::{
    device_sound::DeviceSound,
    session_sound::{SessionSound, SessionState},
    SessionError, SessionResult,
};

use std::path::PathBuf;
use windows::{
    core::*,
    Win32::{
        Devices::FunctionDiscovery::PKEY_Device_FriendlyName,
        Media::Audio::{Endpoints::IAudioEndpointVolume, *},
        System::Com::{
            CoCreateInstance, CoInitializeEx, CoUninitialize, StructuredStorage::PROPVARIANT,
            CLSCTX_ALL, COINIT_MULTITHREADED, STGM_READ,
        },
    },
};

fn initialize() -> Result<()> {
    unsafe {
        CoInitializeEx(None, COINIT_MULTITHREADED).ok()?;
    }
    Ok(())
}

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
            println!("Device {} pushed", device_sound.name);
            devices.push(device_sound);
        }
        uninitialize();
        Ok(devices)
    }
}

pub fn get_actual_volume() -> Result<f32> {
    initialize()?;
    let result = unsafe {
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
        volume
    };
    uninitialize();
    Ok(result)
}

pub fn get_device_by_id(device_id: &str) -> SessionResult<DeviceSound> {
    unsafe {
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;

        let wide_id: Vec<u16> = device_id.encode_utf16().chain(std::iter::once(0)).collect();
        let device = device_enumerator.GetDevice(PCWSTR(wide_id.as_ptr()));
        match device {
            Ok(device) => {
                let id = device.GetId()?.to_string();
                let property_store = device.OpenPropertyStore(STGM_READ)?;
                let name_value: PROPVARIANT = property_store.GetValue(&PKEY_Device_FriendlyName)?;
                let device_name = name_value.to_string();
                uninitialize();
                Ok(DeviceSound {
                    id: id.unwrap_or_default(),
                    name: device_name.clone(),
                    endpoint: device.clone(),
                })
            }
            Err(_) => Err(SessionError::DeviceNotFound {
                device_id: device_id.to_string(),
            }),
        }
    }
}

pub fn get_session_for_device(device_id: &str) -> SessionResult<Vec<SessionSound>> {
    initialize()?;
    let device = get_device_by_id(device_id);
    match device {
        Ok(device) => unsafe {
            let sessions = device
                .endpoint
                .Activate::<IAudioSessionManager2>(CLSCTX_ALL, None);
            let session = match sessions {
                Ok(session) => session,
                Err(_) => return Ok(vec![]),
            };
            let session_enum = session.GetSessionEnumerator()?;
            let count = session_enum.GetCount()?;

            let mut sessions = Vec::new();
            for i in 0..count {
                let session = session_enum.GetSession(i)?;
                let session2: IAudioSessionControl2 = session.cast()?;

                let process_id = session2.GetProcessId()?;

                let simple_volume: ISimpleAudioVolume = session2.cast()?;
                let volume_level = simple_volume.GetMasterVolume()?;
                let display_name = match session2.GetDisplayName() {
                    Ok(name) => {
                        if name.is_empty() {
                            String::from("Unknown")
                        } else {
                            name.to_string()?
                        }
                    }
                    Err(_) => String::from("Unknown"),
                };

                sessions.push(SessionSound {
                    id: format!("session-{}", i),
                    process_id,
                    display_name: display_name,
                    volume_level,
                    icon_path: None,
                    state: SessionState::Active,
                });
            }

            Ok(sessions)
        },
        Err(e) => {
            uninitialize();
            Err(e)
        }
    }
}

fn get_session_info(session_control: IAudioSessionControl2) -> SessionResult<SessionSound> {
    unsafe {
        let display_name = session_control.GetDisplayName()?;
        let display_name_str = pwstr_to_string(&display_name);

        let process_id = session_control.GetProcessId().unwrap_or(0);

        let state = session_control.GetState().unwrap_or(AudioSessionState(2));
        let session_state: SessionState = state.into();

        let simple_volume: ISimpleAudioVolume = session_control.cast()?;
        let volume = simple_volume.GetMasterVolume().unwrap_or(0.0);
        let volume_level = if volume.is_nan() { 0.0 } else { volume * 100.0 };

        let icon_path = get_session_icon_path(&session_control);

        let session_id = format!("session-{}-{}", process_id, volume_level as u32);

        Ok(SessionSound {
            id: session_id,
            display_name: display_name_str,
            process_id,
            volume_level,
            state: session_state,
            icon_path,
        })
    }
}

fn get_session_icon_path(session_control: &IAudioSessionControl2) -> Option<PathBuf> {
    unsafe {
        let display_name = session_control.GetDisplayName().ok()?;
        let name_str = pwstr_to_string(&display_name);

        if !name_str.is_empty() {
            return Some(PathBuf::from(name_str));
        }
        None
    }
}

fn pwstr_to_string(pwstr: &PWSTR) -> String {
    unsafe {
        if pwstr.is_null() {
            return String::new();
        }
        let len = (0..).take_while(|&i| *pwstr.0.offset(i) != 0).count();
        let slice = std::slice::from_raw_parts(pwstr.0, len);
        String::from_utf16_lossy(slice)
    }
}
