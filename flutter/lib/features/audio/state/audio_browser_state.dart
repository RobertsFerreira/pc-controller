import 'package:pc_remote_control/features/audio/models/audio_request.dart';
import 'package:pc_remote_control/features/audio/models/audio_session.dart';

enum AudioLoadStatus {
  idle,
  loading,
  success,
  error,
}

class AudioBrowserState {
  final List<DeviceSound> devices;
  final List<AudioSession> sessions;
  final String? selectedDeviceId;
  final AudioLoadStatus devicesStatus;
  final AudioLoadStatus sessionsStatus;
  final String? errorMessage;

  const AudioBrowserState({
    this.devices = const [],
    this.sessions = const [],
    this.selectedDeviceId,
    this.devicesStatus = AudioLoadStatus.idle,
    this.sessionsStatus = AudioLoadStatus.idle,
    this.errorMessage,
  });

  AudioBrowserState copyWith({
    List<DeviceSound>? devices,
    List<AudioSession>? sessions,
    String? selectedDeviceId,
    bool clearSelectedDeviceId = false,
    AudioLoadStatus? devicesStatus,
    AudioLoadStatus? sessionsStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AudioBrowserState(
      devices: devices ?? this.devices,
      sessions: sessions ?? this.sessions,
      selectedDeviceId: clearSelectedDeviceId
          ? null
          : (selectedDeviceId ?? this.selectedDeviceId),
      devicesStatus: devicesStatus ?? this.devicesStatus,
      sessionsStatus: sessionsStatus ?? this.sessionsStatus,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
