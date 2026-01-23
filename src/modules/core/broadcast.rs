use crate::modules::core::models::ServerEvent;
use tokio::sync::broadcast;

#[derive(Clone)]
pub struct Broadcaster {
    tx: broadcast::Sender<ServerEvent>,
}

impl Broadcaster {
    pub fn new(capacity: usize) -> Self {
        let (tx, _) = broadcast::channel(capacity);
        Self { tx }
    }

    pub fn subscribe(&self) -> broadcast::Receiver<ServerEvent> {
        self.tx.subscribe()
    }

    pub fn broadcast(
        &self,
        event: ServerEvent,
    ) -> Result<usize, broadcast::error::SendError<ServerEvent>> {
        self.tx.send(event)
    }

    pub fn receiver_count(&self) -> usize {
        self.tx.receiver_count()
    }
}

impl Default for Broadcaster {
    fn default() -> Self {
        Self::new(100)
    }
}
