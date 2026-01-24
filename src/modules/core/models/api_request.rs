use crate::modules::volume_control::models::audio_requests::ActionSoundRequest;
use serde::{Deserialize, Serialize};

/// Tipos de módulos suportados
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum ModuleType {
    Audio,
    Display,
    Network,
}

/// Request global que roteia para o módulo apropriado
#[derive(Debug, Deserialize)]
#[serde(tag = "module", rename_all = "snake_case")]
pub enum ApiRequest {
    Audio { request: ActionSoundRequest },
    Display,
    Network,
}
