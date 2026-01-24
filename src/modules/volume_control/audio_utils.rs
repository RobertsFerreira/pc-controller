use std::path::Path;

use windows::{
    core::{Result, PWSTR},
    Win32::{
        Foundation::CloseHandle,
        System::Threading::{
            OpenProcess, QueryFullProcessImageNameW, PROCESS_NAME_WIN32,
            PROCESS_QUERY_LIMITED_INFORMATION,
        },
    },
};

/// Obtém o nome amigável de um processo a partir do PID
///
/// Abre o processo, obtém o caminho completo do executável,
/// e extrai apenas o nome do arquivo sem extensão.
pub fn get_friendly_process_name(pid: u32) -> Result<String> {
    unsafe {
        // Abre o processo com permissões para ler informações
        let process_handle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pid)?;

        let mut buffer = [0u16; 1024];
        let mut size = buffer.len() as u32;

        // Obtém o caminho completo do executável do processo
        QueryFullProcessImageNameW(
            process_handle,
            PROCESS_NAME_WIN32,
            PWSTR(buffer.as_mut_ptr()),
            &mut size,
        )?;

        // Converte de UTF-16 para String (perda segura de dados inválidos)
        let path = String::from_utf16_lossy(&buffer[..size as usize]);
        let _ = CloseHandle(process_handle);

        Ok(extract_simple_name(&path))
    }
}

/// Extrai apenas o nome do arquivo de um caminho completo
fn extract_simple_name(path: &str) -> String {
    let path_obj = Path::new(path);
    path_obj
        .file_name()
        .and_then(|f| f.to_str())
        .unwrap_or("Unknown")
        .trim_end_matches(".exe")
        .to_string()
}
