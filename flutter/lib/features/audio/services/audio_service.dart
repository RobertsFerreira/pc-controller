import 'package:flutter/foundation.dart';
import 'package:pc_remote_control/core/clients/message.dart';
import 'package:pc_remote_control/core/clients/ws_client_interface.dart';
import 'package:pc_remote_control/features/audio/errors/audio_errors.dart';
import 'package:pc_remote_control/features/audio/models/audio_request.dart';

class AudioService {
  final WsClientInterface wsClient;

  AudioService({required this.wsClient});

  Future<void> _ensureConnected() async => await wsClient.connect();

  void _sendAction(Message message) => wsClient.send(message);

  Future<void> listDevices(AudioRequest audioRequest) async {
    final action = audioRequest.action.toString();
    if (audioRequest.action != ActionAudioRequest.listDevices) {
      throw InvalidActionAudio(
        invalidAction: action,
        message: 'Invalid action to list devices',
      );
    }

    try {
      await _ensureConnected();
      _sendAction(
        Message(
          module: audioRequest.module,
          action: action,
          params: audioRequest.params,
        ),
      );
    } catch (e, s) {
      debugPrint('Error: $e');
      debugPrint('Trace: $s');
      throw AudioErrorTransport(message: 'Failed to request device list');
    }
  }
}
