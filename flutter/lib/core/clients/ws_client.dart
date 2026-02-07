import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pc_remote_control/core/clients/ws_client_interface.dart';
import 'package:pc_remote_control/core/settings/app_settings.dart';
import 'package:web_socket/web_socket.dart';

class WsClient implements WsClientInterface {
  WsStatus _status = WsStatus.disconnected;
  WebSocket? _channel;
  StreamSubscription? _channelSubscription;

  late final StreamController<WsStatus> _statusController;
  late final StreamController _messages;

  final AppSettings _appSettings;
  int _attempt = 0;
  Timer? _retryTimer;

  bool _manuallyDisconnected = false;
  final Duration timeout;

  final String url;

  WsClient({required AppSettings appSettings})
    : _appSettings = appSettings,
      url = appSettings.wsUrl,
      timeout = appSettings.wsTimeout {
    _statusController = StreamController<WsStatus>.broadcast();
    _messages = StreamController.broadcast();
    _setStatus(WsStatus.disconnected);
  }

  @override
  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _setStatus(WsStatus.closing);

    _retryTimer?.cancel();
    _retryTimer = null;

    await _closeChannel();

    _setStatus(WsStatus.closed);
  }

  @override
  Future<void> connect() async {
    if (_status == WsStatus.connected ||
        _status == WsStatus.connecting ||
        _status == WsStatus.reconnecting) {
      return;
    }

    _manuallyDisconnected = false;

    try {
      final url = Uri.parse(this.url);
      _setStatus(WsStatus.connecting);

      await _closeChannel();

      _channel = await WebSocket.connect(url).timeout(timeout);
      _channelSubscription = _channel!.events.listen(
        (event) {
          switch (event) {
            case TextDataReceived(text: final data):
              _messages.add(data);
            default:
              debugPrint('Unhandled WebSocket event: $event');
          }
        },
        onDone: () {
          debugPrint('WebSocket disconnected');
          if (_manuallyDisconnected) return;
          _setStatus(WsStatus.disconnected);
          handleRetry();
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _setStatus(WsStatus.error);
          handleRetry();
        },
        cancelOnError: false,
      );
      _setStatus(WsStatus.connected);
      _attempt = 0;
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      _setStatus(WsStatus.error);
      handleRetry();
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      _setStatus(WsStatus.error);
      handleRetry();
    } catch (e, s) {
      debugPrint('Unexpected error: $e');
      debugPrint('trace: $s');
      _setStatus(WsStatus.error);
      handleRetry();
    }
  }

  @override
  Stream<dynamic> get messages => _messages.stream;

  @override
  void send(String data) {
    if (_channel == null || _status != WsStatus.connected) {
      throw StateError('WebSocket is not connected');
    }

    _channel!.sendText(data);
  }

  @override
  WsStatus get status => _status;

  void _setStatus(WsStatus newStatus) {
    if (_status == newStatus) return;

    _status = newStatus;
    if (_statusController.isClosed) return;
    _statusController.add(newStatus);
  }

  @override
  Stream<WsStatus> get statusStream => _statusController.stream;

  @override
  void handleRetry() {
    if (_manuallyDisconnected) return;
    if (_retryTimer != null && _retryTimer!.isActive) return;

    final nextDelay = _appSettings.retryConfig.nextDelay(_attempt);
    if (nextDelay == null) {
      debugPrint('Max retry attempts reached. Giving up.');
      _setStatus(WsStatus.error);
      return;
    }
    _attempt += 1;
    _setStatus(WsStatus.reconnecting);
    debugPrint('Retrying connection in ${nextDelay.inSeconds} seconds...');

    _retryTimer?.cancel();
    _retryTimer = Timer(nextDelay, () {
      debugPrint('Attempting to reconnect...');
      connect();
    });
  }

  Future<void> _closeChannel() async {
    await _channelSubscription?.cancel();
    await _channel?.close();

    _channelSubscription = null;
    _channel = null;
  }

  Future<void> dispose() async {
    await disconnect();
    if (!_statusController.isClosed) {
      await _statusController.close();
    }
    if (!_messages.isClosed) {
      await _messages.close();
    }
  }
}
