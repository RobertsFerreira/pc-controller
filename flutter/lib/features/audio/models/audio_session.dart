import 'package:map_fields/map_fields.dart';

enum AudioSessionState {
  active,
  inactive,
  expired;

  factory AudioSessionState.fromValue(String value) {
    return switch (value) {
      'active' => AudioSessionState.active,
      'inactive' => AudioSessionState.inactive,
      _ => AudioSessionState.expired,
    };
  }
}

class AudioSession {
  final String id;
  final String displayName;
  final double volumeLevel;
  final AudioSessionState state;
  final bool muted;

  AudioSession({
    required this.id,
    required this.displayName,
    required this.volumeLevel,
    required this.state,
    required this.muted,
  });

  factory AudioSession.fromMap(Map<String, dynamic> map) {
    final mapFields = MapFields.load(map);

    return AudioSession(
      id: mapFields.getString('id'),
      displayName: mapFields.getString('display_name'),
      volumeLevel: mapFields.getDouble('volume_level'),
      state: AudioSessionState.fromValue(mapFields.getString('state')),
      muted: mapFields.getBool('muted', false),
    );
  }
}
