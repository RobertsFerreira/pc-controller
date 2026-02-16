use std::sync::Arc;

use crate::modules::audio_control::audio_handlers;
use crate::modules::audio_control::models::audio_requests::SetGroupVolumeRequest;
use crate::modules::audio_control::platform::{
    audio_system_interface::AudioSystemInterface, windows_audio_adapter::WindowsAudioAdapter,
};
use crate::modules::audio_control::types::GroupId;
use crate::modules::core::errors::error_codes;
use crate::modules::core::response::create_error_response;
use crate::modules::core::traits::module_handler::{ModuleHandler, ModuleResponse};
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
                        handle_audio_response(audio_handlers::handle_get_volume(
                            module.audio_system.as_ref(),
                        ))
                    }
                }),
            )
            .route(
                "/api/v1/list_devices",
                get(move || {
                    let module = Arc::clone(&for_list_device);
                    async move {
                        handle_audio_response(audio_handlers::handle_list_devices(
                            module.audio_system.as_ref(),
                        ))
                    }
                }),
            )
            .route(
                "/api/v1/list_session/{device_id}",
                get(move |Path(device_id): Path<String>| {
                    let module = Arc::clone(&for_list_session);
                    async move {
                        handle_audio_response(audio_handlers::handle_list_sessions(
                            module.audio_system.as_ref(),
                            device_id,
                        ))
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
                                Ok(Json(request)) => {
                                    handle_audio_response(audio_handlers::handle_set_group_volume(
                                        module.audio_system.as_ref(),
                                        request.device_id,
                                        GroupId::new(request.group_id),
                                        request.volume.into(),
                                    ))
                                }
                                Err(rejection) => create_error_response(
                                    error_codes::BAD_REQUEST,
                                    &format!("Invalid request body: {}", rejection.body_text()),
                                    None,
                                ),
                            }
                        }
                    },
                ),
            )
    }
}

fn handle_audio_response(result: ModuleResponse) -> Response {
    match result {
        Ok(response) => response,
        Err(error) => {
            tracing::error!("Failed to handle request for module 'audio': {:?}", error);
            create_error_response(
                error_codes::INTERNAL_ERROR,
                "Failed to handle request for module 'audio'",
                None,
            )
        }
    }
}
