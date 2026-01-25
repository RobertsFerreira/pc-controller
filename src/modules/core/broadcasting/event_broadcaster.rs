use crate::modules::core::models::ServerEvent;
use tokio::sync::broadcast;

/// Sistema de broadcast para enviar eventos para múltiplos clientes WebSocket
///
/// Usa o `tokio::sync::broadcast` para permitir que múltiplos clientes
/// se inscrevam e recebam eventos em tempo real.
#[derive(Clone)]
pub struct Broadcaster {
    tx: broadcast::Sender<ServerEvent>,
}

impl Broadcaster {
    /// Cria um novo Broadcaster com capacidade definida
    ///
    /// # Arguments
    /// * `capacity` - Número máximo de eventos em buffer antes de descartar
    pub fn new(capacity: usize) -> Self {
        debug_assert!(capacity > 0, "Broadcaster capacity must be greater than 0");
        let (tx, _) = broadcast::channel(capacity);
        Self { tx }
    }
    /// Inscreve um novo cliente para receber eventos
    ///
    /// Retorna um receiver que pode ser usado para receber eventos.
    pub fn subscribe(&self) -> broadcast::Receiver<ServerEvent> {
        self.tx.subscribe()
    }

    /// Envia um evento para todos os clientes inscritos
    ///
    /// # Arguments
    /// * `event` - Evento a ser broadcasted
    ///
    /// # Returns
    /// Número de receivers que receberam o evento
    pub fn broadcast(
        &self,
        event: ServerEvent,
    ) -> Result<usize, broadcast::error::SendError<ServerEvent>> {
        self.tx.send(event)
    }

    /// Retorna o número atual de receivers ativos
    pub fn receiver_count(&self) -> usize {
        self.tx.receiver_count()
    }
}

/// Implementação padrão com capacidade de 100 eventos
impl Default for Broadcaster {
    fn default() -> Self {
        Self::new(100)
    }
}
