use std::sync::Arc;

use crate::modules::audio_control::audio_handlers;
use crate::modules::audio_control::errors::AudioError;
use crate::modules::audio_control::models::audio_requests::SetGroupVolumeRequest;
use crate::modules::audio_control::platform::{
    audio_system_interface::AudioSystemInterface, windows_audio_adapter::WindowsAudioAdapter,
};
use crate::modules::audio_control::types::GroupId;
use crate::modules::core::response::create_error_response;
use crate::modules::core::traits::module_handler::{ModuleHandler, ModuleResponse};
use anyhow::Error as AnyhowError;
use async_trait::async_trait;
use axum::extract::Path;
use axum::{
    extract::rejection::JsonRejection,
    response::Response,
    routing::{get, post},
    Json, Router,
};

pub struct AudioModule {
    audio_system: Arc<dyn AudioSystemInterface>,
}

impl AudioModule {
    pub fn new(audio_system: Arc<dyn AudioSystemInterface>) -> Self {
        Self { audio_system }
    }
}

impl Default for AudioModule {
    fn default() -> Self {
        Self::new(Arc::new(WindowsAudioAdapter::new()))
    }
}

#[async_trait]
impl ModuleHandler for AudioModule {
    fn routes(self: Arc<Self>) -> Router {
        let for_get_volume = Arc::clone(&self);
        let for_list_device = Arc::clone(&self);
        let for_list_session = Arc::clone(&self);
        let for_set_group_volume = Arc::clone(&self);

        Router::new()
            .route(
                "/api/v1/get_volume",
                get(move || {
                    let module = Arc::clone(&for_get_volume);
                    async move {
                        handle_audio_response(
                            "get_volume",
                            audio_handlers::handle_get_volume(module.audio_system.as_ref()),
                        )
                    }
                }),
            )
            .route(
                "/api/v1/list_devices",
                get(move || {
                    let module = Arc::clone(&for_list_device);
                    async move {
                        handle_audio_response(
                            "list_devices",
                            audio_handlers::handle_list_devices(module.audio_system.as_ref()),
                        )
                    }
                }),
            )
            .route(
                "/api/v1/list_session/{device_id}",
                get(move |Path(device_id): Path<String>| {
                    let module = Arc::clone(&for_list_session);
                    async move {
                        handle_audio_response(
                            "list_session",
                            audio_handlers::handle_list_sessions(
                                module.audio_system.as_ref(),
                                device_id,
                            ),
                        )
                    }
                }),
            )
            .route(
                "/api/v1/set_group_volume",
                post(
                    move |request: Result<Json<SetGroupVolumeRequest>, JsonRejection>| {
                        let module = Arc::clone(&for_set_group_volume);
                        async move {
                            match request {
                                Ok(Json(request)) => handle_audio_response(
                                    "set_group_volume",
                                    audio_handlers::handle_set_group_volume(
                                        module.audio_system.as_ref(),
                                        request.device_id,
                                        GroupId::new(request.group_id),
                                        request.volume.into(),
                                    ),
                                ),
                                Err(rejection) => handle_audio_response(
                                    "set_group_volume",
                                    Err(rejection_to_anyhow(rejection)),
                                ),
                            }
                        }
                    },
                ),
            )
    }
}

fn handle_audio_response(operation: &str, result: ModuleResponse) -> Response {
    match result {
        Ok(response) => response,
        Err(error) => {
            let (status_code, details) = AudioError::error_response_from_anyhow(&error);
            let message = match error.downcast_ref::<AudioError>() {
                Some(AudioError::DeviceNotFound { .. }) => "Device not found".to_string(),
                Some(AudioError::InvalidRequestBody { message }) => message.clone(),
                Some(AudioError::InvalidDeviceId) => "Invalid device ID".to_string(),
                Some(AudioError::NoSessionsFound) => "No sessions found".to_string(),
                _ => format!("Failed to handle audio operation '{operation}'"),
            };

            tracing::error!("Audio operation '{}' failed: {}", operation, error);
            create_error_response(status_code, &message, details)
        }
    }
}

fn rejection_to_anyhow(rejection: JsonRejection) -> AnyhowError {
    let body_text = rejection.body_text();
    let message = if body_text.contains("Volume must be between 0.0 and 100.0") {
        "Volume must be between 0.0 and 100.0".to_string()
    } else {
        format!("Invalid request body: {}", body_text)
    };

    AnyhowError::new(AudioError::InvalidRequestBody { message })
}
