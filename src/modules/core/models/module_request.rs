use std::fmt::Display;

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum ModuleType {
    Audio,
    Display,
    Network,
}

#[derive(Debug, Deserialize)]
#[serde(tag = "module", rename_all = "snake_case")]
pub struct ModuleRequest {
    pub module: ModuleType,
    pub payload: Option<serde_json::Value>,
}

impl Display for ModuleType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let module_str = match self {
            ModuleType::Audio => "audio",
            ModuleType::Display => "display",
            ModuleType::Network => "network",
        };
        write!(f, "{}", module_str)
    }
}
