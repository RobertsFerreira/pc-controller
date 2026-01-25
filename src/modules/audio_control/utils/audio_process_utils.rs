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
        let query_result = QueryFullProcessImageNameW(
            process_handle,
            PROCESS_NAME_WIN32,
            PWSTR(buffer.as_mut_ptr()),
            &mut size,
        );

        let _ = CloseHandle(process_handle);
        query_result?;

        // Converte de UTF-16 para String (perda segura de dados inválidos)
        let path = String::from_utf16_lossy(&buffer[..size as usize]);

        Ok(extract_simple_name(&path))
    }
}

/// Extrai apenas o nome do arquivo de um caminho completo
fn extract_simple_name(path: &str) -> String {
    let path_obj = Path::new(path);
    let name_process = path_obj
        .file_name()
        .and_then(|f| f.to_str())
        .unwrap_or("Unknown")
        .to_string();

    if name_process.to_lowercase().ends_with(".exe") {
        name_process[..name_process.len() - 4].to_string()
    } else {
        name_process.to_string()
    }
}
