use windows::{
    core::Result,
    Win32::System::Com::{CoInitializeEx, CoUninitialize, COINIT_MULTITHREADED},
};

pub struct ComContext;
impl ComContext {
    /// Inicializa a biblioteca COM do Windows
    ///
    /// COM é necessário para acessar APIs de áudio do Windows.
    /// Deve ser chamado antes de qualquer operação de áudio.
    pub fn new() -> Result<Self> {
        unsafe {
            // COINIT_MULTITHREADED permite uso multi-thread das APIs COM
            CoInitializeEx(None, COINIT_MULTITHREADED).ok()?;
        }
        Ok(ComContext)
    }
}

impl Drop for ComContext {
    /// Finaliza a biblioteca COM do Windows
    ///
    /// Deve ser chamado após completar todas as operações de áudio
    /// para limpar recursos alocados pelo COM.
    fn drop(&mut self) {
        unsafe { CoUninitialize() };
    }
}
