use serde::Serialize;

/// Evento do servidor para notificações proativas
#[derive(Debug, Clone, Serialize)]
#[serde(tag = "event_type", rename_all = "snake_case")]
pub enum ServerEvent {
    VolumeChanged {
        device_id: String,
        volume: f32,
    },
    DeviceConnected {
        device_id: String,
        device_name: String,
    },
    DeviceDisconnected {
        device_id: String,
    },
    SessionStarted {
        session_id: String,
        display_name: String,
    },
    SessionEnded {
        session_id: String,
    },
    Notification {
        title: String,
        message: String,
    },
}

impl ServerEvent {
    pub fn to_json(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string(self)
    }
}
