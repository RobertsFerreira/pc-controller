use crate::modules::core::traits::module_handler::ModuleHandler;
use axum::Router;
use std::collections::HashMap;
use std::sync::Arc;

pub struct ModuleRegistry {
    modules: HashMap<String, Arc<dyn ModuleHandler>>,
}

impl ModuleRegistry {
    pub fn new() -> Self {
        Self {
            modules: HashMap::new(),
        }
    }

    pub fn register(&mut self, module_name: &str, handler: Arc<dyn ModuleHandler>) {
        self.modules.insert(module_name.to_lowercase(), handler);
    }

    pub fn has_module(&self, module_name: &str) -> bool {
        self.modules.contains_key(&module_name.to_lowercase())
    }

    pub fn http_routes(&self) -> Router {
        let mut router = Router::new();

        for module in self.modules.values() {
            router = router.merge(Arc::clone(module).routes());
        }

        router
    }
}

impl Default for ModuleRegistry {
    fn default() -> Self {
        Self::new()
    }
}
