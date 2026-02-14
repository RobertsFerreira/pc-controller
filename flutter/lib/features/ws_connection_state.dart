import 'dart:async';

import 'package:pc_remote_control/core/clients/ws_client_interface.dart';

class WsConnectionState {
  final WsClientInterface _wsClient;
  final StreamController<WsStatus> _statusStream =
      StreamController<WsStatus>.broadcast();
  late final StreamSubscription<WsStatus>? _statusSubscription;
  late final WsStatus _currentStatus;

  WsConnectionState({required WsClientInterface client}) : _wsClient = client;

  WsStatus get currentStatus => _currentStatus;

  Stream<WsStatus> get statusStream => _statusStream.stream;

  void start() {
    _statusSubscription ??= _wsClient.statusStream.listen((status) {
      if (_currentStatus == status) return;

      _currentStatus = status;
      _statusStream.add(_currentStatus);
    });
  }

  Future<void> dispose() async {
    await _statusSubscription?.cancel();
    _statusSubscription = null;
    await _statusStream.close();
  }
}
