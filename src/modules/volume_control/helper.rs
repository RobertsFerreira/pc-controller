use std::path::Path;

use windows::{
    core::{Result, PWSTR},
    Win32::{
        Foundation::CloseHandle,
        System::{
            Com::{CoInitializeEx, CoUninitialize, COINIT_MULTITHREADED},
            Threading::{
                OpenProcess, QueryFullProcessImageNameW, PROCESS_NAME_WIN32,
                PROCESS_QUERY_LIMITED_INFORMATION,
            },
        },
    },
};

use crate::modules::volume_control::models::audio_responses::error_codes;
use crate::modules::volume_control::models::SessionError;

/// Manager COM library
pub fn initialize() -> Result<()> {
    unsafe {
        CoInitializeEx(None, COINIT_MULTITHREADED).ok()?;
    }
    Ok(())
}

pub fn uninitialize() {
    unsafe { CoUninitialize() };
}

// Map process ID to friendly name
pub fn get_friendly_process_name(pid: u32) -> Result<String> {
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

pub fn error_response_from_anyhow(error: &anyhow::Error) -> (u16, Option<String>) {
    if let Some(session_err) = error.downcast_ref::<SessionError>() {
        match session_err {
            SessionError::DeviceNotFound { .. } => (error_codes::NOT_FOUND, None),
            SessionError::InvalidDeviceId => (error_codes::BAD_REQUEST, None),
            SessionError::NoSessionsFound => (error_codes::NOT_FOUND, None),
            _ => (error_codes::INTERNAL_ERROR, Some(session_err.to_string())),
        }
    } else {
        (error_codes::INTERNAL_ERROR, Some(error.to_string()))
    }
}
