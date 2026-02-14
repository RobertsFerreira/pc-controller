class AudioRequest {
  final String module;
  final ActionAudioRequest action;
  final Map<String, dynamic> params;

  AudioRequest({
    this.module = 'audio',
    required this.action,
    this.params = const {},
  });

  factory AudioRequest.listDevices() {
    return AudioRequest(
      action: ActionAudioRequest.listDevices,
    );
  }

  factory AudioRequest.listSession(String deviceId) {
    return AudioRequest(
      action: ActionAudioRequest.listSession,
      params: AudioRequestParams.listSession(deviceId).params,
    );
  }

  factory AudioRequest.setVolume(
    String deviceId,
    String groupId,
    double volume,
  ) {
    return AudioRequest(
      action: ActionAudioRequest.setVolume,
      params: AudioRequestParams.setVolume(
        deviceId,
        groupId,
        volume,
      ).params,
    );
  }
}

enum ActionAudioRequest {
  listDevices(action: 'devices_list'),
  listSession(action: 'session_list'),
  setVolume(action: 'set_group_volume');

  final String action;

  const ActionAudioRequest({required this.action});

  @override
  String toString() => action;
}

class AudioRequestParams {
  final Map<String, dynamic> params;

  AudioRequestParams._(this.params);

  factory AudioRequestParams.listSession(String deviceId) {
    return AudioRequestParams._({'device_id': deviceId});
  }

  factory AudioRequestParams.setVolume(
    String deviceId,
    String groupId,
    double volume,
  ) {
    return AudioRequestParams._({
      "device_id": deviceId,
      "group_id": groupId,
      "volume": volume,
    });
  }
}
