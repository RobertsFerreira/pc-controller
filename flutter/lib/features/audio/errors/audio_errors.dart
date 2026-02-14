base class AudioErrors implements Exception {
  final String message;

  AudioErrors({required this.message});
}

final class InvalidActionAudio extends AudioErrors {
  final String invalidAction;
  InvalidActionAudio({required this.invalidAction, required super.message});
}

final class AudioErrorTransport extends AudioErrors {
  AudioErrorTransport({required super.message});
}
