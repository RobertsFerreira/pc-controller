enum WsStatus {
  disconnected,
  connected,
  connecting,
  reconnecting,
  closing,
  closed,
  error,
}

abstract class WsClientInterface {
  Future<void> connect();
  Future<void> disconnect();
  void send(String data);

  WsStatus get status;

  Stream<WsStatus> get statusStream;
  Stream<dynamic> get messages;

  void handleRetry();
}
