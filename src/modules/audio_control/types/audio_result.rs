use crate::modules::audio_control::errors::AudioError;

pub type AudioResult<T> = Result<T, AudioError>;
