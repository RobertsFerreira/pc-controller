use crate::modules::core::errors::error_codes;
use crate::modules::core::response::create_error_response;
use crate::modules::core::traits::module_handler::{ModuleHandler, ModuleResponse};
use std::collections::HashMap;
use std::sync::Arc;

pub struct ModuleRegistry {
    handlers: HashMap<String, Arc<dyn ModuleHandler>>,
}

impl ModuleRegistry {
    pub fn new() -> Self {
        Self {
            handlers: HashMap::new(),
        }
    }

    pub fn register(&mut self, module_name: &str, handler: Arc<dyn ModuleHandler>) {
        self.handlers.insert(module_name.to_lowercase(), handler);
    }

    pub async fn handle(&self, module_name: &str, request: &str) -> ModuleResponse {
        let handler = self.handlers.get(&module_name.to_lowercase());

        match handler {
            Some(handler) => handler.handle(request).await,
            None => Ok(create_error_response(
                error_codes::NOT_FOUND,
                "Resource not found",
                None,
            )),
        }
    }

    pub fn has_module(&self, module_name: &str) -> bool {
        self.handlers.contains_key(&module_name.to_lowercase())
    }
}

impl Default for ModuleRegistry {
    fn default() -> Self {
        Self::new()
    }
}
