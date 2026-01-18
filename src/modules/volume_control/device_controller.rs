use crate::modules::volume_control::models::{
    device_sound::DeviceSound,
    session_sound::{SessionGroup, SessionState},
    SessionError, SessionResult,
};

use std::{collections::HashMap, path::Path};
use windows::{
    core::*,
    Win32::{
        Devices::FunctionDiscovery::PKEY_Device_FriendlyName,
        Foundation::CloseHandle,
        Media::Audio::{Endpoints::IAudioEndpointVolume, *},
        System::Com::{
            CoCreateInstance, CoInitializeEx, CoUninitialize, StructuredStorage::PROPVARIANT,
            CLSCTX_ALL, COINIT_MULTITHREADED, STGM_READ,
        },
        System::Threading::*,
    },
};

/// Manager COM library
fn initialize() -> Result<()> {
    unsafe {
        CoInitializeEx(None, COINIT_MULTITHREADED).ok()?;
    }
    Ok(())
}

fn uninitialize() {
    unsafe { CoUninitialize() };
}

// Map process ID to friendly name
fn get_friendly_process_name(pid: u32) -> Result<String> {
    unsafe {
        let process_handle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pid)?;

        let mut buffer = [0u16; 1024];
        let mut size = buffer.len() as u32;

        QueryFullProcessImageNameW(
            process_handle,
            PROCESS_NAME_WIN32,
            PWSTR(buffer.as_mut_ptr()),
            &mut size,
        )?;

        let path = String::from_utf16_lossy(&buffer[..size as usize]);
        let _ = CloseHandle(process_handle);

        Ok(extract_simple_name(&path))
    }
}

fn extract_simple_name(path: &str) -> String {
    let path_obj = Path::new(path);
    path_obj
        .file_name()
        .and_then(|f| f.to_str())
        .unwrap_or("Unknown")
        .trim_end_matches(".exe")
        .to_string()
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

// Get the actual system volume (master volume)
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

pub fn get_session_for_device(device_id: &str) -> SessionResult<Vec<SessionGroup>> {
    initialize()?;
    let device = get_device_by_id(device_id);
    match device {
        Ok(device) => unsafe {
            let session_manager: IAudioSessionManager2 =
                device.endpoint.Activate(CLSCTX_ALL, None)?;

            let session_enum = session_manager.GetSessionEnumerator()?;
            let count = session_enum.GetCount()?;

            let mut groups: HashMap<GUID, Vec<IAudioSessionControl2>> = HashMap::new();

            for i in 0..count {
                let session = session_enum.GetSession(i)?;
                let session2: IAudioSessionControl2 = session.cast()?;

                let guid = session2.GetGroupingParam()?;

                groups.entry(guid).or_default().push(session2);
            }

            let mut session_groups = Vec::new();
            for (guid, sessions) in groups {
                if let Some(group) = create_session_group_from_guid(guid, sessions) {
                    session_groups.push(group);
                }
            }

            uninitialize();
            Ok(session_groups)
        },
        Err(e) => {
            uninitialize();
            Err(e)
        }
    }
}

fn create_session_group_from_guid(
    guid: GUID,
    sessions: Vec<IAudioSessionControl2>,
) -> Option<SessionGroup> {
    unsafe {
        let first = &sessions[0];

        let pid = first.GetProcessId().ok()?;
        let display_name = match get_friendly_process_name(pid) {
            Ok(name) => name,
            Err(_) => format!("PID {}", pid),
        };

        let mut total_volume = 0.0f32;
        let mut active_count = 0;
        let mut is_muted = false;
        let mut has_active = false;

        for session in &sessions {
            let simple_volume: ISimpleAudioVolume = session.cast().ok()?;
            let volume = simple_volume.GetMasterVolume().ok()?;

            if !volume.is_nan() {
                total_volume += volume;
                active_count += 1;
            }

            let muted = simple_volume.GetMute().ok()?;
            is_muted = is_muted || muted.as_bool();

            let state = session.GetState().ok()?;
            if state.0 == 0 {
                has_active = true;
            }
        }

        let avg_volume = if active_count > 0 {
            (total_volume / active_count as f32) * 100.0
        } else {
            0.0
        };

        let group_state = if has_active {
            SessionState::Active
        } else {
            SessionState::Inactive
        };

        let id = format!("{:?}", guid);

        Some(SessionGroup {
            id,
            display_name,
            volume_level: avg_volume,
            state: group_state,
            muted: is_muted,
        })
    }
}

pub fn set_group_volume(group_id: &str, device_id: &str, volume: f32) -> SessionResult<()> {
    initialize()?;
    let device = get_device_by_id(device_id);
    match device {
        Ok(device) => unsafe {
            let session_manager: IAudioSessionManager2 =
                device.endpoint.Activate(CLSCTX_ALL, None)?;

            let session_enum = session_manager.GetSessionEnumerator()?;
            let count = session_enum.GetCount()?;

            let mut found_sessions = 0;
            let volume_scalar = (volume / 100.0).clamp(0.0, 1.0);

            for i in 0..count {
                let session = session_enum.GetSession(i)?;
                let session2: IAudioSessionControl2 = session.cast()?;

                let guid = session2.GetGroupingParam()?;

                let guid_str = format!("{:?}", guid);
                if guid_str == group_id {
                    let simple_volume: ISimpleAudioVolume = session2.cast()?;
                    simple_volume.SetMasterVolume(volume_scalar, std::ptr::null())?;
                    found_sessions += 1;
                }
            }

            if found_sessions == 0 {
                uninitialize();
                return Err(SessionError::NoSessionsFound);
            }

            uninitialize();
            Ok(())
        },
        Err(e) => {
            uninitialize();
            Err(e)
        }
    }
}
