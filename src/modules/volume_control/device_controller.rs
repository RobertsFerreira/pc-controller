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

pub fn list_sessions_for_device(device_id: &str) -> SessionResult<Vec<SessionSound>> {
    if device_id.trim().is_empty() {
        return Err(SessionError::InvalidDeviceId);
    }

    initialize().map_err(SessionError::ComInitFailed)?;

    unsafe {
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;

        let device_collection: IMMDeviceCollection =
            device_enumerator.EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE)?;
        let device_count = device_collection.GetCount()?;

        if device_count == 0 {
            return Err(SessionError::NoSessionsFound);
        }

        let mut target_device: Option<IMMDevice> = None;
        for index in 0..device_count {
            let device: IMMDevice = device_collection.Item(index)?;
            let id = device.GetId()?;
            let id_str = id.to_string()?;

            if id_str == device_id {
                target_device = Some(device);
                break;
            }
        }

        let device = target_device.ok_or_else(|| SessionError::DeviceNotFound {
            device_id: device_id.to_string(),
        })?;

        let session_manager: IAudioSessionManager2 = device
            .Activate(CLSCTX_ALL, None)
            .map_err(SessionError::SessionManagerFailed)?;

        let session_enumerator: IAudioSessionEnumerator = session_manager
            .GetSessionEnumerator()
            .map_err(SessionError::SessionEnumFailed)?;

        let session_count = session_enumerator.GetCount()?;

        if session_count == 0 {
            return Err(SessionError::NoSessionsFound);
        }

        let mut sessions: Vec<SessionSound> = Vec::new();
        for index in 0..session_count {
            if let Ok(session) = session_enumerator.GetSession(index) {
                let session_control: IAudioSessionControl2 = session.cast()?;
                let session_info = get_session_info(session_control)?;
                sessions.push(session_info);
            }
        }

        if sessions.is_empty() {
            return Err(SessionError::NoSessionsFound);
        }

        uninitialize();
        Ok(sessions)
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
