use crate::modules::volume_control::errors::AudioError;

pub type AudioResult<T> = Result<T, AudioError>;
