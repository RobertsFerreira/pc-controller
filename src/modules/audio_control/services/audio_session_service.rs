use std::collections::HashMap;

use windows::{
    core::{Interface, GUID, PCWSTR},
    Win32::{
        Devices::FunctionDiscovery::PKEY_Device_FriendlyName,
        Media::Audio::{
            IAudioSessionControl2, IAudioSessionManager2, IMMDeviceEnumerator, ISimpleAudioVolume,
            MMDeviceEnumerator,
        },
        System::Com::{CoCreateInstance, StructuredStorage::PROPVARIANT, CLSCTX_ALL, STGM_READ},
    },
};

use crate::modules::{
    audio_control::{
        errors::AudioError,
        models::{DeviceSound, SessionGroup, SessionState},
        types::{audio_result::AudioResult, GroupId},
        utils::audio_process_utils::get_friendly_process_name,
    },
    core::com::ComContext,
};

/// Obtém um dispositivo pelo ID
fn get_device_by_id(device_id: &str) -> AudioResult<DeviceSound> {
    unsafe {
        let device_enumerator: IMMDeviceEnumerator =
            CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;

        // Converte ID de string para WideString (UTF-16)
        let wide_id: Vec<u16> = device_id.encode_utf16().chain(std::iter::once(0)).collect();
        let device = device_enumerator.GetDevice(PCWSTR(wide_id.as_ptr()));
        match device {
            Ok(device) => {
                let id = device
                    .GetId()?
                    .to_string()
                    .map_err(AudioError::Utf16Error)?;
                let property_store = device.OpenPropertyStore(STGM_READ)?;
                let name_value: PROPVARIANT = property_store.GetValue(&PKEY_Device_FriendlyName)?;
                let device_name = name_value.to_string();
                Ok(DeviceSound {
                    id,
                    name: device_name.clone(),
                    endpoint: device.clone(),
                })
            }
            Err(_) => Err(AudioError::DeviceNotFound {
                device_id: device_id.to_string(),
            }),
        }
    }
}

/// Cria um SessionGroup a partir de múltiplas sessões com o mesmo GUID
///
/// Sessões de áudio podem ser agrupadas (ex: Edge com múltiplas abas).
/// Agrupa por GUID e calcula volume médio e estado agregado.
fn create_session_group_from_guid(
    guid: GUID,
    sessions: Vec<IAudioSessionControl2>,
) -> Option<SessionGroup> {
    unsafe {
        if sessions.is_empty() {
            return None;
        }

        let first = &sessions[0];

        // Obtém o PID e o nome amigável do processo
        let pid = first.GetProcessId().ok()?;
        let display_name = match get_friendly_process_name(pid) {
            Ok(name) => name,
            Err(_) => format!("PID {}", pid),
        };

        let mut total_volume = 0.0f32;
        let mut active_count = 0;
        let mut is_muted = false;
        let mut has_active = false;

        // Itera sobre todas as sessões do grupo
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

            // state.0 == 0 significa que a sessão está ativa
            if state.0 == 0 {
                has_active = true;
            }
        }

        // Calcula volume médio e converte para percentual
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

        let id = GroupId::from(&guid);

        Some(SessionGroup {
            id,
            display_name,
            volume_level: avg_volume,
            state: group_state,
            muted: is_muted,
        })
    }
}

pub fn get_session_for_device(device_id: &str) -> AudioResult<Vec<SessionGroup>> {
    let _com_ctx = ComContext::new()?;
    let device = get_device_by_id(device_id);
    match device {
        Ok(device) => unsafe {
            // Ativa o gerenciador de sessões para o dispositivo
            let session_manager: IAudioSessionManager2 =
                device.endpoint.Activate(CLSCTX_ALL, None)?;

            let session_enum = session_manager.GetSessionEnumerator()?;
            let count = session_enum.GetCount()?;

            // Agrupa sessões por GUID de agrupamento
            let mut groups: HashMap<GUID, Vec<IAudioSessionControl2>> = HashMap::new();

            for i in 0..count {
                let session = session_enum.GetSession(i)?;
                let session2: IAudioSessionControl2 = session.cast()?;

                let guid = session2.GetGroupingParam()?;

                groups.entry(guid).or_default().push(session2);
            }

            // Converte grupos de sessões em SessionGroups
            let mut session_groups = Vec::new();
            for (guid, sessions) in groups {
                if let Some(group) = create_session_group_from_guid(guid, sessions) {
                    session_groups.push(group);
                }
            }

            Ok(session_groups)
        },
        Err(e) => Err(e),
    }
}

pub fn set_group_volume(group_id: &GroupId, device_id: &str, volume: f32) -> AudioResult<()> {
    let _com_ctx = ComContext::new()?;
    let device = get_device_by_id(device_id);
    match device {
        Ok(device) => unsafe {
            let session_manager: IAudioSessionManager2 =
                device.endpoint.Activate(CLSCTX_ALL, None)?;

            let session_enum = session_manager.GetSessionEnumerator()?;
            let count = session_enum.GetCount()?;

            let mut found_sessions = 0;

            // Converte de percentual (0-100) para scalar (0.0-1.0)
            let volume_scalar = (volume / 100.0).clamp(0.0, 1.0);

            for i in 0..count {
                let session = session_enum.GetSession(i)?;
                let session2: IAudioSessionControl2 = session.cast()?;

                let guid = session2.GetGroupingParam()?;

                let current_group_id = GroupId::from(&guid);
                if current_group_id == *group_id {
                    let simple_volume: ISimpleAudioVolume = session2.cast()?;

                    // std::ptr::null() significa sem notificação de evento de mudança
                    simple_volume.SetMasterVolume(volume_scalar, std::ptr::null())?;
                    found_sessions += 1;
                }
            }

            if found_sessions == 0 {
                return Err(AudioError::NoSessionsFound);
            }

            Ok(())
        },
        Err(e) => Err(e),
    }
}
