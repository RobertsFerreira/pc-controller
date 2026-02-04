use std::time::SystemTime;

/// Retorna o timestamp atual em segundos Unix
pub fn get_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .expect("System clock is set before UNIX_EPOCH")
        .as_secs()
}
