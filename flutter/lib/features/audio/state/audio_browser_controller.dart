import 'package:flutter/foundation.dart';
import 'package:pc_remote_control/core/errors/app_error.dart';
import 'package:pc_remote_control/features/audio/services/audio_service.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_state.dart';

class AudioBrowserController extends ValueNotifier<AudioBrowserState> {
  final AudioService service;

  AudioBrowserController({required this.service})
    : super(const AudioBrowserState());

  Future<void> loadDevices() async {
    value = value.copyWith(
      devicesStatus: AudioLoadStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final devices = await service.listDevices();
      value = value.copyWith(
        devices: devices,
        devicesStatus: AudioLoadStatus.success,
      );
    } catch (error) {
      value = value.copyWith(
        devicesStatus: AudioLoadStatus.error,
        errorMessage: _messageFromError(error),
      );
    }
  }

  Future<void> selectDevice(String deviceId) async {
    value = value.copyWith(
      selectedDeviceId: deviceId,
      sessions: const [],
      sessionsStatus: AudioLoadStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final sessions = await service.listSessions(deviceId);
      value = value.copyWith(
        sessions: sessions,
        sessionsStatus: AudioLoadStatus.success,
      );
    } catch (error) {
      value = value.copyWith(
        sessionsStatus: AudioLoadStatus.error,
        errorMessage: _messageFromError(error),
      );
    }
  }

  Future<void> bootstrapSessions() async {
    if (value.devicesStatus == AudioLoadStatus.idle) {
      await loadDevices();
    }

    final selectedDeviceId = value.selectedDeviceId;
    if (selectedDeviceId != null) {
      await selectDevice(selectedDeviceId);
    }
  }

  String _messageFromError(Object error) {
    if (error is AppError) return error.message;
    return error.toString();
  }
}
